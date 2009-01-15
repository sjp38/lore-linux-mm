Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CE0F86B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 06:13:32 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0FBDU69019455
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 20:13:30 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3666545DE52
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 20:13:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1129545DE4F
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 20:13:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E6405E08002
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 20:13:29 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 938341DB8043
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 20:13:29 +0900 (JST)
Date: Thu, 15 Jan 2009 20:12:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mark_page_accessed() in do_swap_page() move latter than
 memcg charge
Message-Id: <20090115201224.676928d6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115200545.EBE6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090109043257.GB9737@balbir.in.ibm.com>
	<20090109134736.a995fc49.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115200545.EBE6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, menage@google.com, Hugh Dickins <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009 20:08:36 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 
> sorry for late responce.
> 
> > > In this case we've hit a case where the page is valid and the pc is
> > > not. This does fix the problem, but won't this impact us getting
> > > correct reclaim stats and thus indirectly impact the working of
> > > pressure?
> > > 
> >  - If retruns NULL, only global LRU's status is updated. 
> > 
> > Because this page is not belongs to any memcg, we cannot update
> > any counters. But yes, your point is a concern.
> > 
> > Maybe moving acitvate_page() to
> > ==
> > do_swap_page()
> > {
> >     
> > - activate_page()
> >    mem_cgroup_try_charge()..
> >    ....
> >    mem_cgroup_commit_charge()....
> >    ....
> > +  activate_page()   
> > }
> > ==
> > is necessary. How do you think, kosaki ?
> 
> 
> OK. it makes sense. and my test found no bug.
> 
Thank you very much! KOSAKI.

Reviewed-by; KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

-Kame

> ==
> 
> mark_page_accessed() update reclaim_stat statics.
> but currently, memcg charge is called after mark_page_accessed().
> 
> then, mark_page_accessed() don't update memcg statics correctly.
> 
> fixing here.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> ---
>  mm/memory.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: b/mm/memory.c
> ===================================================================
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2426,8 +2426,6 @@ static int do_swap_page(struct mm_struct
>  		count_vm_event(PGMAJFAULT);
>  	}
>  
> -	mark_page_accessed(page);
> -
>  	lock_page(page);
>  	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
>  
> @@ -2480,6 +2478,8 @@ static int do_swap_page(struct mm_struct
>  		try_to_free_swap(page);
>  	unlock_page(page);
>  
> +	mark_page_accessed(page);
> +
>  	if (write_access) {
>  		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
>  		if (ret & VM_FAULT_ERROR)
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
