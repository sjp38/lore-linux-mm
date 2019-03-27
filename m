Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65458C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:21:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1912620651
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:21:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="da2zqrOU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1912620651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E23B56B0292; Wed, 27 Mar 2019 14:21:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD3D96B0293; Wed, 27 Mar 2019 14:21:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9AB56B0294; Wed, 27 Mar 2019 14:21:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 90AC66B0292
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:21:02 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k185so8360108pga.5
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:21:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=r+cTR41uFvO6ym3rehWkF5VhWCJZ8hDWEilr1ugeptM=;
        b=Qky2D/xw8SSJsRtpcUxr8vHUxrih2njTDHYr8ob3LLxMDZRQ1IEHwhxwHOcio53uFW
         yO8/HXm+9DU7bKgy68jn9On3FSQBX/SJRPOypEwfaJzWfNNCSibUvxxn/NiFKPUM8spJ
         XY1LnZQQT+9w6O376oWe/lAzk2NH3+lve7KtGYNPHk7a6z14SakC1Pv0Tnmixw7HEll1
         wvSs/qstnUC5UVDZ06IzdZhSJ/OAWKO2Iy5OGvBi5uuZHppyjmGdHhHqVwKFkp8gWYnn
         VxqFT5BoFo9LQtC2g+wi7g0vEcCYNDtCxIlVZhpJifCptbYzeqDvnfKynqyQsAFAzKSq
         xK7Q==
X-Gm-Message-State: APjAAAUdpJyvtjeAsdaIqv/BffiPCYqkTl6wRO9OeJgAsWte9JZBGtA8
	0B9rgJF702Lz1EqhLBLCdr3+V6f1n03QyiVK561rjis8pg84wPgB4qwyzMCnu4qWpjyQmkwHcBO
	uAYLre4SUoicTmhy/Te6CUujKZSz+yfMUpYi2566xukFYz38rGLDusZ5cJ7uRExc+hQ==
X-Received: by 2002:a65:65c5:: with SMTP id y5mr36181422pgv.192.1553710862246;
        Wed, 27 Mar 2019 11:21:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8R2zdT1j0E09UR6mrSFiqXa8CpgGUY76I7ntaJ1i+vQdjFyKl90luiGFeC11GS/Bcu65x
X-Received: by 2002:a65:65c5:: with SMTP id y5mr36181354pgv.192.1553710861454;
        Wed, 27 Mar 2019 11:21:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710861; cv=none;
        d=google.com; s=arc-20160816;
        b=qFzoTNg2S4BhSxejSTjn2Q5caBr3pPcbRYsCWjg2sFAkf2fu0uWRSphs/U6n9ha9VG
         wHIBuDZ1iwjfZIjjZa1OgnahoGxfAlyp8x4+ge+3XdLGl+0LdRYor9KyBtY6pTdbOklE
         PLeZlA0d+YEjcD8k2HfVskrhcVng8vrhc52mL7j0WjlqFI2KRFVa6PkiIipq7bc35os2
         NXnZIPrlyJ0TQ4zYzrB/qJxOsSo10Irq81P+6XFkSLvUDiQvxypZMyS3BAonMTJIeCRm
         EztlUcpObTzp5dBBYWJPJ9kXdUo6Jshc7VRFGaE8pH4r0jVGdxD44Wk2O+iXNeOa6LNH
         1q7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=r+cTR41uFvO6ym3rehWkF5VhWCJZ8hDWEilr1ugeptM=;
        b=sEdRk7jxXwDmzXyAiO25hUaGaLxba8HvD6veSGBJAmQPMuJwzQFVkHNyUM8mLWKWJp
         pw72ySYBcMVhDb9UkgSY1O0apq8nG/M2AZQqi7tPWVrND+q8oKAPBvTjl8KQeEp5Y7V1
         1H6Mve8vjJjqPpCEjUDSspGu3N1a34OypxralJowqpa67rqMTtvrIwv19tEYpNuH12af
         HEwjL/yAL5kDbfEzUaQG6LqHCUZuEL79ZSd9cLwy+ThaIuBUUQyskTqf0dikukQnNku/
         FFauNAG1kINsubJn3cc2ql+dBlCzK+M+M/4iWjHSgvvMOon+Wqi571kCy/AGudImGJfq
         fvOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=da2zqrOU;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p15si10636528plr.254.2019.03.27.11.21.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:21:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=da2zqrOU;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 50DF720643;
	Wed, 27 Mar 2019 18:21:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710861;
	bh=n6oO/fbQ9AJD4xqfK1dYw0hrWMF6RbgADfedmoKjVIg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=da2zqrOU0TrL3oFhEare+W6+/7oLy8I7t7r2EobC1mC+3MJbsB1GDeovc2psg/mLR
	 oqkYUPUS/KY3ld22c5PmKeX/i/BT93uZl9/uqRd/PLK2HLnIQVE9c2k5PGfTMJAi7o
	 TuLmZcEBAYeeYDdhxGOC1qUUDpEvemiVLqC4SD/s=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 11/87] mm/page_ext.c: fix an imbalance with kmemleak
