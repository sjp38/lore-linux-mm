Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A0ABC10F00
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 12:18:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C04032186A
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 12:18:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C04032186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 230616B027C; Fri, 15 Mar 2019 08:18:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DF4B6B027E; Fri, 15 Mar 2019 08:18:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CF9D6B027F; Fri, 15 Mar 2019 08:18:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9C086B027C
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 08:18:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p4so3804576edd.0
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 05:18:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=mbXZJOi2PLydjdBD/9vTz7QBDlvp7WkjKxgsGkpp2Ys=;
        b=twjU73yySJszja2lNdWtEvT86iHTlEkvWnsTvx2oevJ7ZxeWsV2xNkDixGTUgAMfyw
         ofAoiEdfqVtWA5TbQ1oYYHeUThZAUu3m+X4AeUi0dG624WzHAbNFRPMUa6qoXYf4DJnp
         1b7/xjkJizieGhk5YVEQk5FOBj2K8eRJgmNB3NTOiE4Gle+KtBI5zQrI45vBDPjap/Z8
         AKEgXgj+rZ9l1QhpJMPw/IFt4UTvdmSDpE2rAkCQwkzJVVt/Ywe/vT3bTHCBBi2qvkRS
         EGuZT+Ns05/C66Tp6SSdbtfMQ9y73zzYR2BiIoi5FwnkeAB7+J9UlLaY06FdVZ2Jy1jv
         UfhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWhyY9NeJahVlitR3NgvSHt3WsSOUj3rw4Idpv+YBxUiQNrQOTW
	CDnWY4Kt3wnhB06e0sYeFtW+6uOXsBzN+oDJQP/IBeieOIaj2mpNr2RMdbRET3EW0Ai+ToF0t/S
	BY/LefNVk4WrCwIw9kDU5Z76mMvWAjhAfOEADN63eweWPFo38lbUqIWL4MPye+i+8rA==
X-Received: by 2002:a05:6402:13c2:: with SMTP id a2mr2490010edx.69.1552652332131;
        Fri, 15 Mar 2019 05:18:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjZt2SJn4H6HnFUYDR4CMLKuX8fyn9sLiTA0vXDBzv8dRZk1KXWQrfXDkfGPwI91dwBM9e
X-Received: by 2002:a05:6402:13c2:: with SMTP id a2mr2489932edx.69.1552652330489;
        Fri, 15 Mar 2019 05:18:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552652330; cv=none;
        d=google.com; s=arc-20160816;
        b=dXX6RCzWnfD8LjvkA/w4T6LTsyoOm7k1v71MMMpChRY3qeC7M27zkCfNqR4B68/Guh
         vERNyCdnhRjSu7osaRxdP26R8SpfjmR5H3N+nUrx+6skYz3arQjD8D1TrbTDxCQOpTUE
         MEJxYh023fu0+H9L0uh/XgDuDn/m+4sHXDvgEZ2050Jg4vCa+om1g1m25nYUKWFkMZxQ
         L2KLD6LAzJJ1zX4jNCWmNbVZiL5j6gKhRhEzc+2Y74x2UTBGyyl3E84PPE91tkWhY+a4
         6V0fCwrX+usxT3099nlBKp1sdLfYC6wmdpb0lHDw0n98Os3bsr7WGvMuDosb+7UkewUx
         3OsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=mbXZJOi2PLydjdBD/9vTz7QBDlvp7WkjKxgsGkpp2Ys=;
        b=rUcaA3Fyo88UvCmktFyWfZaP7gdV2tEL6aUZKM9Tg0xuNxVvlQ9+uHqDz5UNvkFoC+
         gRTwvmo8pHnREiNy7AafIO0aCt26VNDngeV8GadZs5xuWIT372A5IRMoO5uyPtHkUxZB
         GNyHowpIqo2c0VVp6rFxc6fMC8Hl8Rhz/DrpBXs0FckbJUIv71d62lEtKHKuiqoR5k3c
         GgYryvC6JiG9CHExYtzzqaOX55YIWwojknxWEFfceDj2GNE/qVwoxWTf/V5pSfHuKVPG
         nfbv9011L/AIzRTZ3tvDx7CovKZlLGGLwcuAl7NMhgZ3oy5iV4Jf658/wnHZHSjlGrMI
         svhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id f9si353033ede.17.2019.03.15.05.18.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 05:18:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Fri, 15 Mar 2019 13:18:49 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Fri, 15 Mar 2019 12:18:32 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	anshuman.khandual@arm.com,
	william.kucharski@oracle.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH] mm: Fix __dump_page when mapping->host is not set
