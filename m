Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1AB6B000D
	for <linux-mm@kvack.org>; Tue, 22 May 2018 10:50:07 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id bd7-v6so12291436plb.20
        for <linux-mm@kvack.org>; Tue, 22 May 2018 07:50:07 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k7-v6si17061384pls.368.2018.05.22.07.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 07:50:06 -0700 (PDT)
Subject: [PATCH 07/11] mm, madvise_inject_error: fix page count leak
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 22 May 2018 07:40:09 -0700
Message-ID: <152700000922.24093.14813242965473482705.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152699997165.24093.12194490924829406111.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152699997165.24093.12194490924829406111.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: stable@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Andi Kleen <ak@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, hch@lst.de, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, tony.luck@intel.com

The madvise_inject_error() routine uses get_user_pages() to lookup the
pfn and other information for injected error, but it fails to release
that pin.

The dax-dma-vs-truncate warning catches this failure with the following
signature:

 Injecting memory failure for pfn 0x208900 at process virtual address 0x7f3908d00000
 Memory failure: 0x208900: reserved kernel page still referenced by 1 users
 Memory failure: 0x208900: recovery action for reserved kernel page: Failed
 WARNING: CPU: 37 PID: 9566 at fs/dax.c:348 dax_disassociate_entry+0x4e/0x90
 CPU: 37 PID: 9566 Comm: umount Tainted: G        W  OE     4.17.0-rc6+ #1900
 [..]
 RIP: 0010:dax_disassociate_entry+0x4e/0x90
 RSP: 0018:ffffc9000a9b3b30 EFLAGS: 00010002
 RAX: ffffea0008224000 RBX: 0000000000208a00 RCX: 0000000000208900
 RDX: 0000000000000001 RSI: ffff8804058c6160 RDI: 0000000000000008
 RBP: 000000000822000a R08: 0000000000000002 R09: 0000000000208800
 R10: 0000000000000000 R11: 0000000000208801 R12: ffff8804058c6168
 R13: 0000000000000000 R14: 0000000000000002 R15: 0000000000000001
 FS:  00007f4548027fc0(0000) GS:ffff880431d40000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: 000056316d5f8988 CR3: 00000004298cc000 CR4: 00000000000406e0
 Call Trace:
  __dax_invalidate_mapping_entry+0xab/0xe0
  dax_delete_mapping_entry+0xf/0x20
  truncate_exceptional_pvec_entries.part.14+0x1d4/0x210
  truncate_inode_pages_range+0x291/0x920
  ? kmem_cache_free+0x1f8/0x300
  ? lock_acquire+0x9f/0x200
  ? truncate_inode_pages_final+0x31/0x50
  ext4_evict_inode+0x69/0x740

Cc: <stable@vger.kernel.org>
Fixes: bd1ce5f91f54 ("HWPOISON: avoid grabbing the page count...")
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/madvise.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 4d3c922ea1a1..246fa4d4eee2 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -631,11 +631,13 @@ static int madvise_inject_error(int behavior,
 
 
 	for (; start < end; start += PAGE_SIZE << order) {
+		unsigned long pfn;
 		int ret;
 
 		ret = get_user_pages_fast(start, 1, 0, &page);
 		if (ret != 1)
 			return ret;
+		pfn = page_to_pfn(page);
 
 		/*
 		 * When soft offlining hugepages, after migrating the page
@@ -651,17 +653,20 @@ static int madvise_inject_error(int behavior,
 
 		if (behavior == MADV_SOFT_OFFLINE) {
 			pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n",
-						page_to_pfn(page), start);
+					pfn, start);
 
 			ret = soft_offline_page(page, MF_COUNT_INCREASED);
+			put_page(page);
 			if (ret)
 				return ret;
 			continue;
 		}
+		put_page(page);
+
 		pr_info("Injecting memory failure for pfn %#lx at process virtual address %#lx\n",
-						page_to_pfn(page), start);
+				pfn, start);
 
-		ret = memory_failure(page_to_pfn(page), MF_COUNT_INCREASED);
+		ret = memory_failure(pfn, MF_COUNT_INCREASED);
 		if (ret)
 			return ret;
 	}