Date: Wed, 27 Mar 2019 14:19:24 -0400
Message-Id: <20190327182040.17444-11-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327182040.17444-1-sashal@kernel.org>
References: <20190327182040.17444-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit 0c81585499601acd1d0e1cbf424cabfaee60628c ]

After offlining a memory block, kmemleak scan will trigger a crash, as
it encounters a page ext address that has already been freed during
memory offlining.  At the beginning in alloc_page_ext(), it calls
kmemleak_alloc(), but it does not call kmemleak_free() in
free_page_ext().

    BUG: unable to handle kernel paging request at ffff888453d00000
    PGD 128a01067 P4D 128a01067 PUD 128a04067 PMD 47e09e067 PTE 800ffffbac2ff060
    Oops: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
    CPU: 1 PID: 1594 Comm: bash Not tainted 5.0.0-rc8+ #15
    Hardware name: HP ProLiant DL180 Gen9/ProLiant DL180 Gen9, BIOS U20 10/25/2017
    RIP: 0010:scan_block+0xb5/0x290
    Code: 85 6e 01 00 00 48 b8 00 00 30 f5 81 88 ff ff 48 39 c3 0f 84 5b 01 00 00 48 89 d8 48 c1 e8 03 42 80 3c 20 00 0f 85 87 01 00 00 <4c> 8b 3b e8 f3 0c fa ff 4c 39 3d 0c 6b 4c 01 0f 87 08 01 00 00 4c
    RSP: 0018:ffff8881ec57f8e0 EFLAGS: 00010082
    RAX: 0000000000000000 RBX: ffff888453d00000 RCX: ffffffffa61e5a54
    RDX: 0000000000000000 RSI: 0000000000000008 RDI: ffff888453d00000
    RBP: ffff8881ec57f920 R08: fffffbfff4ed588d R09: fffffbfff4ed588c
    R10: fffffbfff4ed588c R11: ffffffffa76ac463 R12: dffffc0000000000
    R13: ffff888453d00ff9 R14: ffff8881f80cef48 R15: ffff8881f80cef48
    FS:  00007f6c0e3f8740(0000) GS:ffff8881f7680000(0000) knlGS:0000000000000000
    CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
    CR2: ffff888453d00000 CR3: 00000001c4244003 CR4: 00000000001606a0
    Call Trace:
     scan_gray_list+0x269/0x430
     kmemleak_scan+0x5a8/0x10f0
     kmemleak_write+0x541/0x6ca
     full_proxy_write+0xf8/0x190
     __vfs_write+0xeb/0x980
     vfs_write+0x15a/0x4f0
     ksys_write+0xd2/0x1b0
     __x64_sys_write+0x73/0xb0
     do_syscall_64+0xeb/0xaaa
     entry_SYSCALL_64_after_hwframe+0x44/0xa9
    RIP: 0033:0x7f6c0dad73b8
    Code: 89 02 48 c7 c0 ff ff ff ff eb b3 0f 1f 80 00 00 00 00 f3 0f 1e fa 48 8d 05 65 63 2d 00 8b 00 85 c0 75 17 b8 01 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 58 c3 0f 1f 80 00 00 00 00 41 54 49 89 d4 55
    RSP: 002b:00007ffd5b863cb8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
    RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00007f6c0dad73b8
    RDX: 0000000000000005 RSI: 000055a9216e1710 RDI: 0000000000000001
    RBP: 000055a9216e1710 R08: 000000000000000a R09: 00007ffd5b863840
    R10: 000000000000000a R11: 0000000000000246 R12: 00007f6c0dda9780
    R13: 0000000000000005 R14: 00007f6c0dda4740 R15: 0000000000000005
    Modules linked in: nls_iso8859_1 nls_cp437 vfat fat kvm_intel kvm irqbypass efivars ip_tables x_tables xfs sd_mod ahci libahci igb i2c_algo_bit libata i2c_core dm_mirror dm_region_hash dm_log dm_mod efivarfs
    CR2: ffff888453d00000
    ---[ end trace ccf646c7456717c5 ]---
    Kernel panic - not syncing: Fatal exception
    Shutting down cpus with NMI
    Kernel Offset: 0x24c00000 from 0xffffffff81000000 (relocation range:
    0xffffffff80000000-0xffffffffbfffffff)
    ---[ end Kernel panic - not syncing: Fatal exception ]---

Link: http://lkml.kernel.org/r/20190227173147.75650-1-cai@lca.pw
Signed-off-by: Qian Cai <cai@lca.pw>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_ext.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 121dcffc4ec1..a7be1c7a79f6 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -286,6 +286,7 @@ static void free_page_ext(void *addr)
 		table_size = get_entry_size() * PAGES_PER_SECTION;
 
 		BUG_ON(PageReserved(page));
+		kmemleak_free(addr);
 		free_pages_exact(addr, table_size);
 	}
 }
-- 
2.19.1

