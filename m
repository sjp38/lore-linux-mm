Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D832AC76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:10:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94683218C3
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:10:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="CwPpeZJ6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94683218C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F6A28E000A; Fri, 19 Jul 2019 00:10:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A7C68E0001; Fri, 19 Jul 2019 00:10:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 296AC8E000A; Fri, 19 Jul 2019 00:10:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E378C8E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:10:29 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j22so17896896pfe.11
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:10:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Br0ow86Xm097y3BZUXg3y8/lBFlBwZ/ixtOSE1KuIa0=;
        b=ao4VnPrrgRqVqPDzbPSa91kch4jOJXhaEZ1bnW76Xy7O66ZwtxTEoVLF+1ViCU16U+
         bf0mNsaeNoluupLDyuwbNcTTtMq4OWvDoSQiaJg1SnqQiitm1Y8Nl1aqe5nEo1EkdNmy
         AztcY52q2Yl3eNIw7qIjSL4BHlc9XuRJFuNssRXs9/1I3RndBYbCf9YnacbOU1lcOfIr
         MaUZDvVNAma9xWTQNeTUKhhf4adeUlBymQ5ajGXtTbZEm2/iME9DTllbALUeo2O4bajs
         qyyDSTGBwETQXkKZtQzgKnKdv1rrUHK/2+B1PQf8g8ncIwRpmWYsb5sTCvcDi/cIu2uA
         znzw==
X-Gm-Message-State: APjAAAVVI6wkYOfiaP8n9CG4OBnM0PFvakNdtoWyj3qarArKro782gYc
	DBmpypP2bjcR4wFeUGOZ6uYst8JjzJ243dqz4W3niDZDnKbA6vrcxqjF1xeAJwbsFvZd3k0czjF
	nYnqCE0hpgt2PoA6qvyCE7rPbgLKdaz5VSXvhHvCaZxEfyj0mmtQXe99U2fOXGd0VkQ==
X-Received: by 2002:a17:902:6b07:: with SMTP id o7mr53084851plk.180.1563509429583;
        Thu, 18 Jul 2019 21:10:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXKHFVachp5SgSylqnzC8gnOqcQHGjvPiSju1DDmGTeJIECPHvb6pO/bh0qNKsteoUWKwc
X-Received: by 2002:a17:902:6b07:: with SMTP id o7mr53084783plk.180.1563509428821;
        Thu, 18 Jul 2019 21:10:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509428; cv=none;
        d=google.com; s=arc-20160816;
        b=AEXOdZo/VlQ/eiuzxBtaUFlat5W9oLOEPj0WDRaNviWofoTUGuCZaujaMjnKZAcr7T
         OpWLzwC2b5kzfMMXKU4/Dx8bmrpx+m6oTP1D8CBRPgRrdPuaULOdTatunE4iCN+2mE6g
         HRy56jwFxLNV3YPhPGhtMmpYOS+/JL6h9MvxLUqRiaEfT5jl3ZN/ZAD5QMHePuCwYsay
         1OGTfkCjXDeAy2HK89LfffWjwMeyh06ifNpyRtK7uGl+2roLZ6e9kMHl95TloDqukegz
         rPTeQI8WiqwIM2OgJhce9YvNH8C6XBTC4YX+Uhna8I2QjXlJCr/gxl8Rqik0WRXNzSwp
         BVbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Br0ow86Xm097y3BZUXg3y8/lBFlBwZ/ixtOSE1KuIa0=;
        b=kL4FmAkv1NogHe+RtXSR8fs0LHhKgJQwbqQlW7JSTJnONEVjBiEb9o2OWjjzDOuQwE
         hMcHE6W6ewv6BvXBE/XktyMg4FggP4Fq8zF3U2hv/t2OwsNvnyZzHSwCwVMaJ5ITwIJ+
         8LK/ZJoB6vCFId1Ppge4PxF2O3CIx4eRMydxInJ1oYk0likEotong1J/4rO2AxRdRGMi
         L3VPQZzzY+dsXUhpuQhbSbghqc6fPs4InIN0SoTiLPLLfAhDyK/P3jNisLxo7648KMs+
         hKjP0w/fL1syfMUIoeQ032YBPCPtunylQ5w8HADayx82Tmlgh+NN+uTkfZNyy1ccRAfO
         X3+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=CwPpeZJ6;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r129si775715pgr.21.2019.07.18.21.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:10:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=CwPpeZJ6;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9CA75218B6;
	Fri, 19 Jul 2019 04:10:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509428;
	bh=K+lgvhlJARZzRR8BpW0eTQ6hiGRb26FnZGlVHZoy5sw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=CwPpeZJ6gnjhEQvDrHOocicErA3y9ZsKcI0D1c8yFcLBqS9pXcDf3O7+QizRLctb4
	 9dn/5E9EusnoITofmpqqtLJmeY/mLMwhFi3JCJh4CMqY8tQUha2OUWPn3IAXZ9btd8
	 3adAb0yWlXCJV2KxOmEEQak/JbedZL4+Ae1TGqbM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 088/101] mm/kmemleak.c: fix check for softirq context
Date: Fri, 19 Jul 2019 00:07:19 -0400
Message-Id: <20190719040732.17285-88-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719040732.17285-1-sashal@kernel.org>
References: <20190719040732.17285-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dmitry Vyukov <dvyukov@google.com>

[ Upstream commit 6ef9056952532c3b746de46aa10d45b4d7797bd8 ]

