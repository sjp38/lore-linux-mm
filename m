Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id B06AA6B0139
	for <linux-mm@kvack.org>; Thu,  8 May 2014 21:26:25 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so3833423qgd.1
        for <linux-mm@kvack.org>; Thu, 08 May 2014 18:26:25 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id s6si1367534qaj.62.2014.05.08.18.26.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 18:26:25 -0700 (PDT)
Received: by mail-qg0-f50.google.com with SMTP id z60so3769909qgd.9
        for <linux-mm@kvack.org>; Thu, 08 May 2014 18:26:25 -0700 (PDT)
Date: Thu, 8 May 2014 21:26:03 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
Message-ID: <20140509012601.GA2906@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
 <20140506102925.GD11096@twins.programming.kicks-ass.net>
 <CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com>
 <20140506150014.GA6731@gmail.com>
 <CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>
 <20140506153315.GB6731@gmail.com>
 <CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com>
 <20140506161836.GC6731@gmail.com>
 <1399446892.4161.34.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1399446892.4161.34.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

On Wed, May 07, 2014 at 05:14:52PM +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2014-05-06 at 12:18 -0400, Jerome Glisse wrote:
> > 
> > I do understand that i was pointing out that if i move to, tlb which i
> > am fine with, i will still need to sleep there. That's all i wanted to
> > stress, i did not wanted force using mmu_notifier, i am fine with them
> > becoming atomic as long as i have a place where i can intercept cpu
> > page table update and propagate them to device mmu.
> 
> Your MMU notifier can maintain a map of "dirty" PTEs and you do the
> actual synchronization in the subsequent flush_tlb_* , you need to add
> hooks there but it's much less painful than in the notifiers.
> 
> *However* Linus, even then we can't sleep. We do things like
> ptep_clear_flush() that need the PTL and have the synchronous flush
> semantics.
> 
> Sure, today we wait, possibly for a long time, with IPIs, but we do not
> sleep. Jerome would have to operate within a similar context. No sleep
> for you :)
> 
> Cheers,
> Ben.
> 
> 

So Linus, Benjamin is right there was couple case i did not think about.
For instance with cow page, one thread might trigger copy on write allocate
new page and update page table and another cpu thread might start using the
new page before we even get a chance to update the GPU page table thus GPU
could be working on outdated data.

Same kind of race exist on fork when we write protect a page or on when we
split a huge page.

I thought that i only needed to special case page reclaimation, migration
and forbid things like ksm but i am wrong.

So with that in mind are you ok if i pursue the mmu_notifier case taking
into account the result about rwsem+optspin that would allow to make the
many fork workload fast while still allowing mmu_notifier callback to
sleep ?

Otherwise i have no other choice than to add something like mmu_notifier
in the place where there can a be race (huge page split, cow, ...). Which
sounds like a bad idea to me when mmu_notifier is perfect for the job.

Cheers,
Jerome Glisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
