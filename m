Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1317AC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 09:46:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C47BA206BB
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 09:46:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C47BA206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5755A6B0003; Tue,  3 Sep 2019 05:46:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FCEB6B0005; Tue,  3 Sep 2019 05:46:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C33A6B0006; Tue,  3 Sep 2019 05:46:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0015.hostedemail.com [216.40.44.15])
	by kanga.kvack.org (Postfix) with ESMTP id 163836B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 05:46:05 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 94ACF2195D
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 09:46:04 +0000 (UTC)
X-FDA: 75893128248.25.map72_8c03bd385c003
X-HE-Tag: map72_8c03bd385c003
X-Filterd-Recvd-Size: 8320
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 09:46:02 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1F1C228;
	Tue,  3 Sep 2019 02:46:01 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.42.170])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id CDC9C3F59C;
	Tue,  3 Sep 2019 02:45:53 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	catalin.marinas@arm.com,
	will@kernel.org
Cc: mark.rutland@arm.com,
	mhocko@suse.com,
	ira.weiny@intel.com,
	david@redhat.com,
	cai@lca.pw,
	logang@deltatee.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	mgorman@techsingularity.net,
	osalvador@suse.de,
	ard.biesheuvel@arm.com,
	steve.capper@arm.com,
	broonie@kernel.org,
	valentin.schneider@arm.com,
	Robin.Murphy@arm.com,
	steven.price@arm.com,
	suzuki.poulose@arm.com
Subject: [PATCH V7 0/3] arm64/mm: Enable memory hot remove
Date: Tue,  3 Sep 2019 15:15:55 +0530
Message-Id: <1567503958-25831-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series enables memory hot remove on arm64 after fixing a memblock
removal ordering problem in generic try_remove_memory() and a possible
arm64 platform specific kernel page table race condition. This series
is based on the following current arm64 tree.

git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git (for-next/core)

Concurrent vmalloc() and hot-remove conflict:

As pointed out earlier on the v5 thread [2] there can be potential conflict
between concurrent vmalloc() and memory hot-remove operation. The problem here
is caused by inadequate locking in vmalloc() which protects installation of a
page table page but not the walk or the leaf entry modification.

Lets not free page table pages if any for vmemmap mappings after unmapping
it's virtual range if vmalloc and vmemap range overlaps. The only downside
here is that some page table pages might remain empty and unused until next
memory hot-add operation for the same memory range. But as mentioned earlier
those will be minimal.

Only the following two configurations have vmalloc and vmemmap overlap where
free_empty_tables() function is not getting called.

1. 4K page size with 48 bit VA space
2. 16K page size with 48 bit VA space

Testing:

Memory hot remove has been tested on arm64 for 4K, 16K, 64K page config
options with all possible CONFIG_ARM64_VA_BITS and CONFIG_PGTABLE_LEVELS
combinations. It is only build tested on non-arm64 platforms.

Changes in V7:

- vmalloc_vmemmap_overlap gets evaluated early during boot for a given config
- free_empty_tables() gets conditionally called based on vmalloc_vmemmap_overlap

