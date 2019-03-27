Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10588C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B80E02147C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="zExNGB+2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B80E02147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63BD26B0272; Wed, 27 Mar 2019 14:11:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F20B6B0274; Wed, 27 Mar 2019 14:11:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B7B36B0275; Wed, 27 Mar 2019 14:11:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 066266B0272
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:11:05 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id f10so4818682plr.18
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:11:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=a3IiyyQQ+sJf7QAlAbHSXhrbQtGUV7UgG9SwJvLVvCo=;
        b=MI8hTSwm9d+Xnj0TSxJjAJLcc9QdQ7vXuQnZ9apMRuzFwk8phFjlKI5IY/CC/lbV/M
         9fO5o/d99PJyJWUtklkfA8dN1TLcBDlEFytdqkS5X66tpKBUS4yVTC78MeyGPvg6pPOe
         PZjcgFS56eG/Ac6LaiZdpzTFHyY47mhy1JjVRd05W2BGaWfpyk7FtSmCk9xN9rIGJ2q6
         6ZiaiWDRQCOIW6JKD0RNXGrGcKEI96/ojD7IkvF71AtImEMQpGT95lZvkV5lutf/pyvo
         snbHQ9mVEo8QAjtTeXZW+qEgBVK+vEurq7pYHG6o+RXHec93cK2mQJDTVMB0UsPRk0hh
         uB+w==
X-Gm-Message-State: APjAAAW/F0ijcrVvFmbILK4Bkm2nnvjfGM4DyiJztJPh599NqMdmIoy7
	JKbO7C44jkO1wlcLwCjxWqqqM5CfHZ2xbTS98mhBfL74EW02ZRTiz6ixFH6kEYhsokzydr9EoIL
	6jxuHQkaRU7DKotJborligUrgy+a3VgBJqMu/Ybi/SqQC12Zt2mWoujE/psUND6n0Gw==
X-Received: by 2002:a17:902:9306:: with SMTP id bc6mr37342763plb.59.1553710264685;
        Wed, 27 Mar 2019 11:11:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxw58srosPsi3zzR41GBkHLR73NrTg4GWOHO/QAlKkr7dDeuRpG5ciAuMy17Y1Y4YE0LJEI
X-Received: by 2002:a17:902:9306:: with SMTP id bc6mr37342691plb.59.1553710263861;
        Wed, 27 Mar 2019 11:11:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710263; cv=none;
        d=google.com; s=arc-20160816;
        b=iQStQlLXcNK2H+qndwadqGYRsH5tiN7ieHsF3JBoLmq9A2KHtAdUH0F5sc1vcF7aUY
         TcPiWhRNlysqyrfiSpg+XqU+MEEiRaofy8d2WABbE0at51LJ7I6SNO+mVzGu8+wOWwrB
         hcB66ckpThEBST/8S0fbTGn0fSukL87rZGdyqmBUAW46xfWoqcVYUgOG7DrXXlG1+GFJ
         4T7q9z9DkPezTUuUs/KB+FchcqEbbH3Bh2AoQbYlUBCK6G4Nj/ygvx266e4Oo4Oyxszz
         +RZe27IaFl7titJcUHh/1ulVnbdIwog3O1lMMLfFbjqYP/2I2uOQt0J0SnyZxh/KVVEw
         MvPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=a3IiyyQQ+sJf7QAlAbHSXhrbQtGUV7UgG9SwJvLVvCo=;
        b=ST75B+Ky3YjrygDHFbiZ4yx4CSL9x9YUp7jLdPLZ2mtEEoZgewt+97Tz+x7Cswngzp
         B1lS4TvMY1oS9QbRYbWhrvan5oVZt7qvnzPhdkk/r9px321MwvFU0xeHh20zbEmxJm5g
         M0JaUjve7TYdDMqDV57WAjjhU+anCpe1ZL1usGl5M369fTo4WtfgTRvFYDNzGtvE5Lua
         acMrVLUaa8NEmUOkl2HdW6f6WKpUanx64lmTGkbPgaqC8vERE9Thc3uccoAB4dSeQN4Y
         4cgjxtEVrKYTbZ083Zxd/2WvT0TDQDXL5BetAEZbfywMms6LVVJNpG+isc4s+YG3EK4A
         PwKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zExNGB+2;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b2si13672296pgn.93.2019.03.27.11.11.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:11:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zExNGB+2;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B799221741;
	Wed, 27 Mar 2019 18:11:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710263;
	bh=mQJVbhiBQ/mFWaHDkeyAI7TUcTYfmZcdkzp8Oh3xvlQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=zExNGB+2hWLYKDkQiO0EALPWEWe3yvpaJ/BtbBKpKifN8Rpjee3LHlCmDWFxebWJK
	 jWL754X2HHSdxuoR02y5hRFKLrtcSCkLaq+twYa0NZWrxLaB1Q9PJ+ckO/KQ6mZtKC
	 EHi3eucbYuCmTvRn+gNLNBbdGFdT63PIiA+N9Fgg=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 023/192] mm/page_ext.c: fix an imbalance with kmemleak
Date: Wed, 27 Mar 2019 14:07:35 -0400
Message-Id: <20190327181025.13507-23-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327181025.13507-1-sashal@kernel.org>
References: <20190327181025.13507-1-sashal@kernel.org>
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
index 4961f13b6ec1..aad120123688 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -273,6 +273,7 @@ static void free_page_ext(void *addr)
 		table_size = get_entry_size() * PAGES_PER_SECTION;
 
 		BUG_ON(PageReserved(page));
+		kmemleak_free(addr);
 		free_pages_exact(addr, table_size);
 	}
 }
-- 
2.19.1

