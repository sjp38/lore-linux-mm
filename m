Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B126F6B0078
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 19:16:50 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0M0GleS007002
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 Jan 2010 09:16:48 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FD5D45DE58
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 09:16:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 342FC45DE51
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 09:16:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 161BF1DB8046
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 09:16:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EF3E81DB803C
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 09:16:45 +0900 (JST)
Date: Fri, 22 Jan 2010 09:13:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 28 of 30] memcg huge memory
Message-Id: <20100122091317.39db5546.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100121160807.GB5598@random.random>
References: <patchbomb.1264054824@v2.random>
	<4c405faf58cfe5d1aa6e.1264054852@v2.random>
	<20100121161601.6612fd79.kamezawa.hiroyu@jp.fujitsu.com>
	<20100121160807.GB5598@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Jan 2010 17:08:07 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> > > @@ -228,6 +229,7 @@ static int __do_huge_pmd_anonymous_page(
> > >  
> > >  	spin_lock(&mm->page_table_lock);
> > >  	if (unlikely(!pmd_none(*pmd))) {
> > > +		mem_cgroup_uncharge_page(page);
> > >  		put_page(page);
> > >  		pte_free(mm, pgtable);
> > 
> On Thu, Jan 21, 2010 at 04:16:01PM +0900, KAMEZAWA Hiroyuki wrote:
> > Can't we do this put_page() and uncharge() outside of page table lock ?
> 
> Yes we can, but it's only a microoptimization because this only
> triggers during a controlled race condition across different
> threads. But no problem to optimize it...
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -228,6 +228,7 @@ static int __do_huge_pmd_anonymous_page(
>  
>  	spin_lock(&mm->page_table_lock);
>  	if (unlikely(!pmd_none(*pmd))) {
> +		spin_unlock(&mm->page_table_lock);
>  		put_page(page);
>  		pte_free(mm, pgtable);
>  	} else {
> @@ -238,8 +239,8 @@ static int __do_huge_pmd_anonymous_page(
>  		page_add_new_anon_rmap(page, vma, haddr);
>  		set_pmd_at(mm, haddr, pmd, entry);
>  		prepare_pmd_huge_pte(pgtable, mm);
> +		spin_unlock(&mm->page_table_lock);
>  	}
> -	spin_unlock(&mm->page_table_lock);
>  
>  	return ret;
>  }
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -230,6 +230,7 @@ static int __do_huge_pmd_anonymous_page(
>  	spin_lock(&mm->page_table_lock);
>  	if (unlikely(!pmd_none(*pmd))) {
>  		spin_unlock(&mm->page_table_lock);
> +		mem_cgroup_uncharge_page(page);
>  		put_page(page);
>  		pte_free(mm, pgtable);
>  	} else {
> 
> 
> Also below I appended the update memcg_compound to stop using the
> batch system. Also note your "likely" I removed it because for KVM
> most of the time it'll be TransHugePages to be charged. I prefer
> likely/unlikely when it's always a slow path no matter what workload
> (assuming useful/optimized workloads only ;). 
Hmm.. But I never believe KVM will be "likley" case in a few years.

> Like said in earlier
> email I guess the below may be wasted time because of the rework
> coming on the file. Also note the TransHugePage check here it's used
> instead of page_size == PAGE_SIZE to eliminate that additional branch
> at compile time if TRANSPARENT_HUGEPAGE=n.
> 
seems nice.

> Now the only real pain remains in the LRU list accounting, I tried to
> solve it but found no clean way that didn't require mess all over
> vmscan.c. So for now hugepages in lru are accounted as 4k pages
> ;). Nothing breaks just stats won't be as useful to the admin...
> 
Hmm, interesting/important problem...I keep it in my mind.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
