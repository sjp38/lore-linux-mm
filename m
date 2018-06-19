Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85D0E6B0007
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 03:54:59 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x3-v6so8219431wrs.14
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 00:54:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25-v6si5969504eda.331.2018.06.19.00.54.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jun 2018 00:54:58 -0700 (PDT)
Subject: Re: [PATCH v2 0/7] kmalloc-reclaimable caches
References: <20180618091808.4419-1-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <386fda93-a2d4-6302-c233-12bc77c7668c@suse.cz>
Date: Tue, 19 Jun 2018 09:54:54 +0200
MIME-Version: 1.0
In-Reply-To: <20180618091808.4419-1-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>, Vijayanand Jitta <vjitta@codeaurora.org>

On 06/18/2018 11:18 AM, Vlastimil Babka wrote:
> v2 changes:
> - shorten cache names to kmalloc-rcl-<SIZE>
> - last patch shortens <SIZE> for all kmalloc caches to e.g. "1k", "4M"
> - include dma caches to the 2D kmalloc_caches[] array to avoid a branch
> - vmstat counter nr_indirectly_reclaimable_bytes renamed to
>   nr_kernel_misc_reclaimable, doesn't include kmalloc-rcl-*
> - /proc/meminfo counter renamed to KReclaimable, includes kmalloc-rcl*
>   and nr_kernel_misc_reclaimable
> 
> Hi,
> 
> as discussed at LSF/MM [1] here's a patchset that introduces
> kmalloc-reclaimable caches (more details in the second patch) and uses them for
> SLAB freelists and dcache external names. The latter allows us to repurpose the
> NR_INDIRECTLY_RECLAIMABLE_BYTES counter later in the series.

More info about user benefits of the patchset:

With patch 4, dcache external names are allocated from kmalloc-rcl-*
caches, eliminating the need for manual accounting. More importantly, it
also ensures the reclaimable kmalloc allocations are grouped in pages
separate from the regular kmalloc allocations. The need for proper
accounting of dcache external names has shown it's easy for misbehaving
process to allocate lots of them, causing premature OOMs. Without the
added grouping, it's likely that similar workload can interleave the
dcache external names allocations with regular kmalloc allocations
(note: I haven't searched myself for an example of such regular kmalloc
allocation, but I would be very surprised if there wasn't some). A
pathological case would be e.g. one 64byte regular allocations with 63
external dcache names in a page (64x64=4096), which means the page is
not freed even after reclaiming after all dcache names, and the process
can thus steal the whole page with single 64byte allocation.

If there other kmalloc users similar to dcache external names become
identified, they can also benefit from the new functionality simply by
adding __GFP_RECLAIMABLE to the kmalloc calls.

Side benefits of the patchset (that could be also merged separately)
include removed branch for detecting __GFP_DMA kmalloc(), and shortening
kmalloc cache names in /proc/slabinfo output. The latter is potentially
an ABI break in case there are tools parsing the names and expecting the
values to be in bytes.
