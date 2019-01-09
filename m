Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67583C43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 08:39:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1CBF214C6
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 08:39:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="hLEsvWQO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1CBF214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 461FA8E009D; Wed,  9 Jan 2019 03:39:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EB268E0038; Wed,  9 Jan 2019 03:39:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DA4F8E009D; Wed,  9 Jan 2019 03:39:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED8078E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 03:39:46 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id 124so3321776ybb.9
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 00:39:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :dkim-signature;
        bh=d8nk7slwlRpiZg/raOdY1xeZB8HZ56EW4GxJN3oaLI4=;
        b=VwYqyKVDv+jJQARPKn4jpQoa2T7oJgZl6YGuIPW6rH7j0JrV6AmKJCBjBRE6rMqYjX
         fVnbQnKvC4kmMaIem2iBp0uSCqa1aCp4LM2G250Ph904MIYXIBd8l8uOXv/aZD9ITOKF
         cgVg2gqHhfw04MEp7CrzpGU+vZvMT97pkb5i5HS7uAlKpXROW12P3WW12aro3OdImCuB
         JRr/HQSpuYcA6vajRiB9A+IHzJr3j0Ww6J/zArnXsy4NkeCQ+fgb88GniG1rZ/AXfh1p
         a8p3lHQqYOkvLCH0ODsQXfSwytYcf8qkBxKBUpydjsK0DhuIbNW9kMgYMr3F7wB/RZaY
         XbXw==
X-Gm-Message-State: AJcUukdkcdEiR5JXdFktrnxYMm30Le9ERRYmSE2EpDh6ardzMCmowEkw
	lfagKsuqsHkP/WH6Rp2iek3sk6LQhS6irysgkfpxmN14THuC3C63jAoDvt+sDkf4eyTn/f3w6xK
	hDLhGUsay8/b1TrMKcBWi5LvQ8Qf1PO/zlsFTfSyFDgxsBcs2p+ydQDLFnpqImT4+bg==
X-Received: by 2002:a25:2f58:: with SMTP id v85mr4932961ybv.100.1547023186541;
        Wed, 09 Jan 2019 00:39:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5cQPw1zVHHjEMnP35RIY4dPMkMb8roBvEvbWkYVxurWhN2feOjaA1+L1GD10vPxnJy2XyA
