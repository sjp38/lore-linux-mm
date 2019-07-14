Return-Path: <SRS0=QXz1=VL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D229FC73C66
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 03:53:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4359320644
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 03:53:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4359320644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C75C6B0003; Sat, 13 Jul 2019 23:53:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8789E8E0003; Sat, 13 Jul 2019 23:53:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 768088E0002; Sat, 13 Jul 2019 23:53:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5F96B0003
	for <linux-mm@kvack.org>; Sat, 13 Jul 2019 23:53:45 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r142so8174322pfc.2
        for <linux-mm@kvack.org>; Sat, 13 Jul 2019 20:53:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:sender:precedence:list-id
         :archived-at:list-archive:list-post:content-transfer-encoding;
        bh=4FgdNXv1nJUkz1LoZHSUkxMa7YToTy8PMBJRLbp42rs=;
        b=JqlFZHlAOvSRR6rKkGI/Dg+k/7HoXOye3/3OwJ0hfTut+8oKuIx0/1GfyMReZpEMsO
         E04lVzzJe8fuRZJ4xBsLtNoq7aT9JwEijVAutl31mpHZCz1redkDXiF4GV1i7NcENWgJ
         xdQguqyYUBuCU5jjFbFwT/4Ox6kX3o5C2P0jeneof9Qvo9nn1rf9JMLBjDXYM3MnEeU4
         pu69qnJXsaf/FghCXcR8bgoP3WykiHrDjH7N6y0TUbz+4nuztXy66npjvEFDhxFSejoD
         oSqwDoii+PRjZv83GI58XaNIJWVJS+70GP7GdHeiKTKzdLGwxoaIYYy0V5gzL5Sogn7I
         RbvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAVl//TUM0FNx30avuM2MDUqZO5t91USsEoMqC0qIEqYKLrvFES8
	2UHsangJnhFAMRClD6aqeGldM9ZLJTIWFsXuN6mhGZDe9JcPrsoLZjCIyQYBPHZK5AykjrL8LFc
	To2iykb4cDF+rk7DN6l9lYtbeZl1dfPB5fOvJLeygnGp2Y0bxu9eY+l1u89jwySgIsA==
X-Received: by 2002:a17:902:be15:: with SMTP id r21mr20389722pls.293.1563076424691;
        Sat, 13 Jul 2019 20:53:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx03ZLAR9+9ow7KCe4kcdjeQPwdE6t7FZ/TQo/uxNfo5iDN+I6TLjp0WgqQ6hsK8CGy5Wwl
X-Received: by 2002:a17:902:be15:: with SMTP id r21mr20389650pls.293.1563076423232;
        Sat, 13 Jul 2019 20:53:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563076423; cv=none;
        d=google.com; s=arc-20160816;
        b=McsgAmzf97WBIu3O9LsH7T24CrmwykL9EvckwOdWo7jceDgzFbmHBUfeiya/1uTU+i
         kje5KOCnf9VXyiv9cIFd7g0I5fnDXlg5FaW9qKlQPwhKoOXYjAx5PU00uQ707SzTZhyr
         OYb5xZPHgtHeIR+4ZSuJkF6OPLu9A8lBm91gnSTC9UcQ+QwlZZ6ALDQydRdF9K6VBbFL
         Z5aeJn2Ar+nwVTwit1G1E1zyzSa2eeSEa9OJ4ULpoYb6lUpKmTy7acRslIEMLJeWPdhC
         /awrKtBnQbrLX/IbVWVN1FU6GlU2CfMnrmtVk4LvOGweqENoGIv20Fe25ACI2hoEJpnX
         6CIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:sender:mime-version:message-id:date:subject:cc
         :to:from;
        bh=4FgdNXv1nJUkz1LoZHSUkxMa7YToTy8PMBJRLbp42rs=;
        b=JewePbCHbXa7SJn2oqAtZBf2SiDQ8en7h2j0kEhIcUr5WjkbO9dIsTkk9ogrcDe/hG
         HLL9+W8XtpSpGu9VF9ZsIFbKdwjtGZF0uiNY0T/MBfILrUdmptVHnROifvAwCIgpe/Gc
         hLR5aCJUqbdA7o70+PHRDsdrMa80Sf+o53bazikYguS9MbL6r4xEzpn22i/cQEwxtSim
         r6/Y803ljwVU00hfq8p6/uN8GsBsaG9yOC9k+MI8vm/Km1PedvMftqSBK3R2KykF6Jql
         VNsfMCxyyS6bdb24DQKUZAsJcVVysb69fWol4JLzB2vNNZtLNXBHPU54daVcak2mCSGb
         YgWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-167.sinamail.sina.com.cn (mail3-167.sinamail.sina.com.cn. [202.108.3.167])
        by mx.google.com with SMTP id t29si7626739pfq.272.2019.07.13.20.53.42
        for <linux-mm@kvack.org>;
        Sat, 13 Jul 2019 20:53:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) client-ip=202.108.3.167;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([221.219.5.31])
	by sina.com with ESMTP
	id 5D2AA74300000FC5; Sun, 14 Jul 2019 11:53:41 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 47069245089480
