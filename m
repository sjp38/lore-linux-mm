Return-Path: <SRS0=s2+Z=O6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4843CC43387
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 06:28:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2C4C218FD
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 06:28:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2C4C218FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A27248E0005; Fri, 21 Dec 2018 01:28:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D3B78E0001; Fri, 21 Dec 2018 01:28:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C2848E0005; Fri, 21 Dec 2018 01:28:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 342798E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 01:28:23 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c53so4996961edc.9
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 22:28:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=HS4LqYa5zMLrFex9YH/ZvG6EKsMIcwd62UdOqCIKPu8=;
        b=gt+rrnZaapRhWMHj25IfRzX6soNxyNltwF3qy1U4Y5QfiOitT6B1+E6/dvkA9E3Uzi
         HBrviU5SQNm0iH6o7i2Tf41b5ipmsemltd7J0KXxSZJp93Vyx0yR7Q63lI7c+hkPPWP9
         RmFLMrZFmDF7JkjsMkEhQMDp9xQYoI06cLoX7QEfLEFoAD5OgAtrUPoDShmmOk5i33+N
         MMrUyMkQ3lJdj2Yum66a/uU35uBXexSmcw2h7NoqGF2l2UZjFO4gFQluWWOJsS6yqCAo
         5ZvwgYyFGg+MsqXDNW3SRuaptnFFM9Yin7kqZiKz0GItPbaQAYtW8vW69HJNeBynxNQa
         3frQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AA+aEWbcB+9Hfcu1csgwoiTU19Es6z3VIfSYbR5u51bDhGVbbndfhcV2
	UBD0gWz8pFDsvxFdp2ar8Vefj+WVm8JSMcpFavqAcAURhk+4SkPZdTeXWBYdLDsVYRi5jN4OJda
	BHoM4a4rwq/0/eTaIDGfwbScxxkTZ9da28EPIHuKqL8fRribsMP8OwC5ZLbqkM6YuJQ==
X-Received: by 2002:a50:b837:: with SMTP id j52mr1348007ede.73.1545373702683;
        Thu, 20 Dec 2018 22:28:22 -0800 (PST)
X-Google-Smtp-Source: AFSGD/X2T1+2NKX5Rw2tPpi1A0qFb8OO7wo9SyzjBVwRlxlyfKdFbuoCva0pq3QSxq1Arwh6LRus
X-Received: by 2002:a50:b837:: with SMTP id j52mr1347962ede.73.1545373701333;
        Thu, 20 Dec 2018 22:28:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545373701; cv=none;
        d=google.com; s=arc-20160816;
        b=gz5DN74VHECccbGIg5fmXWuuMMJmoZxMTninuVPZcVUEJa6/HjaIkL5zDMW0S5OYAt
         cFTn6EAGVf0EgrsW/i6UZFX2JW1qAgI2AzN6UeWW9/JGzTEw7fEaKKIRJnWISnhxC0cd
         geqNCEYSZAqfUmixhkbk5ocsN+K1hLNnMAunbmcC3lfZe5rJz2ZH9BqFu66aWPJ4TP+j
         D61OGfTEHQnW9B6GUVxGT4XqK2a7JyKnRneNxAvIOnMq9GBe/T/PlMuty2FSfcQPfD0h
         ruy0DZ20IdpesF5kxXSC2p7cJCppcJuPLpnf6jL6PFnnLl1QVuz+OkZHod2A3TnByKRa
         i+0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=HS4LqYa5zMLrFex9YH/ZvG6EKsMIcwd62UdOqCIKPu8=;
        b=oB7fGiqG7RPkUtSfp6wK5y7XXrM+sjGHHbJgfS2SaKQ/1nFnB7hfRQF9UPystHcT1d
         7oPLNwjhUnf4ILTXPP1BqTc5l17YlXdGgIowAAk7A6kv2zdnOhQ/BRxzGXzvz9SCvFyc
         qvOZWehwdCnrJKit3FfIZ40zjL9Hzj7m6pIAJMXVDzKNoRjtmlwD00hMtgQpxQGn/hwo
         byy+yqGq3/tHer2W4FB+H0KfAA22gYG8COCULFR3B99k+Yhm98rvmuTWHHscVkLVWzQA
         mjGuWK3SdK+7kUzwJlbUwdkPsp2TXdI3xhm6iU7MZl3Wbf0z1RnkOY07PnqV9MpeTYn+
         aLIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id gp17-v6si1240695ejb.103.2018.12.20.22.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 22:28:21 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Fri, 21 Dec 2018 07:28:20 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Fri, 21 Dec 2018 06:28:17 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	vbabka@suse.cz,
	pavel.tatashin@microsoft.com,
	rppt@linux.vnet.ibm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v3] mm, page_alloc: Fix has_unmovable_pages for HugePages
