Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 6A3F96B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 05:12:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0D8A83EE0C1
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 18:12:04 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EA7BB45DE58
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 18:12:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D1B4E45DE59
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 18:12:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BCEF81DB8052
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 18:12:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 74F2E1DB8047
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 18:12:03 +0900 (JST)
Message-ID: <4F82A77D.4020800@jp.fujitsu.com>
Date: Mon, 09 Apr 2012 18:10:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] thp, memcg: split hugepage for memcg oom on cow
References: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

(2012/04/04 10:56), David Rientjes wrote:

> On COW, a new hugepage is allocated and charged to the memcg.  If the
> memcg is oom, however, this charge will fail and will return VM_FAULT_OOM
> to the page fault handler which results in an oom kill.
> 
> Instead, it's possible to fallback to splitting the hugepage so that the
> COW results only in an order-0 page being charged to the memcg which has
> a higher liklihood to succeed.  This is expensive because the hugepage
> must be split in the page fault handler, but it is much better than
> unnecessarily oom killing a process.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/huge_memory.c |    1 +
>  mm/memory.c      |   18 +++++++++++++++---
>  2 files changed, 16 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -959,6 +959,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
>  		put_page(new_page);
> +		split_huge_page(page);
>  		put_page(page);
>  		ret |= VM_FAULT_OOM;
>  		goto out;



?? how about
==
if (transparent_hugepage_enabled(vma) &&
            !transparent_hugepage_debug_cow())
                new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
                                              vma, haddr, numa_node_id(), 0);
        else
                new_page = NULL;
	
if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
                put_page(new_page);
                new_page = NULL; /* never OOM, just cause fallback */
}

if (unlikely(!new_page)) {
                count_vm_event(THP_FAULT_FALLBACK);
                ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
                                                   pmd, orig_pmd, page, haddr);
                put_page(page);
                goto out;
}
==
?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
