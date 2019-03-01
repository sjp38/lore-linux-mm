Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02016C10F03
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 22:08:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80B7420850
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 22:08:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Hb3sWPNH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80B7420850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5F7A8E0003; Fri,  1 Mar 2019 17:08:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE9658E0001; Fri,  1 Mar 2019 17:08:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8A008E0003; Fri,  1 Mar 2019 17:08:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB338E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 17:08:27 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id b6so20057187qkg.4
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 14:08:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=yvAuTtzQfqXqE8IZMtG7AZ5bAKkbA6mRsJ7lYZpZ7V0=;
        b=ZQNBppPmvrePBi0IpZmP1gNk3ez0DSVqOkirmAq8+ACyy2ZhmRtc0oDIEQZ0YxQ0BH
         xWkqvodFNxk+TNotxPYuUjBN2IdLyiZ+604LjzEbnVC7/IvAyWO/Bx0RtxR8yl+vy4aZ
         PLrjYDHFE5yAAcg/hnKForTvM1zWEJmqBstpae7udV131OqLMpLppOUGZs3IGbfiXb2n
         r5Q8+f01jFjLMomJdywHPKTtTX9KXSOyX99Kb0/IB4N2as0+sHXTkyK3U9DZ0DHZ2OPP
         /Whiix6uVy2NXRlFmPxx0VnBHuaGJmkKMbSrKGtB6HWLcnMsrsxWmTBYlsWdUX62OhdW
         VxhA==
X-Gm-Message-State: APjAAAXk46nYhg+RJHolZFijDoy2AlUl9+SVAMdqSjS7Xu8QPe8siPcv
	HIu91JXzc6I/uHs8Vda0SGN6Xm//TL7CSUxYsxSJH9o38MA7aMoh+wVDv3G/3q+zRQhWLBeCYk7
	VI7/DcZrIBfxDYJENtSmdX6UR3wGl249uaIFo0+5OMq1oRBw6LC8os9smcipf62yc+wJEu0KOlS
	YHnibnPfQUUlaxTZVK9r6TBuDPVotL80JWtAVaonpGBeHnInRtTtXSQtH/5xIo8pkWf2aWEMHU0
	ugeGVgZ8jHZ9KO0av3cSCEbQXU0TSr//JQpAnUYMnT/6dI8249pSr2bxEUUKkV8C5vRDiIAuGGT
	PPj9MkU6k7dX8dhKSTxt818NyKHh+sSletymV4sOsrwEMFkWYsLSS4I0YVmKgG6OdVRwPCTY3ri
	m
X-Received: by 2002:a37:3793:: with SMTP id e141mr5826635qka.233.1551478107146;
        Fri, 01 Mar 2019 14:08:27 -0800 (PST)
X-Received: by 2002:a37:3793:: with SMTP id e141mr5826522qka.233.1551478105409;
        Fri, 01 Mar 2019 14:08:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551478105; cv=none;
        d=google.com; s=arc-20160816;
        b=I6MFDm4K6xOWrriao0yDcoFIzZ6NWa8hF1/8Qm0YJ0llXQL7wObf/LXCrXA/RjFCEs
         nM3iGTwTN9l2vm9cb4oitmo1kBc7zFySwbwq6twaJCduwaEaeXAXQusvsQ8VLULzI8Fn
         oq9X3et5TlO/6cww8IYuytbtajS5FehNsg6/F0CAGHFTmeCGBzX+ELQzDiN/hR6wN7jh
         d1EVjSq1bctDS5F2LIR/sKTEYXs+Co+ugq6ZVMWWzI9yBc7OnZvQDlfi4lYEGR7z/u6x
         7kTNMFpkmdOKI4UbiJW+nQbe7zBcip1ItFL0Egg9dCjIew+Y8EaAvFufpuTAIwN5zCjP
         wxSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=yvAuTtzQfqXqE8IZMtG7AZ5bAKkbA6mRsJ7lYZpZ7V0=;
        b=Hpu3hKhZE3ZKPqppKZ1QiKSyD/mcbhSRwKliVOrT1iW9hdvzqCGGINAeyZBeGuTpvL
         T4ccDM4msNM2KAxDWOKMhX+w1aQ6ncn+uDve10gCRANvCLa0Sj6xR5mvIE6u0SMGxU0e
         9J+Gle2XmDdPfmKZqLNdUtgxGkxM6FLbBEAN0ntPaFwnd04U8IjBuQO3sK07z68NeUNk
         X9Z3ekkLziA2scmVqru8UT5HMm2dFin8J7j8mY3WfpVIGYY39v+wgcJa9UpX/GGmo2ic
         M0YFSTF8OMTNLu17eywsNgCHEkKCH9qu//QhL4VU7vjYTfZaC4ctagv2mx1tfN+ZW9On
         wkYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Hb3sWPNH;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18sor26964134qve.28.2019.03.01.14.08.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 14:08:25 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Hb3sWPNH;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=yvAuTtzQfqXqE8IZMtG7AZ5bAKkbA6mRsJ7lYZpZ7V0=;
        b=Hb3sWPNHP7knSve9nERSqPxxpADpVZsbVTgRY+6TXYAxZYC8uMiTzM0WnPdFOcO4ah
         ZAN4ItaorlaDKU+oVczGgA4LItcF9LLa8gZOVrZHkjJgSXln9xbwJ9SwIXyZkegssyHl
         FMh5EvLrXmx9fJ72H52Zhp/jLp7yGel5wJkcvjbjWIw+mXiW1hkKo2i+C1tmMawTJadM
         3o4C1S3ImU+FhyrJwidAT+CE8qKcmiFGEWDInH29exEuW7/occRWLVDtUpSu9r6x9FMH
         4JpvhYE4QiV9UjZ0jjrxQ/W3BZ3pNDW+K2M/DkEReFaYQT/BFwXkDXsQLmr2WNF8oa/U
         jYzw==
