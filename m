Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 540FC6B0007
	for <linux-mm@kvack.org>; Wed, 23 May 2018 20:10:36 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id e8-v6so23640135qtj.0
        for <linux-mm@kvack.org>; Wed, 23 May 2018 17:10:36 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q11-v6si841531qtq.38.2018.05.23.17.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 17:10:34 -0700 (PDT)
Date: Wed, 23 May 2018 20:10:27 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/5] mm: rework hmm to use devm_memremap_pages
Message-ID: <20180524001026.GA3527@redhat.com>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, stable@vger.kernel.org, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 21, 2018 at 03:35:14PM -0700, Dan Williams wrote:
> Hi Andrew, please consider this series for 4.18.
> 
> For maintainability, as ZONE_DEVICE continues to attract new users,
> it is useful to keep all users consolidated on devm_memremap_pages() as
> the interface for create "device pages".
> 
> The devm_memremap_pages() implementation was recently reworked to make
> it more generic for arbitrary users, like the proposed peer-to-peer
> PCI-E enabling. HMM pre-dated this rework and opted to duplicate
> devm_memremap_pages() as hmm_devmem_pages_create().
> 
> Rework HMM to be a consumer of devm_memremap_pages() directly and fix up
> the licensing on the exports given the deep dependencies on the mm.

I am on PTO right now so i won't be able to quickly review it all
but forcing GPL export is problematic for me now. I rather have
device driver using "sane" common helpers than creating their own
crazy thing.

Back in couple weeks i will review this some more.

> 
> Patches based on v4.17-rc6 where there are no upstream consumers of the
> HMM functionality.
> 
> ---
> 
> Dan Williams (5):
>       mm, devm_memremap_pages: mark devm_memremap_pages() EXPORT_SYMBOL_GPL
>       mm, devm_memremap_pages: handle errors allocating final devres action
>       mm, hmm: use devm semantics for hmm_devmem_{add,remove}
>       mm, hmm: replace hmm_devmem_pages_create() with devm_memremap_pages()
>       mm, hmm: mark hmm_devmem_{add,add_resource} EXPORT_SYMBOL_GPL
> 
> 
>  Documentation/vm/hmm.txt |    1 
>  include/linux/hmm.h      |    4 -
>  include/linux/memremap.h |    1 
>  kernel/memremap.c        |   39 +++++-
>  mm/hmm.c                 |  297 +++++++---------------------------------------
>  5 files changed, 77 insertions(+), 265 deletions(-)
