Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52E9A6B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d5so20770107pfg.3
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:38 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k70si5822376pfj.411.2017.07.24.16.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:36 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 00/23] percpu: replace percpu area map allocator with bitmap allocator
Date: Mon, 24 Jul 2017 19:01:57 -0400
Message-ID: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>, Dennis Zhou <dennisz@fb.com>

Hi everyone,

V2:
There was a good bit of refactoring. Several variable names were
modified to more descriptive. First bit is now kept track of instead of
first block.

Chunk slots are back to being managed in bytes.

The reserved region is no longer expanded to be page aligned. The other
regions in the first chunk are now expanded accordingly to align with the
minimum allocation size. This lets the first chunk allocation code be
combined. The chunks now keep track of start and end offsets to support
the reserved region. Block size should now be changeable within some
constraints.

The unit_size is expected to be a multiple of the bitmap block size. The
LCM(page size, block size) > 1 to map the bitmap correctly to the
backing pages.

Iterators were added for walking the metadata blocks to find free space
and for walking the metadata to update the chunk hints.

The metadata now keeps track of the best starting offsets rather than
just the first one.

Empty page count had an error where the count was being incremented when
it was populating pages for an allocation. Chunk scanning on the free
path now occurs if a page becomes free in the case of large metadata
blocks.

The data presented below has been updated and additional data is
provided to demonstrate the variable performance of the allocation path
for the area map allocator.

---------

The Linux kernel percpu memory allocator is responsible for managing
percpu memory. It allocates memory from chunks of percpu areas and uses a
simple first-fit area allocator to manage allocations inside each chunk.
There now exist use cases where allocating and deallocating a million or
more objects occurs making the current implementation inadequate.

The two primary problems with the current area map allocator are:
  1. The backing data structure is an array of the areas. To manage this
     array, it is possible to need to memmove a large portion of it.
  2. On allocation, chunks are considered based on the contig_hint. It is
     possible that the contig_hint may be large enough while the alignment 
     could not meet the request. This causes scanning over every free
     fragment that could spill over into scanning chunks.

The primary considerations for the new allocator were the following:
 - Remove the memmove operation from the critical path
 - Be conservative with additional use of memory
 - Provide consistency in performance and memory footprint
 - Focus on small allocations < 64 bytes

This patchset introduces a simple bitmap allocator backed by metadata
blocks as a replacement for the area map allocator for percpu memory. Each
chunk has an allocation bitmap, a boundary bitmap, and a set of metadata
blocks. The allocation map serves as the ground truth for allocations
while the boundary map serves as a way to distinguish between consecutive
allocations. The minimum allocation size has been increased to 4-bytes.

The key property behind the bitmap allocator is its static metadata. The
main problem it solves is that a memmove is no longer part of the critical
path for freeing, which was the primary source of latency. This also helps
bound the metadata overhead. The area map allocator prior required an
integer per allocation. This may be beneficial with larger allocations,
but as mentioned, allocating a significant number of small objects is
becoming more common. This causes worst-case scenarios for metadata
overhead.

In an effort to make freeing fast, the only time metadata is updated on
the free path is if a whole block becomes free or the freed area spans
across metadata blocks. This causes the chunka??s contig_hint to be
potentially smaller than what it could allocate by up to a block. If the
chunka??s contig hint is smaller than a block, a check occurs and the hint
is kept accurate. Metadata is always kept accurate on allocation and
therefore the situation where a chunk has a larger contig hint than
available will never occur.

I have primarily done testing against a simple workload of allocation of
1 million objects of varying size. Deallocation was done by in order,
alternating, and in reverse. These numbers were collected after rebasing
ontop of a80099a152. I present the worst-case numbers here:

  Area Map Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |        310      |     4770
             16B    |        557      |     1325
             64B    |        436      |      273
            256B    |        776      |      131
           1024B    |       3280      |      122

  Bitmap Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |        490      |       70
             16B    |        515      |       75
             64B    |        610      |       80
            256B    |        950      |      100
           1024B    |       3520      |      200

This data demonstrates the inability for the area map allocator to
handle less than ideal situations. In the best case of reverse
deallocation, the area map allocator was able to perform within range
of the bitmap allocator. In the worst case situation, freeing took
nearly 5 seconds for 1 million 4-byte objects. The bitmap allocator
dramatically improves the consistency of the free path. The small
allocations performed nearly identical regardless of the freeing
pattern.

While it does add to the allocation latency, the allocation scenario
here is optimal for the area map allocator. The area map allocator runs
into trouble when it is allocating in chunks where the latter half is
full. It is difficult to replicate this, so I present a variant where
the pages are second half filled. Freeing was done sequentially. Below
are the numbers for this scenario:

  Area Map Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |       4118      |     4892
             16B    |       1651      |     1163
             64B    |        598      |      285
            256B    |        771      |      158
           1024B    |       3034      |      160

  Bitmap Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |        481      |       67
             16B    |        506      |       69
             64B    |        636      |       75
            256B    |        892      |       90
           1024B    |       3262      |      147