From: Hillf Danton <hdanton@sina.com>
To: Qian Cai <cai@lca.pw>
Cc: Yang Shi <yang.shi@linux.alibaba.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	akpm@linux-foundation.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: list corruption in deferred_split_scan()
Date: Sun, 14 Jul 2019 11:53:30 +0800
Message-Id: <1562795006.8510.19.camel@lca.pw>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/1562795006.8510.19.camel@lca.pw/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190714035330.iKOxudnCUJO89vCtOVq4vroT26dVDoPiuwsbnxo5gGY@z>


On Wed, 10 Jul 2019 14:43:28 -0700 (PDT) Qian Cai wrote:
> 
> Running LTP oom01 test case with swap triggers a crash below. Revert the series
> "Make deferred split shrinker memcg aware" [1] seems fix the issue.
> 
> aefde94195ca mm: thp: make deferred split shrinker memcg aware
> cf402211cacc mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix-2-fix
> ca37e9e5f18d mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix-2
> 5f419d89cab4 mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix
> c9d49e69e887 mm: shrinker: make shrinker not depend on memcg kmem
> 1c0af4b86bcf mm: move mem_cgroup_uncharge out of __page_cache_release()
> 4e050f2df876 mm: thp: extract split_queue_* into a struct
> 
> [1] https://lore.kernel.org/linux-mm/1561507361-59349-1-git-send-email-yang.shi@linux.alibaba.com/
> 
> [ 1145.730682][ T5764] list_del corruption, ffffea00251c8098->next is LIST_POISON1 (dead000000000100)
> [ 1145.739763][ T5764] ------------[ cut here ]------------
> [ 1145.745126][ T5764] kernel BUG at lib/list_debug.c:47!
> [ 1145.750320][ T5764] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN NOPTI
> [ 1145.757513][ T5764] CPU: 1 PID: 5764 Comm: oom01 Tainted: G        W         5.2.0-next-20190710+ #7
> [ 1145.766709][ T5764] Hardware name: HPE ProLiant DL385 Gen10/ProLiant DL385 Gen10, BIOS A40 01/25/2019
> [ 1145.776000][ T5764] RIP: 0010:__list_del_entry_valid.cold.0+0x12/0x4a
> [ 1145.782491][ T5764] Code: c7 40 5a 33 af e8 ac fe bc ff 0f 0b 48 c7 c7 80 9e
> a1 af e8 f6 4c 01 00 4c 89 ea 48 89 de 48 c7 c7 20 59 33 af e8 8c fe bc ff <0f>
> 0b 48 c7 c7 40 9f a1 af e8 d6 4c 01 00 4c 89 e2 48 89 de 48 c7
> [ 1145.802078][ T5764] RSP: 0018:ffff888514d773c0 EFLAGS: 00010082
> [ 1145.808042][ T5764] RAX: 000000000000004e RBX: ffffea00251c8098 RCX: ffffffffae95d318
> [ 1145.815923][ T5764] RDX: 0000000000000000 RSI: 0000000000000008 RDI: ffff8888440bd380
> [ 1145.823806][ T5764] RBP: ffff888514d773d8 R08: ffffed1108817a71 R09: ffffed1108817a70
> [ 1145.831689][ T5764] R10: ffffed1108817a70 R11: ffff8888440bd387 R12: dead000000000122
> [ 1145.839571][ T5764] R13: dead000000000100 R14: ffffea00251c8034 R15: dead000000000100
> [ 1145.847455][ T5764] FS:  00007f765ad4d700(0000) GS:ffff888844080000(0000) knlGS:0000000000000000
> [ 1145.856299][ T5764] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1145.862784][ T5764] CR2: 00007f8cebec7000 CR3: 0000000459338000 CR4: 00000000001406a0
> [ 1145.870664][ T5764] Call Trace:
> [ 1145.873835][ T5764]  deferred_split_scan+0x337/0x740
> [ 1145.878835][ T5764]  ? split_huge_page_to_list+0xe30/0xe30
> [ 1145.884364][ T5764]  ? __radix_tree_lookup+0x12d/0x1e0
> [ 1145.889539][ T5764]  ? node_tag_get.part.0.constprop.6+0x40/0x40
> [ 1145.895592][ T5764]  do_shrink_slab+0x244/0x5a0
> [ 1145.900159][ T5764]  shrink_slab+0x253/0x440
> [ 1145.904462][ T5764]  ? unregister_shrinker+0x110/0x110
> [ 1145.909641][ T5764]  ? kasan_check_read+0x11/0x20
> [ 1145.914383][ T5764]  ? mem_cgroup_protected+0x20f/0x260
> [ 1145.919645][ T5764]  shrink_node+0x31e/0xa30
> [ 1145.923949][ T5764]  ? shrink_node_memcg+0x1560/0x1560
> [ 1145.929126][ T5764]  ? ktime_get+0x93/0x110
> [ 1145.933340][ T5764]  do_try_to_free_pages+0x22f/0x820
> [ 1145.938429][ T5764]  ? shrink_node+0xa30/0xa30
> [ 1145.942906][ T5764]  ? kasan_check_read+0x11/0x20
> [ 1145.947647][ T5764]  ? check_chain_key+0x1df/0x2e0
> [ 1145.952474][ T5764]  try_to_free_pages+0x242/0x4d0
> [ 1145.957299][ T5764]  ? do_try_to_free_pages+0x820/0x820
> [ 1145.962566][ T5764]  __alloc_pages_nodemask+0x9ce/0x1bc0
> [ 1145.967917][ T5764]  ? kasan_check_read+0x11/0x20
> [ 1145.972657][ T5764]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
> [ 1145.977920][ T5764]  ? kasan_check_read+0x11/0x20
> [ 1145.982659][ T5764]  ? check_chain_key+0x1df/0x2e0
> [ 1145.987487][ T5764]  ? do_anonymous_page+0x343/0xe30
> [ 1145.992489][ T5764]  ? lock_downgrade+0x390/0x390
> [ 1145.997230][ T5764]  ? __count_memcg_events+0x8b/0x1c0
> [ 1146.002404][ T5764]  ? kasan_check_read+0x11/0x20
> [ 1146.007145][ T5764]  ? __lru_cache_add+0x122/0x160
> [ 1146.011974][ T5764]  alloc_pages_vma+0x89/0x2c0
> [ 1146.016538][ T5764]  do_anonymous_page+0x3e1/0xe30
> [ 1146.021367][ T5764]  ? __update_load_avg_cfs_rq+0x2c/0x490
> [ 1146.026893][ T5764]  ? finish_fault+0x120/0x120
> [ 1146.031461][ T5764]  ? call_function_interrupt+0xa/0x20
> [ 1146.036724][ T5764]  handle_pte_fault+0x457/0x12c0
> [ 1146.041552][ T5764]  __handle_mm_fault+0x79a/0xa50
> [ 1146.046378][ T5764]  ? vmf_insert_mixed_mkwrite+0x20/0x20
> [ 1146.051817][ T5764]  ? kasan_check_read+0x11/0x20
> [ 1146.056557][ T5764]  ? __count_memcg_events+0x8b/0x1c0
> [ 1146.061732][ T5764]  handle_mm_fault+0x17f/0x370
> [ 1146.066386][ T5764]  __do_page_fault+0x25b/0x5d0
> [ 1146.071037][ T5764]  do_page_fault+0x4c/0x2cf
> [ 1146.075426][ T5764]  ? page_fault+0x5/0x20
> [ 1146.079553][ T5764]  page_fault+0x1b/0x20
> [ 1146.083594][ T5764] RIP: 0033:0x410be0
> [ 1146.087373][ T5764] Code: 89 de e8 e3 23 ff ff 48 83 f8 ff 0f 84 86 00 00 00
> 48 89 c5 41 83 fc 02 74 28 41 83 fc 03 74 62 e8 95 29 ff ff 31 d2 48 98 90 <c6>
> 44 15 00 07 48 01 c2 48 39 d3 7f f3 31 c0 5b 5d 41 5c c3 0f 1f
> [ 1146.106959][ T5764] RSP: 002b:00007f765ad4cec0 EFLAGS: 00010206
> [ 1146.112921][ T5764] RAX: 0000000000001000 RBX: 00000000c0000000 RCX: 00007f98f2674497
> [ 1146.120804][ T5764] RDX: 0000000001d95000 RSI: 00000000c0000000 RDI: 0000000000000000
> [ 1146.128687][ T5764] RBP: 00007f74d9d4c000 R08: 00000000ffffffff R09: 0000000000000000
> [ 1146.136569][ T5764] R10: 0000000000000022 R11: 000000000
> [ 1147.588181][ T5764] Shutting down cpus with NMI
> [ 1147.592756][ T5764] Kernel Offset: 0x2d400000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
> [ 1147.604414][ T5764] ---[ end Kernel panic - not syncing: Fatal exception ]---


