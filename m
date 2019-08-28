Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4A05C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:18:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFF4E217F5
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:18:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFF4E217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BD646B000C; Wed, 28 Aug 2019 03:18:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 344146B000D; Wed, 28 Aug 2019 03:18:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20BD96B000E; Wed, 28 Aug 2019 03:18:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0205.hostedemail.com [216.40.44.205])
	by kanga.kvack.org (Postfix) with ESMTP id EDF946B000C
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 03:18:43 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 8E183180AD81B
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:18:43 +0000 (UTC)
X-FDA: 75870984126.21.noise44_693beed42334d
X-HE-Tag: noise44_693beed42334d
X-Filterd-Recvd-Size: 4812
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:18:43 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id z51so1763379edz.13
        for <linux-mm@kvack.org>; Wed, 28 Aug 2019 00:18:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=w4tygEA7hdMTAmlKH0W1U33PjlTpQI6lJR6+C+DfktA=;
        b=IK8Z0sUPeAU6hbfFw2XzrCIa8Q/1xv/iAlKrIP/KAKAaNVJ8xXoRMwhkj67T7xflBT
         oiCmzzZCL6RqWW/RzUoJICGNHrL53cizbzFBFGPkC4+NPCeF2oboZo/r6SxEk4cMlbr8
         J3/ZtMVmxXCXU0DaKyBUYWYy2gT/Ks9crTbcehAkSCt627qrLreAAXe2CIpeKT8DTDhd
         RBD8vaWiEgwxwi/uBCvmagJS2fRtbjhP7u/63/V/FUI1bkfYRefRkPbkRMyr06YTbgWz
         prXgtRq1wtFWzAJs6NAGSaUhLi1LVZyv5+UjP9iqGIWhTIaVp1+v4lu18PsKNSLx9Wo7
         Qnsg==
X-Gm-Message-State: APjAAAXYAWbot47Qg+a/tvv0is4SEXordyXesmphoBZWg/rb94PoYySN
	8gDeKifRatU9pItImT2TMZw=
X-Google-Smtp-Source: APXvYqx8RZh3jXZjSGE4MwlVL2inkV97jj78gIfYfWZpFlCJSBjw/ehfjxk7ZWkKSVITMEKA1h8pEA==
X-Received: by 2002:a50:c90d:: with SMTP id o13mr2607574edh.148.1566976721988;
        Wed, 28 Aug 2019 00:18:41 -0700 (PDT)
Received: from tiehlicka.microfocus.com (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id y19sm278969edu.90.2019.08.28.00.18.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 28 Aug 2019 00:18:39 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>
Cc: Hillf Danton <hdanton@sina.com>,
	<linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Adric Blake <promarbler14@gmail.com>,
	Yafang Shao <laoar.shao@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH] mm, memcg: do not set reclaim_state on soft limit reclaim
Date: Wed, 28 Aug 2019 09:18:08 +0200
Message-Id: <20190828071808.20410-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

Adric Blake has noticed[1] the following warning:
[38491.963105] WARNING: CPU: 7 PID: 175 at mm/vmscan.c:245 set_task_recla=
im_state+0x1e/0x40
[...]
[38491.963239] Call Trace:
[38491.963246]  mem_cgroup_shrink_node+0x9b/0x1d0
[38491.963250]  mem_cgroup_soft_limit_reclaim+0x10c/0x3a0
[38491.963254]  balance_pgdat+0x276/0x540
[38491.963258]  kswapd+0x200/0x3f0
[38491.963261]  ? wait_woken+0x80/0x80
[38491.963265]  kthread+0xfd/0x130
[38491.963267]  ? balance_pgdat+0x540/0x540
[38491.963269]  ? kthread_park+0x80/0x80
[38491.963273]  ret_from_fork+0x35/0x40
[38491.963276] ---[ end trace 727343df67b2398a ]---

which tells us that soft limit reclaim is about to overwrite the
reclaim_state configured up in the call chain (kswapd in this case but
the direct reclaim is equally possible). This means that reclaim stats
would get misleading once the soft reclaim returns and another reclaim
is done.

Fix the warning by dropping set_task_reclaim_state from the soft reclaim
which is always called with reclaim_state set up.

Reported-by: Adric Blake <promarbler14@gmail.com>
Acked-by: Yafang Shao <laoar.shao@gmail.com>
Acked-by: Yang Shi <yang.shi@linux.alibaba.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>

[1] http://lkml.kernel.org/r/CAE1jjeePxYPvw1mw2B3v803xHVR_BNnz0hQUY_JDMN8=
ny29M6w@mail.gmail.com
---
 mm/vmscan.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c77d1e3761a7..a6c5d0b28321 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3220,6 +3220,7 @@ unsigned long try_to_free_pages(struct zonelist *zo=
nelist, int order,
=20
 #ifdef CONFIG_MEMCG
=20
+/* Only used by soft limit reclaim. Do not reuse for anything else. */
 unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 						gfp_t gfp_mask, bool noswap,
 						pg_data_t *pgdat,
@@ -3235,7 +3236,8 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgr=
oup *memcg,
 	};
 	unsigned long lru_pages;
=20
-	set_task_reclaim_state(current, &sc.reclaim_state);
+	WARN_ON_ONCE(!current->reclaim_state);
+
 	sc.gfp_mask =3D (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
=20
@@ -3253,7 +3255,6 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgr=
oup *memcg,
=20
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
=20
-	set_task_reclaim_state(current, NULL);
 	*nr_scanned =3D sc.nr_scanned;
=20
 	return sc.nr_reclaimed;
--=20
2.20.1


