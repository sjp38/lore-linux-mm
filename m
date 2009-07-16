Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5B05C6B004F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 19:43:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6GNhvZY011389
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Jul 2009 08:43:57 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F026D45DE58
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 08:43:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BB8AA45DE4E
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 08:43:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C843E38008
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 08:43:56 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 16060E38001
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 08:43:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] profile: Suppress warning about large allocations when profile=1 is specified
In-Reply-To: <20090716103719.GA22499@csn.ul.ie>
References: <20090716100305.9D16.A69D9226@jp.fujitsu.com> <20090716103719.GA22499@csn.ul.ie>
Message-Id: <20090717084206.A8FA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Jul 2009 08:43:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Heinz Diehl <htd@fancy-poultry.org>, David Miller <davem@davemloft.net>, Arnaldo Carvalho de Melo <acme@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Thu, Jul 16, 2009 at 10:12:20AM +0900, KOSAKI Motohiro wrote:
> > > When profile= is used, a large buffer is allocated early at boot. This
> > > can be larger than what the page allocator can provide so it prints a
> > > warning. However, the caller is able to handle the situation so this patch
> > > suppresses the warning.
> > 
> > I'm confused.
> > 
> > Currently caller doesn't handle error return.
> > 
> > ----------------------------------------------------------
> > asmlinkage void __init start_kernel(void)
> > {
> > (snip)
> >         init_timers();
> >         hrtimers_init();
> >         softirq_init();
> >         timekeeping_init();
> >         time_init();
> >         sched_clock_init();
> >         profile_init();           <-- ignore return value
> > ------------------------------------------------------------
> > 
> > and, if user want to use linus profiler, the user should choice select
> > proper bucket size by boot parameter.
> > Currently, allocation failure message tell user about specified bucket size
> > is wrong.
> > I think this patch hide it.
> > 
> 
> Look at what profile_init() itself is doing. You can't see it from the
> patch context but when alloc_pages_exact() fails, it calls vmalloc(). If
> that fails, profiling is just disabled. There isn't really anything the
> caller of profile_init() can do about it and the page allocator doesn't
> need to scream about it.

Indeed. Thanks correct me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> 
> > 
> > > 
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > ---
> > >  kernel/profile.c |    5 +++--
> > >  1 files changed, 3 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/kernel/profile.c b/kernel/profile.c
> > > index 69911b5..419250e 100644
> > > --- a/kernel/profile.c
> > > +++ b/kernel/profile.c
> > > @@ -117,11 +117,12 @@ int __ref profile_init(void)
> > >  
> > >  	cpumask_copy(prof_cpu_mask, cpu_possible_mask);
> > >  
> > > -	prof_buffer = kzalloc(buffer_bytes, GFP_KERNEL);
> > > +	prof_buffer = kzalloc(buffer_bytes, GFP_KERNEL|__GFP_NOWARN);
> > >  	if (prof_buffer)
> > >  		return 0;
> > >  
> > > -	prof_buffer = alloc_pages_exact(buffer_bytes, GFP_KERNEL|__GFP_ZERO);
> > > +	prof_buffer = alloc_pages_exact(buffer_bytes,
> > > +					GFP_KERNEL|__GFP_ZERO|__GFP_NOWARN);
> > >  	if (prof_buffer)
> > >  		return 0;
> > 
> > 
> > 
> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