The data shows a parabolic curve of performance for the area map
allocator. This is due to the memmove operation being the dominant cost
with the lower object sizes as more objects are packed in a chunk and at
higher object sizes, the traversal of the chunk slots is the dominating
cost. The bitmap allocator suffers this problem as well. The above data
shows the inability to scale for the allocation path with the area map
allocator and that the bitmap allocator demonstrates consistent
performance in general.

The second problem of additional scanning can result in the area map
allocator completing in 52 minutes when trying to allocate 1 million
4-byte objects with 8-byte alignment. The same workload takes
approximately 16 seconds to complete for the bitmap allocator.

Alternative implementations were evaluated including: linked lists, trees,
and buddy systems. These all suffer from either high metadata overhead for
small allocations or from the amplified costs of fragmentation with percpu
memory.

This patchset contains the following 23 patches:

  0001-percpu-setup_first_chunk-enforce-dynamic-region-must.patch
  0002-percpu-introduce-start_offset-to-pcpu_chunk.patch
  0003-percpu-remove-has_reserved-from-pcpu_chunk.patch
  0004-percpu-setup_first_chunk-remove-dyn_size-and-consoli.patch
  0005-percpu-unify-allocation-of-schunk-and-dchunk.patch
  0006-percpu-end-chunk-area-maps-page-aligned-for-the-popu.patch
  0007-percpu-setup_first_chunk-rename-schunk-dchunk-to-chu.patch
  0008-percpu-modify-base_addr-to-be-region-specific.patch
  0009-percpu-combine-percpu-address-checks.patch
  0010-percpu-change-the-number-of-pages-marked-in-the-firs.patch
  0011-percpu-introduce-nr_empty_pop_pages-to-help-empty-pa.patch
  0012-percpu-increase-minimum-percpu-allocation-size-and-a.patch
  0013-percpu-generalize-bitmap-un-populated-iterators.patch
  0014-percpu-replace-area-map-allocator-with-bitmap-alloca.patch
  0015-percpu-introduce-bitmap-metadata-blocks.patch
  0016-percpu-add-first_bit-to-keep-track-of-the-first-free.patch
  0017-percpu-skip-chunks-if-the-alloc-does-not-fit-in-the-.patch
  0018-percpu-keep-track-of-the-best-offset-for-contig-hint.patch
  0019-percpu-update-alloc-path-to-only-scan-if-contig-hint.patch
  0020-percpu-update-free-path-to-take-advantage-of-contig-.patch
  0021-percpu-use-metadata-blocks-to-update-the-chunk-conti.patch
  0022-percpu-update-pcpu_find_block_fit-to-use-an-iterator.patch
  0023-percpu-update-header-to-contain-bitmap-allocator-exp.patch

0001-0007 clean up and merge the first chunk allocation paths.
0008-0009 move the base address up and merge the address check logic.
0010 fixes the bitmap size of the first chunk. 0011-0013 are preparatory
patches for the bitmap allocator. 0014 swaps out the area map allocator
for the bitmap allocator. 0015 introduces metadata blocks. 0016-0022
replace temporary scanning functions with faster code. 0023 updates
the header to contain a new copyright and details about the bitmap
allocator.

This patchset is on top of linus#master a80099a152.

diffstats below:

Dennis Zhou (Facebook) (23):
  percpu: setup_first_chunk enforce dynamic region must exist
  percpu: introduce start_offset to pcpu_chunk
  percpu: remove has_reserved from pcpu_chunk
  percpu: setup_first_chunk remove dyn_size and consolidate logic
  percpu: unify allocation of schunk and dchunk
  percpu: end chunk area maps page aligned for the populated bitmap
  percpu: setup_first_chunk rename schunk/dchunk to chunk
  percpu: modify base_addr to be region specific
  percpu: combine percpu address checks
  percpu: change the number of pages marked in the first_chunk pop
    bitmap
  percpu: introduce nr_empty_pop_pages to help empty page accounting
  percpu: increase minimum percpu allocation size and align first
    regions
  percpu: generalize bitmap (un)populated iterators
  percpu: replace area map allocator with bitmap allocator
  percpu: introduce bitmap metadata blocks
  percpu: add first_bit to keep track of the first free in the bitmap
  percpu: skip chunks if the alloc does not fit in the contig hint
  percpu: keep track of the best offset for contig hints
  percpu: update alloc path to only scan if contig hints are broken
  percpu: update free path to take advantage of contig hints
  percpu: use metadata blocks to update the chunk contig hint
  percpu: update pcpu_find_block_fit to use an iterator
  percpu: update header to contain bitmap allocator explanation.

 include/linux/percpu.h |   20 +-
 init/main.c            |    1 -
 mm/percpu-internal.h   |   81 ++-
 mm/percpu-km.c         |    2 +-
 mm/percpu-stats.c      |  100 ++--
 mm/percpu.c            | 1466 ++++++++++++++++++++++++++++++------------------
 6 files changed, 1070 insertions(+), 600 deletions(-)

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
