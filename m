Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 221D06B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 05:00:37 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id wo20so908775obc.25
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 02:00:36 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id r7si2572469oem.136.2013.12.19.02.00.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 02:00:35 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 19 Dec 2013 15:30:06 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id A10A53940023
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 15:30:02 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBJ9xs0152363376
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 15:29:55 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBJA01NT020695
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 15:30:01 +0530
Date: Thu, 19 Dec 2013 17:59:59 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/memory-failure.c: transfer page count from head page
 to tail page after split thp
Message-ID: <52b2c3c3.072e3c0a.78ad.ffffc6feSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1387444174-16752-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1387444174-16752-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 19, 2013 at 04:09:34AM -0500, Naoya Horiguchi wrote:
>Memory failures on thp tail pages cause kernel panic like below:
>
>  [  317.361821] mce: [Hardware Error]: Machine check events logged
>  [  317.361831] MCE exception done on CPU 7
>  [  317.362007] BUG: unable to handle kernel NULL pointer dereference at 0000000000000058
>  [  317.362015] IP: [<ffffffff811b7cd1>] dequeue_hwpoisoned_huge_page+0x131/0x1e0
>  [  317.362017] PGD bae42067 PUD ba47d067 PMD 0
>  [  317.362019] Oops: 0000 [#1] SMP
>  ...
>  [  317.362052] CPU: 7 PID: 128 Comm: kworker/7:2 Tainted: G   M       O 3.13.0-rc4-131217-1558-00003-g83b7df08e462 #25
>  ...
>  [  317.362083] Call Trace:
>  [  317.362091]  [<ffffffff811d9bae>] me_huge_page+0x3e/0x50
>  [  317.362094]  [<ffffffff811dab9b>] memory_failure+0x4bb/0xc20
>  [  317.362096]  [<ffffffff8106661e>] mce_process_work+0x3e/0x70
>  [  317.362100]  [<ffffffff810b1e21>] process_one_work+0x171/0x420
>  [  317.362102]  [<ffffffff810b2c1b>] worker_thread+0x11b/0x3a0
>  [  317.362105]  [<ffffffff810b2b00>] ? manage_workers.isra.25+0x2b0/0x2b0
>  [  317.362109]  [<ffffffff810b93c4>] kthread+0xe4/0x100
>  [  317.362112]  [<ffffffff810b92e0>] ? kthread_create_on_node+0x190/0x190
>  [  317.362117]  [<ffffffff816e3c6c>] ret_from_fork+0x7c/0xb0
>  [  317.362119]  [<ffffffff810b92e0>] ? kthread_create_on_node+0x190/0x190
>  ...
>  [  317.362162] RIP  [<ffffffff811b7cd1>] dequeue_hwpoisoned_huge_page+0x131/0x1e0
>  [  317.362163]  RSP <ffff880426699cf0>
>  [  317.362164] CR2: 0000000000000058
>
>The reasoning of this problem is shown below:
> - when we have a memory error on a thp tail page, the memory error
>   handler grabs a refcount of the head page to keep the thp under us.
> - Before unmapping the error page from processes, we split the thp,
>   where page refcounts of both of head/tail pages don't change.
> - Then we call try_to_unmap() over the error page (which was a tail
>   page before). We didn't pin the error page to handle the memory error,
>   this error page is freed and removed from LRU list.
> - We never have the error page on LRU list, so the first page state
>   check returns "unknown page," then we move to the second check
>   with the saved page flag.
> - The saved page flag have PG_tail set, so the second page state check
>   returns "hugepage."
> - We call me_huge_page() for freed error page, then we hit the above panic.
>
>The root cause is that we didn't move refcount from the head page to
>the tail page after split thp. So this patch suggests to do this.
>
>This panic was introduced by commit 524fca1e73 "HWPOISON: fix misjudgement
>of page_action() for errors on mlocked pages."  Note that we did have
>the same refcount problem before this commit, but it was just ignored
>because we had only first page state check which returned "unknown page."
>The commit changed the refcount problem from "doesn't work" to "kernel panic."
>
>Cc: stable@vger.kernel.org # 3.9+
>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
> mm/memory-failure.c | 10 ++++++++++
> 1 file changed, 10 insertions(+)
>
>diff --git v3.13-rc4.orig/mm/memory-failure.c v3.13-rc4/mm/memory-failure.c
>index db08af92c6fc..fabe55046c1d 100644
>--- v3.13-rc4.orig/mm/memory-failure.c
>+++ v3.13-rc4/mm/memory-failure.c
>@@ -938,6 +938,16 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
> 				BUG_ON(!PageHWPoison(p));
> 				return SWAP_FAIL;
> 			}
>+			/*
>+			 * We pinned the head page for hwpoison handling,
>+			 * now we split the thp and we are interested in
>+			 * the hwpoisoned raw page, so move the refcount
>+			 * to it.
>+			 */
>+			if (hpage != p) {
>+				put_page(hpage);
>+				get_page(p);
>+			}
> 			/* THP is split, so ppage should be the real poisoned page. */
> 			ppage = p;
> 		}
>-- 
>1.8.3.1
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
