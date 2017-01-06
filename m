Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1916B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 12:13:08 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id 192so23220978itl.7
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 09:13:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h127si27717732ioa.186.2017.01.06.09.13.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 09:13:07 -0800 (PST)
Date: Fri, 6 Jan 2017 12:13:01 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v15 13/16] mm/hmm/migrate: new memory migration helper for
 use with device memory v2
Message-ID: <20170106171300.GA3804@redhat.com>
References: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
 <1483721203-1678-14-git-send-email-jglisse@redhat.com>
 <d5c4a464-1f17-8517-3646-33dd5bf06ef5@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <d5c4a464-1f17-8517-3646-33dd5bf06ef5@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Nellans <dnellans@nvidia.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On Fri, Jan 06, 2017 at 10:46:09AM -0600, David Nellans wrote:
> 
> 
> On 01/06/2017 10:46 AM, Jerome Glisse wrote:
> > This patch add a new memory migration helpers, which migrate memory
> > backing a range of virtual address of a process to different memory
> > (which can be allocated through special allocator). It differs from
> > numa migration by working on a range of virtual address and thus by
> > doing migration in chunk that can be large enough to use DMA engine
> > or special copy offloading engine.
> >
> > Expected users are any one with heterogeneous memory where different
> > memory have different characteristics (latency, bandwidth, ...). As
> > an example IBM platform with CAPI bus can make use of this feature
> > to migrate between regular memory and CAPI device memory. New CPU
> > architecture with a pool of high performance memory not manage as
> > cache but presented as regular memory (while being faster and with
> > lower latency than DDR) will also be prime user of this patch.
> Why should the normal page migration path (where neither src nor dest
> are device private), use the hmm_migrate functionality?  11-14 are
> replicating a lot of the normal migration functionality but with special
> casing for HMM requirements.

You are mischaracterizing patch 11-14. Patch 11-12 adds new flags and
modify existing functions so that they can be share. Patch 13 implement
new migration helper while patch 14 optimize this new migration helper.

hmm_migrate() is different from existing migration code because it works
on virtual address range of a process. Existing migration code works
from page. The only difference with existing code is that we collect
pages from virtual address and we allow use of dma engine to perform
copy.

> When migrating THP's or a list of pages (your use case above), normal
> NUMA migration is going to want to do this as fast as possible too (see
> Zi Yan's patches for multi-threading normal migrations & prototype of
> using intel IOAT for transfers, he sees 3-5x speedup).

This is core features of HMM and as such optimization like better THP
support are defer to later patchset.

> 
> If the intention is to provide a common interface hook for migration to
> use DMA acceleration (which is a good idea), it probably shouldn't be
> special cased inside HMM functionality. For example, using the intel IOAT
> for migration DMA has nothing to do with HMM whatsoever. We need a normal
> migration path interface to allow DMA that isn't tied to HMM.

There is nothing that ie hmm_migrate() to HMM. If that make you feel better
i can drop the hmm_ prefix but i would need another name than migrate() as
it is already taken. I can probably name it vma_range_dma_migrate() or
something like that.

The only think that is HMM specific in this code is understanding HMM special
page table entry and handling those. Such entry can only be migrated by DMA
and not by memcpy hence why i do not modify existing code to support those.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
