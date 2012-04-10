Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id A42EB6B007E
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 20:23:51 -0400 (EDT)
Received: by iajr24 with SMTP id r24so8889679iaj.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 17:23:51 -0700 (PDT)
Date: Mon, 9 Apr 2012 17:23:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] thp, memcg: split hugepage for memcg oom on cow
In-Reply-To: <4F82A77D.4020800@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1204091722110.21813@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com> <4F82A77D.4020800@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

On Mon, 9 Apr 2012, KAMEZAWA Hiroyuki wrote:

> if (transparent_hugepage_enabled(vma) &&
>             !transparent_hugepage_debug_cow())
>                 new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
>                                               vma, haddr, numa_node_id(), 0);
>         else
>                 new_page = NULL;
> 	
> if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
>                 put_page(new_page);
>                 new_page = NULL; /* never OOM, just cause fallback */
> }
> 
> if (unlikely(!new_page)) {
>                 count_vm_event(THP_FAULT_FALLBACK);
>                 ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
>                                                    pmd, orig_pmd, page, haddr);
>                 put_page(page);
>                 goto out;
> }

This would result in the same error since do_huge_pmd_wp_page_fallback() 
would fail to charge the necessary memory to the memcg.

Are you still including my change to handle_mm_fault() to retry if this 
returns VM_FAULT_OOM?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
