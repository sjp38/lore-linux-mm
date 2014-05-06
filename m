Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 092D56B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 12:49:41 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id i17so8793500qcy.25
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:49:40 -0700 (PDT)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id j6si5407410qan.32.2014.05.06.09.49.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 09:49:39 -0700 (PDT)
Received: by mail-qa0-f49.google.com with SMTP id cm18so7585825qab.8
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:49:39 -0700 (PDT)
Date: Tue, 6 May 2014 12:49:33 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
Message-ID: <20140506164931.GD6731@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
 <20140506102925.GD11096@twins.programming.kicks-ass.net>
 <CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com>
 <20140506150014.GA6731@gmail.com>
 <CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>
 <20140506153315.GB6731@gmail.com>
 <CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com>
 <20140506161836.GC6731@gmail.com>
 <CA+55aFweCGWQMSxP09MJMhJ0XySZqvw=QaoUWwsWU4KaqDgOhw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFweCGWQMSxP09MJMhJ0XySZqvw=QaoUWwsWU4KaqDgOhw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

On Tue, May 06, 2014 at 09:32:16AM -0700, Linus Torvalds wrote:
> On Tue, May 6, 2014 at 9:18 AM, Jerome Glisse <j.glisse@gmail.com> wrote:
> >
> > I do understand that i was pointing out that if i move to, tlb which i
> > am fine with, i will still need to sleep there.
> 
> No can do. The TLB flushing itself is called with a spinlock held, and
> we need to continue to do that.
> 
> Why do you really need to sleep? Because that sounds bogus.
> 
> What you *should* do is send the flush message, and not wait for any
> reply. You can then possibly wait for the result later on: we already
> have this multi-stage TLB flush model (using the "mmu_gather"
> structure) that has three phases:
> 
>  - create mmu_gather (allocate space for batching etc). This can sleep.
>  - do the actual flushing (possibly multiple times). This is the
> "synchronous with the VM" part and cannot sleep.
>  - tear down the mmu_gather data structures and actually free the
> pages we batched. This can sleep.
> 
> and what I think a GPU flush has to do is to do the actual flushes
> when asked to (because that's what it will need to do to work with a
> real TLB eventually), but if there's some crazy asynchronous
> acknowledge thing from hardware, it's possible to perhaps wait for
> that in the final phase (*before* we free the pages we gathered).

Plan i had in mind was to add an item atomicly inside mmu notifier to
schedule work on the gpu and have the tlb wait on the gpu to acknowledge
that it did update its page table and it is done using those pages.
This would happen in tlb_flush_mmu

> 
> Now, such an asynchronous model had better not mark page tables dirty
> after we flushed (we'd lose that information), but quite frankly,
> anything that is remote enough to need some async flush thing cannor
> sanely be close enough to be closely tied to the actual real page
> tables, so I don't think we need to care.

That's an issue as soon as i schedule the work (read as early on as i
can) the gpu can report any of the page as dirty and it can possibly
do so only once we wait for it in tlb_flush_mmu.

> 
> Anyway, I really think that the existing mmu_gather model *should*
> work fine for this all. It may be a bit inconvenient for crazy
> hardware, but the important part is that it definitely should work for
> any future hardware that actually gets this right.
> 

I stress again the GPU with dedicated memory is not going away on the
opposite you might see more dedicated memory not accessible from the
CPU.

> It does likely involve adding some kind of device list to "struct
> mm_struct", and I'm sure there's some extension to "struct mmu_gather"
> too, but _conceptually_ it should all be reasonably non-invasive.
> 
> Knock wood.
> 
>             Linus

I will port over to piggy back on mmu gather and other tlb flush. I will
post as soon as i have something that works with features this patchset
has.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
