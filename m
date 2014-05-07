Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id D72786B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 08:39:57 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id j7so945778qaq.31
        for <linux-mm@kvack.org>; Wed, 07 May 2014 05:39:57 -0700 (PDT)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id 4si7713334qcl.32.2014.05.07.05.39.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 05:39:57 -0700 (PDT)
Received: by mail-qa0-f53.google.com with SMTP id ih12so899033qab.12
        for <linux-mm@kvack.org>; Wed, 07 May 2014 05:39:57 -0700 (PDT)
Date: Wed, 7 May 2014 08:39:49 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
Message-ID: <20140507123948.GA2582@gmail.com>
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
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

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

Well getting back the dirty info from the GPU also require to sleep. Maybe
i should explain how it is suppose to work. GPU have several command buffer
and execute instructions inside those command buffer in sequential order.
To update the GPU mmu you need to schedule command into one of those command
buffer but when you do so you do not know how much command are in front of
you and how long it will take to the GPU to get to your command.

Yes GPU this patchset target have preemption but it is not as flexible as
CPU preemption there is not kernel thread running and scheduling, all the
scheduling is done in hardware. So the preemption is more limited that on
CPU.

That is why any update or information retrieval from the GPU need to go
through some command buffer and no matter how high priority the command
buffer for mmu update is, it can still long time (think flushing thousand
of GPU thread and saving there context).

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

So for the ptep_clear_flush my idea is to have a special lru for page that
are in use by the GPU. This will prevent the page reclaimation try_to_unmap
and thus the ptep_clear_flush. I would block ksm so again another user that
would no do ptep_clear_flush. I would need to fix remap_file_pages either
adding some callback there or refactor the unmap and tlb flushing.

Finaly for page migration i see several solutions, forbid it (easy for me
but likely not what we want) have special code inside migrate code to handle
page in use by a device, or have special code inside try_to_unmap to handle
it.

I think this is all the current user of ptep_clear_flush and derivative that
does flush tlb while holding spinlock.

Note that for special lru or event special handling of page in use by a device
i need a new page flag. Would this be acceptable ?

For the special lru i was thinking of doing it per device as anyway each device
is unlikely to constantly address all the page it has mapped. Simple lru list
would do and probably offering some helper for device driver to mark page accessed
so page frequently use are not reclaim.

But a global list is fine as well and simplify the case diffirent device use
same pages.

Cheers,
Jerome Glisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
