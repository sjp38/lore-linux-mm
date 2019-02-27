Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F276DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:24:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F48C20643
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:24:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ELfEv57r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F48C20643
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CF898E0026; Wed, 27 Feb 2019 12:24:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 381DB8E0001; Wed, 27 Feb 2019 12:24:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 220568E0026; Wed, 27 Feb 2019 12:24:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA6958E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:24:57 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id k5so16040739qte.0
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:24:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=eGf2XMn9IfDELcBfR0ySSI84sQWNLNydLOW9RCSe8uM=;
        b=erkYvAdN4Mr0UW/um8JnxPiNqsxCp0fg3HPS4wXoOD/1zBiYb9fJqCp5EfMpBDsNab
         TeF8O/4FtEOdphebzmiLilisqtoVc/2yfLe0Nr2SWkoMwbTMQzd2NyTquHkPaeyhPozG
         7w/KShZaFl9tq2kTyPZxDgawRzWuvwuwDRhLJdyOo5bRg2ANVr2yQoL+wfRVTVgKgeei
         ZfapjuMy7srhGbtMpdjPyfcdBcWvt4Cgcbe+5erTq1u1/4oRZJr4TBDUIueJmnPncaPR
         tcZXx0UB+J0a3r3eMX/OuJRDT+mw7VN8WpMq9XhoYqAju31ddZ4UYMKaZSNWIvZbUR5g
         be2A==
X-Gm-Message-State: APjAAAUysPfjwVpR6V+vbuNx7Pxg6oU6jKUvFJ69cy1kY7MyeY6Rp22j
	zHKcZYNOQHS1WsxNYcQQNCNxE0Ixqbuc+HvsHP9Yz7RzPTI59xdea9RXQbB9N27YqtqMZENK7tn
	XFhwG4rh1dKsCk2f5s/rlLqUYwIvWGSBVLgcT7MK0t9fDRFigmSTX8ygFoMh2HDrffEPBkfPdmd
	97fPN+MeIRd+UqFFk/klKDo5+VnVhb54zg4nt6yUnbBCCKNAmamDQgYprnw1X0jhqZ1jyWtoAaH
	zBG/l62mRp3/VLiRpmUO6e0z/Bnl6NA8W81TQnZ0gWnVQwV55DWv58qtf0fGuCMaaeIM7h7ckdC
	DGAXTC3p02jezFSnw60CJgtjlkFe6GN0u6Bev6sfuMVzUDt/r9QGhtyOwktaTYDbxx+3aWOwBTC
	z
X-Received: by 2002:ac8:37f6:: with SMTP id e51mr2560710qtc.1.1551288297647;
        Wed, 27 Feb 2019 09:24:57 -0800 (PST)
X-Received: by 2002:ac8:37f6:: with SMTP id e51mr2560655qtc.1.1551288296727;
        Wed, 27 Feb 2019 09:24:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551288296; cv=none;
        d=google.com; s=arc-20160816;
        b=Na6lwPEbUwOy27MxiF9fqrL9qK6iAIIT3sASGp6pqUI3GpOZVMNLrzTmMqZ5evWEln
         RAjADvUT5xauWB3zOlkuO7vk8fl0SBZOFXb6u6zb+kRdFwDDQq/H95yDhxi3r74tr+zr
         5gCIKQ4Jg6kZkicaSu7YtgpQ2moJA9eTDIP2zokdzS72WTFZo5QVw0yenmuXPsRfNBbq
         4yd6lLdQapczEUgEajdSdbhEC6btCsULHqucoLpRozKlkw4NUy53meOUXQ/qMFHLHoR4
         GTSOzeyBTdqSUDMxZwJrTUr8G8e1Kwu+AWFIrmBIJpQC8FoY0T1LZWnh+uqltcKNDwz2
         dfbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=eGf2XMn9IfDELcBfR0ySSI84sQWNLNydLOW9RCSe8uM=;
        b=eOyp4L/5kCXOpSje2lxKX3QcOQU9wXs7aykShIRZzIcx7uy76NVgmwK8N0l9scyG+W
         /tgRAJ/AmGq+6w18UHCPH1gLfb+ooB9ahVLr/g7jPEWhRnfCVBE6A0PSy1bvFhO1UY3H
         gf3JHBdYsTHRq05Fy6QMTjIt6H/kPPBTdefUF+mgECj/FtE0XVZt4IdVusGvTVhUVgvI
         LCaWVDme9qoG50V6nH5zvEJGjHs+dMGt+v/hVWv0ov0MxnuKC6X6UWX0/C5QliLbYUFC
         o/yayNz3UziSLWZ8U8mLZ5lxqMjIfrQL6MxtgOahw8dd4QWHJwzEq/a2OKgTkV/o1qmP
         fTNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ELfEv57r;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p23sor20272421qtn.56.2019.02.27.09.24.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 09:24:56 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ELfEv57r;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=eGf2XMn9IfDELcBfR0ySSI84sQWNLNydLOW9RCSe8uM=;
        b=ELfEv57rF2VnWlN80wIdUM4GJxm6WYaKyKmas1794arhEIq5WEXOlSA+DCuuwrUcbS
         8w4vQ+NpuiS425lccJN8w8NOc27xngVIrJh4eJY3+uoYwOdRC0HuT9yg0ieGdL/bN7U9
         fpmexV8QIJkoGQSbbUlmfxGrsHYUZz6Os2eTqjDhiIh8Pskayj2dap3bfNpuab1HlpSY
         JQu5Tg+ZQS3ISXK29qzTcMKoZUQ07TomB92A3MeKJ9nsH7GN3nMzyyeq3Ob0oWAtw0t2
         T3jUPI+G+o2oyGQnu7+xyXZJUQCx9oVL8X5yizI9pfNeC64cg00JRfH71FWfXcVWU1go
         SPGg==
