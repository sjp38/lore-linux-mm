Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id B5B846B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 15:03:45 -0400 (EDT)
Received: by qkoo18 with SMTP id o18so89170756qko.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 12:03:45 -0700 (PDT)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id j12si13649381qkh.54.2015.06.01.12.03.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 12:03:44 -0700 (PDT)
Received: by qgdy38 with SMTP id y38so26083221qgd.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 12:03:44 -0700 (PDT)
Date: Mon, 1 Jun 2015 15:03:32 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 01/36] mmu_notifier: add event information to address
 invalidation v7
Message-ID: <20150601190331.GA4170@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432236705-4209-2-git-send-email-j.glisse@gmail.com>
 <alpine.LNX.2.03.1505292001580.13637@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.LNX.2.03.1505292001580.13637@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Fri, May 29, 2015 at 08:43:59PM -0700, John Hubbard wrote:
> On Thu, 21 May 2015, j.glisse@gmail.com wrote:
> 
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > The event information will be useful for new user of mmu_notifier API.
> > The event argument differentiate between a vma disappearing, a page
> > being write protected or simply a page being unmaped. This allow new
> > user to take different path for different event for instance on unmap
> > the resource used to track a vma are still valid and should stay around.
> > While if the event is saying that a vma is being destroy it means that any
> > resources used to track this vma can be free.
> > 
> > Changed since v1:
> >   - renamed action into event (updated commit message too).
> >   - simplified the event names and clarified their usage
> >     also documenting what exceptation the listener can have in
> >     respect to each event.
> > 
> > Changed since v2:
> >   - Avoid crazy name.
> >   - Do not move code that do not need to move.
> > 
> > Changed since v3:
> >   - Separate hugue page split from mlock/munlock and softdirty.
> 
> Do we care about fixing up patch comments? If so:
> 
> s/hugue/huge/

I am noting them down and will go over them.


[...]
> > +	MMU_HSPLIT,
> 
> Let's rename MMU_HSPLIT to one of the following, take your pick:
> 
> MMU_HUGE_PAGE_SPLIT (too long, but you can't possibly misunderstand it)
> MMU_PAGE_SPLIT (my favorite: only huge pages are ever split, so it works)
> MMU_HUGE_SPLIT (ugly, but still hard to misunderstand)

I will go with MMU_HUGE_PAGE_SPLIT 


[...]
> 
> > +	MMU_ISDIRTY,
> 
> This MMU_ISDIRTY seems like a problem to me. First of all, it looks 
> backwards: the only place that invokes it is the clear_refs_write() 
> routine, for the soft-dirty tracking feature. And in that case, the pages 
> are *not* being made dirty! Rather, the kernel is actually making the 
> pages non-writable, in order to be able to trap the subsequent page fault 
> and figure out if the page is in active use.
> 
> So, given that there is only one call site, and that call site should 
> actually be setting MMU_WRITE_PROTECT instead (I think), let's just delete 
> MMU_ISDIRTY.
> 
> Come to think about it, there is no callback possible for "a page became 
> dirty", anyway. Because the dirty and accessed bits are actually set by 
> the hardware, and software is generally unable to know the current state.
> So MMU_ISDIRTY just seems inappropriate to me, across the board.
> 
> I'll take a look at the corresponding HMM_ISDIRTY, too.

Ok i need to rename that one to CLEAR_SOFT_DIRTY, the idea is that
for HMM i would rather not write protect the memory for the device
and just rely on the regular and conservative dirtying of page. The
soft dirty is really for migrating a process where you first clear
the soft dirty bit, then copy memory while process still running,
then freeze process an only copy memory that was dirtied since
first copy. Point being that adding soft dirty to HMM is something
that can be done down the road. We should have enough bit inside
the device page table for that.


> 
> > +	MMU_MIGRATE,
> > +	MMU_MPROT,
> 
> The MMU_PROT also looks questionable. Short answer: probably better to 
> read the protection, and pass either MMU_WRITE_PROTECT, MMU_READ_WRITE 
> (that's a new item, of course), or MMU_UNMAP.
> 
> Here's why: the call site knows the protection, but by the time it filters 
> down to HMM (in later patches), that information is lost, and HMM ends up 
> doing (ouch!) another find_vma() call in order to retrieve it--and then 
> translates it into only three possible things:
> 
> // hmm_mmu_mprot_to_etype() sets one of these:
> 
>    HMM_MUNMAP
>    HMM_WRITE_PROTECT
>    HMM_NONE

Linus complained of my previous version where i differenciated the
kind of protection change that was happening, hence why i only pass
down mprot.


> 
> 
> > +	MMU_MUNLOCK,
> 
> I think MMU_UNLOCK would be clearer. We already know the scope, so the 
> extra "M" isn't adding anything.

I named it that way so it matches syscall name munlock(). I think
it is clearer to use MUNLOCK, or maybe SYSCALL_MUNLOCK

> 
> > +	MMU_MUNMAP,
> 
> Same thing here: MMU_UNMAP seems better.

Well same idea here.


> 
> > +	MMU_WRITE_BACK,
> > +	MMU_WRITE_PROTECT,
> 
> We may have to add MMU_READ_WRITE (and maybe another one, I haven't 
> bottomed out on that), if you agree with the above approach of 
> always sending a precise event, instead of "protection changed".

I think Linus point made sense last time, but i would need to read
again the thread. The idea of that patch is really to provide context
information on what kind of CPU page table changes is happening and
why.

In that respect i should probably change MMU_WRITE_PROTECT to 
MMU_KSM_WRITE_PROTECT.


Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
