Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 8E4DA6B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 09:19:52 -0400 (EDT)
Received: by yhr47 with SMTP id 47so13496005yhr.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 06:19:51 -0700 (PDT)
Date: Mon, 9 Jul 2012 22:19:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Warn about costly page allocation
Message-ID: <20120709131942.GA3594@barrios>
References: <1341801500-5798-1-git-send-email-minchan@kernel.org>
 <20120709082200.GX14154@suse.de>
 <20120709084657.GA7915@bbox>
 <20120709091203.GY14154@suse.de>
 <20120709125048.GA2203@barrios>
 <20120709130551.GA14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120709130551.GA14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Jul 09, 2012 at 02:05:51PM +0100, Mel Gorman wrote:
> On Mon, Jul 09, 2012 at 09:50:48PM +0900, Minchan Kim wrote:
> > > <SNIP>
> > > 
> > > You're aiming this at embedded QA people according to your changelog so
> > > do whatever you think is going to be the most effective. It's already
> > > "known" that high-order kernel allocations are meant to be unreliable and
> > > apparently this is being ignored. The in-code warning could look
> > > something like
> > > 
> > > if (unlikely(order > PAGE_ALLOC_COSTLY_ORDER)) {
> > > 	printk_once("%s: page allocation high-order stupidity: order:%d, mode:0x%x\n",
> > >                    current->comm, order, gfp_mask);
> > > 	if (gfp_flags & __GFP_MOVABLE) {
> > > 		printk_once("Enable compaction or whatever\n");
> > > 		dump_stack();
> > > 	} else {
> > > 		printk_once("Regular high-order kernel allocations like this will eventually start failing.");
> > > 		dump_stack();
> > > 	}
> > > }
> > 
> > I'm not sure we have to check further for __GFP_MOVABLE because I have not seen driver
> > uses __GFP_MOVABLE for high order allocation. Although it uses the flag, it's never
> > compactable since it's out of LRU list. So I think it's rather overkill.
> > 
> 
> Then I would have considered it even more important to warn them that
> their specific usage is going to break eventually, with or without
> compaction. However, you know the target audience for this warning so it's
> your call.
> 
> > > 
> > > There should be a comment above it giving more information if you think
> > > the embedded people will actually read it. Of course, if this warning
> > > triggers during driver initialisation then it might be a completely useless.
> > > You could rate limit the warning (printk_ratelimit()) instead to be more
> > > effective. As I don't know what sort of device drivers you are seeing this
> > > problem with I can't judge what the best style of warning would be.
> > 
> > Okay.
> > I will send patch like below tomorrow if there isn't any objection.
> > 
> > if (unlikely(order > PAGE_ALLOC_COSTLY_ORDER)) {
> > 	if (printk_ratelimit()) {
> > 		printk("%s: page allocation high-order stupidity: order:%d, mode:0x%x\n",
> > 			current->comm, order, gfp_mask);
> > 		printk_once("Enable compaction or whatever\n");
> > 		printk_once("Regular high-order kernel allocations like this will eventually start failing.\n");

s/printk_once/printk/g
Copy&Paste should go away. :(

> > 		dump_stack();
> > 	}
> > }
> 
> The warning message could be improved. I did not expect you to use "Enable
> compaction or whatever" verbatim. I was just illustrating what type of
> warnings I thought might be useful. I expected you would change it to
> something that embedded driver authors would pay attention to :)

Okay.

> 
> As you are using printk_ratelimit(), you can also use pr_warning to
> annotate this as KERN_WARNING.

Will do.
Thanks, Mel.

> 
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
