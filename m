Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 45B766B025E
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 09:16:51 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u84so74889543pfj.6
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 06:16:51 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id gh2si12042255pac.29.2016.10.13.06.16.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 06:16:00 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id os4so729991pac.3
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 06:16:00 -0700 (PDT)
Date: Thu, 13 Oct 2016 15:15:53 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: Re: [PATCH v2] z3fold: add shrinker
Message-Id: <20161013151553.6cb79106d0d347187d105467@gmail.com>
In-Reply-To: <20161013002006.GN23194@dastard>
References: <20161012001827.53ae55723e67d1dee2a2f839@gmail.com>
	<20161011225206.GJ23194@dastard>
	<20161012102634.f32cb17648eff6b2fd452aea@gmail.com>
	<20161013002006.GN23194@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 13 Oct 2016 11:20:06 +1100
Dave Chinner <david@fromorbit.com> wrote:

<snip>
> 
> That's an incorrect assumption. Long spinlock holds prevent
> scheduling on that CPU, and so we still get latency problems.

Fair enough. The problem is, some of the z3fold code that need mutual
exclusion runs with preemption disabled so spinlock is still the way
to go. I'll try to avoid taking it while actual shrinking is in progress
though.
 
> > Please also note that the time
> > spent in the loop is deterministic since we take not more than one entry
> > from every unbuddied list.
> 
> So the loop is:
> 
> 	for_each_unbuddied_list_down(i, NCHUNKS - 3) {
> 
> NCHUNKS = (PAGE_SIZE - (1 << (PAGE_SHIFT - 6)) >> (PAGE_SHIFT - 6)
> 
> So for 4k page, NCHUNKS = (4096 - (1<<6)) >> 6, which is 63. So,
> potentially 60 memmoves under a single spinlock on a 4k page
> machine. That's a lot of work, especially as some of those memmoves
> are going to move a large amount of data in the page.
> 
> And if we consider 64k pages, we've now got NCHUNKS = 1023, which
> means your shrinker is not, by default, going to scan all your
> unbuddied lists because it will expire nr_to_scan (usually
> SHRINK_BATCH = 128) before it's got through all of them. So not only
> will the shrinker do too much under a spinlock, it won't even do
> what you want it to do correctly on such setups.

Thanks for the pointer, I'll address that in the new patch.

> Further, the way nr_to_scan is decremented and the shrinker return
> value are incorrect. nr_to_scan is not the /number of objects to
> free/, but the number of objects to /check for reclaim/. The
> shrinker is then supposed to return the number it frees (or
> compacts) to give feedback to the shrinker infrastructure about how
> much reclaim work is being done (i.e. scanned vs freed ratio). This
> code always returns 0, which tells the shrinker infrastructure that
> it's not making progress...

Will fix.
> 
> > What I could do though is add the following piece of code at the end of
> > the loop, right after the /break/:
> > 		spin_unlock(&pool->lock);
> > 		cond_resched();
> > 		spin_lock(&pool->lock);
> > 
> > Would that make sense for you?
> 
> Not really, because it ignores the fact that shrinkers can (and
> often do) run concurrently on multiple CPUs, and so serialising them
> all on a spinlock just causes contention, even if you do this.
> 
> Memory reclaim is only as good as the worst shrinker it runs. I
> don't care what your subsystem does, but if you're implementing a
> shrinker then it needs to play by memory reclaim and shrinker
> context rules.....
> 

Ok, see above.

Best regards,
   Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
