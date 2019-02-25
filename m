Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 214CCC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:17:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4B3E20652
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:17:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Lqj0ZxYb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4B3E20652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66C618E000A; Mon, 25 Feb 2019 14:17:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A67F8E0004; Mon, 25 Feb 2019 14:17:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D54C8E000A; Mon, 25 Feb 2019 14:17:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1071B8E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 14:17:20 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id w134so8543199qka.6
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:17:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=m+7ZtkYRrs+C+Tlxrf4w4o1aKJq7DAlP5H0Onz6M+/k=;
        b=V6F3xXSjHIoxDPz6sKkeZG1zaBAib4YJGCA9ERsmkRzjPYg47+2cs42dkDn0IE9S6S
         BuMQWr7kcWQF8j3eBgBrjFYzwddnRYMA0xxNt1cx7v/C0w8XvoSw4E+Ae2c2CuwdB+/3
         iN7yTEvTY0u7lorA4cPrHcoTm2Csin3PQSJUrSK0N94v1VjCuMCax5iGUI+79siXxNcL
         HaSGnyd9AwLQ4JeHVyp9n4acWoMF/0dvNEFgASP8kh49a097xUpJoMSaC6SqW2b2albf
         xIq/UBIGrf4UqPNSxM5n/Q10mgblv9f8ZhbeJ9DWe8/QUwLBJJSLVAIi5U6Wx8joyDjY
         n76w==
X-Gm-Message-State: AHQUAuZevGnaho/R+ZC6jgowApAole4wqaoW9WwUjS4GSsUwUtYpEUIS
	MVwNc+eOnKrNGbTktSZy/MrUGJ6aLWm1bQtWh2gTRpyErPC+HfJBYgR0ZHyMAzPKPJsIO+AGKxz
	7djIjAmeu3dgqVFsZ8VppaUZ7dcKRMcUsKgRtOOv8aexzOJJWMgVJnyJfkRnJZN7ptmnssb0OTZ
	DeiqD1rvOyEUcbP0WmIIJKa3/yF4tgXYzgY1hKKgjVPn5QVw5XVbbpBEaE0n2r8jrdsM1YTG1bt
	GD1JCQaSEcnjH6UaQm8gwLIDbUg2rPBt4WS84tJNBd6PgJS33oF4uYFCitSXcUs27URFh5VBxly
	Pa4jMXcNsf94VXDa3I4DTH/uScVgGAMo9nVSemZHkBALNT2+AmXh8r4U5psmHO115V73mVuR9ZS
	f
X-Received: by 2002:a0c:963d:: with SMTP id 58mr15027482qvx.25.1551122239786;
        Mon, 25 Feb 2019 11:17:19 -0800 (PST)
X-Received: by 2002:a0c:963d:: with SMTP id 58mr15027433qvx.25.1551122239045;
        Mon, 25 Feb 2019 11:17:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551122239; cv=none;
        d=google.com; s=arc-20160816;
        b=flIh32qLiUnsIDbVW5hXSLPCjIWRHOew2BDW9fOXaKOY9MLYR0B09/JpjY6oZtJFEc
         d7Ate08AdgWWGCNL7ozj2rI2kDZSaa2IB5/4TcojZO097HC47fDGFz6pHjMe2g0Nm4/d
         9iOpAkERMFLKEoxFTsqV0QqtqCrXZrclB96KqRUhWl0CYEEOiceGZryYYkYW5ddiskgN
         FA38LWv/L5mAanF1q/nC9VIUEba+jEWk3gEeJ0rBIeW+rnnYtUTt5Pgzm0+OT1mA9kT6
         3/eV2Iec/0Zv5re7nN/g8N6JV4yyHmaXL6mJDJTlpbhMN9GaMK+MqbME4GoWePCmQs/j
         qb1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=m+7ZtkYRrs+C+Tlxrf4w4o1aKJq7DAlP5H0Onz6M+/k=;
        b=oRr59tWvRxZWhhRebdY1Dkjvfv1lb0XhnB+mnGOtXMi0ePAAOdowKEuw7cMakM/Q7/
         6AVvUG6DBCj5hnGfZ+FL7Be7/iUUMdHDXrp1ku/WtEpdI99n+Aj+YGGk9QNUyCu/zGUp
         g2VApqLLPA9yWx11gGO1LuMn9T65CsgoqwJ2Q4IOT2XSiHeMHDm6lsiXk5dXj1ByzOLC
         vkVApKJZ/O4ahV8Wi1noi3xJR0EcWG+Z9vCEhm5utyTfItpiyLIFsLF5tedE3x96RYZO
         7z59sWVamDj6Q/kkRMeeQuG7GqwNEnTYifeQqneo7EAsbczu1P7JW/XUcXVNJLYAug4N
         VUMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Lqj0ZxYb;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s6sor12131606qvc.39.2019.02.25.11.17.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 11:17:18 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Lqj0ZxYb;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=m+7ZtkYRrs+C+Tlxrf4w4o1aKJq7DAlP5H0Onz6M+/k=;
        b=Lqj0ZxYbp/gTGp1LmAT/nz+ogVoq427sl7clAn8rADEp8ZCBXUzLGSBkh+FXJNJUy0
         geNgqUFRfueaQXs6yt9ta/UckWv6BkwKs2rHe40w/FY1OS5kmUkwRA3ui2Hv0K3+Zptf
         gBby1vqoB4LEaxK20etssgN9Blw8G114aaZgxEdPiUcoyuOKpxLGhOiY1Pt6auBGBDQo
         bhR5X3VBu0QtQA4DwkJLHVkRVBLBjhtBxS73bk7gPRLN8dOBSZcxtdRuov0SHVM6/c0m
         A7ccbay+G8In0/EwyxVmmN3VtLlrw/z8C+Utu0cg1klJA13RuhgpapxOzJtA7bL+kl29
         aZiw==
