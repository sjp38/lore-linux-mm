Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9B27C6B005A
	for <linux-mm@kvack.org>; Tue,  6 May 2014 14:13:20 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id i8so3205567qcq.1
        for <linux-mm@kvack.org>; Tue, 06 May 2014 11:13:20 -0700 (PDT)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id x1si5539136qal.50.2014.05.06.11.13.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 11:13:20 -0700 (PDT)
Received: by mail-qg0-f47.google.com with SMTP id j107so2618876qga.6
        for <linux-mm@kvack.org>; Tue, 06 May 2014 11:13:19 -0700 (PDT)
Date: Tue, 6 May 2014 14:13:12 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
Message-ID: <20140506181308.GG6731@gmail.com>
References: <20140506102925.GD11096@twins.programming.kicks-ass.net>
 <CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com>
 <20140506150014.GA6731@gmail.com>
 <CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>
 <20140506153315.GB6731@gmail.com>
 <CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com>
 <20140506161836.GC6731@gmail.com>
 <CA+55aFweCGWQMSxP09MJMhJ0XySZqvw=QaoUWwsWU4KaqDgOhw@mail.gmail.com>
 <20140506172853.GF6731@gmail.com>
 <CA+55aFwhHYnVhzx4-TchrpM5AN2Oqm1fy8ot0bguJ=T_eeA0fg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFwhHYnVhzx4-TchrpM5AN2Oqm1fy8ot0bguJ=T_eeA0fg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

On Tue, May 06, 2014 at 10:43:22AM -0700, Linus Torvalds wrote:
> On Tue, May 6, 2014 at 10:28 AM, Jerome Glisse <j.glisse@gmail.com> wrote:
> >
> > Also, just to be sure, are my changes to the radix tree otherwise
> > acceptable at least in principle.
> 
> It looks like it adds several "loop over each page" cases just to
> check whether each page might be on remote memory.
> 
> Which seems a complete waste of time 99.99% of the time.
> 
> But maybe I'm looking at the wrong patch.
> 
>           Linus

It is patch 8 for core changes and patch 9 to demonstrate per fs changes.

So yes each place that does radix tree lookup need to check that the entries
it got out of the radix tree are not special one and because many place in
the code gang lookup with pagevec_lookup there is need to go over entries
that were looked up to take appropriate action.

Other design is to do migration inside the various radix tree lookup functions
but that means going out of rcu section and possibly sleeping waiting for the
GPU to copy back things into system memory.

I could grow the radix function to return some bool to avoid looping over for
case where there is no special entry.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
