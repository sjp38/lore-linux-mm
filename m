Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9C25C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 08:39:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6537920863
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 08:39:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6537920863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B35728E00D0; Mon, 11 Feb 2019 03:39:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE59C8E00C4; Mon, 11 Feb 2019 03:39:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AB948E00D0; Mon, 11 Feb 2019 03:39:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7AB8E00C4
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 03:39:01 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id n7so1231265pfa.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 00:39:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=Ui6t4AVIDeNKtFuVoZC8nCrXLKgQwhSum6wqTp2EnTU=;
        b=LZzPlS3jNZSZHbKzJjJWOC2YXkfHYCxfk3VRaewpf7sNk/siOu7kduZt10KTVU81t2
         3POjPXt3VX1I8qTr3ir+4PjwtOXOwEMLxFYUhw7QZa7WIxfxaL1E79Sxc218DMggHhCr
         LGE/tGjpz0nSD3R1RlBR48tbDmgoobU2XFBfyf5dT3UBGGKODK8TcYIV12z+BwL9URAG
         kIgGFOeHDdJlEX+U1KEnvEcOUEplq7PAZTcRudvuY+uUMAP8eFEhGNFXIk7+7uj9Jpdz
         DDK5x0EtY12sWua8BsW1G7KmOtNzUoB6YauEucnYw5Ln9Yt8d50PKODYp4lAYTSiA2A3
         Tdng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaQWXXLEK5Z7hCWtyULR4NnRSeKcHn+95w9NClNAdqdnD8hZ/l9
	6hL0uM6tB0XLNKhGK5uAWzX71a6CbF0B27wLIletVlctscWHBkgclGy11GirvX41UED/qFmnuAJ
	x7czjD6voHP6Tm0nshC56dNnNGXLCqERBMbZqCbCtRtGjHQfL/l2J0hxytliY/CUwDw==
X-Received: by 2002:a62:1212:: with SMTP id a18mr36544686pfj.217.1549874340789;
        Mon, 11 Feb 2019 00:39:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZP81tdRHiBZmkwhs7TRFQMk10g1wTw1I/Du66SKnMvYiVHDX2SUvPnoLVvikM+ZhDRg6Ma
X-Received: by 2002:a62:1212:: with SMTP id a18mr36544601pfj.217.1549874339048;
        Mon, 11 Feb 2019 00:38:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549874339; cv=none;
        d=google.com; s=arc-20160816;
        b=gvFbqfK2peYkBsNKHqDK3DlbI7Yl+UnmuZzPzkFYzbGIAYPwg8klZHHRiVcdZ8np1O
         vYCQgdP0jcYkUDL3jui/XS56zG7w7KaABJvVd2KjKlC0JGCVcmubPm6NPPlWNAk35JEM
         1fQjd9TKUXucKW0ICOBKSrzeUhRE+tllgAUA9W5OMDz5JTvxsHfIWtJCDF1riddgqBBD
         5XVNgeMEPT/kL2/i9ztuo1b4JTTAWkVUwrT0PTZ/3UkfT9O8Pou92n9n5VaS8aJlBpml
         VrFfgOSJIiDWURZVyHQWcPfQdH3a4MCmQHI71Lt8PuOqmj/tviTLFznlkAUXYYBHULgX
         yvGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=Ui6t4AVIDeNKtFuVoZC8nCrXLKgQwhSum6wqTp2EnTU=;
        b=FjIExKH+Rq394Nnz24iK7YBE/aSOkt2GqKXcJ7xS99VRwuwVgisfAMfPCH/nQ5s80o
         laUftrCrKFBgjnrHRd1C0pNzf8rqHf9p48FB3Rz7+q3J/qGnsHAKLJGwpWriSPSrBIGQ
         eqAlPT7rAfUDE/DFzxpiKSSQiyWYJ5weY4ieLVdNYclG4HsvJUN3ka+0C2oqhQU72jPh
         2P7IavK9s18rSARkv6MJpCfDNozLtxmIwXazNq+I/iDlnnpBc/am/Q4o3eEwjmjrcSB8
         cIK4NWVTK/2vZwzA/3m++R7j30MnX5zGsFyeKSn7e+vWGGeWV2AJeTcIZWUAuupUrSy/
         JioQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d14si9729967pll.30.2019.02.11.00.38.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 00:38:59 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 00:38:58 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,358,1544515200"; 
   d="scan'208";a="143222845"
