Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0806B0296
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 06:33:21 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id yr2so7802954wjc.4
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:33:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z20si56223wmz.148.2017.01.19.03.33.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 03:33:20 -0800 (PST)
Date: Thu, 19 Jan 2017 12:33:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [ATTEND] many topics
Message-ID: <20170119113317.GO30786@dhcp22.suse.cz>
References: <20170118054945.GD18349@bombadil.infradead.org>
 <20170118133243.GB7021@dhcp22.suse.cz>
 <20170119110513.GA22816@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170119110513.GA22816@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu 19-01-17 03:05:13, willy@infradead.org wrote:
> On Wed, Jan 18, 2017 at 02:32:43PM +0100, Michal Hocko wrote:
> > On Tue 17-01-17 21:49:45, Matthew Wilcox wrote:
> > [...]
> > > 8. Nailing down exactly what GFP_TEMPORARY means
> > 
> > It's a hint that the page allocator should group those pages together
> > for better fragmentation avoidance. Have a look at e12ba74d8ff3 ("Group
> > short-lived and reclaimable kernel allocations"). Basically it is
> > something like __GFP_MOVABLE for kernel allocations which cannot go to
> > the movable zones.
> 
> Let me rephrase the topic ... Under what conditions should somebody use
> the GFP_TEMPORARY gfp_t?

Most users of slab (kmalloc) do not really have to care. Slab will add
__GFP_RECLAIMABLE to all reclaimable caches automagically AFAIR. The
remaining would have to implement some kind of shrinker to allow the
reclaim.

> Example usages that I have questions about:
> 
> 1. Is it permissible to call kmalloc(GFP_TEMPORARY), or is it only
> for alloc_pages?

kmalloc will use it internally as mentioned above.  I am not even sure
whether direct using of kmalloc(GFP_TEMPORARY) is ok.  I would have to
check the code but I guess it would be just wrong unless you know your
cache is reclaimable.

> I ask because if the slab allocator is unaware of
> GFP_TEMPORARY, then a non-GFP_TEMPORARY allocation may be placed in a
> page allocated with GFP_TEMPORARY and we've just made it meaningless.
> 
> 2. Is it permissible to sleep while holding a GFP_TEMPORARY allocation?
> eg, take a mutex, or wait_for_completion()?

Yes, GFP_TEMPORARY has ___GFP_DIRECT_RECLAIM set so this is by
definition sleepable allocation request.

> 3. Can I make one GFP_TEMPORARY allocation, and then another one?

Not sure I understand. WHy would be a problem?

> 4. Should I disable preemption while holding a GFP_TEMPORARY allocation,
> or are we OK with a task being preempted?

no, it can sleep.

> 5. What about something even longer duration like allocating a kiocb?
> That might take an arbitrary length of time to be freed, but eventually
> the command will be timed out (eg 30 seconds for something that ends up
> going through SCSI).

I do not understand. The reclaimability of the object is in hands of the
respective shrinker...
 
> 6. Or shorter duration like doing a GFP_TEMPORARY allocation, then taking
> a spinlock, which *probably* isn't contended, but you never know.
> 
> 7. I can see it includes __GFP_WAIT so it's not suitable for using from
> interrupt context, but interrupt context might be the place which can
> benefit from it the most.  Or does GFP_ATOMIC's __GFP_HIGH also allow for
> allocation from the movable zone?  Should we have a GFP_TEMPORARY_ATOMIC?

This is where __GFP_RECLAIMABLE should be used as this is the core of
the functionality.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
