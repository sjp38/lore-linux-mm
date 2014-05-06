Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f182.google.com (mail-ve0-f182.google.com [209.85.128.182])
	by kanga.kvack.org (Postfix) with ESMTP id 21A356B003A
	for <linux-mm@kvack.org>; Tue,  6 May 2014 12:32:17 -0400 (EDT)
Received: by mail-ve0-f182.google.com with SMTP id sa20so4745095veb.27
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:32:16 -0700 (PDT)
Received: from mail-ve0-x22f.google.com (mail-ve0-x22f.google.com [2607:f8b0:400c:c01::22f])
        by mx.google.com with ESMTPS id yq2si2404273vcb.199.2014.05.06.09.32.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 09:32:16 -0700 (PDT)
Received: by mail-ve0-f175.google.com with SMTP id jw12so4069403veb.34
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:32:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140506161836.GC6731@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
	<20140506102925.GD11096@twins.programming.kicks-ass.net>
	<CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com>
	<20140506150014.GA6731@gmail.com>
	<CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>
	<20140506153315.GB6731@gmail.com>
	<CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com>
	<20140506161836.GC6731@gmail.com>
Date: Tue, 6 May 2014 09:32:16 -0700
Message-ID: <CA+55aFweCGWQMSxP09MJMhJ0XySZqvw=QaoUWwsWU4KaqDgOhw@mail.gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

On Tue, May 6, 2014 at 9:18 AM, Jerome Glisse <j.glisse@gmail.com> wrote:
>
> I do understand that i was pointing out that if i move to, tlb which i
> am fine with, i will still need to sleep there.

No can do. The TLB flushing itself is called with a spinlock held, and
we need to continue to do that.

Why do you really need to sleep? Because that sounds bogus.

What you *should* do is send the flush message, and not wait for any
reply. You can then possibly wait for the result later on: we already
have this multi-stage TLB flush model (using the "mmu_gather"
structure) that has three phases:

 - create mmu_gather (allocate space for batching etc). This can sleep.
 - do the actual flushing (possibly multiple times). This is the
"synchronous with the VM" part and cannot sleep.
 - tear down the mmu_gather data structures and actually free the
pages we batched. This can sleep.

and what I think a GPU flush has to do is to do the actual flushes
when asked to (because that's what it will need to do to work with a
real TLB eventually), but if there's some crazy asynchronous
acknowledge thing from hardware, it's possible to perhaps wait for
that in the final phase (*before* we free the pages we gathered).

Now, such an asynchronous model had better not mark page tables dirty
after we flushed (we'd lose that information), but quite frankly,
anything that is remote enough to need some async flush thing cannor
sanely be close enough to be closely tied to the actual real page
tables, so I don't think we need to care.

Anyway, I really think that the existing mmu_gather model *should*
work fine for this all. It may be a bit inconvenient for crazy
hardware, but the important part is that it definitely should work for
any future hardware that actually gets this right.

It does likely involve adding some kind of device list to "struct
mm_struct", and I'm sure there's some extension to "struct mmu_gather"
too, but _conceptually_ it should all be reasonably non-invasive.

Knock wood.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