Ignore the noise if there is no chance you think to corrupt the local list walk
in some way like:

	CPU0				CPU1
	----				----
	take no lock			spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
	list_for_each_safe(pos, next,
				&list)
					list_del(page_deferred_list(page));
	page = list_entry((void *)pos,
		struct page, mapping);
					spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);


--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2765,7 +2765,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
 		if (!list_empty(page_deferred_list(head))) {
 			ds_queue->split_queue_len--;
-			list_del(page_deferred_list(head));
+			list_del_init(page_deferred_list(head));
 		}
 		if (mapping)
 			__dec_node_page_state(page, NR_SHMEM_THPS);
@@ -2814,7 +2814,7 @@ void free_transhuge_page(struct page *page)
 	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
 	if (!list_empty(page_deferred_list(page))) {
 		ds_queue->split_queue_len--;
-		list_del(page_deferred_list(page));
+		list_del_init(page_deferred_list(page));
 	}
 	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
 	free_compound_page(page);
--

The major important is listed above; the minor trivial part below.
Both are only for thought collectings.

--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2869,9 +2869,8 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 	struct pglist_data *pgdata = NODE_DATA(sc->nid);
 	struct deferred_split *ds_queue;
 	unsigned long flags;
-	LIST_HEAD(list), *pos, *next;
 	struct page *page;