X-Google-Smtp-Source: AHgI3IYrVi3kQzK9fm+9q0vn7ot8sih2IcY+CZt3/2nkfik2wLi6KzXNqxG8pu14jc+M0VM9oCqzIA==
X-Received: by 2002:a0c:8a48:: with SMTP id 8mr14631008qvu.177.1551122238764;
        Mon, 25 Feb 2019 11:17:18 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id y17sm6855812qtc.33.2019.02.25.11.17.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 11:17:18 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
Date: Mon, 25 Feb 2019 14:17:10 -0500
Message-Id: <20190225191710.48131-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When onlining memory pages, it calls kernel_unmap_linear_page(),
However, it does not call kernel_map_linear_page() while offlining
memory pages. As the result, it triggers a panic below while onlining on
ppc64le as it checks if the pages are mapped before unmapping,
Therefore, let it call kernel_map_linear_page() when setting all pages
as reserved.

kernel BUG at arch/powerpc/mm/hash_utils_64.c:1815!
Oops: Exception in kernel mode, sig: 5 [#1]
LE SMP NR_CPUS=256 DEBUG_PAGEALLOC NUMA pSeries
CPU: 2 PID: 4298 Comm: bash Not tainted 5.0.0-rc7+ #15
NIP:  c000000000062670 LR: c00000000006265c CTR: 0000000000000000
REGS: c0000005bf8a75b0 TRAP: 0700   Not tainted  (5.0.0-rc7+)
MSR:  800000000282b033 <SF,VEC,VSX,EE,FP,ME,IR,DR,RI,LE>  CR: 28422842  XER: 00000000
CFAR: c000000000804f44 IRQMASK: 1
GPR00: c00000000006265c c0000005bf8a7840 c000000001518200 c0000000013cbcc8
GPR04: 0000000000080004 0000000000000000 00000000ccc457e0 c0000005c4e341d8
GPR08: 0000000000000000 0000000000000001 c000000007f4f800 0000000000000001
GPR12: 0000000000002200 c000000007f4e100 0000000000000000 0000000139c29710
GPR16: 0000000139c29714 0000000139c29788 c0000000013cbcc8 0000000000000000
GPR20: 0000000000034000 c0000000016e05e8 0000000000000000 0000000000000001
GPR24: 0000000000bf50d9 800000000000018e 0000000000000000 c0000000016e04b8
GPR28: f000000000d00040 0000006420a2f217 f000000000d00000 00ea1b2170340000
NIP [c000000000062670] __kernel_map_pages+0x2e0/0x4f0
LR [c00000000006265c] __kernel_map_pages+0x2cc/0x4f0
Call Trace:
[c0000005bf8a7840] [c00000000006265c] __kernel_map_pages+0x2cc/0x4f0 (unreliable)
[c0000005bf8a78d0] [c00000000028c4a0] free_unref_page_prepare+0x2f0/0x4d0
[c0000005bf8a7930] [c000000000293144] free_unref_page+0x44/0x90
[c0000005bf8a7970] [c00000000037af24] __online_page_free+0x84/0x110
[c0000005bf8a79a0] [c00000000037b6e0] online_pages_range+0xc0/0x150
[c0000005bf8a7a00] [c00000000005aaa8] walk_system_ram_range+0xc8/0x120
[c0000005bf8a7a50] [c00000000037e710] online_pages+0x280/0x5a0
[c0000005bf8a7b40] [c0000000006419e4] memory_subsys_online+0x1b4/0x270
[c0000005bf8a7bb0] [c000000000616720] device_online+0xc0/0xf0
[c0000005bf8a7bf0] [c000000000642570] state_store+0xc0/0x180
[c0000005bf8a7c30] [c000000000610b2c] dev_attr_store+0x3c/0x60
[c0000005bf8a7c50] [c0000000004c0a50] sysfs_kf_write+0x70/0xb0
[c0000005bf8a7c90] [c0000000004bf40c] kernfs_fop_write+0x10c/0x250
[c0000005bf8a7ce0] [c0000000003e4b18] __vfs_write+0x48/0x240
[c0000005bf8a7d80] [c0000000003e4f68] vfs_write+0xd8/0x210
[c0000005bf8a7dd0] [c0000000003e52f0] ksys_write+0x70/0x120
[c0000005bf8a7e20] [c00000000000b000] system_call+0x5c/0x70
Instruction dump:
7fbd5278 7fbd4a78 3e42ffeb 7bbd0640 3a523ac8 7e439378 487a2881 60000000
e95505f0 7e6aa0ae 6a690080 7929c9c2 <0b090000> 7f4aa1ae 7e439378 487a28dd

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/page_alloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 10d0f2ed9f69..025fc93d1518 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8349,6 +8349,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);
+		kernel_map_pages(page, 1 << order, 1);
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
-- 
2.17.2 (Apple Git-113)