Date: Fri, 21 Dec 2018 07:28:09 +0100
Message-Id: <20181221062809.31771-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20181221062809.4a6XAfcevBvwifZIWk-kExC8j7-yW5dJccCY247RwUw@z>

v3 -> v2: Get rid of the round_up()
v2 -> v1: Adjust skip pages logic per Michal

From 8c057ff497a078f28e293af8c0bd089893a57753 Mon Sep 17 00:00:00 2001
From: Oscar Salvador <osalvador@suse.de>
Date: Wed, 19 Dec 2018 00:04:18 +0000
Subject: [PATCH] mm, page_alloc: fix has_unmovable_pages for HugePages

While playing with gigantic hugepages and memory_hotplug, I triggered the
following #PF when "cat memoryX/removable":

<---
kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
kernel: #PF error: [normal kernel read fault]
kernel: PGD 0 P4D 0
kernel: Oops: 0000 [#1] SMP PTI
kernel: CPU: 1 PID: 1481 Comm: cat Tainted: G            E     4.20.0-rc6-mm1-1-default+ #18
kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
kernel: RIP: 0010:has_unmovable_pages+0x154/0x210
kernel: Code: 1b ff ff ff eb 32 48 8b 45 00 bf 00 10 00 00 a9 00 00 01 00 74 07 0f b6 4d 51 48 d3 e7 e8 c4 81 05 00 48 85 c0 49 89 c1 75 7e <41> 8b 41 08 83 f8 09 74 41 83 f8 1b 74 3c 4d 2b 64 24 58 49 81 ec
kernel: RSP: 0018:ffffc90000a1fd30 EFLAGS: 00010246
kernel: RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000009
kernel: RDX: ffffffff82aed4f0 RSI: 0000000000001000 RDI: 0000000000001000
kernel: RBP: ffffea0001800000 R08: 0000000000200000 R09: 0000000000000000
kernel: R10: 0000000000001000 R11: 0000000000000003 R12: ffff88813ffd45c0
kernel: R13: 0000000000060000 R14: 0000000000000001 R15: ffffea0000000000
kernel: FS:  00007fd71d9b3500(0000) GS:ffff88813bb00000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
kernel: CR2: 0000000000000008 CR3: 00000001371c2002 CR4: 00000000003606e0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
kernel: Call Trace:
kernel:  is_mem_section_removable+0x7d/0x100
kernel:  removable_show+0x90/0xb0
kernel:  dev_attr_show+0x1c/0x50
kernel:  sysfs_kf_seq_show+0xca/0x1b0
kernel:  seq_read+0x133/0x380
kernel:  __vfs_read+0x26/0x180
kernel:  vfs_read+0x89/0x140
kernel:  ksys_read+0x42/0x90
kernel:  do_syscall_64+0x5b/0x180
kernel:  entry_SYSCALL_64_after_hwframe+0x44/0xa9
kernel: RIP: 0033:0x7fd71d4c8b41
kernel: Code: fe ff ff 48 8d 3d 27 9e 09 00 48 83 ec 08 e8 96 02 02 00 66 0f 1f 44 00 00 8b 05 ea fc 2c 00 48 63 ff 85 c0 75 13 31 c0 0f 05 <48> 3d 00 f0 ff ff 77 57 f3 c3 0f 1f 44 00 00 55 53 48 89 d5 48 89
kernel: RSP: 002b:00007ffeab5f6448 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
kernel: RAX: ffffffffffffffda RBX: 0000000000020000 RCX: 00007fd71d4c8b41
kernel: RDX: 0000000000020000 RSI: 00007fd71d809000 RDI: 0000000000000003
kernel: RBP: 0000000000020000 R08: ffffffffffffffff R09: 0000000000000000
kernel: R10: 000000000000038b R11: 0000000000000246 R12: 00007fd71d809000
kernel: R13: 0000000000000003 R14: 00007fd71d80900f R15: 0000000000020000
kernel: Modules linked in: af_packet(E) xt_tcpudp(E) ipt_REJECT(E) xt_conntrack(E) nf_conntrack(E) nf_defrag_ipv4(E) ip_set(E) nfnetlink(E) ebtable_nat(E) ebtable_broute(E) bridge(E) stp(E) llc(E) iptable_mangle(E) iptable_raw(E) iptable_security(E) ebtable_filter(E) ebtables(E) iptable_filter(E) ip_tables(E) x_tables(E) kvm_intel(E) kvm(E) irqbypass(E) crct10dif_pclmul(E) crc32_pclmul(E) ghash_clmulni_intel(E) bochs_drm(E) ttm(E) drm_kms_helper(E) drm(E) aesni_intel(E) virtio_net(E) syscopyarea(E) net_failover(E) sysfillrect(E) failover(E) aes_x86_64(E) crypto_simd(E) sysimgblt(E) cryptd(E) pcspkr(E) glue_helper(E) parport_pc(E) fb_sys_fops(E) i2c_piix4(E) parport(E) button(E) btrfs(E) libcrc32c(E) xor(E) zstd_decompress(E) zstd_compress(E) raid6_pq(E) sd_mod(E) ata_generic(E) ata_piix(E) ahci(E) libahci(E) serio_raw(E) crc32c_intel(E) virtio_pci(E) virtio_ring(E) virtio(E) libata(E) sg(E) scsi_mod(E) autofs4(E)
kernel: CR2: 0000000000000008
kernel: ---[ end trace 49cade81474e40e7 ]---
kernel: RIP: 0010:has_unmovable_pages+0x154/0x210
kernel: Code: 1b ff ff ff eb 32 48 8b 45 00 bf 00 10 00 00 a9 00 00 01 00 74 07 0f b6 4d 51 48 d3 e7 e8 c4 81 05 00 48 85 c0 49 89 c1 75 7e <41> 8b 41 08 83 f8 09 74 41 83 f8 1b 74 3c 4d 2b 64 24 58 49 81 ec
kernel: RSP: 0018:ffffc90000a1fd30 EFLAGS: 00010246
kernel: RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000009
kernel: RDX: ffffffff82aed4f0 RSI: 0000000000001000 RDI: 0000000000001000
kernel: RBP: ffffea0001800000 R08: 0000000000200000 R09: 0000000000000000
kernel: R10: 0000000000001000 R11: 0000000000000003 R12: ffff88813ffd45c0
kernel: R13: 0000000000060000 R14: 0000000000000001 R15: ffffea0000000000
kernel: FS:  00007fd71d9b3500(0000) GS:ffff88813bb00000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
kernel: CR2: 0000000000000008 CR3: 00000001371c2002 CR4: 00000000003606e0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
--->

The reason is we do not pass the Head to page_hstate(), and so, the call
to compound_order() in page_hstate() returns 0, so we end up checking all
hstates's size to match PAGE_SIZE.

Obviously, we do not find any hstate matching that size, and we return
NULL.  Then, we dereference that NULL pointer in
hugepage_migration_supported() and we got the #PF from above.

Fix that by getting the head page before calling page_hstate().

Also, since gigantic pages span several pageblocks, re-adjust the logic
for skipping pages.
While are it, we can also get rid of the round_up().

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ec9cc407216..995d1079f958 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7802,11 +7802,14 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		 * handle each tail page individually in migration.
 		 */
 		if (PageHuge(page)) {
+			struct page *head = compound_head(page);
+			unsigned int skip_pages;
 
-			if (!hugepage_migration_supported(page_hstate(page)))
+			if (!hugepage_migration_supported(page_hstate(head)))
 				goto unmovable;
 
-			iter = round_up(iter + 1, 1<<compound_order(page)) - 1;
+			skip_pages = (1 << compound_order(head)) - (page - head);
+			iter += skip_pages - 1;
 			continue;
 		}
 
-- 
2.13.7

