Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 887F7C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:34:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B2B12087F
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:34:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="BSSSeKvG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B2B12087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8D386B0005; Tue,  7 May 2019 01:34:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3D106B0006; Tue,  7 May 2019 01:34:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2C626B0007; Tue,  7 May 2019 01:34:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C42A6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 01:34:22 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j36so4801524pgb.20
        for <linux-mm@kvack.org>; Mon, 06 May 2019 22:34:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gpEu/R/zuL+40/xQkNB9q888MjDlc7SeNKJ6L90C5Tk=;
        b=MUtX3+sEisyBU1pcnajGuQLISXJcLXydu9vLA253s7jPX9nJNVKcEDBXafqmWtiF1e
         ASRbZKyVpEygQh01Oyne/jlnqUErOaOvsVnlTipAiHWNNX8CHN3sTf8+GFASI3bMW2o7
         BlOeH66EGvV3HBfG3X3F6yV1mYcEcs6BB0RUQv0dZMLTIuQBlIKXmhLkJ9PjaNrQq/xe
         3XNZd3gL20ZKosbljc7752EOQCZrVOi25OH0cyo6i1+1j2FfjbBKHTxtpGHLA+KrlpyO
         hEex8/Csy1ryuuzRVlbbgei36mX48JELPse8LZveD7CFPR83w4ST8Kc+NdCPNoGY1lSB
         E7oA==
X-Gm-Message-State: APjAAAUnpqMt1ZEDKp9Qn2oQ81pzablxPwMC4i1EM6oSpqiTZ2wxwEpN
	iBMFY2nWnSQp6g/6tAR8n5ig4oEFoeZNrzHjsEq4vzM0juvZVwfmZXMyRmBc9lvACeo5ZaJd+ub
	T/1uZaw7/EVi0m6XATRu+NiVp6GGZUrB1xrbR5t6XgjJg+XF5anY9VeAq5eerErSOtw==
X-Received: by 2002:aa7:8e04:: with SMTP id c4mr38474895pfr.48.1557207261869;
        Mon, 06 May 2019 22:34:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCc1a7w0x/UlOddMYYwX8pxFTHoUKy7d0uaF++YMrNlutKpLzeoeLYbZEe22mwGIZWyqrF
X-Received: by 2002:aa7:8e04:: with SMTP id c4mr38474839pfr.48.1557207260946;
        Mon, 06 May 2019 22:34:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557207260; cv=none;
        d=google.com; s=arc-20160816;
        b=t4GHA7nWAgljcddO4wY3gImGM2dujgDOKij1sm/dOPqwjFMoPPdjwgGqn370h8/9sA
         D6LRmQ8GZgPLy5zxx2LVfYLyGMGeUAmm9XqYnGIy+dnpJ7Ctp3OozxmkhBJ5W3WFduYV
         MNCyfDnxtTcQFDbyosABxB9ICIMBnG/xTtOiqUfnuvdJo7qKkz1c/7PRtqRHTdB6RNtd
         HocFM5CVV8RZEmeZc4wLQzQcC0NMlhsbU9Od1WXd66USHv+eZJPZyM7245GeBhDqF4mE
         sR7qSufRd5Lc8TXqImL4/WQS75XtLwj95Iv9ESVUSbE7KnccytwucOTW0d3pniExdGXj
         JA0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=gpEu/R/zuL+40/xQkNB9q888MjDlc7SeNKJ6L90C5Tk=;
        b=G4PHtiZ0ApXSErT4u8OJLQ7p2szt/K80LXmuFmnNYpO8zqu4scR5ijvSLVLkAk1ymM
         CMxxaDE2dYBq2gxrai/7etG+scHaQCCvzuO/RkiE5eGiaYstL1cNv81EoL+kCttZ09uu
         h6gxXKoROy5XGK+6tYf1B5LOLkTZKH9C2OrfDJ0jv7OChoROenVCWp49GU/2v+jtNJIy
         eLopMcKxh/iL4k+gnXvdllzqQpOd1bcaTqqB5Lf7y6nY5HajG3zxmPqxn1R/ENDur3/J
         V0ZgWOEIvOAItnUUSF0MZNkE3NAD2cZojCUc/rc9u+ZeQayoMrFCHkdQpq7x1LBg03sq
         /Lkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BSSSeKvG;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i36si3871020pgl.491.2019.05.06.22.34.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 22:34:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BSSSeKvG;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1A3E721530;
	Tue,  7 May 2019 05:34:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557207260;
	bh=vtaTpa38CojxyPM1lfClIIF52DyI3e1yNz+U3k9Z5As=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=BSSSeKvGl6+wW6FMKan/jiZB3DTRfWoUG8en9QuuMNeqMAYJHr/AGzcJF9k5yeS10
	 WFJ1oFXR8eWr058PnDOIH8dlzIC7wlS+xot4Ym6x9QKWfIpYySgeY5UF+wIwS+BwAs
	 5ff27QLFJx7d7ZekiUNU6b3u9GO+4KDyQr65m0CA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Andrey Konovalov <andreyknvl@google.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 56/99] slab: store tagged freelist for off-slab slabmgmt
Date: Tue,  7 May 2019 01:31:50 -0400
Message-Id: <20190507053235.29900-56-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507053235.29900-1-sashal@kernel.org>
References: <20190507053235.29900-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit 1a62b18d51e5c5ecc0345c85bb9fef870ab721ed ]

Commit 51dedad06b5f ("kasan, slab: make freelist stored without tags")
calls kasan_reset_tag() for off-slab slab management object leading to
freelist being stored non-tagged.

