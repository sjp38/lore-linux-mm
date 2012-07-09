Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id F2CF86B0062
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 10:06:30 -0400 (EDT)
Date: Mon, 9 Jul 2012 22:06:22 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [patch] mm, slub: ensure irqs are enabled for kmemcheck
Message-ID: <20120709140622.GA26595@localhost>
References: <20120708040009.GA8363@localhost>
 <CAAmzW4OD2_ODyeY7c1VMPajwzovOms5M8Vnw=XP=uGUyPogiJQ@mail.gmail.com>
 <alpine.DEB.2.00.1207081558540.18461@chino.kir.corp.google.com>
 <alpine.LFD.2.02.1207091209220.3050@tux.localdomain>
 <alpine.DEB.2.00.1207090333560.8224@chino.kir.corp.google.com>
 <1341841593.14828.9.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341841593.14828.9.camel@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, JoonSoo Kim <js1304@gmail.com>, Vegard Nossum <vegard.nossum@gmail.com>, Christoph Lameter <cl@linux.com>, Rus <rus@sfinxsoft.com>, Ben Hutchings <ben@decadent.org.uk>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 09, 2012 at 09:46:33AM -0400, Steven Rostedt wrote:
> On Mon, 2012-07-09 at 03:36 -0700, David Rientjes wrote:
> > kmemcheck_alloc_shadow() requires irqs to be enabled, so wait to disable
> > them until after its called for __GFP_WAIT allocations.
> > 
> > This fixes a warning for such allocations:
> > 
> > 	WARNING: at kernel/lockdep.c:2739 lockdep_trace_alloc+0x14e/0x1c0()
> > 
> > Cc: stable@vger.kernel.org [3.1+]
> > Acked-by: Fengguang Wu <fengguang.wu@intel.com>
> > Tested-by: Fengguang Wu <fengguang.wu@intel.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  mm/slub.c |   13 ++++++-------
> >  1 file changed, 6 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/slub.c b/mm/slub.c
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1314,13 +1314,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
> >  			stat(s, ORDER_FALLBACK);
> >  	}
> >  
> > -	if (flags & __GFP_WAIT)
> > -		local_irq_disable();
> > -
> > -	if (!page)
> > -		return NULL;
> > -
> > -	if (kmemcheck_enabled
> > +	if (page && kmemcheck_enabled
> 
> One micro-optimization nit...
> 
> If kmemcheck_enabled is mostly false, and page is mostly true, wouldn't
> it be better to swap the two?
> 
> 	if (kmemcheck_enabled && page
> 
> Then the first check would just short-circuit out and we don't do the
> double check.

I had the same gut feeling but at the time was not as conscious as you ;)
Now I can dig out a similar optimization by Andrew Morton which also
saves memory bytes:

On Tue, Jun 19, 2012 at 03:00:14PM -0700, Andrew Morton wrote:

: With my gcc and CONFIG_CGROUP_MEM_RES_CTLR=n (for gawd's sake can we
: please rename this to CONFIG_MEMCG?), this:
: 
: --- a/mm/vmscan.c~memcg-prevent-from-oom-with-too-many-dirty-pages-fix
: +++ a/mm/vmscan.c
: @@ -726,8 +726,8 @@ static unsigned long shrink_page_list(st
:                          * writeback from reclaim and there is nothing else to
:                          * reclaim.
:                          */
: -                       if (PageReclaim(page)
: -                                       && may_enter_fs && !global_reclaim(sc))
: +                       if (!global_reclaim(sc) && PageReclaim(page) &&
: +                                       may_enter_fs)
:                                 wait_on_page_writeback(page);
:                         else {
:                                 nr_writeback++;
: 
: 
: reduces vmscan.o's .text by 48 bytes(!).  Because the compiler can
: avoid generating any code for PageReclaim() and perhaps the
: may_enter_fs test.  Because global_reclaim() evaluates to constant
: true.  Do you think that's an improvement?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