X-Received: by 2002:a25:2f58:: with SMTP id v85mr4932935ybv.100.1547023185933;
        Wed, 09 Jan 2019 00:39:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547023185; cv=none;
        d=google.com; s=arc-20160816;
        b=l4zLAaRs/E7Ylu9tj2WrlkFKbWG8AZZRD9vW0g4ljmmsIr21axwq4sZ2Z1bzsSCDX3
         rm6XQtasSvxBxyNNR6z+9pT9PKk2UsJLhAYB1iJns48HcfTpSInYdH+vMXmGDm9OW1B+
         2u8TZ9/NlvNONMmvhJ6pNkTHwdWGsgHxeLTb2Z+L/BQrIl3ZyebbxuTJax0gw7JWPS2j
         tLXNh4goeJTR1i8Yt1+m7w3Nkjxxd4Hy94BcxUs69a00IQfnCV/PYNh8KRfiSEZgH4KY
         gL8p2ygPnr2fG7SOFrCa2QO3uvSr+Rn/M/7QLlRJKsAfic0EaajmEiK1MDEzBB6XHITX
         9RfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:message-id:date:subject:cc:to:from;
        bh=d8nk7slwlRpiZg/raOdY1xeZB8HZ56EW4GxJN3oaLI4=;
        b=LO7d20eaYW42GL0vQTeBQYrwZYb0Wz4DRJ9qlyFXa6QPa5JkLZ1y3gqbgaZ0Pbiqek
         I8F/ghk8eOGQICUNvBhHtnDM0pObV9tKyD4vw6BpXguPMAfl1taX72bvgkig+U76Pn/0
         STDQbiowVXh6Nzp2y7m7j5D4ktKon9IoLO9fjjy/BZdvpqXXvfWaA8soOMXvLmNBCRCU
         0muLWHyIV7Ee46CapnlDGTRH5p9UiNx246Wuguqb1yvqoLchHhryPlC/sLWyOag5U8YL
         mdkvCGe8hCs5YyW90mzKEZRquMSirzarLE5PN6EN33XRgGYSPa7CijeO5NhxSDjsGJYB
         nSVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=hLEsvWQO;
       spf=pass (google.com: domain of prpatel@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=prpatel@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id e189si29876247ybb.13.2019.01.09.00.39.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 00:39:45 -0800 (PST)
Received-SPF: pass (google.com: domain of prpatel@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=hLEsvWQO;
       spf=pass (google.com: domain of prpatel@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=prpatel@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c35b3440001>; Wed, 09 Jan 2019 00:39:32 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 09 Jan 2019 00:39:44 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 09 Jan 2019 00:39:44 -0800
Received: from HQMAIL108.nvidia.com (172.18.146.13) by HQMAIL103.nvidia.com
 (172.20.187.11) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 9 Jan
 2019 08:39:44 +0000
Received: from hqnvemgw02.nvidia.com (172.16.227.111) by HQMAIL108.nvidia.com
 (172.18.146.13) with Microsoft SMTP Server (TLS) id 15.0.1395.4 via Frontend
 Transport; Wed, 9 Jan 2019 08:39:44 +0000
Received: from prpatel.nvidia.com (Not Verified[10.24.229.63]) by hqnvemgw02.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5c35b34c0006>; Wed, 09 Jan 2019 00:39:44 -0800
From: Prateek Patel <prpatel@nvidia.com>
To: <paul@paul-moore.com>, <sds@tycho.nsa.gov>, <eparis@parisplace.org>,
	<linux-kernel@vger.kernel.org>, <catalin.marinas@arm.com>,
	<selinux@vger.kernel.org>
CC: <linux-tegra@vger.kernel.org>, <talho@nvidia.com>, <swarren@nvidia.com>,
	<prpatel@nvidia.com>, <linux-mm@kvack.org>, <snikam@nvidia.com>,
	<vdumpa@nvidia.com>, Sri Krishna chowdary <schowdary@nvidia.com>
Subject: [PATCH] selinux: avc: mark avc node as not a leak
Date: Wed, 9 Jan 2019 14:09:22 +0530
Message-ID: <1547023162-6381-1-git-send-email-prpatel@nvidia.com>
X-Mailer: git-send-email 2.7.4
X-NVConfidentiality: public
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1547023172; bh=d8nk7slwlRpiZg/raOdY1xeZB8HZ56EW4GxJN3oaLI4=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 X-NVConfidentiality:MIME-Version:Content-Type;
	b=hLEsvWQOHdvqppyoGhavWWiwtZHwSrIOoTQRuR78d2ScVatIwkp8OmLC69zts+iBf
	 rsYu5zBXuve4SBmFveLWtpGwKsN55oKASYwIZl5Sc03RASnWufgc1HAJ6fcLTCXyWS
	 k4jxYJkeBhaN2237bCl4Nj/Hq1rNbnsjWVJjOkRfrDUamBVpv2ydK51cEuhLo7IOKI
	 1PlqVrim5zVM/NoBOy3IirQw2x4hE/+Vy+Jxax+zSGEYfC2QUybzY7jqzFGBvvJIHF
	 5QhqomtxUsdzzeQOK5ssYb7M725bS95iCtix76TycWyH0bjc8zb/9ztsLv6nWJvpzM
	 UTuAJev+smbpg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109083922.AhLOLLRb6NnBEDDAn88E4lbPWKQquRdJXiuOQAB2O44@z>

From: Sri Krishna chowdary <schowdary@nvidia.com>

kmemleak detects allocated objects as leaks if not accessed for
default scan time. The memory allocated using avc_alloc_node
is freed using rcu mechanism when nodes are reclaimed or on
avc_flush. So, there is no real leak here and kmemleak_scan
detects it as a leak which is false positive. Hence, mark it as
kmemleak_not_leak.

Following is the log for avc_alloc_node detected as leak:
unreferenced object 0xffffffc0dd1a0e60 (size 64):
  comm "InputDispatcher", pid 648, jiffies 4294944629 (age 698.180s)
  hex dump (first 32 bytes):
    ed 00 00 00 ed 00 00 00 17 00 00 00 3f fe 41 00  ............?.A.
    00 00 00 00 ff ff ff ff 01 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffc000192390>] __save_stack_trace+0x24/0x34
    [<ffffffc000192dcc>] create_object+0x13c/0x290
    [<ffffffc000b926f0>] kmemleak_alloc+0x80/0xbc
    [<ffffffc00018e018>] kmem_cache_alloc+0x128/0x1f8
    [<ffffffc000313d40>] avc_alloc_node+0x2c/0x1e8
    [<ffffffc000313f34>] avc_insert+0x38/0x13c
    [<ffffffc000314084>] avc_compute_av+0x4c/0x60
    [<ffffffc00031461c>] avc_has_perm_flags+0x90/0x188
    [<ffffffc000319430>] sock_has_perm+0x84/0x98
    [<ffffffc0003194e4>] selinux_socket_sendmsg+0x1c/0x28
    [<ffffffc000312f58>] security_socket_sendmsg+0x14/0x20
    [<ffffffc0009c60c4>] sock_sendmsg+0x70/0xc8
    [<ffffffc0009c8884>] SyS_sendto+0x140/0x1ec
    [<ffffffc0000853c0>] el0_svc_naked+0x34/0x38
    [<ffffffffffffffff>] 0xffffffffffffffff

Signed-off-by: Sri Krishna chowdary <schowdary@nvidia.com>
Signed-off-by: Prateek <prpatel@nvidia.com>
---
 security/selinux/avc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/security/selinux/avc.c b/security/selinux/avc.c
index 635e5c1..ecfd0cd 100644
--- a/security/selinux/avc.c
+++ b/security/selinux/avc.c
@@ -30,6 +30,7 @@
 #include <linux/audit.h>
 #include <linux/ipv6.h>
 #include <net/ipv6.h>
+#include <linux/kmemleak.h>
 #include "avc.h"
 #include "avc_ss.h"
 #include "classmap.h"
@@ -573,6 +574,7 @@ static struct avc_node *avc_alloc_node(struct selinux_avc *avc)
 	if (!node)
 		goto out;
 
+	kmemleak_not_leak(node);
 	INIT_HLIST_NODE(&node->list);
 	avc_cache_stats_incr(allocations);
 
-- 
2.7.4

