Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 666F66B004A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 20:45:38 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EF12D3EE0C1
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:45:36 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B31CF45DEBA
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:45:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6836645DE9E
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:45:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A70E1DB803F
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:45:35 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 105B51DB8038
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:45:35 +0900 (JST)
Message-ID: <4F838245.4000108@jp.fujitsu.com>
Date: Tue, 10 Apr 2012 09:43:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] thp, memcg: split hugepage for memcg oom on cow
References: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com> <4F82A77D.4020800@jp.fujitsu.com> <alpine.DEB.2.00.1204091722110.21813@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1204091722110.21813@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

(2012/04/10 9:23), David Rientjes wrote:

> On Mon, 9 Apr 2012, KAMEZAWA Hiroyuki wrote:
> 
>> if (transparent_hugepage_enabled(vma) &&
>>             !transparent_hugepage_debug_cow())
>>                 new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
>>                                               vma, haddr, numa_node_id(), 0);
>>         else
>>                 new_page = NULL;
>> 	
>> if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
>>                 put_page(new_page);
>>                 new_page = NULL; /* never OOM, just cause fallback */
>> }
>>
>> if (unlikely(!new_page)) {
>>                 count_vm_event(THP_FAULT_FALLBACK);
>>                 ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
>>                                                    pmd, orig_pmd, page, haddr);
>>                 put_page(page);
>>                 goto out;
>> }
> 
> This would result in the same error since do_huge_pmd_wp_page_fallback() 
> would fail to charge the necessary memory to the memcg.
> 

Ah, I see. this will charge 1024 pages anyway. But ...hm, memcg easily returns
failure when many pages are requested. AND.... I misunderstood your patch.
You split hugepage and allocate 1 page at fault. Ok, seems reasonable, I'm sorry.

Thanks,
-Kame

> Are you still including my change to handle_mm_fault() to retry if this 
> returns VM_FAULT_OOM?
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
