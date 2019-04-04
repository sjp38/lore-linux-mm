Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB286C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B65220820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="uiRPlq6m";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="MyEaAGe4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B65220820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2DD86B0278; Wed,  3 Apr 2019 22:01:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB7576B0279; Wed,  3 Apr 2019 22:01:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A30F6B027A; Wed,  3 Apr 2019 22:01:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 763A06B0278
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:48 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id n13so968520qtn.6
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=3UekVlM57ISUTTW0lHTJU3YrdfYPvp3rAFH0aaIT5ag=;
        b=kUyg9pIEnUYP3SndR9qZ6BFzj894EBoZQVg0sFqaqXb7FA3yNHUIzVogCZolFunyle
         3DNhPpzUeBaiifLMW0JEgxmRy9vZeeB1PbdAikGPSt/Xnuzxsl6SgcTrQ+gf+NEfTWfy
         cRLR3EDnZvQsJeer3TKRxz8n1rUkxyqmzfT9GOKA+6HaWT0+evE0WU36hJZRWmKZdW2Y
         VTtxjGlN6ew84wzKHpjdl4ym9leZOh64Lu7syAJbYyioad9bDuvD6WJEymB+FlFTmbbK
         VceMExsupgoD8hCaf+XuHckiakSD1Sh1iyKkkh/ejsDp1nLsmRnlDuOdgxUjtjLNbwbW
         t5LQ==
X-Gm-Message-State: APjAAAWzK5rTN8zukbvGtVCUixrR9dl3amzUZuJA/eYzOiyATxxxAlYI
	PoA9D6ZJ32XTIwQZAJ8KAHzqJBhUmBlZd+olr+uqJFPllNabg+ylkVYgMZOGliC2+MLqwsbg/1j
	kZzmjc/59qGwBlgJv2QJnGjy9sHTqs2pHd1oxOa+b3uMVUm+spXHF4hLqQgGfNosqOQ==
X-Received: by 2002:ad4:42cb:: with SMTP id f11mr2557927qvr.53.1554343308262;
        Wed, 03 Apr 2019 19:01:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzICTZnPoNUzGTgHjMdy3lfEmPUWNJtE63FU8Wlz1rYnF04qx/iW2QYkQNqZ+bgTmZNGQcP
X-Received: by 2002:ad4:42cb:: with SMTP id f11mr2557898qvr.53.1554343307645;
        Wed, 03 Apr 2019 19:01:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343307; cv=none;
        d=google.com; s=arc-20160816;
        b=kcI1oydqN6jknELYB2oLbdwUy5xzyJuG22sAghKPeehr62TmNtK6WdTFUE5NriTcQv
         uz9BDA11RESMgAOqZSq4RWje5VXw6pDS1ZgqHVRBpfuPt/l7e3hlRaNDCzKsF/f4xbyh
         3eErEjbyAW5X02QHzNpXj1ULCOGZsW30IwvlZLU8W771xjgbzj93heFY/tvMV6RyNxtq
         RBFm7Yxr2nciFaFeoOhOEquvbG6zww66JeUDj5jK1J88x3Ru4FM1M4/ErF5pvHbWC9YK
         coZ+H73vAPpECVAn5eniIL0bMOYQaRmgrUJOqacYlGNmvryObK0avxnz9Eh7hB7yVm2x
         ZQOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=3UekVlM57ISUTTW0lHTJU3YrdfYPvp3rAFH0aaIT5ag=;
        b=Lns4QZHfLkg7/4u1NaDUt0un48PeB0dVC3jQFimUaReYrHlAYyo5St1gS33h40xlc0
         O5dLtDWPjLJRl8sCR2ErK7Qppv0QInmBrpZErxsybOitHIdFc3KgxDvzOT0w+PbPhDHl
         xOsW2HMhy7frGW3SvUUd4w8E1r91kfAGOFJXN+o5mhDeDioCrFspPWa+M35TYoUA2E5r
         +v/HMkMRYzPLnw5klE95lF/1i3T8yFnKljUSA/8DA1GP7ISXkljsorNk8B7ZeOlVgt2+
         YxNpBle99/6PKnQ94QrFhhCaVBoiULqJVrhI5elvW0ed5NaN9oU1l9ccUAGjBAPFkW/n
         52/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=uiRPlq6m;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=MyEaAGe4;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id t21si8256843qte.338.2019.04.03.19.01.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=uiRPlq6m;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=MyEaAGe4;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 6095422710;
	Wed,  3 Apr 2019 22:01:47 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:47 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=3UekVlM57ISUT
	TW0lHTJU3YrdfYPvp3rAFH0aaIT5ag=; b=uiRPlq6mC9oXMnQB8WtxkGcQ0xCOf
	b7pGGA5rxoUR/W1l4alCIYJEymTCa8ogRidqOt//14B9/kwgDh7KNV1tDBvlj/kl
	hLStBwtyoswGRgSzMavZE4wASV2KjaPBgA+nLU2FAvuRQfZV+bHPgxk0GLw5lmYD
	jxQkgxNJNeB58nNLj7OtRyBjx8E2RlRBGivEIb/+KigepHrhmsSm7KZlE6qOFsZt
	tU99yhvHWv3AztL49xrP3e8IgTnrpXO3AAyC2YUd5z6jA0bxIbKBsABPAnNjrvFY
	gTMDhTxYWCKPVCpyVxtE2GZq36+2Tgk0eW0gTk4nOR/hFrN7Zo8MwUc/Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=3UekVlM57ISUTTW0lHTJU3YrdfYPvp3rAFH0aaIT5ag=; b=MyEaAGe4
	6nOYVcgLm7Dnv4D9kfwxR4el7PgmlaH7vQjvG+tPatHJsI3xAPkNLbR7BtYveG/c
	6+muJpOgUMqIUvMKE8gjytzHGnEBQ+sdfi8rcp9AhOwc8JZjddR22gm52qp9xLsP
	wjGYGkNFVAKDlVLLalxRMCO8w2JAiMzYeMWpCgVihfnUP3+ve75nO0SawyavLK/g
	xhyxO1VhM2YadnHl9lkLwBEly6Mapb235uQS3Sfmt2gB7/xGTXnwLY4uQgBQMy9t
	itUHnRVMWx10CzCOp6vW54XgaDyggW8Dtx2jpaHNV9wZNmp5p3Xw9cQsZSn6PP8e
	UIsiQeAH+R6Kmg==