in_softirq() is a wrong predicate to check if we are in a softirq
context.  It also returns true if we have BH disabled, so objects are
falsely stamped with "softirq" comm.  The correct predicate is
in_serving_softirq().

If user does cat from /sys/kernel/debug/kmemleak previously they would
see this, which is clearly wrong, this is system call context (see the
comm):

unreferenced object 0xffff88805bd661c0 (size 64):
  comm "softirq", pid 0, jiffies 4294942959 (age 12.400s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 ff ff ff ff 00 00 00 00  ................
    00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
  backtrace:
    [<0000000007dcb30c>] kmemleak_alloc_recursive include/linux/kmemleak.h:55 [inline]
    [<0000000007dcb30c>] slab_post_alloc_hook mm/slab.h:439 [inline]
    [<0000000007dcb30c>] slab_alloc mm/slab.c:3326 [inline]
    [<0000000007dcb30c>] kmem_cache_alloc_trace+0x13d/0x280 mm/slab.c:3553
    [<00000000969722b7>] kmalloc include/linux/slab.h:547 [inline]
    [<00000000969722b7>] kzalloc include/linux/slab.h:742 [inline]
    [<00000000969722b7>] ip_mc_add1_src net/ipv4/igmp.c:1961 [inline]
    [<00000000969722b7>] ip_mc_add_src+0x36b/0x400 net/ipv4/igmp.c:2085
    [<00000000a4134b5f>] ip_mc_msfilter+0x22d/0x310 net/ipv4/igmp.c:2475
    [<00000000d20248ad>] do_ip_setsockopt.isra.0+0x19fe/0x1c00 net/ipv4/ip_sockglue.c:957
    [<000000003d367be7>] ip_setsockopt+0x3b/0xb0 net/ipv4/ip_sockglue.c:1246
    [<000000003c7c76af>] udp_setsockopt+0x4e/0x90 net/ipv4/udp.c:2616
    [<000000000c1aeb23>] sock_common_setsockopt+0x3e/0x50 net/core/sock.c:3130
    [<000000000157b92b>] __sys_setsockopt+0x9e/0x120 net/socket.c:2078
    [<00000000a9f3d058>] __do_sys_setsockopt net/socket.c:2089 [inline]
    [<00000000a9f3d058>] __se_sys_setsockopt net/socket.c:2086 [inline]
    [<00000000a9f3d058>] __x64_sys_setsockopt+0x26/0x30 net/socket.c:2086
    [<000000001b8da885>] do_syscall_64+0x7c/0x1a0 arch/x86/entry/common.c:301
    [<00000000ba770c62>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

now they will see this:

unreferenced object 0xffff88805413c800 (size 64):
  comm "syz-executor.4", pid 8960, jiffies 4294994003 (age 14.350s)
  hex dump (first 32 bytes):
    00 7a 8a 57 80 88 ff ff e0 00 00 01 00 00 00 00  .z.W............
    00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
  backtrace:
    [<00000000c5d3be64>] kmemleak_alloc_recursive include/linux/kmemleak.h:55 [inline]
    [<00000000c5d3be64>] slab_post_alloc_hook mm/slab.h:439 [inline]
    [<00000000c5d3be64>] slab_alloc mm/slab.c:3326 [inline]
    [<00000000c5d3be64>] kmem_cache_alloc_trace+0x13d/0x280 mm/slab.c:3553
    [<0000000023865be2>] kmalloc include/linux/slab.h:547 [inline]
    [<0000000023865be2>] kzalloc include/linux/slab.h:742 [inline]
    [<0000000023865be2>] ip_mc_add1_src net/ipv4/igmp.c:1961 [inline]
    [<0000000023865be2>] ip_mc_add_src+0x36b/0x400 net/ipv4/igmp.c:2085
    [<000000003029a9d4>] ip_mc_msfilter+0x22d/0x310 net/ipv4/igmp.c:2475
    [<00000000ccd0a87c>] do_ip_setsockopt.isra.0+0x19fe/0x1c00 net/ipv4/ip_sockglue.c:957
    [<00000000a85a3785>] ip_setsockopt+0x3b/0xb0 net/ipv4/ip_sockglue.c:1246
    [<00000000ec13c18d>] udp_setsockopt+0x4e/0x90 net/ipv4/udp.c:2616
    [<0000000052d748e3>] sock_common_setsockopt+0x3e/0x50 net/core/sock.c:3130
    [<00000000512f1014>] __sys_setsockopt+0x9e/0x120 net/socket.c:2078
    [<00000000181758bc>] __do_sys_setsockopt net/socket.c:2089 [inline]
    [<00000000181758bc>] __se_sys_setsockopt net/socket.c:2086 [inline]
    [<00000000181758bc>] __x64_sys_setsockopt+0x26/0x30 net/socket.c:2086
    [<00000000d4b73623>] do_syscall_64+0x7c/0x1a0 arch/x86/entry/common.c:301
    [<00000000c1098bec>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

Link: http://lkml.kernel.org/r/20190517171507.96046-1-dvyukov@gmail.com
Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 72e3fb3bb037..6c94b6865ac2 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -576,7 +576,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	if (in_irq()) {
 		object->pid = 0;
 		strncpy(object->comm, "hardirq", sizeof(object->comm));
-	} else if (in_softirq()) {
+	} else if (in_serving_softirq()) {
 		object->pid = 0;
 		strncpy(object->comm, "softirq", sizeof(object->comm));
 	} else {
-- 
2.20.1