Received: from yhuang-dev.sh.intel.com ([10.239.159.151])
  by fmsmga004.fm.intel.com with ESMTP; 11 Feb 2019 00:38:54 -0800
From: "Huang, Ying" <ying.huang@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Huang Ying <ying.huang@intel.com>,
	Hugh Dickins <hughd@google.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Rik van Riel <riel@redhat.com>,
	Jan Kara <jack@suse.cz>,
	Dave Jiang <dave.jiang@intel.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap operations
Date: Mon, 11 Feb 2019 16:38:46 +0800
Message-Id: <20190211083846.18888-1-ying.huang@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Huang Ying <ying.huang@intel.com>

When swapin is performed, after getting the swap entry information from
the page table, system will swap in the swap entry, without any lock held
to prevent the swap device from being swapoff.  This may cause the race
like below,

CPU 1				CPU 2
-----				-----
				do_swap_page
				  swapin_readahead
				    __read_swap_cache_async
swapoff				      swapcache_prepare
  p->swap_map = NULL		        __swap_duplicate
					  p->swap_map[?] /* !!! NULL pointer access */

Because swapoff is usually done when system shutdown only, the race may
not hit many people in practice.  But it is still a race need to be fixed.

To fix the race, get_swap_device() is added to check whether the specified
swap entry is valid in its swap device.  If so, it will keep the swap
entry valid via preventing the swap device from being swapoff, until
put_swap_device() is called.

Because swapoff() is very rare code path, to make the normal path runs as
fast as possible, disabling preemption + stop_machine() instead of
reference count is used to implement get/put_swap_device().  From
get_swap_device() to put_swap_device(), the preemption is disabled, so
stop_machine() in swapoff() will wait until put_swap_device() is called.

In addition to swap_map, cluster_info, etc.  data structure in the struct
swap_info_struct, the swap cache radix tree will be freed after swapoff,
so this patch fixes the race between swap cache looking up and swapoff
too.

Races between some other swap cache usages protected via disabling
preemption and swapoff are fixed too via calling stop_machine() between
clearing PageSwapCache() and freeing swap cache data structure.

Alternative implementation could be replacing disable preemption with
rcu_read_lock_sched and stop_machine() with synchronize_sched().

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Not-Nacked-by: Hugh Dickins <hughd@google.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrea Parri <andrea.parri@amarulasolutions.com>

Changelog:

v7:

- Rebased on patch: "mm, swap: bounds check swap_info accesses to avoid NULL derefs"

v6:

- Add more comments to get_swap_device() to make it more clear about
  possible swapoff or swapoff+swapon.

v5:

- Replace RCU with stop_machine()

v4:

- Use synchronize_rcu() in enable_swap_info() to reduce overhead of
  normal paths further.

v3:

- Re-implemented with RCU to reduce the overhead of normal paths

v2:

- Re-implemented with SRCU to reduce the overhead of normal paths.

- Avoid to check whether the swap device has been swapoff in
  get_swap_device().  Because we can check the origin of the swap
  entry to make sure the swap device hasn't bee swapoff.
