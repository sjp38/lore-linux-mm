Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 184AF6B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 10:31:11 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so1075435pfb.7
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 07:31:11 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id f8si2457021pgc.288.2017.01.10.07.31.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 07:31:10 -0800 (PST)
Subject: Re: [HMM v15 13/16] mm/hmm/migrate: new memory migration helper for
 use with device memory v2
References: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
 <1483721203-1678-14-git-send-email-jglisse@redhat.com>
 <d5c4a464-1f17-8517-3646-33dd5bf06ef5@nvidia.com>
 <20170106171300.GA3804@redhat.com>
From: David Nellans <dnellans@nvidia.com>
Message-ID: <9642114e-3093-cff0-e177-1071b478f27f@nvidia.com>
Date: Tue, 10 Jan 2017 09:30:30 -0600
MIME-Version: 1.0
In-Reply-To: <20170106171300.GA3804@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Anshuman Khandual <khandual@linux.vnet.ibm.com>


> You are mischaracterizing patch 11-14. Patch 11-12 adds new flags and
> modify existing functions so that they can be share. Patch 13 implement
> new migration helper while patch 14 optimize this new migration helper.
>
> hmm_migrate() is different from existing migration code because it works
> on virtual address range of a process. Existing migration code works
> from page. The only difference with existing code is that we collect
> pages from virtual address and we allow use of dma engine to perform
> copy.
You're right, but why not just introduce a new general migration interface
that works on vma range first, then case all the normal migration paths for
HMM and then DMA?  Being able to migrate based on vma range certainly
makes user level control of memory placement/migration less complicated
than
page interfaces.

> There is nothing that ie hmm_migrate() to HMM. If that make you feel better
> i can drop the hmm_ prefix but i would need another name than migrate() as
> it is already taken. I can probably name it vma_range_dma_migrate() or
> something like that.
>
> The only think that is HMM specific in this code is understanding HMM special
> page table entry and handling those. Such entry can only be migrated by DMA
> and not by memcpy hence why i do not modify existing code to support those.
I'd be happier if there was a vma_migrate proposed independently, I
think it would find
users outside the HMM sandbox. In the IBM migration case, they might
want the vma
interface but choose to use CPU based migration rather than this DMA
interface,
It certainly would make testing of the vma_migrate interface easier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
