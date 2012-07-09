Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 0D26B6B0072
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 08:50:58 -0400 (EDT)
Received: by ggm4 with SMTP id 4so12306551ggm.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 05:50:58 -0700 (PDT)
Date: Mon, 9 Jul 2012 21:50:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Warn about costly page allocation
Message-ID: <20120709125048.GA2203@barrios>
References: <1341801500-5798-1-git-send-email-minchan@kernel.org>
 <20120709082200.GX14154@suse.de>
 <20120709084657.GA7915@bbox>
 <20120709091203.GY14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120709091203.GY14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Jul 09, 2012 at 10:12:03AM +0100, Mel Gorman wrote:
> On Mon, Jul 09, 2012 at 05:46:57PM +0900, Minchan Kim wrote:
> > > > <SNIP>
> > > > +#if defined(CONFIG_DEBUG_VM) && !defined(CONFIG_COMPACTION)
> > > > +static inline void check_page_alloc_costly_order(unsigned int order)
> > > > +{
> > > > +	if (unlikely(order > PAGE_ALLOC_COSTLY_ORDER)) {
> > > > +		printk_once("WARNING: You are tring to allocate %d-order page."
> > > > +		" You might need to turn on CONFIG_COMPACTION\n", order);
> > > > +	}
> > > 
> > > WARN_ON_ONCE would tell you what is trying to satisfy the allocation.
> > 
> > Do you mean that it would be better to use WARN_ON_ONCE rather than raw printk?
> 
> Yes.
> 
> > If so, I would like to insist raw printk because WARN_ON_ONCE could be disabled
> > by !CONFIG_BUG.
> > If I miss something, could you elaborate it more?
> > 
> 
> Ok, but all this will tell you is that *something* tried a high-order
> allocation. It will not tell you who and because it's a printk_once, it
> will also not tell you how often it's happening. You could add a
> dump_stack to capture that information.

That's a good idea.

> 
> > > 
> > > It should further check if this is a GFP_MOVABLE allocation or not and if
> > > not, then it should either be documented that compaction may only delay
> > > allocation failures and that they may need to consider reserving the memory
> > > in advance or doing something like forcing MIGRATE_RESERVE to only be used
> > > for high-order allocations.
> > 
> > Okay. but I got confused you want to add above description in code directly
> > like below or write it down in comment of check_page_alloc_costly_order?
> > 
> 
> You're aiming this at embedded QA people according to your changelog so
> do whatever you think is going to be the most effective. It's already
> "known" that high-order kernel allocations are meant to be unreliable and
> apparently this is being ignored. The in-code warning could look
> something like
> 
> if (unlikely(order > PAGE_ALLOC_COSTLY_ORDER)) {
> 	printk_once("%s: page allocation high-order stupidity: order:%d, mode:0x%x\n",
>                    current->comm, order, gfp_mask);
> 	if (gfp_flags & __GFP_MOVABLE) {
> 		printk_once("Enable compaction or whatever\n");
> 		dump_stack();
> 	} else {
> 		printk_once("Regular high-order kernel allocations like this will eventually start failing.");
> 		dump_stack();
> 	}
> }

I'm not sure we have to check further for __GFP_MOVABLE because I have not seen driver
uses __GFP_MOVABLE for high order allocation. Although it uses the flag, it's never
compactable since it's out of LRU list. So I think it's rather overkill.

> 
> There should be a comment above it giving more information if you think
> the embedded people will actually read it. Of course, if this warning
> triggers during driver initialisation then it might be a completely useless.
> You could rate limit the warning (printk_ratelimit()) instead to be more
> effective. As I don't know what sort of device drivers you are seeing this
> problem with I can't judge what the best style of warning would be.

Okay.
I will send patch like below tomorrow if there isn't any objection.

if (unlikely(order > PAGE_ALLOC_COSTLY_ORDER)) {
	if (printk_ratelimit()) {
		printk("%s: page allocation high-order stupidity: order:%d, mode:0x%x\n",
			current->comm, order, gfp_mask);
		printk_once("Enable compaction or whatever\n");
		printk_once("Regular high-order kernel allocations like this will eventually start failing.\n");
		dump_stack();
	}
}

> 
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
