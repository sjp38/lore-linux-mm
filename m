Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AB7896B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 19:18:19 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBF0IGkP032460
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 15 Dec 2010 09:18:17 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F37F45DE6B
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 09:18:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 52FC445DE73
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 09:18:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 43B371DB804E
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 09:18:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D40E1DB804A
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 09:18:16 +0900 (JST)
Date: Wed, 15 Dec 2010 09:12:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 36 of 66] memcg compound
Message-Id: <20101215091209.8c757ad1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101214173817.GH5638@random.random>
References: <patchbomb.1288798055@v2.random>
	<495ffee2d60adab4d18b.1288798091@v2.random>
	<20101118152628.GY8135@csn.ul.ie>
	<20101119101041.ffe00712.kamezawa.hiroyu@jp.fujitsu.com>
	<20101214173817.GH5638@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Tue, 14 Dec 2010 18:38:17 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:
 
> > > > @@ -2491,14 +2503,14 @@ __do_uncharge(struct mem_cgroup *mem, co
> > > >  	if (batch->memcg != mem)
> > > >  		goto direct_uncharge;
> > > >  	/* remember freed charge and uncharge it later */
> > > > -	batch->bytes += PAGE_SIZE;
> > > > +	batch->bytes += page_size;
> > 
> > Hmm, isn't it simpler to avoid batched-uncharge when page_size > PAGE_SIZE ?
> 
> As you wish, so I'm changing it like this.
> 
> archs where the pmd is implemented purely in software might actually
> be able to use page sizes smaller than 2M that may make sense to
> batch, but for now if you think this is simpler I'll go for it. We
> need simple.
> 

Thank you. Hmm,..seems not very simple :( I'm sorry.
Please do as you want.

-Kame

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2503,6 +2503,9 @@ __do_uncharge(struct mem_cgroup *mem, co
>  	if (!batch->do_batch || test_thread_flag(TIF_MEMDIE))
>  		goto direct_uncharge;
>  
> +	if (page_size != PAGE_SIZE)
> +		goto direct_uncharge;
> +
>  	/*
>  	 * In typical case, batch->memcg == mem. This means we can
>  	 * merge a series of uncharges to an uncharge of res_counter.
> @@ -2511,9 +2514,9 @@ __do_uncharge(struct mem_cgroup *mem, co
>  	if (batch->memcg != mem)
>  		goto direct_uncharge;
>  	/* remember freed charge and uncharge it later */
> -	batch->bytes += page_size;
> +	batch->bytes += PAGE_SIZE;
>  	if (uncharge_memsw)
> -		batch->memsw_bytes += page_size;
> +		batch->memsw_bytes += PAGE_SIZE;
>  	return;
>  direct_uncharge:
>  	res_counter_uncharge(&mem->res, page_size);
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