---
 include/linux/swap.h |  13 +++-
 mm/memory.c          |   2 +-
 mm/swap_state.c      |  16 ++++-
 mm/swapfile.c        | 150 ++++++++++++++++++++++++++++++++++---------
 4 files changed, 145 insertions(+), 36 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 649529be91f2..aecd1430d0a9 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -175,8 +175,9 @@ enum {
 	SWP_PAGE_DISCARD = (1 << 10),	/* freed swap page-cluster discards */
 	SWP_STABLE_WRITES = (1 << 11),	/* no overwrite PG_writeback pages */
 	SWP_SYNCHRONOUS_IO = (1 << 12),	/* synchronous IO is efficient */
+	SWP_VALID	= (1 << 13),	/* swap is valid to be operated on? */
 					/* add others here before... */
-	SWP_SCANNING	= (1 << 13),	/* refcount in scan_swap_map */
+	SWP_SCANNING	= (1 << 14),	/* refcount in scan_swap_map */
 };
 
 #define SWAP_CLUSTER_MAX 32UL
@@ -460,7 +461,7 @@ extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
 extern int page_swapcount(struct page *);
-extern int __swap_count(struct swap_info_struct *si, swp_entry_t entry);
+extern int __swap_count(swp_entry_t entry);
 extern int __swp_swapcount(swp_entry_t entry);
 extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
@@ -470,6 +471,12 @@ extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
 extern void exit_swap_address_space(unsigned int type);
+extern struct swap_info_struct *get_swap_device(swp_entry_t entry);
+
+static inline void put_swap_device(struct swap_info_struct *si)
+{
+	preempt_enable();
+}
 
 #else /* CONFIG_SWAP */
 
@@ -576,7 +583,7 @@ static inline int page_swapcount(struct page *page)
 	return 0;
 }
 
