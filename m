Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 485D66B029D
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 07:11:41 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id h7so8022879wjy.6
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 04:11:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q192si6296500wme.11.2017.01.19.04.11.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 04:11:39 -0800 (PST)
Date: Thu, 19 Jan 2017 13:11:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [ATTEND] many topics
Message-ID: <20170119121135.GR30786@dhcp22.suse.cz>
References: <20170118054945.GD18349@bombadil.infradead.org>
 <20170118133243.GB7021@dhcp22.suse.cz>
 <20170119110513.GA22816@bombadil.infradead.org>
 <20170119113317.GO30786@dhcp22.suse.cz>
 <20170119115243.GB22816@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170119115243.GB22816@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@bombadil.infradead.org
Cc: willy@infradead.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu 19-01-17 03:52:43, willy@bombadil.infradead.org wrote:
> On Thu, Jan 19, 2017 at 12:33:17PM +0100, Michal Hocko wrote:
> > On Thu 19-01-17 03:05:13, willy@infradead.org wrote:
> > > Let me rephrase the topic ... Under what conditions should somebody use
> > > the GFP_TEMPORARY gfp_t?
> > 
> > Most users of slab (kmalloc) do not really have to care. Slab will add
> > __GFP_RECLAIMABLE to all reclaimable caches automagically AFAIR. The
> > remaining would have to implement some kind of shrinker to allow the
> > reclaim.
> 
> I seem to be not making myself clear.  Picture me writing a device driver.
> When should I use GFP_TEMPORARY?

I guess the original intention was to use this flag for allocations
which will be either freed shortly or they are reclaimable.
 
> > > Example usages that I have questions about:
> > > 
> > > 1. Is it permissible to call kmalloc(GFP_TEMPORARY), or is it only
> > > for alloc_pages?
> > 
> > kmalloc will use it internally as mentioned above.  I am not even sure
> > whether direct using of kmalloc(GFP_TEMPORARY) is ok.  I would have to
> > check the code but I guess it would be just wrong unless you know your
> > cache is reclaimable.
> 
> You're not using words that have any meaning to a device driver writer.
> Here's my code:
> 
> int foo_ioctl(..)
> {
> 	struct foo *foo = kmalloc(sizeof(*foo), GFP_TEMPORARY);
> }
> 
> Does this work?  If not, should it?  Or should slab be checking for
> this and calling WARN()?

I would have to check the code but I believe that this shouldn't be
harmful other than increase the fragmentation.

> > > I ask because if the slab allocator is unaware of
> > > GFP_TEMPORARY, then a non-GFP_TEMPORARY allocation may be placed in a
> > > page allocated with GFP_TEMPORARY and we've just made it meaningless.
> > > 
> > > 2. Is it permissible to sleep while holding a GFP_TEMPORARY allocation?
> > > eg, take a mutex, or wait_for_completion()?
> > 
> > Yes, GFP_TEMPORARY has ___GFP_DIRECT_RECLAIM set so this is by
> > definition sleepable allocation request.
> 
> Again, we're talking past each other.  Can foo_ioctl() sleep before
> releasing its GFP_TEMPORARY allocation, or will that make the memory
> allocator unhappy?

I do not think it would make the allocator unhappy as long as the sleep
is not for ever...

> > > 3. Can I make one GFP_TEMPORARY allocation, and then another one?
> > 
> > Not sure I understand. WHy would be a problem?
> 
> As you say above, GFP_TEMPORARY may sleep, so this is a variation on the "can I sleep while holding a GFP_TEMPORARY allocation" question.
> 
> > > 4. Should I disable preemption while holding a GFP_TEMPORARY allocation,
> > > or are we OK with a task being preempted?
> > 
> > no, it can sleep.
> > 
> > > 5. What about something even longer duration like allocating a kiocb?
> > > That might take an arbitrary length of time to be freed, but eventually
> > > the command will be timed out (eg 30 seconds for something that ends up
> > > going through SCSI).
> > 
> > I do not understand. The reclaimability of the object is in hands of the
> > respective shrinker...
> 
> There is no shrinker here.  This is about the object being "temporary",
> for some value of temporary.  I want to nail down what the MM is willing
> to tolerate in terms of length of time an object is allocated for.

>From my understanding MM will use the information for optimizing objects
placing and the longer the user will use that memory the worse this
optimization works. I do not think the (ab)use would be fatal...
 
> > > 6. Or shorter duration like doing a GFP_TEMPORARY allocation, then taking
> > > a spinlock, which *probably* isn't contended, but you never know.
> > > 
> > > 7. I can see it includes __GFP_WAIT so it's not suitable for using from
> > > interrupt context, but interrupt context might be the place which can
> > > benefit from it the most.  Or does GFP_ATOMIC's __GFP_HIGH also allow for
> > > allocation from the movable zone?  Should we have a GFP_TEMPORARY_ATOMIC?
> > 
> > This is where __GFP_RECLAIMABLE should be used as this is the core of
> > the functionality.
> 
> This response also doesn't make sense to me.

I meant to say that such an allocation can use __GFP_RECLAIMABLE | __GFP_NOWAIT.


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
