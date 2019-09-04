Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24BE7C41514
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:53:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9FED22CED
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:53:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="Ai2bzEbJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9FED22CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 514A66B0003; Wed,  4 Sep 2019 09:53:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C53B6B0006; Wed,  4 Sep 2019 09:53:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DC386B0007; Wed,  4 Sep 2019 09:53:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0156.hostedemail.com [216.40.44.156])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0F36B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 09:53:13 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B619BB2B9
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:53:12 +0000 (UTC)
X-FDA: 75897379824.07.sack61_1be9ba3612846
X-HE-Tag: sack61_1be9ba3612846
X-Filterd-Recvd-Size: 4059
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net [95.108.205.193])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:53:11 +0000 (UTC)
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 5723E2E1AF9;
	Wed,  4 Sep 2019 16:53:09 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id VODvC8jeNf-r9Nu2Lhc;
	Wed, 04 Sep 2019 16:53:09 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1567605189; bh=9NG/dDnFeKeZHp7gq4Bt3jk12l8IcLQ6rwdO1YD1xvQ=;
	h=Message-ID:Date:To:From:Subject:Cc;
	b=Ai2bzEbJdK+baGdRKLO3SHZG+trevrPdYggz78BEbE91uKDRhP/r9odOJkZ2Dga3G
	 FRTz0fb1uTJTZwcwqMnA44/U1x/ocUIpHSlF7wqoKjKBtWlvjg/cs2pLxaO+QAOYKF
	 ZnbqrmTnFEbaAXSvZhbTEvvJhjBU5YXvFV3SbSTs=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:c142:79c2:9d86:677a])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id qxrH47Cxp8-r8D0XNmB;
	Wed, 04 Sep 2019 16:53:09 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH v1 0/7] mm/memcontrol: recharge mlocked pages
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>
Date: Wed, 04 Sep 2019 16:53:08 +0300
Message-ID: <156760509382.6560.17364256340940314860.stgit@buzz>
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
locking in another. After that first container cannot get rid of cache.
Also removed cgroup stays pinned by these mlocked pages.

This patchset implements recharging pages to cgroup of mlock user.

There are three cases:
* recharging at first mlock
* recharging at munlock to any remaining mlock
* recharging at 'culling' in reclaimer to any existing mlock

To keep things simple recharging ignores memory limit. After that memory
usage temporary could be higher than limit but cgroup will reclaim memory
later or trigger oom, which is valid outcome when somebody mlock too much.

---

Konstantin Khlebnikov (7):
      mm/memcontrol: move locking page out of mem_cgroup_move_account
      mm/memcontrol: add mem_cgroup_recharge
      mm/mlock: add vma argument for mlock_vma_page()
      mm/mlock: recharge memory accounting to first mlock user
      mm/mlock: recharge memory accounting to second mlock user at munlock
      mm/vmscan: allow changing page memory cgroup during reclaim
      mm/mlock: recharge mlocked pages at culling by vmscan


 Documentation/admin-guide/cgroup-v1/memory.rst |    5 +
 include/linux/memcontrol.h                     |    9 ++
 include/linux/rmap.h                           |    3 -
 mm/gup.c                                       |    2 
 mm/huge_memory.c                               |    4 -
 mm/internal.h                                  |    6 +
 mm/ksm.c                                       |    2 
 mm/memcontrol.c                                |  104 ++++++++++++++++--------
 mm/migrate.c                                   |    2 
 mm/mlock.c                                     |   14 +++
 mm/rmap.c                                      |    5 +
 mm/vmscan.c                                    |   17 ++--
 12 files changed, 121 insertions(+), 52 deletions(-)

--
Signature

