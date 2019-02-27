Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33A08C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:32:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE78620C01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:32:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ItGXDQJU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE78620C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7986A8E000A; Wed, 27 Feb 2019 12:32:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 748008E0001; Wed, 27 Feb 2019 12:32:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6380C8E000A; Wed, 27 Feb 2019 12:32:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 363D18E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:32:01 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 207so13770561qkf.9
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:32:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=hHOFyrwpvydWZWAGP6U/o0hZfnIdyhgSbo6ZXDL9wn0=;
        b=H7ESbkldHb0o2SMpiZC9HqosZQLvAWhKvoWq3CrA+rN4olixJpJ9Fz6Jm4UYojjtWY
         DZS6MmX61DguW374vcynFQPbKOANIPDLOyYGu4E0yMxHihdCzYXqCDyrpXliJwRdjqlq
         4qZLBI82ci/YeiGheO4Qb8FmF04EV54/clI4760kvFLqt1ai96cwlXW9+C0lch+y2fon
         ShWuHKTFjo39R/im66jUZf0MY+oreE3X1jPWiwU25pxR1fEehTEK+C0N7Khd0RHVhsm/
         CL7Vf3SrUc0OJu8s74p/4LXZzcCWoZylne33D9X0nrQNxpVfcVICyEFzCYTS3M2lQ0BG
         qQTg==
X-Gm-Message-State: AHQUAuYxbjv5fQquCkCa4ACv3rdDenkCBtJecpMwEXZj9eCZH8Blz06U
	P6+SumPVH9QeE3qS/xtj9XmJ2QqhTi9IYX6/Pk+oOl7r2+PE/rLM6Tll/w0hoe1PkpWe7eqReNL
	qxHxuJ6E03GUMR+VVi/xtSfAOYMU8Gzix3amocuk/Ke0Xeyq0dPLayzgh0eXNrfm7/ckaDlqTLR
	uB076ZJr+Y+Akj/m0dRnDFc3CrJhdj1+zCDUkfRAnPJ8m641FsK9P1z0tXn9B4gf17BXOOhdmhE
	YL5Pzq503mNiF2ZcDw7mjNTKO4+827NpaJlkQ8MgKZh+AP3j9QxO5swFXUDlVclO3Q10SSnmvUA
	+bKqVM7l/EaOe8fwr4mwvRRKlBowZ+rzPYcffTuFFtaKpnjksSk4QqOR681xqnVji4ogjhJdoXG
	t
X-Received: by 2002:aed:3f05:: with SMTP id p5mr2609146qtf.114.1551288720935;
        Wed, 27 Feb 2019 09:32:00 -0800 (PST)
X-Received: by 2002:aed:3f05:: with SMTP id p5mr2609085qtf.114.1551288719932;
        Wed, 27 Feb 2019 09:31:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551288719; cv=none;
        d=google.com; s=arc-20160816;
        b=lZKDh4NOPY7uVbGQilHrUpIfY9Ehq9fRSh8BeJ+DB1OaZqE/ZRqG4h7NgagLRk4AWC
         B20XH+lCy6QVmjxFkPBgpPEFqI4Cp3jwHEucd45XNc3N2Yc6cfAM3DhZSsHcqJ4Pqf8Y
         hjqdZXFi4cRNHBnWu6OY49lQPcEj5Paxg8PHWEAh1qNIO4ahJhrDM8DRNkPbk+wemNTW
         BSRI+B1DtG5GkT2gNL9K2R7dq78CBUbPWUKsK4G2ZXXgeVhxqNUZq+vn9LQMII8A5pH2
         dTnyqH7qg8rj5st54/UpQAWopYYNHDy7ClFGiA+F4z9oS7pb1cKavtnL4BUQ5BYP+ONA
         lAsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=hHOFyrwpvydWZWAGP6U/o0hZfnIdyhgSbo6ZXDL9wn0=;
        b=V3Aw9EVtb+YNN8+Yians0dM3ZC+ym6oM+GsFYLB9UaCOgVTGePLzlIdgIWb6nLZ9v1
         iaULVZB446I13FlprJyCvymiaVX0NcLfWLqVfiamZYO8dgCwGOcUovf/I5rpdAznORcP
         1YufP8me1Vo1x1DmuDih6PfalVFDHDBaZ2lcZ17KSDUN46rdw2f1RVqgc2xAE29oR8dV
         1kfgrSDpSBJcRHkN2lLyoFoe6bdKLkw2j+m0L4CTcQi4XamBqZaYTqk7TtiCoRLyp6CK
         CSjeKgOMw6UQN7OpKoW57fybOu60YAnbERUR/xgEoPpLjvzPiacYc/HYAK2oa0xZCAdK
         Jc0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ItGXDQJU;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v62sor10151921qkb.31.2019.02.27.09.31.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 09:31:59 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ItGXDQJU;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=hHOFyrwpvydWZWAGP6U/o0hZfnIdyhgSbo6ZXDL9wn0=;
        b=ItGXDQJUi8BRiSGj0pyl/Kn/YqJ5yf8lpj/i2XXCdbi4r6RjSt7DYHoS3qwPzwI38S
         cMt4ZvJUnP2O5ZoALi4sip/uocmzwODpeMJA2MQdjz2aHcucKeHvti+pLxzzJFjY4v7R
         0299Nk5/xQQ0hQ835FJNv9CWKfK3YiQCraqePUSb9rkm86alLI5fdzOcIOzwCE0WsnLH
         lU4YSw8Ryozy6wWjRfpZS9B4Myjv8VfS1gCK8H4148RZFin6T1tUzhQRV1AmG5bKZNkJ
         dGlUJfDoBwVTHSXrt8cfhuGma9VmXAkw2WvHXPU8ec+Rv4mBIASAm17EHJy8ogZa+2Ql
         bJUg==
X-Google-Smtp-Source: AHgI3IYWMSSx9Xalb1WB5XlJJM4CY4wMH21644s0iZYtwCOYjPJzMh8Q3vkWlhUhWuYZIeiy2M0D5Q==
X-Received: by 2002:a37:d1d2:: with SMTP id o79mr3196699qkl.98.1551288719613;
        Wed, 27 Feb 2019 09:31:59 -0800 (PST)
Received: from Qians-MBP.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id y11sm14233372qky.2.2019.02.27.09.31.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 09:31:59 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v3] mm/page_ext: fix an imbalance with kmemleak
Date: Wed, 27 Feb 2019 12:31:47 -0500
Message-Id: <20190227173147.75650-1-cai@lca.pw>
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

v3: place kmemleak_free() before free_pages_exact() to avoid a small window
    where the address has been freed but kmemleak not informed pointed out by
    Catalin.

v2: move kmemleak_free() into free_page_ext() as there is no need to call
    kmemleak_free() in the vfree() case.

 mm/page_ext.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 8c78b8d45117..f116431c3dee 100644
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
2.17.2 (Apple Git-113)

