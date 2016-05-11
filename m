Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD5C6B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 11:32:14 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id sq19so16992868igc.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 08:32:14 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id it6si38586114igb.46.2016.05.11.08.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 08:32:13 -0700 (PDT)
Date: Wed, 11 May 2016 10:32:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: unhide vmstat_text definition for CONFIG_SMP
In-Reply-To: <1462978517-2972312-1-git-send-email-arnd@arndb.de>
Message-ID: <alpine.DEB.2.20.1605111011260.9351@east.gentwo.org>
References: <1462978517-2972312-1-git-send-email-arnd@arndb.de>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 11 May 2016, Arnd Bergmann wrote:

> In randconfig builds with sysfs, procfs and numa all disabled,
> but SMP enabled, we now get a link error in the newly introduced
> vmstat_refresh function:
>
> mm/built-in.o: In function `vmstat_refresh':

Hmmm... vmstat_refresh should not be build if CONFIG_PROC_FS is not set
since there will be no way to trigger it. Lets not complicate this
further.



Subject: Do not build vmstat_refresh if there is no procfs support

It makes no sense to build functionality into the kernel that
cannot be used and causes build issues.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -1358,7 +1358,6 @@ static const struct file_operations proc
 	.llseek		= seq_lseek,
 	.release	= seq_release,
 };
-#endif /* CONFIG_PROC_FS */

 #ifdef CONFIG_SMP
 static struct workqueue_struct *vmstat_wq;
@@ -1422,7 +1421,10 @@ int vmstat_refresh(struct ctl_table *tab
 		*lenp = 0;
 	return 0;
 }
+#endif /* CONFIG_SMP */
+#endif /* CONFIG_PROC_FS */

+#ifdef CONFIG_SMP
 static void vmstat_update(struct work_struct *w)
 {
 	if (refresh_cpu_vm_stats(true)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
