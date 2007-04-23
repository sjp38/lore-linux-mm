From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 00/16] Variable Order Page Cache Patchset V2
Date: Sun, 22 Apr 2007 23:48:45 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: William Lee Irwin III <wli@holomorphy.com>, Badari Pulavarty <pbadari@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Adam Litke <aglitke@gmail.com>, Christoph Lameter <clameter@sgi.com>, Dave Hansen <hansendc@us.ibm.com>, Mel Gorman <mel@skynet.ie>, Avi Kivity <avi@argo.co.il>
List-ID: <linux-mm.kvack.org>

Sorry for the earlier mail. quilt and exim not cooperating.

RFC V1->V2
- Some ext2 support
- Some block layer, fs layer support etc.
- Better page cache macros
- Use macros to clean up code.

This patchset modifies the Linux kernel so that higher order page cache
pages become possible. The higher order page cache pages are compound pages
and can be handled in the same way as regular pages.

Rationales:

1. We have problems supporting devices with a higher blocksize than
   page size. This is for example important to support CD and DVDs that
   can only read and write 32k or 64k blocks. We currently have a shim
   layer in there to deal with this situation which limits the speed
   of I/O. The developers are currently looking for ways to completely
   bypass the page cache because of this deficiency.

2. 32/64k blocksize is also used in flash devices. Same issues.

3. Future harddisks will support bigger block sizes

4. Performace. If we look at IA64 vs. x86_64 then it seems that the
   faster interrupt handling on x86_64 compensate for the speed loss due to
   a smaller page size (4k vs 16k on IA64). Having higher page sizes on all
   platform allows a significant reduction in I/O overhead and increases the
   size of I/O that can be performed by hardware in a single request
   since the number of scatter gather entries are typically limited for
   one request. This is going to become increasingly important to support
   the ever growing memory sizes since we may have to handle excessively
   large amounts of 4k requests for data sizes that may become common
   soon. For example to write a 1 terabyte file the kernel would have to
   handle 256 million 4k chunks.

5. Cross arch compatibility: It is currently not possible to mount
   an 16k blocksize ext2 filesystem created on IA64 on an x86_64 system.

The support here is currently only for buffered I/O and only for two
filesystems ramfs and ext2.

Note that the higher order pages are subject to reclaim. This works in general
since we are always operating on a single page struct. Reclaim is fooled to
think that it is touching page sized objects (there are likely issues to be
fixed there if we want to go down this road).

What is currently not supported:
- Mmapping higher order pages
- Direct I/O (there are some fundamental issues with direct I/O
  putting compound pages that have to be treated as single pages
  on the pagevecs and the variable order page cache putting higher
  order compound pages that hjave to be treated as a single large page
  onto pagevecs.

Breakage:
- Reclaim does not work for some reasons. Compound pages on the active
  list get lost somehow.
- Disk data is corrupted when writing ext2fs data. There is likely
  still a lot of work to do in the block layer.
- There is a lot of incomplete work. There are numerous places
  where the kernel can no longer assume that the page cache consists
  of PAGE_SIZE pages that have not been fixed yet.

Future:
- Expect several more RFCs
- We hope for XFS support soon
- There are filesystem layer and lower layer issues here that I am not
  that familiar with. If you can then please enhance my patches.
- Mmap support could be done in a way that makes the mmap page size
  independent from the page cache order. There is no problem of mapping a
  4k section of a larger page cache page. This should leave mmap as is.
- Lets try to keep scope as small as possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
