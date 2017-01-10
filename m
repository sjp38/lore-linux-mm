Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB5BC6B0266
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 11:58:41 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id t84so134925206qke.7
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 08:58:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m86si1719967qkl.237.2017.01.10.08.58.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 08:58:40 -0800 (PST)
Date: Tue, 10 Jan 2017 11:58:36 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v15 13/16] mm/hmm/migrate: new memory migration helper for
 use with device memory v2
Message-ID: <20170110165835.GA3342@redhat.com>
References: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
 <1483721203-1678-14-git-send-email-jglisse@redhat.com>
 <d5c4a464-1f17-8517-3646-33dd5bf06ef5@nvidia.com>
 <20170106171300.GA3804@redhat.com>
 <9642114e-3093-cff0-e177-1071b478f27f@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9642114e-3093-cff0-e177-1071b478f27f@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Nellans <dnellans@nvidia.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On Tue, Jan 10, 2017 at 09:30:30AM -0600, David Nellans wrote:
> 
> > You are mischaracterizing patch 11-14. Patch 11-12 adds new flags and
> > modify existing functions so that they can be share. Patch 13 implement
> > new migration helper while patch 14 optimize this new migration helper.
> >
> > hmm_migrate() is different from existing migration code because it works
> > on virtual address range of a process. Existing migration code works
> > from page. The only difference with existing code is that we collect
> > pages from virtual address and we allow use of dma engine to perform
> > copy.
> You're right, but why not just introduce a new general migration interface
> that works on vma range first, then case all the normal migration paths for
> HMM and then DMA?  Being able to migrate based on vma range certainly
> makes user level control of memory placement/migration less complicated
> than page interfaces.

Special casing for HMM and DMA is already what those patches do. They share
as much code as doable with existing path. There is one thing to consider
here, because we are working on vma range we can easily optimize the unmap
step. This is why i do not share any of the outer loop with existing code.

Sharing more code than this will be counter-productive from optimization
point of view.

> 
> > There is nothing that ie hmm_migrate() to HMM. If that make you feel better
> > i can drop the hmm_ prefix but i would need another name than migrate() as
> > it is already taken. I can probably name it vma_range_dma_migrate() or
> > something like that.
> >
> > The only think that is HMM specific in this code is understanding HMM special
> > page table entry and handling those. Such entry can only be migrated by DMA
> > and not by memcpy hence why i do not modify existing code to support those.
> I'd be happier if there was a vma_migrate proposed independently, I think
> it would find users outside the HMM sandbox. In the IBM migration case,
> they might want the vma interface but choose to use CPU based migration
> rather than this DMA interface, It certainly would make testing of the
> vma_migrate interface easier.

Like i said that code is not in HMM sandbox, it seats behind its own kernel
option and do not rely on any HMM thing beside hmm_pfn_t which is pfn with
a bunch of flags. The only difference with existing code is that it does
understand HMM CPU pte. It can easily be rename without hmm_ prefix if that
is what people want. The hmm_pfn_t is harder to replace as there isn't any-
thing that match the requirement (need few flags: DEVICE,MIGRATE,EMPTY,
UNADDRESSABLE).

The DMA is a callback function the caller of hmm_migrate() provide so you can
easily provide a callback that just do memcpy (well copy_highpage()). There
is no need to make any change. I can even provide a default CPU copy call-
back.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