However, cache_grow_begin() calls alloc_slabmgmt() which calls
kmem_cache_alloc_node() assigns a tag for the address and stores it in
the shadow address.  As the result, it causes endless errors below
during boot due to drain_freelist() -> slab_destroy() ->
kasan_slab_free() which compares already untagged freelist against the
stored tag in the shadow address.

Since off-slab slab management object freelist is such a special case,
just store it tagged.  Non-off-slab management object freelist is still
stored untagged which has not been assigned a tag and should not cause
any other troubles with this inconsistency.

  BUG: KASAN: double-free or invalid-free in slab_destroy+0x84/0x88
  Pointer tag: [ff], memory tag: [99]

  CPU: 0 PID: 1376 Comm: kworker/0:4 Tainted: G        W 5.1.0-rc3+ #8
  Hardware name: HPE Apollo 70             /C01_APACHE_MB         , BIOS L50_5.13_1.0.6 07/10/2018
  Workqueue: cgroup_destroy css_killed_work_fn
  Call trace:
   print_address_description+0x74/0x2a4
   kasan_report_invalid_free+0x80/0xc0
   __kasan_slab_free+0x204/0x208
   kasan_slab_free+0xc/0x18
   kmem_cache_free+0xe4/0x254
   slab_destroy+0x84/0x88
   drain_freelist+0xd0/0x104
   __kmem_cache_shrink+0x1ac/0x224
   __kmemcg_cache_deactivate+0x1c/0x28
   memcg_deactivate_kmem_caches+0xa0/0xe8
   memcg_offline_kmem+0x8c/0x3d4
   mem_cgroup_css_offline+0x24c/0x290
   css_killed_work_fn+0x154/0x618
   process_one_work+0x9cc/0x183c
   worker_thread+0x9b0/0xe38
   kthread+0x374/0x390
   ret_from_fork+0x10/0x18

  Allocated by task 1625:
   __kasan_kmalloc+0x168/0x240
   kasan_slab_alloc+0x18/0x20
   kmem_cache_alloc_node+0x1f8/0x3a0
   cache_grow_begin+0x4fc/0xa24
   cache_alloc_refill+0x2f8/0x3e8
   kmem_cache_alloc+0x1bc/0x3bc
   sock_alloc_inode+0x58/0x334
   alloc_inode+0xb8/0x164
   new_inode_pseudo+0x20/0xec
   sock_alloc+0x74/0x284
   __sock_create+0xb0/0x58c
   sock_create+0x98/0xb8
   __sys_socket+0x60/0x138
   __arm64_sys_socket+0xa4/0x110
   el0_svc_handler+0x2c0/0x47c
   el0_svc+0x8/0xc

  Freed by task 1625:
   __kasan_slab_free+0x114/0x208
   kasan_slab_free+0xc/0x18
   kfree+0x1a8/0x1e0
   single_release+0x7c/0x9c
   close_pdeo+0x13c/0x43c
   proc_reg_release+0xec/0x108
   __fput+0x2f8/0x784
   ____fput+0x1c/0x28
   task_work_run+0xc0/0x1b0
   do_notify_resume+0xb44/0x1278
   work_pending+0x8/0x10

  The buggy address belongs to the object at ffff809681b89e00
   which belongs to the cache kmalloc-128 of size 128
  The buggy address is located 0 bytes inside of
   128-byte region [ffff809681b89e00, ffff809681b89e80)
  The buggy address belongs to the page:
  page:ffff7fe025a06e00 count:1 mapcount:0 mapping:01ff80082000fb00
  index:0xffff809681b8fe04
  flags: 0x17ffffffc000200(slab)
  raw: 017ffffffc000200 ffff7fe025a06d08 ffff7fe022ef7b88 01ff80082000fb00
  raw: ffff809681b8fe04 ffff809681b80000 00000001000000e0 0000000000000000
  page dumped because: kasan: bad access detected
  page allocated via order 0, migratetype Unmovable, gfp_mask
  0x2420c0(__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE)
   prep_new_page+0x4e0/0x5e0
   get_page_from_freelist+0x4ce8/0x50d4
   __alloc_pages_nodemask+0x738/0x38b8
   cache_grow_begin+0xd8/0xa24
   ____cache_alloc_node+0x14c/0x268
   __kmalloc+0x1c8/0x3fc
   ftrace_free_mem+0x408/0x1284
   ftrace_free_init_mem+0x20/0x28
   kernel_init+0x24/0x548
   ret_from_fork+0x10/0x18

  Memory state around the buggy address:
   ffff809681b89c00: fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe
   ffff809681b89d00: fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe
  >ffff809681b89e00: 99 99 99 99 99 99 99 99 fe fe fe fe fe fe fe fe
                     ^
   ffff809681b89f00: 43 43 43 43 43 fe fe fe fe fe fe fe fe fe fe fe
   ffff809681b8a000: 6d fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe

Link: http://lkml.kernel.org/r/20190403022858.97584-1-cai@lca.pw
Fixes: 51dedad06b5f ("kasan, slab: make freelist stored without tags")
Signed-off-by: Qian Cai <cai@lca.pw>
Reviewed-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 2f2aa8eaf7d9..516df2d854ef 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2371,7 +2371,6 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
 		/* Slab management obj is off-slab. */
 		freelist = kmem_cache_alloc_node(cachep->freelist_cache,
 					      local_flags, nodeid);
-		freelist = kasan_reset_tag(freelist);
 		if (!freelist)
 			return NULL;
 	} else {
-- 
2.20.1

