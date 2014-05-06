Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 070BB6B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 12:18:46 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id w8so8667940qac.5
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:18:46 -0700 (PDT)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id 35si2411233qgy.36.2014.05.06.09.18.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 09:18:45 -0700 (PDT)
Received: by mail-qa0-f53.google.com with SMTP id ih12so4820111qab.40
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:18:45 -0700 (PDT)
Date: Tue, 6 May 2014 12:18:38 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
Message-ID: <20140506161836.GC6731@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
 <20140506102925.GD11096@twins.programming.kicks-ass.net>
 <CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com>
 <20140506150014.GA6731@gmail.com>
 <CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>
 <20140506153315.GB6731@gmail.com>
 <CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

On Tue, May 06, 2014 at 08:47:48AM -0700, Linus Torvalds wrote:
> On Tue, May 6, 2014 at 8:33 AM, Jerome Glisse <j.glisse@gmail.com> wrote:
> >
> > So how can i solve the issue at hand. A device that has its own page
> > table and can not mirror the cpu page table, nor can the device page
> > table be updated atomicly from the cpu.
> 
> So? Just model it as a TLB.
> 
> Sure, the TLB is slow and crappy and is in external memory rather than
> on-die, but it's still a TLB.
> 
> We have CPU's that do that kind of crazy thing (powerpc and sparc both
> have these kinds of "in-memory TLB extensions" in addition to the
> on-die TLB, they just call them "inverse page tables" to try to fool
> people about what they are).
> 
> > I understand that we do not want to sleep when updating process cpu
> > page table but note that only process that use the gpu would have to
> > sleep. So only process that can actually benefit from the using GPU
> > will suffer the consequences.
> 
> NO!
> 
> You don't get it. If a callback can sleep, then we cannot protect it
> with a spinlock.
> 
> It doesn't matter if it only sleeps once in a millennium. It still
> forces its crap on the rest of the system.

I do understand that i was pointing out that if i move to, tlb which i
am fine with, i will still need to sleep there. That's all i wanted to
stress, i did not wanted force using mmu_notifier, i am fine with them
becoming atomic as long as i have a place where i can intercept cpu
page table update and propagate them to device mmu.

> 
> So there is no way in hell that we will allow that VM notifier crap. None.
> 
> And as I've mentioned, there is a correct place to slot this in, and
> that correct way is the _only_ way to ever support future GPU's that
> _do_ share direct access to the page tables.

This work was done in cooperation with NVidia and we discussed with AMD too
so i am very much aware of what is coming next on hardware front and being
able to have GPU have their own GPU page table ie not walking the CPU one is
something of interest to the people who design those future generation of
GPU.

> 
> So trying to do it any other way is broken _anyway_.
> 
>            Linus

I will respin without using mmu_notifier and by hooking it as tlb shootdown.
But it will still need to sleep during the device tlb shootdown and that's
the point i want to make sure is clear.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
