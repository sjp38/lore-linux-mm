Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26F376B0593
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 22:24:36 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k190so56673252pgk.8
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 19:24:36 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id p5si9810043pgf.366.2017.07.15.19.24.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 19:24:34 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 00/10] percpu: replace percpu area map allocator with bitmap allocator
Date: Sat, 15 Jul 2017 22:23:05 -0400
Message-ID: <20170716022315.19892-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>, Dennis Zhou <dennisz@fb.com>

Hi everyone,

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

There is one caveat with this implementation. In an effort to make freeing
fast, the only time metadata is updated on the free path is if a whole
block becomes free or the freed area spans across metadata blocks. This
causes the chunka??s contig_hint to be potentially smaller than what it
could allocate by up to a block. If the chunka??s contig_hint is smaller
than a block, a check occurs and the hint is kept accurate. Metadata is
always kept accurate on allocation and therefore the situation where a
chunk has a larger contig_hint than available will never occur.

I have primarily done testing against a simple workload of allocation of
1 million objects of varying size. Deallocation was done by in order,
alternating, and in reverse. These numbers were collected after rebasing
ontop of a80099a152. I present the worst-case numbers here:

  Area Map Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |        335      |     4960
             16B    |        485      |     1150
             64B    |        445      |      280
            128B    |        505      |      177
           1024B    |       3385      |      140

  Bitmap Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |        725      |       70
             16B    |        760      |       70
             64B    |        855      |       80
            128B    |        910      |       90
           1024B    |       3770      |      260

This data demonstrates the inability for the area map allocator to
handle less than ideal situations. In the best case of reverse
deallocation, the area map allocator was able to perform within range
of the bitmap allocator. In the worst case situation, freeing took
nearly 5 seconds for 1 million 4-byte objects. The bitmap allocator
dramatically improves the consistency of the free path. The small
allocations performed nearly identical regardless of the freeing
pattern.

While it does add to the allocation latency, the allocation scenario
here is optimal for the area map allocator. The second problem of
additional scanning can result in the area map allocator completing in
52 minutes. The same workload takes only 14 seconds to complete for the
bitmap allocator. This was produced under a more contrived scenario of
allocating 1 milion 4-byte objects with 8-byte alignment.

Alternative implementations were evaluated including: linked lists, trees,
and buddy systems. These all suffer from either high metadata overhead for
small allocations or from the amplified costs of fragmentation with percpu
memory.

This patchset contains the following ten patches:

  0001-percpu-pcpu-stats-change-void-buffer-to-int-buffer.patch
  0002-percpu-change-the-format-for-percpu_stats-output.patch
  0003-percpu-expose-pcpu_nr_empty_pop_pages-in-pcpu_stats.patch
  0004-percpu-update-the-header-comment-and-pcpu_build_allo.patch
  0005-percpu-change-reserved_size-to-end-page-aligned.patch
  0006-percpu-modify-base_addr-to-be-region-specific.patch
  0007-percpu-fix-misnomer-in-schunk-dchunk-variable-names.patch
  0008-percpu-change-the-number-of-pages-marked-in-the-firs.patch
  0009-percpu-replace-area-map-allocator-with-bitmap-alloca.patch
  0010-percpu-add-optimizations-on-allocation-path-for-the-.patch

0001-0002 are minor fixes to percpu_stats. 0003 exposes a new field via
percpu_stats. 0004 updates comments in the percpu allocator. 0005-0006 are
preparatory patches that modify the first_chunk's base_addr management and
the reserved region. 0007 does some variable renaming for clarity. 0008
modifies the population map and the variables surrounding population. 0009
is the bitmap allocator backed by metadata blocks implementation. 0010
adds two optimizations on top of the allocator.

This patchset is on top of linus#master a80099a152.

diffstats below:

Dennis Zhou (Facebook) (10):
  percpu: pcpu-stats change void buffer to int buffer
  percpu: change the format for percpu_stats output
  percpu: expose pcpu_nr_empty_pop_pages in pcpu_stats
  percpu: update the header comment and pcpu_build_alloc_info comments
  percpu: change reserved_size to end page aligned
  percpu: modify base_addr to be region specific
  percpu: fix misnomer in schunk/dchunk variable names
  percpu: change the number of pages marked in the first_chunk bitmaps
  percpu: replace area map allocator with bitmap allocator
  percpu: add optimizations on allocation path for the bitmap allocator

 arch/ia64/mm/contig.c    |    3 +-
 arch/ia64/mm/discontig.c |    3 +-
 include/linux/percpu.h   |   43 +-
 init/main.c              |    1 -
 mm/percpu-internal.h     |   84 ++-
 mm/percpu-stats.c        |  111 ++--
 mm/percpu.c              | 1461 +++++++++++++++++++++++++++++-----------------
 7 files changed, 1107 insertions(+), 599 deletions(-)

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
