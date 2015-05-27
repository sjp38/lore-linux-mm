Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 23A9B6B0105
	for <linux-mm@kvack.org>; Wed, 27 May 2015 10:32:13 -0400 (EDT)
Received: by qkhg32 with SMTP id g32so6511249qkh.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 07:32:12 -0700 (PDT)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com. [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id h10si12768067qgf.29.2015.05.27.07.32.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 07:32:12 -0700 (PDT)
Received: by qgf2 with SMTP id 2so4122072qgf.3
        for <linux-mm@kvack.org>; Wed, 27 May 2015 07:32:12 -0700 (PDT)
Date: Wed, 27 May 2015 10:32:00 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 02/36] mmu_notifier: keep track of active invalidation
 ranges v3
Message-ID: <20150527143159.GA1948@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432236705-4209-3-git-send-email-j.glisse@gmail.com>
 <871ti2mwsc.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <871ti2mwsc.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Wed, May 27, 2015 at 10:39:23AM +0530, Aneesh Kumar K.V wrote:
> j.glisse@gmail.com writes:
> 
> > From: Jerome Glisse <jglisse@redhat.com>
> >
> > The mmu_notifier_invalidate_range_start() and mmu_notifier_invalidate_range_end()
> > can be considered as forming an "atomic" section for the cpu page table update
> > point of view. Between this two function the cpu page table content is unreliable
> > for the address range being invalidated.
> >
> > Current user such as kvm need to know when they can trust the content of the cpu
> > page table. This becomes even more important to new users of the mmu_notifier
> > api (such as HMM or ODP).
> 
> I don't see kvm using the new APIs in this patch. Also what is that HMM use this
> for, to protect walking of mirror page table ?. I am sure you are
> covering that in the later patches. May be you may want to mention
> the details here too. 

KVM side is not done, i looked at KVM code long time ago and thought oh it
could take advantage of this but now i do not remember exactly. I would need
to check back.

For HMM this is simple, no device fault can populate or walk the mirror page
table on a range that is being invalidated. But concurrent fault/walk can
happen outside the invalidated range. All handled in hmm_device_fault_start().

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