-static inline int __swap_count(struct swap_info_struct *si, swp_entry_t entry)
+static inline int __swap_count(swp_entry_t entry)
 {
 	return 0;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 34ced1369883..9c0743c17c6c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2719,7 +2719,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 		struct swap_info_struct *si = swp_swap_info(entry);
 
 		if (si->flags & SWP_SYNCHRONOUS_IO &&
-				__swap_count(si, entry) == 1) {
+				__swap_count(entry) == 1) {
 			/* skip swapcache */
 			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
 							vmf->address);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 85245fdec8d9..61453f1faf72 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -310,8 +310,13 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
 			       unsigned long addr)
 {
 	struct page *page;
+	struct swap_info_struct *si;
 
+	si = get_swap_device(entry);
+	if (!si)
+		return NULL;
 	page = find_get_page(swap_address_space(entry), swp_offset(entry));
+	put_swap_device(si);
 
 	INC_CACHE_INFO(find_total);
 	if (page) {
@@ -354,8 +359,8 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr,
 			bool *new_page_allocated)
 {
-	struct page *found_page, *new_page = NULL;
-	struct address_space *swapper_space = swap_address_space(entry);
+	struct page *found_page = NULL, *new_page = NULL;
+	struct swap_info_struct *si;
 	int err;
 	*new_page_allocated = false;
 
@@ -365,7 +370,12 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * called after lookup_swap_cache() failed, re-calling
 		 * that would confuse statistics.
 		 */
-		found_page = find_get_page(swapper_space, swp_offset(entry));
+		si = get_swap_device(entry);
+		if (!si)
+			break;
+		found_page = find_get_page(swap_address_space(entry),
+					   swp_offset(entry));
+		put_swap_device(si);
 		if (found_page)
 			break;
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index cca8420b12db..8f92f36814fb 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -38,6 +38,7 @@
 #include <linux/export.h>
 #include <linux/swap_slots.h>
 #include <linux/sort.h>
+#include <linux/stop_machine.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -1186,6 +1187,64 @@ static unsigned char __swap_entry_free_locked(struct swap_info_struct *p,
 	return usage;
 }
 
+/*
+ * Check whether swap entry is valid in the swap device.  If so,
+ * return pointer to swap_info_struct, and keep the swap entry valid
+ * via preventing the swap device from being swapoff, until
+ * put_swap_device() is called.  Otherwise return NULL.
+ *
+ * Notice that swapoff or swapoff+swapon can still happen before the
+ * preempt_disable() in get_swap_device() or after the
+ * preempt_enable() in put_swap_device() if there isn't any other way
+ * to prevent swapoff, such as page lock, page table lock, etc.  The
+ * caller must be prepared for that.  For example, the following
+ * situation is possible.
+ *
+ *   CPU1				CPU2
+ *   do_swap_page()
+ *     ...				swapoff+swapon
+ *     __read_swap_cache_async()
+ *       swapcache_prepare()
+ *         __swap_duplicate()
+ *           // check swap_map
+ *     // verify PTE not changed
+ *
+ * In __swap_duplicate(), the swap_map need to be checked before
+ * changing partly because the specified swap entry may be for another
+ * swap device which has been swapoff.  And in do_swap_page(), after
+ * the page is read from the swap device, the PTE is verified not
+ * changed with the page table locked to check whether the swap device
+ * has been swapoff or swapoff+swapon.
+ */
+struct swap_info_struct *get_swap_device(swp_entry_t entry)
+{
+	struct swap_info_struct *si;
+	unsigned long type, offset;
+
+	if (!entry.val)
+		goto out;
+	type = swp_type(entry);
+	si = swap_type_to_swap_info(type);
+	if (!si)
+		goto bad_nofile;
+
+	preempt_disable();
+	if (!(si->flags & SWP_VALID))
+		goto unlock_out;
+	offset = swp_offset(entry);
+	if (offset >= si->max)
+		goto unlock_out;
+
+	return si;
+bad_nofile:
+	pr_err("%s: %s%08lx\n", __func__, Bad_file, entry.val);
+out:
+	return NULL;
+unlock_out:
+	preempt_enable();
+	return NULL;
+}
+
 static unsigned char __swap_entry_free(struct swap_info_struct *p,
 				       swp_entry_t entry, unsigned char usage)
 {
@@ -1357,11 +1416,18 @@ int page_swapcount(struct page *page)
 	return count;
 }
 
-int __swap_count(struct swap_info_struct *si, swp_entry_t entry)
+int __swap_count(swp_entry_t entry)
 {
+	struct swap_info_struct *si;
 	pgoff_t offset = swp_offset(entry);
+	int count = 0;
 
-	return swap_count(si->swap_map[offset]);
+	si = get_swap_device(entry);
+	if (si) {
+		count = swap_count(si->swap_map[offset]);
+		put_swap_device(si);
+	}
+	return count;
 }
 
 static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
@@ -1386,9 +1452,11 @@ int __swp_swapcount(swp_entry_t entry)
 	int count = 0;
 	struct swap_info_struct *si;
 
-	si = __swap_info_get(entry);
-	if (si)
+	si = get_swap_device(entry);
+	if (si) {
 		count = swap_swapcount(si, entry);
+		put_swap_device(si);
+	}
 	return count;
 }
 
@@ -2332,9 +2400,9 @@ static int swap_node(struct swap_info_struct *p)
 	return bdev ? bdev->bd_disk->node_id : NUMA_NO_NODE;
 }
 
-static void _enable_swap_info(struct swap_info_struct *p, int prio,
-				unsigned char *swap_map,
-				struct swap_cluster_info *cluster_info)
+static void setup_swap_info(struct swap_info_struct *p, int prio,
+			    unsigned char *swap_map,
+			    struct swap_cluster_info *cluster_info)
 {
 	int i;
 
@@ -2359,7 +2427,11 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	}
 	p->swap_map = swap_map;
 	p->cluster_info = cluster_info;
-	p->flags |= SWP_WRITEOK;
+}
+
+static void _enable_swap_info(struct swap_info_struct *p)
+{
+	p->flags |= SWP_WRITEOK | SWP_VALID;
 	atomic_long_add(p->pages, &nr_swap_pages);
 	total_swap_pages += p->pages;
 
@@ -2378,6 +2450,11 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	add_to_avail_list(p);
 }
 
+static int swap_onoff_stop(void *arg)
+{
+	return 0;
+}
+
 static void enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
 				struct swap_cluster_info *cluster_info,
