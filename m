Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id C66EC6B006C
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 10:51:00 -0400 (EDT)
Received: by qkbp125 with SMTP id p125so95582828qkb.2
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 07:51:00 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id k90si41963923qkh.51.2015.06.29.07.51.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 07:51:00 -0700 (PDT)
Received: by qkeo142 with SMTP id o142so95613665qke.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 07:50:59 -0700 (PDT)
Date: Mon, 29 Jun 2015 10:50:54 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 07/36] HMM: add per mirror page table v3.
Message-ID: <20150629145053.GB2173@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432236705-4209-8-git-send-email-j.glisse@gmail.com>
 <alpine.DEB.2.00.1506251557480.28614@mdh-linux64-2.nvidia.com>
 <20150626164338.GB3748@gmail.com>
 <alpine.DEB.2.00.1506261958010.22464@mdh-linux64-2.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.00.1506261958010.22464@mdh-linux64-2.nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

On Fri, Jun 26, 2015 at 08:02:03PM -0700, Mark Hairgrove wrote:
> On Fri, 26 Jun 2015, Jerome Glisse wrote:
> > On Thu, Jun 25, 2015 at 04:05:48PM -0700, Mark Hairgrove wrote:
> > > On Thu, 21 May 2015, j.glisse@gmail.com wrote:
> > > > From: Jerome Glisse <jglisse@redhat.com>
> > > > [...]
> > > >  
> > > > +	/* update() - update device mmu following an event.
> > > > +	 *
> > > > +	 * @mirror: The mirror that link process address space with the device.
> > > > +	 * @event: The event that triggered the update.
> > > > +	 * Returns: 0 on success or error code {-EIO, -ENOMEM}.
> > > > +	 *
> > > > +	 * Called to update device page table for a range of address.
> > > > +	 * The event type provide the nature of the update :
> > > > +	 *   - Range is no longer valid (munmap).
> > > > +	 *   - Range protection changes (mprotect, COW, ...).
> > > > +	 *   - Range is unmapped (swap, reclaim, page migration, ...).
> > > > +	 *   - Device page fault.
> > > > +	 *   - ...
> > > > +	 *
> > > > +	 * Thought most device driver only need to use pte_mask as it reflects
> > > > +	 * change that will happen to the HMM page table ie :
> > > > +	 *   new_pte = old_pte & event->pte_mask;
> > > 
> > > Documentation request: It would be useful to break down exactly what is 
> > > required from the driver for each event type here, and what extra 
> > > information is provided by the type that isn't provided by the pte_mask.
> > 
> > Mostly event tell you if you need to free or not the device page table for
> > the range, which is not something you can infer from the pte_mask reliably.
> > Difference btw migration and munmap for instance, same pte_mask but range
> > is still valid in the migration case it will just be backed by a new set of
> > pages.
> 
> Given that event->pte_mask and event->type provide redundant information, 
> are they both necessary?

Like said, you can not infer event->type from pte_mask but you can infer
pte_mask from event->type. The idea is behind providing pte_mask is that
simple driver can just use that with the iter walk and simply mask the HMM
page table entry they read ((*ptep) & pte_mask) to repopulate the device
page table.

So yes pte_mask is redundant but i think it will be useful for a range of
device driver.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
