Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1873F6B0037
	for <linux-mm@kvack.org>; Sat, 10 May 2014 20:48:41 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id j15so5544321qaq.41
        for <linux-mm@kvack.org>; Sat, 10 May 2014 17:48:40 -0700 (PDT)
Received: from mail-qa0-x229.google.com (mail-qa0-x229.google.com [2607:f8b0:400d:c00::229])
        by mx.google.com with ESMTPS id h90si4078873qgh.183.2014.05.10.17.48.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 10 May 2014 17:48:40 -0700 (PDT)
Received: by mail-qa0-f41.google.com with SMTP id dc16so5683420qab.0
        for <linux-mm@kvack.org>; Sat, 10 May 2014 17:48:40 -0700 (PDT)
Date: Sat, 10 May 2014 20:48:31 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
Message-ID: <20140511004829.GA7101@gmail.com>
References: <20140506102925.GD11096@twins.programming.kicks-ass.net>
 <CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com>
 <20140506150014.GA6731@gmail.com>
 <CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>
 <20140506153315.GB6731@gmail.com>
 <CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com>
 <20140506161836.GC6731@gmail.com>
 <1399446892.4161.34.camel@pasglop>
 <20140509012601.GA2906@gmail.com>
 <1399696115.4481.48.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1399696115.4481.48.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

On Sat, May 10, 2014 at 02:28:35PM +1000, Benjamin Herrenschmidt wrote:
> On Thu, 2014-05-08 at 21:26 -0400, Jerome Glisse wrote:
> > Otherwise i have no other choice than to add something like mmu_notifier
> > in the place where there can a be race (huge page split, cow, ...). Which
> > sounds like a bad idea to me when mmu_notifier is perfect for the job.
> 
> Even there, how are you going to find a sleepable context ? All that stuff
> has the PTL held.
> 
> Cheers,
> Ben.

All i need is invalidate_page and invalidate_range_start both of which are not
call while holding any lock beside that anon_vma and or mmap_sem. So i am fine
on that front.

The change_pte callback are bracketed by call to invalidate_range_start / end.

What is important is to flush GPU page table prior to any update that would
make the cpu page table point to a different page. For invalidate_page this
is ok because so far it is call either as page reclaimation and those page
is change to swap entry or file entry. Or it is call for page migration and
cpu page table is set to special migration entry (there is also the memory
failure case but this one is harmless too).

So as far as i can tell i am safe on that front and only mmu_notifier provide
the early warning that i need notably for COW.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