X-ME-Sender: <xms:i2WlXPifvyVwTTNfsv7n1GY6ZelcSbug0VQeuXzo0YgUAC4UyWE_rA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepudej
X-ME-Proxy: <xmx:i2WlXMNxmY3qsb5DXjucrDcxkSaZwvIQHKaAi1pfaZnzKqa4apFcUg>
    <xmx:i2WlXIkL7kyXtZnywnyWjEfgAaHy2Qf0cveZTDe0e30OQOWkLvRSFQ>
    <xmx:i2WlXLW020U8yC6ynYTYt59WIC-cz8t8z5XdDCngPS7GAAm6oFeyoQ>
    <xmx:i2WlXKl7Tc3-lPq9aHWAl-Yfw5rXmN3a1WXGpR47rklOp6fsfEYtdg>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 624C610393;
	Wed,  3 Apr 2019 22:01:45 -0400 (EDT)
From: Zi Yan <zi.yan@sent.com>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	Javier Cabezas <jcabezas@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 19/25] mempolicy: add MPOL_F_MEMCG flag, enforcing memcg memory limit.
Date: Wed,  3 Apr 2019 19:00:40 -0700
Message-Id: <20190404020046.32741-20-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404020046.32741-1-zi.yan@sent.com>
References: <20190404020046.32741-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

With MPOL_F_MEMCG set and MPOL_PREFERRED is used, we will enforce
the memory limit set in the corresponding memcg.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/uapi/linux/mempolicy.h |  3 ++-
 mm/mempolicy.c                 | 36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index eb6560e..a9d03e5 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -28,12 +28,13 @@ enum {
 /* Flags for set_mempolicy */
 #define MPOL_F_STATIC_NODES	(1 << 15)
 #define MPOL_F_RELATIVE_NODES	(1 << 14)
+#define MPOL_F_MEMCG		(1 << 13)
 
 /*
  * MPOL_MODE_FLAGS is the union of all possible optional mode flags passed to
  * either set_mempolicy() or mbind().
  */
-#define MPOL_MODE_FLAGS	(MPOL_F_STATIC_NODES | MPOL_F_RELATIVE_NODES)
+#define MPOL_MODE_FLAGS	(MPOL_F_STATIC_NODES | MPOL_F_RELATIVE_NODES | MPOL_F_MEMCG)
 
 /* Flags for get_mempolicy */
 #define MPOL_F_NODE	(1<<0)	/* return next IL mode instead of node mask */
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index af171cc..0e30049 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2040,6 +2040,42 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		goto out;
 	}
 
+	if (pol->mode == MPOL_PREFERRED && (pol->flags & MPOL_F_MEMCG)) {
+		struct task_struct *p = current;
+		struct mem_cgroup *memcg = mem_cgroup_from_task(p);
+		int nid = pol->v.preferred_node;
+		unsigned long nr_memcg_node_size;
+		struct mm_struct *mm = get_task_mm(p);
+		unsigned long nr_pages = hugepage?HPAGE_PMD_NR:1;
+
+		if (!(memcg && mm)) {
+			if (mm)
+				mmput(mm);
+			goto use_other_policy;
+		}
+
+		/* skip preferred node if mm_manage is going on */
+		if (test_bit(MMF_MM_MANAGE, &mm->flags)) {
+			nid = next_memory_node(nid);
+			if (nid == MAX_NUMNODES)
+				nid = first_memory_node;
+		}
+		mmput(mm);
+
+		nr_memcg_node_size = memcg_max_size_node(memcg, nid);
+
+		while (nr_memcg_node_size != ULONG_MAX &&
+			   nr_memcg_node_size <= (memcg_size_node(memcg, nid) + nr_pages)) {
+			if ((nid = next_memory_node(nid)) == MAX_NUMNODES)
+				nid = first_memory_node;
+			nr_memcg_node_size = memcg_max_size_node(memcg, nid);
+		}
+
+		mpol_cond_put(pol);
+		page = __alloc_pages_node(nid, gfp | __GFP_THISNODE, order);
+		goto out;
+	}
+use_other_policy:
 	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {
 		int hpage_node = node;
 
-- 
2.7.4

