Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D879AC76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:14:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9097421873
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:14:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ltXjLN38"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9097421873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3309C8E000C; Fri, 19 Jul 2019 00:14:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BBA88E0001; Fri, 19 Jul 2019 00:14:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15B218E000C; Fri, 19 Jul 2019 00:14:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB3188E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:14:18 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s22so15147822plp.5
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:14:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yvDmSBOFsObMbQ5lrKMMefG08jItCRHoMnb3vSFTOwo=;
        b=ivbRoc6lFmD0BVUzUoTABkZPxORBk4SfofDPrLBQFhhKVg+kT8RxDPb2NHfUu+ZOpq
         0ncIu+A8ZcaCxX3PkCduIqEAhh2expDXOsRTJ1c8yqWhGnkpYCsYfWKGX10PJgW079Fp
         lHoOJUiCOKe8ovzggT0MdHFlZy5dfO6zhx+n95QvgrQtWiDUJzQohe1LRZLvdu530vY4
         oWwosOYRMYepRWJoEupL5n7iAOVGeV8WHp1FqbPOAwRTz63yMnT1LTjkkzm72miDig9r
         ZDgAJEgyHcNPK6onIBqd4to5rG2Vp7fnnqUwieIR4d5eMZ1R5DJCHW1WptO/SrzTu42K
         56Tg==
X-Gm-Message-State: APjAAAUOk/CpLlyBr9h138HjPlbYbDhjPsQY8YMEpyOlL8MuQX1RVjs+
	m5MObe0NZM/Hdr2nbA9fNcRQYvRpBPY06xKYQAwoNgDkEvavpKhlUS7sn0B9HeGUdBVFcuRUW6Q
	rRJDOfsrhq7Wv8l4FuKzJ/MB1TklbMstgWJ460VKXMLj188ggc0/2RzjFHscHXf926Q==
X-Received: by 2002:a17:902:ba8b:: with SMTP id k11mr54217459pls.107.1563509658482;
        Thu, 18 Jul 2019 21:14:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIMXT6MjQG/LSaYEhop6WOEWIv25zOJKhVC6WU7XhGRhiUnbKDoIw13ENaUZO8LK3EXbeE
X-Received: by 2002:a17:902:ba8b:: with SMTP id k11mr54217386pls.107.1563509657547;
        Thu, 18 Jul 2019 21:14:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509657; cv=none;
        d=google.com; s=arc-20160816;
        b=Z+fxR/sHAdzDMqOiLUBUxqQ7FX0nh05d+9skCHQkUn5QBH/fw3WME6b4Ycg266KPbF
         MWZMnjuJL4DXgFyis1lM2fxDuYugh/1TkQxJIOKkR6I6W47Q5NhAfO2wznOnKpWn4SX9
         ii6ROrRiCEgHPcpBp3+B0YOrqinjPkfTI+E/uhjOhw+//GH6MUEYSNLDNV5pNCPaqzu0
         WXq5CJ3kvqT+42RsOuiYHDzymgmAbipFkz79seZ+1Vhz4rxWKu2pVZgnDShorVCL6vV4
         hAzvekff6ugC9+sBUGtFdgG7EB6FXBq9nQsRMeeGz21Wj9UkAsl8ULQdgwdoQ5uAVJVT
         LgfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=yvDmSBOFsObMbQ5lrKMMefG08jItCRHoMnb3vSFTOwo=;
        b=CfsCiTPL6EPAWKk4DVmt6J8+Q4zJFKs9Xv2y5wPLnd6Mb+MU4+fgCYPkGO1VT57mjX
         2xZOmeAOV7zeWwfEvsHy+5g1r7t9tg/SgKYzwNaVYi7Qy27DrnTlYpf9Pb1OjvHdP6T8
         mjf6E9X4e8eWtQBZGrBVm7xZiBCdb1bde9asdyKdN729r4OCvyaqE5tcyGGUYIKa+cIX
         7DaHNpbCuRufiaU/JIBbUgklK6dKT0HKObGfnLb4SOewQ2+HebYmDzlDs3+tT/oeZCXy
         t0jW+93zp0B+x4qiJCToUyX30VcXbK90y5+faFWDrvqA7RVfsXLF/oSvAhdB2pacXtO/
         f96A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ltXjLN38;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y8si1995442plp.96.2019.07.18.21.14.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:14:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ltXjLN38;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5FBB22189D;
	Fri, 19 Jul 2019 04:14:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509657;
	bh=KfYxQ+m8C+PdghU4tvsGWQAiv4Z287oKrWaZk+Sk0YY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ltXjLN38Jrjuw/lovJFuLfbIXkD2413hsMmYokjYagF2H6FtONSHqlGOY7swa08Hp
	 PLfvvxPYfRtkt/5OkCZ+FjgG/v0n8KOQmhQ6csCIeAYqr/r5Wio8jJO1j1LZsT5BMK
	 Zm5Bx13MkMvfdl7WnTUpcgCUGqXe3+DXgSTCEisY=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 42/45] mm/kmemleak.c: fix check for softirq context
Date: Fri, 19 Jul 2019 00:13:01 -0400
Message-Id: <20190719041304.18849-42-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719041304.18849-1-sashal@kernel.org>
References: <20190719041304.18849-1-sashal@kernel.org>
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
index 9e66449ed91f..d05133b37b17 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -569,7 +569,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
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