Changes in V6: (https://lkml.org/lkml/2019/7/15/36)

- Implemented most of the suggestions from Mark Rutland
- Added <linux/memory_hotplug.h> in ptdump
- remove_pagetable() now has two distinct passes over the kernel page table
- First pass unmap_hotplug_range() removes leaf level entries at all level
- Second pass free_empty_tables() removes empty page table pages
- Kernel page table lock has been dropped completely
- vmemmap_free() does not call freee_empty_tables() to avoid conflict with vmalloc()
- All address range scanning are converted to do {} while() loop
- Added 'unsigned long end' in __remove_pgd_mapping()
- Callers need not provide starting pointer argument to free_[pte|pmd|pud]_table() 
- Drop the starting pointer argument from free_[pte|pmd|pud]_table() functions
- Fetching pxxp[i] in free_[pte|pmd|pud]_table() is wrapped around in READ_ONCE()
- free_[pte|pmd|pud]_table() now computes starting pointer inside the function
- Fixed TLB handling while freeing huge page section mappings at PMD or PUD level
- Added WARN_ON(!page) in free_hotplug_page_range()
- Added WARN_ON(![pm|pud]_table(pud|pmd)) when there is no section mapping

- [PATCH 1/3] mm/hotplug: Reorder memblock_[free|remove]() calls in try_remove_memory()
- Request earlier for separate merger (https://patchwork.kernel.org/patch/10986599/)
- s/__remove_memory/try_remove_memory in the subject line
- s/arch_remove_memory/memblock_[free|remove] in the subject line
- A small change in the commit message as re-order happens now for memblock remove
  functions not for arch_remove_memory()

Changes in V5: (https://lkml.org/lkml/2019/5/29/218)

- Have some agreement [1] over using memory_hotplug_lock for arm64 ptdump
- Change 7ba36eccb3f8 ("arm64/mm: Inhibit huge-vmap with ptdump") already merged
- Dropped the above patch from this series
- Fixed indentation problem in arch_[add|remove]_memory() as per David
- Collected all new Acked-by tags
 
Changes in V4: (https://lkml.org/lkml/2019/5/20/19)

- Implemented most of the suggestions from Mark Rutland
- Interchanged patch [PATCH 2/4] <---> [PATCH 3/4] and updated commit message
- Moved CONFIG_PGTABLE_LEVELS inside free_[pud|pmd]_table()
- Used READ_ONCE() in missing instances while accessing page table entries
- s/p???_present()/p???_none() for checking valid kernel page table entries
- WARN_ON() when an entry is !p???_none() and !p???_present() at the same time
- Updated memory hot-remove commit message with additional details as suggested
- Rebased the series on 5.2-rc1 with hotplug changes from David and Michal Hocko
- Collected all new Acked-by tags

Changes in V3: (https://lkml.org/lkml/2019/5/14/197)
 
- Implemented most of the suggestions from Mark Rutland for remove_pagetable()
- Fixed applicable PGTABLE_LEVEL wrappers around pgtable page freeing functions
- Replaced 'direct' with 'sparse_vmap' in remove_pagetable() with inverted polarity
- Changed pointer names ('p' at end) and removed tmp from iterations
- Perform intermediate TLB invalidation while clearing pgtable entries
- Dropped flush_tlb_kernel_range() in remove_pagetable()
- Added flush_tlb_kernel_range() in remove_pte_table() instead
- Renamed page freeing functions for pgtable page and mapped pages
- Used page range size instead of order while freeing mapped or pgtable pages
- Removed all PageReserved() handling while freeing mapped or pgtable pages
- Replaced XXX_index() with XXX_offset() while walking the kernel page table
- Used READ_ONCE() while fetching individual pgtable entries
- Taken overall init_mm.page_table_lock instead of just while changing an entry
- Dropped previously added [pmd|pud]_index() which are not required anymore
- Added a new patch to protect kernel page table race condition for ptdump
- Added a new patch from Mark Rutland to prevent huge-vmap with ptdump

Changes in V2: (https://lkml.org/lkml/2019/4/14/5)

- Added all received review and ack tags
- Split the series from ZONE_DEVICE enablement for better review
- Moved memblock re-order patch to the front as per Robin Murphy
- Updated commit message on memblock re-order patch per Michal Hocko
- Dropped [pmd|pud]_large() definitions
- Used existing [pmd|pud]_sect() instead of earlier [pmd|pud]_large()
- Removed __meminit and __ref tags as per Oscar Salvador
- Dropped unnecessary 'ret' init in arch_add_memory() per Robin Murphy
- Skipped calling into pgtable_page_dtor() for linear mapping page table
  pages and updated all relevant functions

Changes in V1: (https://lkml.org/lkml/2019/4/3/28)

References:

[1] https://lkml.org/lkml/2019/5/28/584
[2] https://lkml.org/lkml/2019/6/11/709

Anshuman Khandual (3):
  mm/hotplug: Reorder memblock_[free|remove]() calls in try_remove_memory()
  arm64/mm: Hold memory hotplug lock while walking for kernel page table dump
  arm64/mm: Enable memory hot remove

 arch/arm64/Kconfig              |   3 +
 arch/arm64/include/asm/memory.h |   1 +
 arch/arm64/mm/mmu.c             | 338 +++++++++++++++++++++++++++++++-
 arch/arm64/mm/ptdump_debugfs.c  |   4 +
 mm/memory_hotplug.c             |   4 +-
 5 files changed, 339 insertions(+), 11 deletions(-)

-- 
2.20.1