-	int split = 0;
+	unsigned long nr_split = 0;
 
 #ifdef CONFIG_MEMCG
 	if (sc->memcg)
@@ -2884,44 +2883,44 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 
 	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
 	/* Take pin on all head pages to avoid freeing them under us */
-	list_for_each_safe(pos, next, &ds_queue->split_queue) {
-		page = list_entry((void *)pos, struct page, mapping);
+	while (sc->nr_to_scan && !list_empty(&ds_queue->split_queue)) {
+		bool locked, pinned;
+
+		page = list_first_entry(&ds_queue->split_queue, struct page,
+						mapping);
 		page = compound_head(page);
+
 		if (get_page_unless_zero(page)) {
-			list_move(page_deferred_list(page), &list);
+			pinned = true;
+			locked = trylock_page(page);
 		} else {
 			/* We lost race with put_compound_page() */
-			list_del_init(page_deferred_list(page));
-			ds_queue->split_queue_len--;
+			pinned = false;
+			locked = false;
+		}
+		list_del_init(page_deferred_list(page));
+		ds_queue->split_queue_len--;
+		--sc->nr_to_scan;
+		if (!pinned)
+			continue;
+		spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
+		if (locked) {
+			if (!split_huge_page(page))
+				nr_split++;
+			unlock_page(page);
 		}
-		if (!--sc->nr_to_scan)
-			break;
-	}
-	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
-
-	list_for_each_safe(pos, next, &list) {
-		page = list_entry((void *)pos, struct page, mapping);
-		if (!trylock_page(page))
-			goto next;
-		/* split_huge_page() removes page from list on success */
-		if (!split_huge_page(page))
-			split++;
-		unlock_page(page);
-next:
 		put_page(page);
+		spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
 	}
-
-	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
-	list_splice_tail(&list, &ds_queue->split_queue);
 	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
 
 	/*
 	 * Stop shrinker if we didn't split any page, but the queue is empty.
 	 * This can happen if pages were freed under us.
 	 */
-	if (!split && list_empty(&ds_queue->split_queue))
+	if (!nr_split && list_empty(&ds_queue->split_queue))
 		return SHRINK_STOP;
-	return split;
+	return nr_split;
 }
 
 static struct shrinker deferred_split_shrinker = {
--

