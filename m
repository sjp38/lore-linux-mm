Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0636B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 18:00:28 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so107284020pad.3
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 15:00:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 5si4441223pds.163.2015.03.27.15.00.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 15:00:27 -0700 (PDT)
Date: Fri, 27 Mar 2015 15:00:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] thp: do not adjust zone water marks if khugepaged is
 not started
Message-Id: <20150327150026.7500f1081e8c30c2303afecd@linux-foundation.org>
In-Reply-To: <20150327144708.0223cc2e55862655259d2720@linux-foundation.org>
References: <1427456378-214780-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20150327144708.0223cc2e55862655259d2720@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Fri, 27 Mar 2015 14:47:08 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> Fair enough, but take a look at start_khugepaged():
> 
> : static int start_khugepaged(void)
> : {
> : 	int err = 0;
> : 	if (khugepaged_enabled()) {
> : 		if (!khugepaged_thread)
> : 			khugepaged_thread = kthread_run(khugepaged, NULL,
> : 							"khugepaged");
> : 		if (unlikely(IS_ERR(khugepaged_thread))) {
> : 			pr_err("khugepaged: kthread_run(khugepaged) failed\n");
> : 			err = PTR_ERR(khugepaged_thread);
> : 			khugepaged_thread = NULL;
> 
> -->> stop here 
> 
> : 		}
> : 
> : 		if (!list_empty(&khugepaged_scan.mm_head))
> : 			wake_up_interruptible(&khugepaged_wait);
> : 
> : 		set_recommended_min_free_kbytes();
> : 	} else if (khugepaged_thread) {
> : 		kthread_stop(khugepaged_thread);
> : 		khugepaged_thread = NULL;
> : 	}
> : 
> : 	return err;
> : }

Looking more closely...  This code seems a bit screwy.

- why is set_recommended_min_free_kbytes() a late_initcall?  We've
  already done that within
  subsys_initcall->hugepage_init->set_recommended_min_free_kbytes()

- there isn't much point in running start_khugepaged() if we've just
  set transparent_hugepage_flags to zero.

- start_khugepaged() is misnamed.

So something like this?

--- a/mm/huge_memory.c~a
+++ a/mm/huge_memory.c
@@ -110,10 +110,6 @@ static int set_recommended_min_free_kbyt
 	int nr_zones = 0;
 	unsigned long recommended_min;
 
-	/* khugepaged thread has stopped to failed to start */
-	if (!khugepaged_thread)
-		return 0;
-
 	for_each_populated_zone(zone)
 		nr_zones++;
 
@@ -145,9 +141,8 @@ static int set_recommended_min_free_kbyt
 	setup_per_zone_wmarks();
 	return 0;
 }
-late_initcall(set_recommended_min_free_kbytes);
 
-static int start_khugepaged(void)
+static int start_stop_khugepaged(void)
 {
 	int err = 0;
 	if (khugepaged_enabled()) {
@@ -158,6 +153,7 @@ static int start_khugepaged(void)
 			pr_err("khugepaged: kthread_run(khugepaged) failed\n");
 			err = PTR_ERR(khugepaged_thread);
 			khugepaged_thread = NULL;
+			goto fail;
 		}
 
 		if (!list_empty(&khugepaged_scan.mm_head))
@@ -168,7 +164,7 @@ static int start_khugepaged(void)
 		kthread_stop(khugepaged_thread);
 		khugepaged_thread = NULL;
 	}
-
+fail:
 	return err;
 }
 
@@ -302,7 +298,7 @@ static ssize_t enabled_store(struct kobj
 		int err;
 
 		mutex_lock(&khugepaged_mutex);
-		err = start_khugepaged();
+		err = start_stop_khugepaged();
 		mutex_unlock(&khugepaged_mutex);
 
 		if (err)
@@ -651,12 +647,13 @@ static int __init hugepage_init(void)
 	 * where the extra memory used could hurt more than TLB overhead
 	 * is likely to save.  The admin can still enable it through /sys.
 	 */
-	if (totalram_pages < (512 << (20 - PAGE_SHIFT)))
+	if (totalram_pages < (512 << (20 - PAGE_SHIFT))) {
 		transparent_hugepage_flags = 0;
-
-	err = start_khugepaged();
-	if (err)
-		goto err_khugepaged;
+	} else {
+		err = start_stop_khugepaged();
+		if (err)
+			goto err_khugepaged;
+	}
 
 	return 0;
 err_khugepaged:
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