@@ -2386,7 +2463,17 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
 	frontswap_init(p->type, frontswap_map);
 	spin_lock(&swap_lock);
 	spin_lock(&p->lock);
-	 _enable_swap_info(p, prio, swap_map, cluster_info);
+	setup_swap_info(p, prio, swap_map, cluster_info);
+	spin_unlock(&p->lock);
+	spin_unlock(&swap_lock);
+	/*
+	 * Guarantee swap_map, cluster_info, etc. fields are used
+	 * between get/put_swap_device() only if SWP_VALID bit is set
+	 */
+	stop_machine(swap_onoff_stop, NULL, cpu_online_mask);
+	spin_lock(&swap_lock);
+	spin_lock(&p->lock);
+	_enable_swap_info(p);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 }
@@ -2395,7 +2482,8 @@ static void reinsert_swap_info(struct swap_info_struct *p)
 {
 	spin_lock(&swap_lock);
 	spin_lock(&p->lock);
-	_enable_swap_info(p, p->prio, p->swap_map, p->cluster_info);
+	setup_swap_info(p, p->prio, p->swap_map, p->cluster_info);
+	_enable_swap_info(p);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 }
@@ -2498,6 +2586,17 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 
 	reenable_swap_slots_cache_unlock();
 
+	spin_lock(&swap_lock);
+	spin_lock(&p->lock);
+	p->flags &= ~SWP_VALID;		/* mark swap device as invalid */
+	spin_unlock(&p->lock);
+	spin_unlock(&swap_lock);
+	/*
+	 * wait for swap operations protected by get/put_swap_device()
+	 * to complete
+	 */
+	stop_machine(swap_onoff_stop, NULL, cpu_online_mask);
+
 	flush_work(&p->discard_work);
 
 	destroy_swap_extents(p);
@@ -3263,17 +3362,11 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 	unsigned char has_cache;
 	int err = -EINVAL;
 
-	if (non_swap_entry(entry))
-		goto out;
-
-	p = swp_swap_info(entry);
+	p = get_swap_device(entry);
 	if (!p)
-		goto bad_file;
-
-	offset = swp_offset(entry);
-	if (unlikely(offset >= p->max))
 		goto out;
 
+	offset = swp_offset(entry);
 	ci = lock_cluster_or_swap_info(p, offset);
 
 	count = p->swap_map[offset];
@@ -3319,11 +3412,9 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 unlock_out:
 	unlock_cluster_or_swap_info(p, ci);
 out:
+	if (p)
+		put_swap_device(p);
 	return err;
-
-bad_file:
-	pr_err("swap_dup: %s%08lx\n", Bad_file, entry.val);
-	goto out;
 }
 
 /*
@@ -3415,6 +3506,7 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 	struct page *list_page;
 	pgoff_t offset;
 	unsigned char count;
+	int ret = 0;
 
 	/*
 	 * When debugging, it's easier to use __GFP_ZERO here; but it's better
@@ -3422,15 +3514,15 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 	 */
 	page = alloc_page(gfp_mask | __GFP_HIGHMEM);
 
-	si = swap_info_get(entry);
+	si = get_swap_device(entry);
 	if (!si) {
 		/*
 		 * An acceptable race has occurred since the failing
-		 * __swap_duplicate(): the swap entry has been freed,
-		 * perhaps even the whole swap_map cleared for swapoff.
+		 * __swap_duplicate(): the swap device may be swapoff
 		 */
 		goto outer;
 	}
+	spin_lock(&si->lock);
 
 	offset = swp_offset(entry);
 
@@ -3448,9 +3540,8 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 	}
 
 	if (!page) {
-		unlock_cluster(ci);
-		spin_unlock(&si->lock);
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto out;
 	}
 
 	/*
@@ -3502,10 +3593,11 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 out:
 	unlock_cluster(ci);
 	spin_unlock(&si->lock);
+	put_swap_device(si);
 outer:
 	if (page)
 		__free_page(page);
-	return 0;
+	return ret;
 }
 
 /*
-- 
2.20.1

