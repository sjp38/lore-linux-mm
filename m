Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 245E36B13F0
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 02:55:01 -0500 (EST)
Received: by bkbzs2 with SMTP id zs2so7019093bkb.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 23:54:59 -0800 (PST)
Subject: [PATCH 0/4] radix-tree: iterating general cleanup
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 07 Feb 2012 11:54:56 +0400
Message-ID: <20120207074905.29797.60353.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org

This patchset implements common radix-tree iteration routine and
reworks page-cache lookup functions with using it.

radix_tree_gang_lookup_*slot() now mostly unused (the last user somethere in
drivers/sh/intc/virq.c), but they are exported, we cannot remove them for now.

Also there some shmem-related radix-tree hacks can be reworked,
radix_tree_locate_item() can be removed. I already have a few extra patches.

And as usual my lovely bloat-o-meter:

add/remove: 4/3 grow/shrink: 4/4 up/down: 1232/-964 (268)
function                                     old     new   delta
radix_tree_next_chunk                          -     499    +499
static.shmem_find_get_pages_and_swap           -     404    +404
find_get_pages_tag                           354     488    +134
find_get_pages                               362     438     +76
find_get_pages_contig                        345     407     +62
__kstrtab_radix_tree_next_chunk                -      22     +22
shmem_truncate_range                        1633    1652     +19
__ksymtab_radix_tree_next_chunk                -      16     +16
radix_tree_gang_lookup_tag_slot              208     180     -28
radix_tree_gang_lookup_tag                   247     207     -40
radix_tree_gang_lookup_slot                  204     162     -42
radix_tree_gang_lookup                       231     160     -71
__lookup                                     217       -    -217
__lookup_tag                                 242       -    -242
shmem_find_get_pages_and_swap                324       -    -324

---

Konstantin Khlebnikov (4):
      bitops: implement "optimized" __find_next_bit()
      radix-tree: introduce bit-optimized iterator
      radix-tree: rewrite gang lookup with using iterator
      radix-tree: use iterators in find_get_pages* functions


 include/asm-generic/bitops/find.h |   36 +++
 include/linux/radix-tree.h        |  129 +++++++++++
 lib/radix-tree.c                  |  422 +++++++++++++------------------------
 mm/filemap.c                      |   75 ++++---
 mm/shmem.c                        |   23 +-
 5 files changed, 375 insertions(+), 310 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
