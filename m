Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D477C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:53:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D3CC21670
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:53:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="GSPWrkxb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D3CC21670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E42066B000A; Wed,  4 Sep 2019 09:53:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCC196B000C; Wed,  4 Sep 2019 09:53:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C68086B000D; Wed,  4 Sep 2019 09:53:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0226.hostedemail.com [216.40.44.226])
	by kanga.kvack.org (Postfix) with ESMTP id A0DE76B000A
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 09:53:20 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0EB82998B
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:53:20 +0000 (UTC)
X-FDA: 75897380160.25.songs70_1d07f06d7e63b
X-HE-Tag: songs70_1d07f06d7e63b
X-Filterd-Recvd-Size: 4800
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net [95.108.205.193])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:53:19 +0000 (UTC)
Received: from mxbackcorp1g.mail.yandex.net (mxbackcorp1g.mail.yandex.net [IPv6:2a02:6b8:0:1402::301])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 4B2552E1B27;
	Wed,  4 Sep 2019 16:53:17 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1g.mail.yandex.net (nwsmtp/Yandex) with ESMTP id TeRZbfHkYc-rGCqWrsv;
	Wed, 04 Sep 2019 16:53:17 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1567605197; bh=VxqnRtVdrBaKi5aYplTaVoduEG2sU6I/aWRnOnGbhO0=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=GSPWrkxb670ZPlW2DXL3qhwLT3Fup/xjYJ6vwF3G2Qai3g/SrzfIXNRgAwcvm0/Ti
	 A18Dsr8a3PSVV8YxTvU8h7v8qAAvrmvPWi7QMygAqAkIhFT6IgIc0TxiiBlmoiaTNw
	 PD0QCzoazULCxKs2DLAfXEzQCa30nglUzzQFLjvs=
Authentication-Results: mxbackcorp1g.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:c142:79c2:9d86:677a])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id 6QVRv2aEFs-rGf4XfSK;
	Wed, 04 Sep 2019 16:53:16 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH v1 4/7] mm/mlock: recharge memory accounting to first mlock
 user
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>
Date: Wed, 04 Sep 2019 16:53:16 +0300
Message-ID: <156760519646.6560.5927254238728419748.stgit@buzz>
In-Reply-To: <156760509382.6560.17364256340940314860.stgit@buzz>
References: <156760509382.6560.17364256340940314860.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently mlock keeps pages in cgroups where they were accounted.
This way one container could affect another if they share file cache.
Typical case is writing (downloading) file in one container and then
locking in another. After that first container cannot get rid of file.

This patch recharges accounting to cgroup which owns mm for mlock vma.
Recharging happens at first mlock, when PageMlocked is set.

Mlock moves pages into unevictable LRU under pte lock thus in this place
we cannot call reclaimer. To keep things simple just charge using force.
After that memory usage temporary could be higher than limit but cgroup
will reclaim memory later or trigger oom, which is valid outcome when
somebody mlock too much.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 Documentation/admin-guide/cgroup-v1/memory.rst |    5 +++++
 mm/mlock.c                                     |    9 ++++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/Documentation/admin-guide/cgroup-v1/memory.rst b/Documentation/admin-guide/cgroup-v1/memory.rst
index 41bdc038dad9..4c79e5a9153b 100644
--- a/Documentation/admin-guide/cgroup-v1/memory.rst
+++ b/Documentation/admin-guide/cgroup-v1/memory.rst
@@ -220,6 +220,11 @@ the cgroup that brought it in -- this will happen on memory pressure).
 But see section 8.2: when moving a task to another cgroup, its pages may
 be recharged to the new cgroup, if move_charge_at_immigrate has been chosen.
 
+Locking pages in memory with mlock() or mmap(MAP_LOCKED) recharges pages
+into current memory cgroup. This recharge ignores memory limit thus memory
+usage could temporary become higher than limit. After that any allocation
+will reclaim memory down to limit or trigger oom if mlock size does not fit.
+
 Exception: If CONFIG_MEMCG_SWAP is not used.
 When you do swapoff and make swapped-out pages of shmem(tmpfs) to
 be backed into memory in force, charges for pages are accounted against the
diff --git a/mm/mlock.c b/mm/mlock.c
index 73d477aaa411..68f068711203 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -97,8 +97,15 @@ void mlock_vma_page(struct vm_area_struct *vma, struct page *page)
 		mod_zone_page_state(page_zone(page), NR_MLOCK,
 				    hpage_nr_pages(page));
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
-		if (!isolate_lru_page(page))
+		if (!isolate_lru_page(page)) {
+			/*
+			 * Force memory recharge to mlock user. Cannot
+			 * reclaim memory because called under pte lock.
+			 */
+			mem_cgroup_try_recharge(page, vma->vm_mm,
+						GFP_NOWAIT | __GFP_NOFAIL);
 			putback_lru_page(page);
+		}
 	}
 }
 


