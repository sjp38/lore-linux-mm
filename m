Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACF9BC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:01:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 641B0218A5
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:01:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="P1bvtev9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 641B0218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 166346B0007; Fri, 19 Jul 2019 00:01:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 117D68E0003; Fri, 19 Jul 2019 00:01:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 004C88E0001; Fri, 19 Jul 2019 00:01:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB0196B0007
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:01:55 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d190so17899939pfa.0
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:01:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1Uqd78ab5LVket8wSYu/7s4SLsPia0WFI4EU+s+WtHQ=;
        b=TliQjZxiwziUInaOeeLxOcYJklmWGY2y2JWzeUGgn2E63qIy76OpRaBqeHWfq2JvjZ
         vKRY58gbo+rGMCWyrrGSRv6ZE7k1kACyNAoHQ6WVzhlsJWLD37I7GKk+FZSwA5ZMq/Tb
         ITJL1kEwqvB9MaEbItMAF2fmkaepbwKmvBaDO2D2UOiBOEz+Sz3dTYaiHWGgvLfSXEHq
         Mbg+Sz2O2pq/NotnMW5yDCLTyRmujrC0xmyc/Jjzl8TMuQiLkYj+ZPIG+oa9sl0jyguS
         0idGi2qxrPmTg+20tQw1YaU/i16BiOqMS5kMuwg6ek2n/mKUK4V2OJFJluKdK7S1Syt2
         lw6g==
X-Gm-Message-State: APjAAAU9ETqTntldWPOQ5iOjKk+nCdpp3JZIMiiz8Uk4jKBwCvCKMNh8
	RPqVc6Eb87CAEJaozqQO2XQgcb5CTSI6wwkAZJyFOtGh+cFBuPa7e9AHHunVYIBElXbUc3Wm3oc
	UGR6lzo+9ZFxYHp6mxZ0hCr8DkICg0rv5Shn/hOgPstMcprGjIyM6gM3a667qctMWaw==
X-Received: by 2002:a17:90a:bd93:: with SMTP id z19mr55945696pjr.49.1563508915395;
        Thu, 18 Jul 2019 21:01:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyBjXTpXc0JfEcDvzS4883rZ5T1ywAVWr6zk/yRe8MDPxFDbzTga/OFxtAyGfdVNOw8ujj
X-Received: by 2002:a17:90a:bd93:: with SMTP id z19mr55945620pjr.49.1563508914412;
        Thu, 18 Jul 2019 21:01:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563508914; cv=none;
        d=google.com; s=arc-20160816;
        b=i5wS6B/aIYBo7hGA3YJFxE9n3zJRM0dmZldY9xwJMH37v/jsmOGns8tc33NSpRsAoB
         BnYgS7rllPXvXxFa1X07TEs20wqQGLRia4KhhEMYOHeZ+QuMA2MP2xswUGPfeM+L/53+
         60OEzR5XUGgVOlT+RWzmgQg55rV1bgz9yIONoSNPnWFtk3BLkEVQ/bGIlDjBIWbb2E8W
         0MaZqw5SdJotYgqgjKIh5l81d1Jx1jc1IQqX27aYXxKUdvAzJw+kJgPUaCfhAYHink+5
         VVeXqgLtBvR7iyTI0toLM73pg0MakeEq74pA9r1il/xyuh8sryqIxFsoOtD7ZJtfB4B5
         xWsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1Uqd78ab5LVket8wSYu/7s4SLsPia0WFI4EU+s+WtHQ=;
        b=k7YOKvjYE/hO/MMxZPs+83eKWWgcpI8OBtaG3P7u9LsBr7ThYTsI2w+xITQ5s72cfy
         kuhfCSTS1f9rjieU4QCF5PtR1Sa3tDGp3UMwS9xZbd10dzA7fjpKDUk/S9NneTjFrQyQ
         ny3APqOOosS9kjNM08UKmPSVr9fWQz2EzQLqwfIViTuIrSRhycPhh1q7F2XWD8WAs81V
         hfrlmG/eh/2COi+WXbBXu+adpymQEy3+W/MK9xCLDmlq2wx65y6XxCFlcqlhOFjepWPH
         IB9BFcxjvwjxROXweTjpuqSNzjdY4FljuwH3cZSlUlkKlCy4wDBq2p/65xWNJrMzGTc/
         MExQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=P1bvtev9;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a16si280903pgw.156.2019.07.18.21.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:01:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=P1bvtev9;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3F1A521873;
	Fri, 19 Jul 2019 04:01:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563508914;
	bh=9GAUxEDGrz6p+X4090gdjhdKhYDC2727M0VEUVEW7Zk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=P1bvtev9IcCHwx/bTh9HILe944CP2yEbgTErDWs2hT5DpSX8ktcrcOtcxlBnU9qBv
	 9ays0IlEp5o6wxMIUlgxL69Efwd76urRw+nt0Vqu8/PGLNBads84SX2vHyOdmjd5kf
	 Nqgz3A4YggRPXpLlmgxo5HGKzdFx8D8+zeU3UQ+k=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 156/171] mm/kmemleak.c: fix check for softirq context
Date: Thu, 18 Jul 2019 23:56:27 -0400
Message-Id: <20190719035643.14300-156-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719035643.14300-1-sashal@kernel.org>
References: <20190719035643.14300-1-sashal@kernel.org>
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
index 9dd581d11565..3e147ea83182 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -575,7 +575,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
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

