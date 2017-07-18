Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94B866B0292
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 15:15:31 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id n42so12801087qtn.10
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 12:15:31 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id x188si2899440qkc.108.2017.07.18.12.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 12:15:30 -0700 (PDT)
Received: by mail-qk0-x22f.google.com with SMTP id p126so19245326qkf.0
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 12:15:30 -0700 (PDT)
Date: Tue, 18 Jul 2017 15:15:28 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 00/10] percpu: replace percpu area map allocator with
 bitmap allocator
Message-ID: <20170718191527.GA4009@destiny>
References: <20170716022315.19892-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170716022315.19892-1-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

On Sat, Jul 15, 2017 at 10:23:05PM -0400, Dennis Zhou wrote:
> Hi everyone,
> 
> The Linux kernel percpu memory allocator is responsible for managing
> percpu memory. It allocates memory from chunks of percpu areas and uses a
> simple first-fit area allocator to manage allocations inside each chunk.
> There now exist use cases where allocating and deallocating a million or
> more objects occurs making the current implementation inadequate.
> 
> The two primary problems with the current area map allocator are:
>   1. The backing data structure is an array of the areas. To manage this
>      array, it is possible to need to memmove a large portion of it.
>   2. On allocation, chunks are considered based on the contig_hint. It is
>      possible that the contig_hint may be large enough while the alignment 
>      could not meet the request. This causes scanning over every free
>      fragment that could spill over into scanning chunks.
> 
> The primary considerations for the new allocator were the following:
>  - Remove the memmove operation from the critical path
>  - Be conservative with additional use of memory
>  - Provide consistency in performance and memory footprint
>  - Focus on small allocations < 64 bytes
> 
> This patchset introduces a simple bitmap allocator backed by metadata
> blocks as a replacement for the area map allocator for percpu memory. Each
> chunk has an allocation bitmap, a boundary bitmap, and a set of metadata
> blocks. The allocation map serves as the ground truth for allocations
> while the boundary map serves as a way to distinguish between consecutive
> allocations. The minimum allocation size has been increased to 4-bytes.
> 
> The key property behind the bitmap allocator is its static metadata. The
> main problem it solves is that a memmove is no longer part of the critical
> path for freeing, which was the primary source of latency. This also helps
> bound the metadata overhead. The area map allocator prior required an
> integer per allocation. This may be beneficial with larger allocations,
> but as mentioned, allocating a significant number of small objects is
> becoming more common. This causes worst-case scenarios for metadata
> overhead.
> 
> There is one caveat with this implementation. In an effort to make freeing
> fast, the only time metadata is updated on the free path is if a whole
> block becomes free or the freed area spans across metadata blocks. This
> causes the chunka??s contig_hint to be potentially smaller than what it
> could allocate by up to a block. If the chunka??s contig_hint is smaller
> than a block, a check occurs and the hint is kept accurate. Metadata is
> always kept accurate on allocation and therefore the situation where a
> chunk has a larger contig_hint than available will never occur.
> 
> I have primarily done testing against a simple workload of allocation of
> 1 million objects of varying size. Deallocation was done by in order,
> alternating, and in reverse. These numbers were collected after rebasing
> ontop of a80099a152. I present the worst-case numbers here:
> 
>   Area Map Allocator:
> 
>         Object Size | Alloc Time (ms) | Free Time (ms)
>         ----------------------------------------------
>               4B    |        335      |     4960
>              16B    |        485      |     1150
>              64B    |        445      |      280
>             128B    |        505      |      177
>            1024B    |       3385      |      140
> 
>   Bitmap Allocator:
> 
>         Object Size | Alloc Time (ms) | Free Time (ms)
>         ----------------------------------------------
>               4B    |        725      |       70
>              16B    |        760      |       70
>              64B    |        855      |       80
>             128B    |        910      |       90
>            1024B    |       3770      |      260
> 
> This data demonstrates the inability for the area map allocator to
> handle less than ideal situations. In the best case of reverse
> deallocation, the area map allocator was able to perform within range
> of the bitmap allocator. In the worst case situation, freeing took
> nearly 5 seconds for 1 million 4-byte objects. The bitmap allocator
> dramatically improves the consistency of the free path. The small
> allocations performed nearly identical regardless of the freeing
> pattern.
> 
> While it does add to the allocation latency, the allocation scenario
> here is optimal for the area map allocator. The second problem of
> additional scanning can result in the area map allocator completing in
> 52 minutes. The same workload takes only 14 seconds to complete for the
> bitmap allocator. This was produced under a more contrived scenario of
> allocating 1 milion 4-byte objects with 8-byte alignment.
> 

Ok so you say that this test is better for the area map allocator, so presumably
this is worst case for the bitmap allocator?  What does the average case look
like?  Trading 2x allocation latency for a pretty significant free latency
reduction seems ok, but are we allocating or freeing more?  Are both allocations
and free's done in performance critical areas, or do allocations only happen in
performance critical areas, making the increased allocation latency hurt more?
And lastly, why are we paying a 2x latency cost?  What is it about the bitmap
allocator that makes it much worse than the area map allocator?  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
