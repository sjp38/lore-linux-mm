Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BBD9C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:16:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D78DF2183F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:16:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="GnpSwvOV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D78DF2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77E4C8E0006; Wed, 27 Feb 2019 12:16:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72DBA8E0001; Wed, 27 Feb 2019 12:16:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 644118E0006; Wed, 27 Feb 2019 12:16:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1268E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:16:15 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id i66so13604125qke.21
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:16:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=TMTIe0PDwn0D4yPgPNHAh5zzexJiE6JbVWtp9zObxko=;
        b=oBhNXfpfs5tmtoufAosuwJ4VsCVqVekwoBwvjfOKbfzJl4j+kt1ApEb/J1YQInnF9m
         3p7zWhmFNx7AkAj7igzdtInkhjA9PeH7+noNbmLulUILRZYlHGXUofXP+FIW2qqBoC1D
         2FqJ3+w7LmUTZmU3GRhr+V9eWxw2XHco0c+Nscgdcy4JXgAkNf/oY8CUhJXhvi5B7ic1
         Yx1TXB5d9auR4YCAzpJk+aZjQH4noGn3e9zDCW69w2SxSEdj/r9igYfMbO8QXjai3Cac
         NiE3l/XaP6uPfPRHEXLQbQnuWQLoVsw0q5Fwn6grUjg/ICvuG30CE/RBoia+2zd9etGi
         SkIA==
X-Gm-Message-State: APjAAAVxX36PauYYb3wlkLUWLMyQ3P8ZCoGMyhwW25qiSN2OcbFdUfhG
	DLV4ucPQBPd7ewCHAmIaglpozR+O764sTsyToyDVWfH1g6m2F/ITQ6zKSh2E7PmNcHMTbKp6MmB
	unj5v9GyGxFHQ7+7D43+ymgmpoRWE9Ls3zQ+9DindH+fbdfi0RuKSyH5zL2nNcIPPpKVjIeJzKz
	HBWAt3+jnDEUfXXns5toNn3ouWTsw/cTFMG6Lt97gSgfvt2U4XiKZWc6JxTjpvuhP66yZuWWxNw
	QQK6mYA+ELR0Sl305osA4udrBIZoxg39Dr4NOGRu/W+rvjWFDy2aZCKlpTcZs279xsR7/vfFpUi
	nxJZAT9hxuLsf8VhcMXT1UdsIbTUfZfNz+Az7mEH2J70gaZVcxuGwNRiwpbHl5xQvuGfT+XogP0
	q
X-Received: by 2002:a0c:9ba1:: with SMTP id o33mr2864936qve.15.1551287774909;
        Wed, 27 Feb 2019 09:16:14 -0800 (PST)
X-Received: by 2002:a0c:9ba1:: with SMTP id o33mr2864865qve.15.1551287774017;
        Wed, 27 Feb 2019 09:16:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287774; cv=none;
        d=google.com; s=arc-20160816;
        b=lO56ONwZHEI16Hm3H6CJf2NcjdT16KVTYWf/vn0CXc0lkN9+7v0rbZE98QQ2gRjhG4
         a/N/m2bX00C+r/g4Onk70CwxCTwxueVok2jRR17/E3zDgNu9Ld3ccqZTBmKaCgb1xyo8
         MRe2achJDpNvl3/btJgyY0NOm7qD1q5s+65D/Q0U0jVVc1LyYDW9qPObJ9Ku+JfjFkeQ
         JdEGV+yV8uKUNjIJNlZAwvWYmBZvERVjC0OThAs4QHYb7X5t6FV4rlj+oWLdCSampHpZ
         Xa9Yo7aRazft2sO6+UcIrs1omgChYK8ftA6KdO1ztWsKkR//zBK1vwwphfakhF6m9slp
         t3bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=TMTIe0PDwn0D4yPgPNHAh5zzexJiE6JbVWtp9zObxko=;
        b=NZ2RmgLVfRr+mhA0Rmzni/0BntAtHzojs2ibhGE2fKUNaF9KCGXKkPCTheiy3c7kcQ
         7+ESvn2xS3EEKd3y90VWLiGzA11uLT3jWbrjvgxQ/taZSoM+kKEXl6jQ4JWEHD3Yi1Mg
         uJ/L6QMSBlwQBFbA/QufIgJ+HR1nYv4i62fO0sRFRdZk85iIOHd7aJsnpc1T0SG+wKmh
         LUUW2kddVkhrQMcXhtMXrlU7g1OHAvdI5msgSlQdOSB42v9BNnT2G86oUccZSNK23UFm
         0k4gdMIv/opvtOuX3nAOwy7ai6LV32+qRD2qjRQhaAg0W6qnY6G121fbQQMRm/jWVkYP
         6D9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=GnpSwvOV;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v6sor20147327qtb.12.2019.02.27.09.16.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 09:16:13 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=GnpSwvOV;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=TMTIe0PDwn0D4yPgPNHAh5zzexJiE6JbVWtp9zObxko=;
        b=GnpSwvOV7UUw1Ift14JNnSwHh4hu8ztI7BNGtPpg9ZxQeKqtTbIF0o3nFJU+AgOllQ
         X9OEe3aWg8vkeFqhm73xRDYEs8UsOR5MO6S4ZKc/xUxcfyl3qUNf/5JZtPLr2onyZAGn
         J+CYcfvTQbWVtPiV5GX+cWd/CvEFDjZCs26AEW9dK0gqf6YR7vQHfjFAL0oVU2LbCx6M
         qu3GAbfdRFG/wGpf8gSd+jYUdCfrPOZgxepmDLI0BDX+XuFCP5E+eJdNGX6og00U/1nW
         PvWua1gj2tl9N/CWF4C5AiC++CDU02ZH+KmmI+GXxGrH/CW3JHKhkzDIwTUwgpgQ8kMU
         3aXQ==
X-Google-Smtp-Source: AHgI3IahJl22kUpVuTO3DtMGp7C3RuulX+s32k9hgSXoKGaK6rj82qyEcwGDhumj/alz13NKy/Q++g==
X-Received: by 2002:ac8:3439:: with SMTP id u54mr2661103qtb.154.1551287773650;
        Wed, 27 Feb 2019 09:16:13 -0800 (PST)
Received: from Qians-MBP.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id m128sm9438130qkf.53.2019.02.27.09.16.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 09:16:13 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/page_ext: fix an imbalance with kmemleak
Date: Wed, 27 Feb 2019 12:15:56 -0500
Message-Id: <20190227171556.75444-1-cai@lca.pw>
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
__free_page_ext().

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
 mm/page_ext.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 8c78b8d45117..b68f2a58ea3b 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -288,6 +288,7 @@ static void __free_page_ext(unsigned long pfn)
 	base = get_entry(ms->page_ext, pfn);
 	free_page_ext(base);
 	ms->page_ext = NULL;
+	kmemleak_free(base);
 }
 
 static int __meminit online_page_ext(unsigned long start_pfn,
-- 
2.17.2 (Apple Git-113)

