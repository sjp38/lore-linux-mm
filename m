Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B16276B0141
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 05:38:31 -0400 (EDT)
Date: Thu, 13 Sep 2012 10:38:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/2 v2]compaction: abort compaction loop if lock is
 contended or run too long
Message-ID: <20120913093826.GT11266@suse.de>
References: <20120910011830.GC3715@kernel.org>
 <20120911163455.bb249a3c.akpm@linux-foundation.org>
 <20120912004840.GI27078@redhat.com>
 <20120912142019.0e06bf52.akpm@linux-foundation.org>
 <20120912234808.GC3404@redhat.com>
 <20120913004722.GA5085@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120913004722.GA5085@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@kernel.org>, linux-mm@kvack.org

On Thu, Sep 13, 2012 at 09:47:22AM +0900, Minchan Kim wrote:
> Hi Andrea,
> 
> On Thu, Sep 13, 2012 at 01:48:08AM +0200, Andrea Arcangeli wrote:
> > On Wed, Sep 12, 2012 at 02:20:19PM -0700, Andrew Morton wrote:
> > > OK, I'll slip this in there:
> > > 
> > > --- a/mm/compaction.c~mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long-fix
> > > +++ a/mm/compaction.c
> > > @@ -909,8 +909,7 @@ static unsigned long compact_zone_order(
> > >  	INIT_LIST_HEAD(&cc.migratepages);
> > >  
> > >  	ret = compact_zone(zone, &cc);
> > > -	if (contended)
> > > -		*contended = cc.contended;
> > > +	*contended = cc.contended;
> > >  	return ret;
> > >  }
> > 
> > Ack the above, thanks.
> > 
> > One more thing, today a bug tripped while building cyanogenmod10 (it
> > swaps despite so much ram) after I added the cc->contended loop break
> > patch. The original version of the fix from Shaohua didn't have this
> > problem because it would only abort compaction if the low_pfn didn't
> > advance and in turn the list would be guaranteed empty.
> 
> Nice catch!
> 
> > 
> > Verifying the list is empty before aborting compaction (which takes a
> > path that ignores the cc->migratelist) should be enough to fix it and
> > it makes it really equivalent to the previous fix. Both cachelines
> > should be cache hot so it should be practically zero cost to check it.
> > 
> > Only lightly tested so far.
> > 
> > ===
> > >From b2a50e49d65596d3920773316ad9b7dd54e4acaf Mon Sep 17 00:00:00 2001
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > Date: Thu, 13 Sep 2012 01:22:03 +0200
> > Subject: [PATCH] mm: compaction: fix leak in cc->contended loop breaking
> >  logic
> > 
> > We cannot return ISOLATE_ABORT when cc->contended is true, if we have
> > some pages already successfully isolated in the cc->migratepages
> > list, or they will be leaked.
> > 
> > The bug was highlighted by a nice VM_BUG_ON in the async compaction in
> > kswapd. So I also added the symmetric VM_BUG_ON to the other caller of
> > the function considering it looks a worthwhile VM_BUG_ON.
> 
> Fair enough.
> 
> > 
> > ------------[ cut here ]------------
> > kernel BUG at mm/compaction.c:934!
> > invalid opcode: 0000 [#1] SMP
> > Modules linked in: tun usbhid kvm_intel xhci_hcd kvm snd_hda_codec_realtek ehci_hcd usbcore snd_hda_intel sn
> > er crc32c_intel psmouse ghash_clmulni_intel sr_mod snd sg cdrom snd_page_alloc usb_common pcspkr [last unloa
> > 
> > CPU 0
> > Pid: 513, comm: kswapd0 Not tainted 3.6.0-rc4+ #17                  /DH61BE
> > RIP: 0010:[<ffffffff8111302c>]  [<ffffffff8111302c>] __compact_pgdat+0x1ac/0x1b0
> > RSP: 0018:ffff880216fa5cb0  EFLAGS: 00010283
> > RAX: 0000000000000003 RBX: ffff880216fa5d00 RCX: 0000000000000002
> > RDX: 00000000000008d7 RSI: 0000000000000002 RDI: ffffffff8195b058
> > RBP: ffffffff8195b000 R08: 0000000000000be4 R09: ffffffff8195a9c0
> > R10: ffffffff8195b400 R11: ffffffff8195b570 R12: 0000000000000001
> > R13: 0000000000000001 R14: ffff880216fa5d10 R15: 0000000000000003
> > FS:  0000000000000000(0000) GS:ffff88021fa00000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 00007f14d4167000 CR3: 00000000018f1000 CR4: 00000000000407f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Process kswapd0 (pid: 513, threadinfo ffff880216fa4000, task ffff880216cfef20)
> > Stack:
> > ffffffff8195a9c0 ffffffff8195b000 0000000000000320 0000000000000003
> > ffffffff8195a9c0 ffffffff8195b640 0000000000000002 0000000000000c80
> > 0000000000000001 ffffffff811132f3 ffff880216fa5d00 ffff880216fa5d00
> > Call Trace:
> > [<ffffffff811132f3>] ? compact_pgdat+0x23/0x30
> > [<ffffffff8110503f>] ? kswapd+0x89f/0xac0
> > [<ffffffff8106f450>] ? wake_up_bit+0x40/0x40
> > [<ffffffff811047a0>] ? shrink_lruvec+0x510/0x510
> > [<ffffffff811047a0>] ? shrink_lruvec+0x510/0x510
> > [<ffffffff8106ef1e>] ? kthread+0x9e/0xb0
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > ---
> >  mm/compaction.c |    6 +++++-
> >  1 files changed, 5 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 6066a35..0292984 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -633,7 +633,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
> >  
> >  	/* Perform the isolation */
> >  	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
> > -	if (!low_pfn || cc->contended)
> > +	if (!low_pfn || (cc->contended && !cc->nr_migratepages))
> >  		return ISOLATE_ABORT;
> 
> I'm not sure it's best.
> As you mentioned, it's same with first version of Shaohua.
> But it could mitigate the goal of the patch if lock contention or
> need_resched happens in the middle of loop once we isolate a
> migratable page.
> 
> What do you think about this?
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 0fbc6b7..7a009dd 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -848,6 +848,10 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>                 switch (isolate_migratepages(zone, cc)) {
>                 case ISOLATE_ABORT:
>                         ret = COMPACT_PARTIAL;
> +                       if (!list_empty(&cc->migratepages)) {
> +                               putback_lru_pages(&cc->migratepages);
> +                               cc->nr_migratepages = 0;
> +                       }
>                         goto out;
>                 case ISOLATE_NONE:
>                         continue;
> 

I agree with Minchan. Andrea's patch ignores the fact that free page
isolation might have aborted due to lock contention. It's not necessarily
going to be isolating the pages it needs for migration.

> 
> >  
> >  	cc->migrate_pfn = low_pfn;
> > @@ -843,6 +843,10 @@ static unsigned long compact_zone_order(struct zone *zone,
> >  	INIT_LIST_HEAD(&cc.migratepages);
> >  
> >  	ret = compact_zone(zone, &cc);
> > +
> > +	VM_BUG_ON(!list_empty(&cc.freepages));
> > +	VM_BUG_ON(!list_empty(&cc.migratepages));
> > +
> >  	*contended = cc.contended;
> >  	return ret;
> >  }
> > 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
