Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 98C7C6B0038
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 06:28:09 -0400 (EDT)
Received: by wibg7 with SMTP id g7so97120418wib.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 03:28:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jx2si17285339wjc.7.2015.03.30.03.28.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 03:28:07 -0700 (PDT)
Date: Mon, 30 Mar 2015 11:28:02 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC][PATCH] mm: hugetlb: add stub-like do_hugetlb_numa()
Message-ID: <20150330102802.GQ4701@suse.de>
References: <1427708426-31610-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1427708426-31610-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Mar 30, 2015 at 09:40:54AM +0000, Naoya Horiguchi wrote:
> hugetlb doesn't support NUMA balancing now, but that doesn't mean that we
> don't have to make hugetlb code prepared for PROTNONE entry properly.
> In the current kernel, when a process accesses to hugetlb range protected
> with PROTNONE, it causes unexpected COWs, which finally put hugetlb subsystem
> into broken/uncontrollable state, where for example h->resv_huge_pages is
> subtracted too much and wrapped around to a very large number, and free
> hugepage pool is no longer maintainable.
> 

Ouch!

> This patch simply clears PROTNONE when it's caught out. Real NUMA balancing
> code for hugetlb is not implemented yet (not sure how much it's worth doing.)
> 

It's not worth doing at all. Furthermore, an application that took the
effort to allocate and use hugetlb pages is not going to appreciate the
minor faults incurred by automatic balancing for no gain. Why not something
like the following untested patch? It simply avoids doing protection updates
on hugetlb VMAs. If it works for you, feel free to take it and reuse most
of the same changelog for it. I'll only be intermittently online for the
next few days and would rather not unnecessarily delay a fix.

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7ce18f3c097a..74bfde50fd4e 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2161,8 +2161,10 @@ void task_numa_work(struct callback_head *work)
 		vma = mm->mmap;
 	}
 	for (; vma; vma = vma->vm_next) {
-		if (!vma_migratable(vma) || !vma_policy_mof(vma))
+		if (!vma_migratable(vma) || !vma_policy_mof(vma) ||
+						is_vm_hugetlb_page(vma)) {
 			continue;
+		}
 
 		/*
 		 * Shared library pages mapped by multiple processes are not

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
