Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5CEA96B010B
	for <linux-mm@kvack.org>; Wed, 27 May 2015 10:33:50 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so6516450qkd.2
        for <linux-mm@kvack.org>; Wed, 27 May 2015 07:33:50 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id f199si18115284qhc.20.2015.05.27.07.33.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 07:33:49 -0700 (PDT)
Received: by qkhg32 with SMTP id g32so6545266qkh.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 07:33:49 -0700 (PDT)
Date: Wed, 27 May 2015 10:33:43 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 03/36] mmu_notifier: pass page pointer to
 mmu_notifier_invalidate_page()
Message-ID: <20150527143342.GB1948@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432236705-4209-4-git-send-email-j.glisse@gmail.com>
 <87wpzulhtz.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87wpzulhtz.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Wed, May 27, 2015 at 10:47:44AM +0530, Aneesh Kumar K.V wrote:
> j.glisse@gmail.com writes:
> 
> > From: Jerome Glisse <jglisse@redhat.com>
> >
> > Listener of mm event might not have easy way to get the struct page
> > behind and address invalidated with mmu_notifier_invalidate_page()
> > function as this happens after the cpu page table have been clear/
> > updated. This happens for instance if the listener is storing a dma
> > mapping inside its secondary page table. To avoid complex reverse
> > dma mapping lookup just pass along a pointer to the page being
> > invalidated.
> 
> .....
> 
> > diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> > index ada3ed1..283ad26 100644
> > --- a/include/linux/mmu_notifier.h
> > +++ b/include/linux/mmu_notifier.h
> > @@ -172,6 +172,7 @@ struct mmu_notifier_ops {
> >  	void (*invalidate_page)(struct mmu_notifier *mn,
> >  				struct mm_struct *mm,
> >  				unsigned long address,
> > +				struct page *page,
> >  				enum mmu_event event);
> >  
> 
> How do we handle this w.r.t invalidate_range ? 

With range invalidation the CPU page table is still reliable when
invalidate_range_start() callback happen. So we can lookup the CPU
page table to get the page backing the address.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