X-Google-Smtp-Source: APXvYqydUjVKaIDbLfWdjzvpw26ezOFLz7mVh5OxBuUY2lUxJ/K388NmyHmGJwxkpph2pO6KYucvDw==
X-Received: by 2002:a0c:b5ce:: with SMTP id o14mr5690012qvf.107.1551478105107;
        Fri, 01 Mar 2019 14:08:25 -0800 (PST)
Received: from ovpn-120-151.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id v83sm2794743qkb.18.2019.03.01.14.08.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 14:08:24 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	benh@kernel.crashing.org,
	paulus@samba.org,
	mpe@ellerman.id.au,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
Date: Fri,  1 Mar 2019 17:08:14 -0500
Message-Id: <20190301220814.97339-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When onlining a memory block with DEBUG_PAGEALLOC, it unmaps the pages
in the block from kernel, However, it does not map those pages while
offlining at the beginning. As the result, it triggers a panic below
while onlining on ppc64le as it checks if the pages are mapped before
unmapping. However, the imbalance exists for all arches where
double-unmappings could happen. Therefore, let kernel map those pages in
generic_online_page() before they have being freed into the page
allocator for the first time where it will set the page count to one.

On the other hand, it works fine during the boot, because at least for
IBM POWER8, it does,

early_setup
  early_init_mmu
    harsh__early_init_mmu
      htab_initialize [1]
        htab_bolt_mapping [2]

where it effectively map all memblock regions just like
kernel_map_linear_page(), so later mem_init() -> memblock_free_all()
will unmap them just fine without any imbalance. On other arches without
this imbalance checking, it still unmap them once at the most.

[1]
for_each_memblock(memory, reg) {
        base = (unsigned long)__va(reg->base);
        size = reg->size;

        DBG("creating mapping for region: %lx..%lx (prot: %lx)\n",
                base, size, prot);

        BUG_ON(htab_bolt_mapping(base, base + size, __pa(base),
                prot, mmu_linear_psize, mmu_kernel_ssize));
        }

[2] linear_map_hash_slots[paddr >> PAGE_SHIFT] = ret | 0x80;

kernel BUG at arch/powerpc/mm/hash_utils_64.c:1815!
Oops: Exception in kernel mode, sig: 5 [#1]
LE SMP NR_CPUS=256 DEBUG_PAGEALLOC NUMA pSeries
CPU: 2 PID: 4298 Comm: bash Not tainted 5.0.0-rc7+ #15
NIP:  c000000000062670 LR: c00000000006265c CTR: 0000000000000000
REGS: c0000005bf8a75b0 TRAP: 0700   Not tainted  (5.0.0-rc7+)
MSR:  800000000282b033 <SF,VEC,VSX,EE,FP,ME,IR,DR,RI,LE>  CR: 28422842
XER: 00000000
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
[c0000005bf8a7840] [c00000000006265c] __kernel_map_pages+0x2cc/0x4f0
(unreliable)
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
 mm/memory_hotplug.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c4f59ac21014..2a778602a821 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -661,6 +661,7 @@ EXPORT_SYMBOL_GPL(__online_page_free);
 
 static void generic_online_page(struct page *page, unsigned int order)
 {
+	kernel_map_pages(page, 1 << order, 1);
 	__free_pages_core(page, order);
 	totalram_pages_add(1UL << order);
 #ifdef CONFIG_HIGHMEM
-- 
2.17.2 (Apple Git-113)

