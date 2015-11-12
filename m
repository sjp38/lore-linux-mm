Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 506336B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 17:52:10 -0500 (EST)
Received: by igvi2 with SMTP id i2so25180186igv.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 14:52:10 -0800 (PST)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id u93si20888068ioi.92.2015.11.12.14.52.09
        for <linux-mm@kvack.org>;
        Thu, 12 Nov 2015 14:52:09 -0800 (PST)
Reply-To: <abanman@sgi.com>
From: Andrew Banman <abanman@sgi.com>
Subject: [BUG] init_memory_block adds missing sections to memory_block on
 large system
Message-ID: <56451820.7000904@sgi.com>
Date: Thu, 12 Nov 2015 16:52:16 -0600
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: abanman@sgi.com, Russ Anderson <rja@sgi.com>, Alex Thorlton <athorlton@sgi.com>, gregkh@linuxfoundation.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, nfont@austin.ibm.com, zhong@linux.vnet.ibm.com

When block_size_bytes is set to 2GB (default behavior for systems with 64GB
or more memory) init_memory_block runs the risk of adding non-present memory
sections to a memory block. These are sections that were not discovered in
sparse_init_one_section and so do not have a valid mem_map. Every pfn 
associated with missing sections is invalid:
!SECTION_MARKED_PRESENT -> !SECTION_HAS_MEM_MAP -> pfn_valid = false.

The problem is that memory blocks are set to always span the full number of
sections per block, which runs the risk of including missing memory sections:

drivers/base/memory.c
---
614        mem->start_section_nr =
615                        base_memory_block_id(scn_nr) * sections_per_block;
616        mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;

Relevant commits:
cb5e39b8 - drivers: base: refactor add_memory_section to add_memory_block
d3360164 - memory hotplug: Update phys_index to [start|end]_section_nr
56a3c655 - memory-hotplug: update documentation ... and remove end_phys_index

printks (below) show which memory sections are getting SECTION_MARKED_PRESENT
and SECTION_HAS_MEM_MAP, and the start & end section nums for each memory block.
You can see that memory16 spans sections 256 through 271, but sections 264 
through 511 are missing.

I found the problem when attempting to offline a block with missing sections.
In test_pages_in_a_zone, pfn_valid_within always returns 1 since
CONFIG_HOLES_IN_ZONE* is not set, thereby allowing an invalid pfn from a missing
section to make its way through the rest of the code - quickly causing the 
system to drop to kdb (see below). This was on the recent 4.3 kernel.

I can't tell what the desired behavior is supposed to be. Was it intended for 
memory blocks to have missing sections in order to give them a uniform number of
sections? If that's the case, then pfn_valid_within is dangerous. Or is what I
describe bad behavior, and memory blocks should only encompass valid pfns?
OR is the real bug the fact that we have missing sections to begin with?

Looking at the loops in memory_dev_init and add_memory_block you can see how
a lot can go wrong depending on what sections are missing. For example, say
section 48 was missing on this same system, then memory3 would start at
section 49 and end at 64. That wouldn't stop memory4 from also starting at
section 64. You could offline mem3 and take part of mem4 with it!

I've opened up a bugzilla where you can see more detailed output:
https://bugzilla.kernel.org/show_bug.cgi?id=107781

Any advice would be great,

Thanks!

Andrew Banman

*Note that CONFIG_HOLES_IN_ZONE is not available on x86, and setting it would be
inappropriate in this case - the problem is missing sections, not holes in a
MAX_ORDER_NR_PAGES.

--------------------------------------------------------------------------------

Boot printks show which memory sections are present (for brevity I've omitted
sequential runs of present sections):

8<---
[    0.000000] ABANMAN section 0 MARKED_PRESENT
...
[    0.000000] ABANMAN section 15 MARKED_PRESENT
[    0.000000] ABANMAN section 32 MARKED_PRESENT
[    0.000000] ABANMAN section 33 MARKED_PRESENT
...
[    0.000000] ABANMAN section 256 MARKED_PRESENT
[    0.000000] ABANMAN section 257 MARKED_PRESENT
[    0.000000] ABANMAN section 258 MARKED_PRESENT
[    0.000000] ABANMAN section 259 MARKED_PRESENT
[    0.000000] ABANMAN section 260 MARKED_PRESENT
[    0.000000] ABANMAN section 261 MARKED_PRESENT
[    0.000000] ABANMAN section 262 MARKED_PRESENT
[    0.000000] ABANMAN section 263 MARKED_PRESENT
[    0.000000] ABANMAN section 512 MARKED_PRESENT
[    0.000000] ABANMAN section 513 MARKED_PRESENT
...
[    0.000000] ABANMAN section 759 MARKED_PRESENT
...
[    1.154561] Using 2GB memory block size for large-memory system
[    1.161219] ABANMAN memory0 registered: sec_start 0 end 15
[    1.167395] ABANMAN memory2 registered: sec_start 32 end 47
[    1.173659] ABANMAN memory3 registered: sec_start 48 end 63
[    1.179928] ABANMAN memory4 registered: sec_start 64 end 79
[    1.186193] ABANMAN memory5 registered: sec_start 80 end 95
[    1.192450] ABANMAN memory6 registered: sec_start 96 end 111
[    1.198794] ABANMAN memory7 registered: sec_start 112 end 127
[    1.205225] ABANMAN memory8 registered: sec_start 128 end 143
[    1.211664] ABANMAN memory9 registered: sec_start 144 end 159
[    1.218102] ABANMAN memory10 registered: sec_start 160 end 175
[    1.224633] ABANMAN memory11 registered: sec_start 176 end 191
[    1.231166] ABANMAN memory12 registered: sec_start 192 end 207
[    1.237706] ABANMAN memory13 registered: sec_start 208 end 223
[    1.244235] ABANMAN memory14 registered: sec_start 224 end 239
[    1.250777] ABANMAN memory15 registered: sec_start 240 end 255
[    1.257304] ABANMAN memory16 registered: sec_start 256 end 271
[    1.263843] ABANMAN memory32 registered: sec_start 512 end 527
...
[    1.361838] ABANMAN memory47 registered: sec_start 752 end 767
--->8

Offlining memory16 crashes the system:

8<---
# echo 0 > /sys/devices/system/memory/memory16/online
Call Trace:
 [<ffffffff813af90f>] memory_subsys_offline+0x5f/0x90
 [<ffffffff8139acd5>] device_offline+0x85/0xb0
 [<ffffffff8139adda>] online_store+0x3a/0x80
 [<ffffffff8120f7ee>] sysfs_write_file+0xbe/0x140
 [<ffffffff811a1bd8>] vfs_write+0xb8/0x1e0
 [<ffffffff811a25f8>] SyS_write+0x48/0xa0
 [<ffffffff8151f289>] system_call_fastpath+0x16/0x1b
 [<00007ffff748dd30>] 0x7ffff748dd2f
--->8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
