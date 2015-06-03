Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 92972900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 12:07:29 -0400 (EDT)
Received: by lbcmx3 with SMTP id mx3so10328167lbc.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 09:07:28 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id v5si1964717wjr.212.2015.06.03.09.07.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 09:07:27 -0700 (PDT)
Received: by wibut5 with SMTP id ut5so108118189wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 09:07:26 -0700 (PDT)
Date: Wed, 3 Jun 2015 12:07:12 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 01/36] mmu_notifier: add event information to address
 invalidation v7
Message-ID: <20150603160711.GA2602@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432236705-4209-2-git-send-email-j.glisse@gmail.com>
 <alpine.LNX.2.03.1505292001580.13637@nvidia.com>
 <20150601190331.GA4170@gmail.com>
 <alpine.LNX.2.03.1506011525460.17506@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.LNX.2.03.1506011525460.17506@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Mon, Jun 01, 2015 at 04:10:46PM -0700, John Hubbard wrote:
> On Mon, 1 Jun 2015, Jerome Glisse wrote:
> > On Fri, May 29, 2015 at 08:43:59PM -0700, John Hubbard wrote:
> > > On Thu, 21 May 2015, j.glisse@gmail.com wrote:
> > > > From: Jerome Glisse <jglisse@redhat.com>

[...]
> > > > +	MMU_ISDIRTY,
> > > 
> > > This MMU_ISDIRTY seems like a problem to me. First of all, it looks 
> > > backwards: the only place that invokes it is the clear_refs_write() 
> > > routine, for the soft-dirty tracking feature. And in that case, the pages 
> > > are *not* being made dirty! Rather, the kernel is actually making the 
> > > pages non-writable, in order to be able to trap the subsequent page fault 
> > > and figure out if the page is in active use.
> > > 
> > > So, given that there is only one call site, and that call site should 
> > > actually be setting MMU_WRITE_PROTECT instead (I think), let's just delete 
> > > MMU_ISDIRTY.
> > > 
> > > Come to think about it, there is no callback possible for "a page became 
> > > dirty", anyway. Because the dirty and accessed bits are actually set by 
> > > the hardware, and software is generally unable to know the current state.
> > > So MMU_ISDIRTY just seems inappropriate to me, across the board.
> > > 
> > > I'll take a look at the corresponding HMM_ISDIRTY, too.
> > 
> > Ok i need to rename that one to CLEAR_SOFT_DIRTY, the idea is that
> > for HMM i would rather not write protect the memory for the device
> > and just rely on the regular and conservative dirtying of page. The
> > soft dirty is really for migrating a process where you first clear
> > the soft dirty bit, then copy memory while process still running,
> > then freeze process an only copy memory that was dirtied since
> > first copy. Point being that adding soft dirty to HMM is something
> > that can be done down the road. We should have enough bit inside
> > the device page table for that.
> > 
> 
> Yes, I think renaming it to CLEAR_SOFT_DIRTY will definitely allow more 
> accurate behavior in response to these events.
> 
> Looking ahead, a couple things:
> 
> 1. This mechanism is also used for general memory utilization tracking (I 
> see that Vladimir DavyDov has an "idle memory tracking" proposal that 
> assumes this works, for example: https://lwn.net/Articles/642202/ and 
> https://lkml.org/lkml/2015/5/12/449).
> 
> 2. It seems hard to avoid the need to eventually just write protect the 
> page, whether it is on the CPU or the remote device, if things like device 
> drivers or user space need to track write accesses to a virtual address. 
> Either you write protect the page, and trap the page faults, or you wait 
> until later and read the dirty bit (indirectly, via something like 
> unmap_mapping_range). Or did you have something else in mind?
> 
> Anyway, none of that needs to hold up this part of the patchset, because 
> the renaming fixes things up for the future code to do the right thing.

I will go over Vladimir patchset it was on my radar but haven't had yet a
chance to go over it. We will likely need to do the write protect for device
too. But as you said this is not an issue that this patch need a fix for,
only HMM would need to change. I will do that.


[...]
> > > We may have to add MMU_READ_WRITE (and maybe another one, I haven't 
> > > bottomed out on that), if you agree with the above approach of 
> > > always sending a precise event, instead of "protection changed".
> > 
> > I think Linus point made sense last time, but i would need to read
> > again the thread. The idea of that patch is really to provide context
> > information on what kind of CPU page table changes is happening and
> > why.
> >
> 
> Shoot, I tried to find that conversation, but my search foo is too weak. 
> If you have a link to that thread, I'd appreciate it, so I can refresh my 
> memory.
> 
> I was hoping to re-read it and see if anything has changed. It's not 
> really a huge problem to call find_vma() again, but I do want to be sure 
> that there's a good reason for doing so.
>  
> Otherwise, I'll just rely on your memory that Linus preferred your current 
> approach, and call it good, then.

http://lkml.iu.edu/hypermail/linux/kernel/1406.3/04880.html

I am working on doing some of the changes discussed so far, i will push my
tree to git://people.freedesktop.org/~glisse/linux hmm branch once i am done.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
