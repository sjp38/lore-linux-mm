Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 050FF6B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 18:03:43 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m83so20166312wmc.1
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 15:03:42 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id s7si12938916wms.59.2016.10.26.15.03.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Oct 2016 15:03:41 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 04A3598BA4
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 22:03:41 +0000 (UTC)
Date: Wed, 26 Oct 2016 23:03:39 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Message-ID: <20161026220339.GE2699@techsingularity.net>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
 <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
 <20161026203158.GD2699@techsingularity.net>
 <CA+55aFy21NqcYTeLVVz4x4kfQ7A+o4HEv7srone6ppKAjCwn7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFy21NqcYTeLVVz4x4kfQ7A+o4HEv7srone6ppKAjCwn7g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 26, 2016 at 02:26:57PM -0700, Linus Torvalds wrote:
> On Wed, Oct 26, 2016 at 1:31 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
> >
> > IO wait activity is not all that matters. We hit the lock/unlock paths
> > during a lot of operations like reclaim.
> 
> I doubt we do.
> 
> Yes, we hit the lock/unlock itself, but do we hit the *contention*?
> 
> The current code is nasty, and always ends up touching the wait-queue
> regardless of whether it needs to or not, but we have a fix for that.
> 

To be clear, are you referring to PeterZ's patch that avoids the lookup? If
so, I see your point.

> With that fixed, do we actually get contention on a per-page basis?

Reclaim would have to running parallel to migrations, faults, clearing
write-protect etc. I can't think of a situation where a normal workload
would hit it regularly and/or for long durations.

> Because without contention, we'd never actually look up the wait-queue
> at all.
> 
> I suspect that without IO, it's really really hard to actually get
> that contention, because things like reclaim end up looking at the LRU
> queue etc wioth their own locking, so it should look at various
> individual pages one at a time, not have multiple queues look at the
> same page.
> 

Except many direct reclaimers on small LRUs while a system is thrashing --
not a case that really matters, you've already lost.

> >> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> >> index 7f2ae99e5daf..0f088f3a2fed 100644
> >> --- a/include/linux/mmzone.h
> >> +++ b/include/linux/mmzone.h
> >> @@ -440,33 +440,7 @@ struct zone {
> >> +     int initialized;
> >>
> >>       /* Write-intensive fields used from the page allocator */
> >>       ZONE_PADDING(_pad1_)
> >
> > zone_is_initialized is mostly the domain of hotplug. A potential cleanup
> > is to use a page flag and shrink the size of zone slightly. Nothing to
> > panic over.
> 
> I really did that to make it very obvious that there was no semantic
> change. I just set the "initialized" flag in the same place where it
> used to initialize the wait_table, so that this:
> 
> >>  static inline bool zone_is_initialized(struct zone *zone)
> >>  {
> >> -     return !!zone->wait_table;
> >> +     return zone->initialized;
> >>  }
> 
> ends up being obviously equivalent.
> 

No problem with that.

> >> +#define WAIT_TABLE_BITS 8
> >> +#define WAIT_TABLE_SIZE (1 << WAIT_TABLE_BITS)
> >> +static wait_queue_head_t bit_wait_table[WAIT_TABLE_SIZE] __cacheline_aligned;
> >> +
> >> +wait_queue_head_t *bit_waitqueue(void *word, int bit)
> >> +{
> >> +     const int shift = BITS_PER_LONG == 32 ? 5 : 6;
> >> +     unsigned long val = (unsigned long)word << shift | bit;
> >> +
> >> +     return bit_wait_table + hash_long(val, WAIT_TABLE_BITS);
> >> +}
> >> +EXPORT_SYMBOL(bit_waitqueue);
> >> +
> >
> > Minor nit that it's unfortunate this moved to the scheduler core. It
> > wouldn't have been a complete disaster to add a page_waitqueue_init() or
> > something similar after sched_init.
> 
> I considered that, but decided that "minimal patch" was better. Plus,
> with that bit_waitqueue() actually also being used for the page
> locking queues (which act _kind of_ but not quite, like a bitlock),
> the bit_wait_table is actually more core than just the bit-wait code.
> 
> In fact, I considered just renaming it to "hashed_wait_queue", because
> that's effectively how we use it now, rather than being particularly
> specific to the bit-waiting. But again, that would have made the patch
> bigger, which I wanted to avoid since this is a post-rc2 thing due to
> the gfs2 breakage.
> 

No objection. Shuffling it around does not make it obviously better in
any way.

In the meantime, a machine freed up. FWIW, it survived booting on a 2-socket
and about 20 minutes of bashing on reclaim paths from multiple processes
to beat on lock/unlock. I didn't do a performance comparison or gather
profile data but I wouldn't expect anything interesting from profiles
other than some cycles saved.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