Date: Fri, 15 Mar 2019 13:18:26 +0100
Message-Id: <20190315121826.23609-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

While debugging something, I added a dump_page() into do_swap_page(),
and I got the splat from below.
The issue happens when dereferencing mapping->host in __dump_page():

...
else if (mapping) {
	pr_warn("%ps ", mapping->a_ops);
	if (mapping->host->i_dentry.first) {
		struct dentry *dentry;
		dentry = container_of(mapping->host->i_dentry.first, struct dentry, d_u.d_alias);
		pr_warn("name:\"%pd\" ", dentry);
	}
}
...

Swap address space does not contain an inode information, and so mapping->host
equals NULL.

Although the dump_page() call was added artificially into do_swap_page(),
I am not sure if we can hit this from any other path, so it looks worth
fixing it.
We can easily do that by cheking mapping->host first.

Splat:

kernel: page:ffffea0000630180 count:3 mapcount:0 mapping:0000000000000000 index:0x0
kernel: swap_aops
kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000138
kernel: #PF error: [normal kernel read fault]
kernel: PGD 800000001eaea067 P4D 800000001eaea067 PUD 1eae9067 PMD 0
kernel: Oops: 0000 [#1] SMP PTI
kernel: CPU: 0 PID: 1522 Comm: __mremap Tainted: G            E     5.0.0-rc8-mm1-1-default+ #43
kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
kernel: RIP: 0010:__dump_page+0x2d6/0x380
kernel: Code: ff 48 c7 c7 4d ac e3 81 31 c0 e8 e9 03 ef ff e9 27 fe ff ff 49 8b 75 70 31 c0 48 c7 c7 55 ac e3 81 e8 d2 03 ef ff 49 8b 45 00 <48> 8b 80 38 01 00 00 48 85 c0 0f 84 01 fe ff ff 48 8d b0 50 ff ff
kernel: RSP: 0000:ffffc900004c3ae0 EFLAGS: 00010296
kernel: RAX: 0000000000000000 RBX: ffffea0000630180 RCX: 0000000000000000
kernel: RDX: 000000000000000a RSI: ffffffff8276700c RDI: 0000000000000246
kernel: RBP: 0000000000000000 R08: ffffffff82767002 R09: 000000000000000a
kernel: R10: 00000000000005f2 R11: 0000000000012047 R12: ffffffff81e3b2d8
kernel: R13: ffff8880184e60a0 R14: ffff888013095100 R15: ffffea0000630180
kernel: FS:  00007f141813d4c0(0000) GS:ffff88801f200000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
kernel: CR2: 0000000000000138 CR3: 000000001eaf2005 CR4: 00000000003606b0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
kernel: Call Trace:
kernel:  dump_page+0xe/0x20
kernel:  do_swap_page+0x6a0/0xa10
kernel:  __handle_mm_fault+0xa7f/0xc00
kernel:  handle_mm_fault+0xfa/0x210
kernel:  __do_page_fault+0x1f4/0x490
kernel:  do_page_fault+0x32/0x140
kernel:  async_page_fault+0x1e/0x30
kernel: RIP: 0010:copy_user_generic_unrolled+0xa0/0xc0
kernel: Code: 7f 40 ff c9 75 b6 89 d1 83 e2 07 c1 e9 03 74 12 4c 8b 06 4c 89 07 48 8d 76 08 48 8d 7f 08 ff c9 75 ee 21 d2 74 10 89 d1 8a 06 <88> 07 48 ff c6 48 ff c7 ff c9 75 f2 31 c0 0f 01 ca c3 66 66 2e 0f
kernel: RSP: 0018:ffffc900004c3d90 EFLAGS: 00050202
kernel: RAX: 00000000013a620a RBX: 0000000000000001 RCX: 0000000000000001
kernel: RDX: 0000000000000001 RSI: ffffc9000025f07a RDI: 00000000013a6260
kernel: RBP: ffff8880195fa400 R08: ffffc9000025f000 R09: 000000000000001c
kernel: R10: 0000000000000001 R11: 0000000000000fe4 R12: 7fffffffffffffff
kernel: R13: 0000000000000000 R14: 00000000013a6260 R15: 0000000000000000
kernel:  _copy_to_user+0x22/0x30
kernel:  n_tty_read+0x725/0x8d0
kernel:  ? do_wait_intr_irq+0xa0/0xa0
kernel:  tty_read+0x90/0xf0
kernel:  vfs_read+0x89/0x140
kernel:  ksys_read+0x42/0x90
kernel:  do_syscall_64+0x5b/0x180
kernel:  entry_SYSCALL_64_after_hwframe+0x44/0xa9
kernel: RIP: 0033:0x7f1417c53b41
kernel: Code: Bad RIP value.
kernel: RSP: 002b:00007fffa7377d88 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
kernel: RAX: ffffffffffffffda RBX: 00007f1417f1e9e0 RCX: 00007f1417c53b41
kernel: RDX: 0000000000000400 RSI: 00000000013a6260 RDI: 0000000000000000
kernel: RBP: 0000000000000d68 R08: 00007f1417f20880 R09: 00007f141813d4c0
kernel: R10: 000000000000019b R11: 0000000000000246 R12: 00007f1417f1a8e0
kernel: R13: 00007f1417f1b420 R14: 00007f1417f1b420 R15: 0000000000000000
kernel: Modules linked in: parport_pc(E) af_packet(E) xt_tcpudp(E) ipt_REJECT(E) xt_conntrack(E) nf_conntrack(E) nf_defrag_ipv4(E) ip_set(E) nfnetlink(E) ebtable_nat(E) ebtable_broute(E) bridge(E) stp(E) llc(E) iptable_mangle(E) iptable_raw(E) iptable_security(E) ebtable_filter(E) ebtables(E) iptable_filter(E) ip_tables(E) x_tables(E) kvm_intel(E) kvm(E) irqbypass(E) crct10dif_pclmul(E) crc32_pclmul(E) ghash_clmulni_intel(E) aesni_intel(E) bochs_drm(E) aes_x86_64(E) crypto_simd(E) ttm(E) cryptd(E) glue_helper(E) drm_kms_helper(E) virtio_net(E) drm(E) net_failover(E) pcspkr(E) failover(E) syscopyarea(E) sysfillrect(E) sysimgblt(E) fb_sys_fops(E) i2c_piix4(E) parport(E) button(E) btrfs(E) libcrc32c(E) xor(E) zstd_decompress(E) zstd_compress(E) xxhash(E) raid6_pq(E) sd_mod(E) ata_generic(E) ata_piix(E) crc32c_intel(E) serio_raw(E) ahci(E) libahci(E) virtio_pci(E) virtio_ring(E) virtio(E) libata(E) sg(E) scsi_mod(E) autofs4(E)
kernel: CR2: 0000000000000138
kernel: ---[ end trace b061d02f3cb1a1d1 ]---
kernel: RIP: 0010:__dump_page+0x2d6/0x380
kernel: Code: ff 48 c7 c7 4d ac e3 81 31 c0 e8 e9 03 ef ff e9 27 fe ff ff 49 8b 75 70 31 c0 48 c7 c7 55 ac e3 81 e8 d2 03 ef ff 49 8b 45 00 <48> 8b 80 38 01 00 00 48 85 c0 0f 84 01 fe ff ff 48 8d b0 50 ff ff
kernel: RSP: 0000:ffffc900004c3ae0 EFLAGS: 00010296
kernel: RAX: 0000000000000000 RBX: ffffea0000630180 RCX: 0000000000000000
kernel: RDX: 000000000000000a RSI: ffffffff8276700c RDI: 0000000000000246
kernel: RBP: 0000000000000000 R08: ffffffff82767002 R09: 000000000000000a
kernel: R10: 00000000000005f2 R11: 0000000000012047 R12: ffffffff81e3b2d8
kernel: R13: ffff8880184e60a0 R14: ffff888013095100 R15: ffffea0000630180
kernel: FS:  00007f141813d4c0(0000) GS:ffff88801f200000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
kernel: CR2: 00007f1417c53b17 CR3: 000000001eaf2005 CR4: 00000000003606b0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400

Fixes: 1c6fb1d89e73c ("mm: print more information about mapping in __dump_page")
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/debug.c b/mm/debug.c
index c0b31b6c3877..7759f12a8fbb 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -79,7 +79,7 @@ void __dump_page(struct page *page, const char *reason)
 		pr_warn("ksm ");
 	else if (mapping) {
 		pr_warn("%ps ", mapping->a_ops);
-		if (mapping->host->i_dentry.first) {
+		if (mapping->host && mapping->host->i_dentry.first) {
 			struct dentry *dentry;
 			dentry = container_of(mapping->host->i_dentry.first, struct dentry, d_u.d_alias);
 			pr_warn("name:\"%pd\" ", dentry);
-- 
2.13.7

