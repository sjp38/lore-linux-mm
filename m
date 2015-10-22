Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id CC2346B0253
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 10:11:21 -0400 (EDT)
Received: by oiao187 with SMTP id o187so48041475oia.3
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 07:11:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c9si8879843oek.6.2015.10.22.07.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 07:11:21 -0700 (PDT)
Date: Thu, 22 Oct 2015 10:11:11 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v11 15/15] HMM: add documentation explaining HMM
 internals and how to use it.
Message-ID: <20151022141111.GA2914@redhat.com>
References: <1445461210-2605-1-git-send-email-jglisse@redhat.com>
 <1445461210-2605-16-git-send-email-jglisse@redhat.com>
 <562856BD.3020806@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <562856BD.3020806@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>

On Wed, Oct 21, 2015 at 08:23:41PM -0700, Randy Dunlap wrote:
> Hi,
> 
> Some corrections and a few questions...

Thanks for the corrections. Answer below.

> On 10/21/15 14:00, JA(C)rA'me Glisse wrote:
> > This add documentation on how HMM works and a more in depth view of how it
> > should be use by device driver writers.
> > 
> > Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>

[...]

> > +synchronizing device page table for range that the device driver explicitly ask
> 
>                                        ranges                                  asks
> 
> or is only one range supported?

Several ranges are supported.


[...]

> > +  /* Mirror memory (in read mode) between addressA and addressB */
> > +  your_hmm_event->hmm_event.start = addressA;
> > +  your_hmm_event->hmm_event.end = addressB;
> 
> Multiple events (ranges) can be specified?

Device driver have to make one call per range but multiple threads can make
concurrent call for different ranges.

> Is hmm_event.end (addressB) included or excluded from the range?

Forgot to copy comment from header file, start is inclusive, end is exclusive.


[...]

> > +  struct hmm_pt_iter iter;
> > +  hmm_pt_iter_init(&iter, &mirror->pt)
> > +
> > +  /* Get pointer to HMM page table entry for a given address. */
> > +  dma_addr_t *hmm_pte;
> > +  hmm_pte = hmm_pt_iter_walk(&iter, &addr, &next);
> 
> what are 'addr' and 'next'? (types)

unsigned long will add then to the doc, good point.

[...]


> > +  /* Migrate system memory between addressA and addressB to device memory. */
> > +  your_hmm_event->hmm_event.start = addressA;
> > +  your_hmm_event->hmm_event.end = addressB;
> 
> is hmm_event.end (addressB) inclusive and exclusive?
> i.e., is it end_of_copy + 1?
> i.e., is the size of the copy addressB - addressA or
>       addressB - addressA + 1?
> i.e., is addressB = addressA + size
> or is    addressB = addressA + size - 1

Exclusive last one.


> In my experience it is usually better to have a start_address and size
> instead of start_address and end_address.

I switched several time btw the 2 offer differents version of the patchset,
it is something that can be change down the road unless you have strong
feeling about it.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
