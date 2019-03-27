Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50E47C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:23:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 066892070B
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:23:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="xQWvIoYl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 066892070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B143F6B0293; Wed, 27 Mar 2019 14:23:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC6316B0294; Wed, 27 Mar 2019 14:23:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98DE96B0295; Wed, 27 Mar 2019 14:23:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 641EB6B0293
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:23:41 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r13so10929250pga.13
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:23:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=p2gGlIF+FYehCWalGfWHRxg3LwYVEnTeFk8yO2xaE5s=;
        b=AT8aFZU53gGPPLz/2Dbj+MqdzFC/dTRSgCSFJVOMgaIfpzkldh/4n3nV4orZw+eP96
         wx02g4ZFmposxpJWTuU4tO5tYmCdM53UrHm5DnTVlgnDgDgepxGzrSP3kkS54kWZ0wqw
         2XgWxMQRWgUXwHag+C3QYp/5HzNW3NBPdTgEkfF5trhPQn3FdPEnAYvOQDut8xtatN8b
         K6OD9ku/WpPFauvlGtuJBV4L1wf+8Xnt7Pyr4gsL0dfvhg7vFy8cHVsbHqFvZ4M/cuD1
         wTUznY2ep9RpNf2a5sUnhsQjsHxKAlvkhUaHatf/tgxpapuNXli/Jrexsqusx0F/o6S8
         GUgQ==
X-Gm-Message-State: APjAAAXpJ4wmB0tRts1qxo+6Tc2J05hRQcDQIkOgY641Vlzmt4hguqGg
	e2hbUU0wLJBEHMfSQ27fIrwGrJEp4BdjRkIGxuNLX16e5gkoTmkUE8OMDQ+KW/BbZFG2nPB/pfj
	zZ+IYM69WNJtLeynhrKiJwylNRE+fgzOpGirph01u0A5JTLJE02S63OEsUi0pVNUcaw==
X-Received: by 2002:a62:a509:: with SMTP id v9mr37828427pfm.64.1553711021061;
        Wed, 27 Mar 2019 11:23:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyu54+8qrNNdOvtQRFF5qMcK8PrqAacbzHpkjg4GD7C/3BWyb0v08PZWLFidrhqz3a2DNxZ
X-Received: by 2002:a62:a509:: with SMTP id v9mr37828377pfm.64.1553711020261;
        Wed, 27 Mar 2019 11:23:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553711020; cv=none;
        d=google.com; s=arc-20160816;
        b=xRQp6Ujw/+1PGNFUV3kBlcJhEBxD6zlBcHjGn5tcIg2qg1ryaTQ0cqUtKYg4yMyRXT
         FCCS9yCxtHlv6xyPjS5N1mTjthoq1DkOH1nxpH+7Szt/aWVxxKzT4ggh8WRAQzgytJ7Z
         SK/QOKFt7x9LtmkcK75rAQOXtQHMFa1BI+71x+Co53eC2k5CcNV51SMbTSNyqrOEBMro
         J89CQbjKz20RBCHCCiWkIxD0oXK08c/Piy6mJHoQdEX+g9bsrVCLNJM/5yaW5DWf4ivF
         1Y4ODAcHv+77AF3YGF/5PlpYX6zAORJ5wA2+16UNiIkiZLUG2DQE046ZQmRnYy4wbTFP
         lB8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=p2gGlIF+FYehCWalGfWHRxg3LwYVEnTeFk8yO2xaE5s=;
        b=AKqKF+54vACDEx84aTtRrSOQZtKqg6BF2YhAHzwiwqGnIJM3RXazyxvOjjNQwDIuct
         slWlMMPs3CHyuSEqrHZpwHg9A6uCTjRe9kfZSgY9S6X0tUPJZ9BdT7bkproYH+VWhSU7
         aBglSaEXJbagyrZN+eK/fFtGSnWTSjK+YzZpZVqAqHbB+bXlzoKAXjxRNVoHu3J83cZr
         rAiTLXvMhgxtZCjxsVuTYEpZjCuKHXk9mmB0PqBNckk8kYdd5YvYTpUh39vPyRo/DEEF
         f4Qz38Q37gtdmngGVYgvKhsIYBi3GU6RSWuatBXLsl2nD42QGIC0iPyXWGxad2bbe+EJ
         zqiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xQWvIoYl;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l8si1254171plt.347.2019.03.27.11.23.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:23:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xQWvIoYl;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 24CD320643;
	Wed, 27 Mar 2019 18:23:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553711019;
	bh=Bouatde+C4tDIJEqSzqd05lUUOg14vh41CuMhmXihMY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=xQWvIoYl2LY7GycccA1vdghxKnaDulZ5A/s8ZrzEEIro4HkZCU3zkpkiD5GvLykbp
	 6r/F0dv2PGoIPvrcm9+6YgWLK3EyfOMsR809oX78o6/ruJrD/UMtl6ItD4136Ik2za
	 GQlZklwHxICZYUN69+HwgodKRKwvTedYcLzEsBuA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.4 09/63] mm/page_ext.c: fix an imbalance with kmemleak
Date: Wed, 27 Mar 2019 14:22:29 -0400
Message-Id: <20190327182323.18577-9-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327182323.18577-1-sashal@kernel.org>
References: <20190327182323.18577-1-sashal@kernel.org>
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
index 4d1eac0d4fc5..de1f34c5a2f1 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -255,6 +255,7 @@ static void free_page_ext(void *addr)
 		table_size = sizeof(struct page_ext) * PAGES_PER_SECTION;
 
 		BUG_ON(PageReserved(page));
+		kmemleak_free(addr);
 		free_pages_exact(addr, table_size);
 	}
 }
-- 
2.19.1

