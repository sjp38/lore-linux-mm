Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 96F036B0035
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 13:33:15 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id ik5so7518456vcb.7
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 10:33:15 -0700 (PDT)
Received: from mail-vc0-x22b.google.com (mail-vc0-x22b.google.com [2607:f8b0:400c:c03::22b])
        by mx.google.com with ESMTPS id sa4si21823080vdc.98.2014.07.09.10.33.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 10:33:14 -0700 (PDT)
Received: by mail-vc0-f171.google.com with SMTP id id10so7724314vcb.30
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 10:33:14 -0700 (PDT)
Date: Wed, 9 Jul 2014 13:33:26 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 1/8] mmput: use notifier chain to call subsystem exit
 handler.
Message-ID: <20140709173325.GE4249@gmail.com>
References: <1404856801-11702-1-git-send-email-j.glisse@gmail.com>
 <1404856801-11702-2-git-send-email-j.glisse@gmail.com>
 <20140709162123.GN1958@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140709162123.GN1958@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 09, 2014 at 06:21:24PM +0200, Joerg Roedel wrote:
> On Tue, Jul 08, 2014 at 05:59:58PM -0400, j.glisse@gmail.com wrote:
> > +int mmput_register_notifier(struct notifier_block *nb)
> > +{
> > +	return blocking_notifier_chain_register(&mmput_notifier, nb);
> > +}
> > +EXPORT_SYMBOL_GPL(mmput_register_notifier);
> > +
> > +int mmput_unregister_notifier(struct notifier_block *nb)
> > +{
> > +	return blocking_notifier_chain_unregister(&mmput_notifier, nb);
> > +}
> > +EXPORT_SYMBOL_GPL(mmput_unregister_notifier);
> 
> I am still not convinced that this is required. For core code that needs
> to hook into mmput (like aio or uprobes) it really improves code
> readability if their teardown functions are called explicitly in mmput.
> 
> And drivers that deal with the mm can use the already existing
> mmu_notifers. That works at least for the AMD-IOMMUv2 and KFD drivers.
> 
> Maybe HMM is different here, but then you should explain why and how it
> is different and why you can't add an explicit teardown function for
> HMM.

My first patchset added a call to hmm in mmput but Andrew asked me to
instead add a notifier chain as he foresee more user for that. Hence
why i did this patch.

On why hmm need to cleanup here it is simple :
  - hmm is tie to mm_struct (add a pointer to mm_struct)
  - hmm pointer of mm_struct is clear on fork
  - hmm object lifespan should be the same as mm_struct
  - device file descriptor can outlive the mm_struct into which they
    were open and thus an hmm structure that was allocated on behalf
    of a device driver would stay allocated for as long as children
    that have no use for it leaves (ie until they close the device
    file).

So again, hmm is tie to mm_struct life span. We want to free hmm and
its resources when mm is destroyed. We can not do that in file >release
callback because it might happen long after the mm struct is free.

We can not do that from mmu_notifier release callback because this
would lead to use after free.

We could add a delayed job from mmu_notifier callback but this would
be hacky as we would have no way to synchronize ourself with the mm
destruction without complex rules and crazy code.

So again i do not see any alternative to hmm interfacing them and i
genuinely belive iommuv2 is in the same situation as us thus justifying
even more the notifier chain idea.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