X-Google-Smtp-Source: APXvYqxD/o1GZkCxMwP7T66aS5TvYzSycvD3lu0ElNPXhx5gFwaeq7YliPcu8fUyV5WbiCmtTIBBag==
X-Received: by 2002:aed:3f5d:: with SMTP id q29mr2497984qtf.193.1551288296449;
        Wed, 27 Feb 2019 09:24:56 -0800 (PST)
Received: from Qians-MBP.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id s5sm2987167qkf.87.2019.02.27.09.24.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 09:24:55 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v2] mm/page_ext: fix an imbalance with kmemleak
Date: Wed, 27 Feb 2019 12:24:45 -0500
Message-Id: <20190227172445.75553-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After offlined a memory block, kmemleak scan will trigger a crash, as it
encounters a page ext address that has already been freed during memory
offlining. At the beginning in alloc_page_ext(), it calls
kmemleak_alloc(), but it does not call kmemleak_free() in
free_page_ext().

BUG: unable to handle kernel paging request at ffff888453d00000
PGD 128a01067 P4D 128a01067 PUD 128a04067 PMD 47e09e067 PTE 800ffffbac2ff060
Oops: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
CPU: 1 PID: 1594 Comm: bash Not tainted 5.0.0-rc8+ #15
Hardware name: HP ProLiant DL180 Gen9/ProLiant DL180 Gen9, BIOS U20 10/25/2017
RIP: 0010:scan_block+0xb5/0x290
Code: 85 6e 01 00 00 48 b8 00 00 30 f5 81 88 ff ff 48 39 c3 0f 84 5b 01
00 00 48 89 d8 48 c1 e8 03 42 80 3c 20 00 0f 85 87 01 00 00 <4c> 8b 3b
e8 f3 0c fa ff 4c 39 3d 0c 6b 4c 01 0f 87 08 01 00 00 4c
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
Code: 89 02 48 c7 c0 ff ff ff ff eb b3 0f 1f 80 00 00 00 00 f3 0f 1e fa
48 8d 05 65 63 2d 00 8b 00 85 c0 75 17 b8 01 00 00 00 0f 05 <48> 3d 00
f0 ff ff 77 58 c3 0f 1f 80 00 00 00 00 41 54 49 89 d4 55
RSP: 002b:00007ffd5b863cb8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00007f6c0dad73b8
RDX: 0000000000000005 RSI: 000055a9216e1710 RDI: 0000000000000001
RBP: 000055a9216e1710 R08: 000000000000000a R09: 00007ffd5b863840
R10: 000000000000000a R11: 0000000000000246 R12: 00007f6c0dda9780
R13: 0000000000000005 R14: 00007f6c0dda4740 R15: 0000000000000005
Modules linked in: nls_iso8859_1 nls_cp437 vfat fat kvm_intel kvm
irqbypass efivars ip_tables x_tables xfs sd_mod ahci libahci igb
i2c_algo_bit libata i2c_core dm_mirror dm_region_hash dm_log dm_mod
efivarfs
CR2: ffff888453d00000
---[ end trace ccf646c7456717c5 ]---
RIP: 0010:scan_block+0xb5/0x290
Code: 85 6e 01 00 00 48 b8 00 00 30 f5 81 88 ff ff 48 39 c3 0f 84 5b 01
00 00 48 89 d8 48 c1 e8 03 42 80 3c 20 00 0f 85 87 01 00 00 <4c> 8b 3b
e8 f3 0c fa ff 4c 39 3d 0c 6b 4c 01 0f 87 08 01 00 00 4c
RSP: 0018:ffff8881ec57f8e0 EFLAGS: 00010082
RAX: 0000000000000000 RBX: ffff888453d00000 RCX: ffffffffa61e5a54
RDX: 0000000000000000 RSI: 0000000000000008 RDI: ffff888453d00000
RBP: ffff8881ec57f920 R08: fffffbfff4ed588d R09: fffffbfff4ed588c
R10: fffffbfff4ed588c R11: ffffffffa76ac463 R12: dffffc0000000000
R13: ffff888453d00ff9 R14: ffff8881f80cef48 R15: ffff8881f80cef48
FS:  00007f6c0e3f8740(0000) GS:ffff8881f7680000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff888453d00000 CR3: 00000001c4244003 CR4: 00000000001606a0
Kernel panic - not syncing: Fatal exception
Shutting down cpus with NMI
Kernel Offset: 0x24c00000 from 0xffffffff81000000 (relocation range:
0xffffffff80000000-0xffffffffbfffffff)
---[ end Kernel panic - not syncing: Fatal exception ]---

Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: move kmemleak_free() into free_page_ext() as there is no need to call
    kmemleak_free() in the vfree() case.

 mm/page_ext.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 8c78b8d45117..0b6637d7bae9 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -274,6 +274,7 @@ static void free_page_ext(void *addr)
 
 		BUG_ON(PageReserved(page));
 		free_pages_exact(addr, table_size);
+		kmemleak_free(addr);
 	}
 }
 
-- 
2.17.2 (Apple Git-113)

