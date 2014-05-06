Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC3F829AA
	for <linux-mm@kvack.org>; Tue,  6 May 2014 11:33:26 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id s7so3093209qap.34
        for <linux-mm@kvack.org>; Tue, 06 May 2014 08:33:26 -0700 (PDT)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id o3si6092861qcc.23.2014.05.06.08.33.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 08:33:23 -0700 (PDT)
Received: by mail-qa0-f53.google.com with SMTP id ih12so4686084qab.26
        for <linux-mm@kvack.org>; Tue, 06 May 2014 08:33:23 -0700 (PDT)
Date: Tue, 6 May 2014 11:33:17 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
Message-ID: <20140506153315.GB6731@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
 <20140506102925.GD11096@twins.programming.kicks-ass.net>
 <CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com>
 <20140506150014.GA6731@gmail.com>
 <CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

On Tue, May 06, 2014 at 08:18:34AM -0700, Linus Torvalds wrote:
> On Tue, May 6, 2014 at 8:00 AM, Jerome Glisse <j.glisse@gmail.com> wrote:
> >
> > So question becomes how to implement process address space mirroring
> > without pinning memory and track cpu page table update knowing that
> > device page table update is unbound can not be atomic from cpu point
> > of view.
> 
> Perhaps as a fake TLB and interacting with the TLB shootdown? And
> making sure that everything is atomic?
> 
> Some of these devices are going to actually *share* the real page
> tables. Not "cache" them. Actually use the page tables directly.
> That's where all these on-die APU things are going, where the device
> really ends up being something much more like ASMP (asymmetric
> multi-processing) than a traditional external device.
> 
> So we *will* have to extend our notion of TLB shootdown to have not
> just a mask of possible active CPU's, but possible active devices. No
> question about that.

Well no, as i said and explain in my mail APU and IOMMUv2 is a one sided
coin and you can not use the device memory with such solution. So yes
there is interest from many player to mirror the cpu page table by other
means than by having the IOMMU walk the cpu page table (this include
AMD).

> 
> But doing this with sleeping in some stupid VM notifier is completely
> out of the question, because it *CANNOT EVEN WORK* for that eventual
> real goal of sharing the physical page tables where the device can do
> things like atomic dirty/accessed bit settings etc. It can only work
> for crappy sh*t that does the half-way thing. It's completely racy wrt
> the actual page table updates. That kind of page table sharing needs
> true atomicity for exactly the same reason we need it for our current
> SMP. So it needs to have all the same page table locking rules etc.
> Not that shitty notifier callback.
> 
> As I said, the VM notifiers were misdesigned to begin with. They are
> an abomination. We're not going to extend on that and make it worse.
> We are *certainly* not going to make them blocking and screwing our
> core VM that way. And that's doubly and triply true when it cannot
> work for the generic case _anyway_.
> 
>               Linus

So how can i solve the issue at hand. A device that has its own page
table and can not mirror the cpu page table, nor can the device page
table be updated atomicly from the cpu. Yes such device will exist
and the IOMMUv2 walking the cpu page table is not capable of supporting
GPU memory which is a big big big needed feature. Compare 20Gb/s vs
300Gb/s of GPU memory.

I understand that we do not want to sleep when updating process cpu
page table but note that only process that use the gpu would have to
sleep. So only process that can actually benefit from the using GPU
will suffer the consequences.

That said it also play a role with page reclamation hence why i am
proposing to have a separate lru for page involve with a GPU.

So having the hardware walking the cpu page table is out of the
question.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
