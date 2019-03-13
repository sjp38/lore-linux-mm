Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E56EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 21:09:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55D802070D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 21:09:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="FuKlcEr+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55D802070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED2938E000C; Wed, 13 Mar 2019 17:09:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E82D78E0001; Wed, 13 Mar 2019 17:09:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D99368E000C; Wed, 13 Mar 2019 17:09:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA1558E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 17:09:58 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id b188so2816079qkg.15
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:09:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=yntyjzFMcFh+bacgvW8ewUIkqWqdqwu7OHwrppRgspA=;
        b=BAEoGyLQKTLUIO9aAcF+YOfmjWBKYPKfoIoMslX9Eora03RgmaZViFrcoDVF4GhH/f
         lEYAmfRMtoaufN+99/awDKxzWmVTUuv7z89jtSJtrhwtlcrQ4Epklx+cjzedQD2jzQdp
         agmfXQA8Ksi1Gm3y6xO+vBKuL+cHMSJ8pAvazn5s0DuvO8FkbX/XDfxGKpjt8f5jQKuz
         aSkB4JYV02pIUT+/VRal3q38Glc6tOqPs2rE2/AGHxRkU46oGP4fLUeVR3Byp5n3ukRJ
         657my6Dlehq+tqwm8lZH0TJuhgWBmhm8DWSK7AIdufo2ybVtpf1Tudn2pMnvV5vIT0rR
         a86Q==
X-Gm-Message-State: APjAAAXn47kLRIxy1prcqSggKhVuwMLM17WcLHZYDHMyKuXSy2UKpTc8
	tRl8UPsZtNeTau9w/fECteVsnI9RZSzXjHxZN09nczRegWhuZUZTzDVJ7vw6DwZYgy2lJfO4VSz
	3huJ7qzDhNJMrXPf77dGi0dRAjJFeQK0aQHbEHZ0Cwb0Y+S0INREGVW9QzZtWejRtWFEJ/9vjiV
	gnmzU7iSEe7jPTzueurLoebNl/M6/Uz+L/YW4BFtkBg8ldQ0m+ix32Nxgb9oHRgXY1SPQMnFnZA
	xn8dPu5rcTsleot4xOH6ZBDbrAtru3x9i9YEq5ieZFIlyIjvxB8klpDfj+kTvN3nRuCi86780KS
	XCqGWXRstbdUNl0D9eY4ypbW9SIcXe8R473jpWmxKn8koViLKdrj7LAH3SGSM9kXB3QjudoMmxT
	I
X-Received: by 2002:ac8:2847:: with SMTP id 7mr35596746qtr.335.1552511398312;
        Wed, 13 Mar 2019 14:09:58 -0700 (PDT)
X-Received: by 2002:ac8:2847:: with SMTP id 7mr35596699qtr.335.1552511397538;
        Wed, 13 Mar 2019 14:09:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552511397; cv=none;
        d=google.com; s=arc-20160816;
        b=PB9zrPNCoPPkTWw1iJaX7ZwBq0CJHE/c4pV1vugCPOP3E9L+lkMLmjnIKo7l5Qa5YT
         UGBJLwIZM/0v5mThvyMITaY2ESLTgKSGEfX7KfgY2NPhWBqXh2gcvWmqEFCojAKckwRP
         L5asnsG+41WQqtq/aeqSYdprOdAOo2gN1WeYL8iieycz+ncUPAKNXP/Q8A4eeKfqZJGc
         NI06cZQYI1elsyAWkaNxm7LxHCTF/WnnEu9if4kAMs/ICLBkzdEBzjzVn6+kNpYhRrgj
         7bUH7jIlmzBMM1/g8lRLZzUc6IEBJJU1c72yt3W3g5qb+imsHSxnmvC8fWn3VDzq33DV
         MAcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=yntyjzFMcFh+bacgvW8ewUIkqWqdqwu7OHwrppRgspA=;
        b=p51x6XOoJjrRqODrLAIQLMNE6MIKoSdJuTf6kUol6uHslGzzXkYS7T494v/n6z+iOQ
         oQMkIVyorSpCfJ6N0lvSAxz01ftS3zwTIahs+JsFmt8XFXSWNtmQVkFWN8rnnFc6oVez
         3glgwyltBIs9q2SWFrEVi6OzKlVNzMnaZKg4Bg8blEbNzFUvLidHvQ591HCrFBHlGDTp
         /s1Xd+YRCUIznxUJ46oXq0QIhaEw9PB18+U+DlWCui+bZ1Ir3A2LL1urd+M/H4Gj6kBq
         itQjkoFlXeTDcJ8yMB/zlgWgmRtHeVWiq4T8P4rE8BinuzDJJHieGCXwNbHVcG4MmbyG
         a2ag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=FuKlcEr+;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d3sor14105799qvc.35.2019.03.13.14.09.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 14:09:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=FuKlcEr+;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=yntyjzFMcFh+bacgvW8ewUIkqWqdqwu7OHwrppRgspA=;
        b=FuKlcEr+VJzGaq58c78qb6CXUp6wn4LjnxWHjBA3UeCUhcmCH8GBz+PM9Cn6v3qDz6
         sHLwNji6BXocYx5PWJOAOS14pyrVEMW0g2dxZ7gQEGT+PxeTMtvh8mxAFmObxt3GgGr2
         Yr0qh9L3RkzHgin7wxxZ1k7b5h2IW4BMPUw/plGF5u1wx4YPMKtowpUhGJ5pwxDhK2gR
         0yROEK+C02n/nrK2NIL/EiYkynHX8uwfFPH0brSlQ6vMe0TSCIpRsBzZMBJHp2aJHyI8
         /zPOPRdykBBXE50ynBbl26ifDajWmdrMz1JKSJPCT+zFc4vQ66fv8l+Q3QyXRC4/m5XY
         DQ+w==
X-Google-Smtp-Source: APXvYqzmqivJugqv3R7qcZOh+9VRMCcmrhHWNgZ1gdV6C9cKprn+dRNFjSCNIZiiWsANa/GfBjWa8Q==
X-Received: by 2002:a0c:9dda:: with SMTP id p26mr36410060qvf.134.1552511397101;
        Wed, 13 Mar 2019 14:09:57 -0700 (PDT)
Received: from ovpn-121-103.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id r58sm8780766qtr.24.2019.03.13.14.09.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 14:09:56 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	osalvador@suse.de,
	anshuman.khandual@arm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/hotplug: fix notification in offline error path
Date: Wed, 13 Mar 2019 17:09:39 -0400
Message-Id: <20190313210939.49628-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When start_isolate_page_range() returned -EBUSY in __offline_pages(), it
calls memory_notify(MEM_CANCEL_OFFLINE, &arg) with an uninitialized
"arg". As the result, it triggers warnings below. Also, it is only
necessary to notify MEM_CANCEL_OFFLINE after MEM_GOING_OFFLINE.

page:ffffea0001200000 count:1 mapcount:0 mapping:0000000000000000
index:0x0
flags: 0x3fffe000001000(reserved)
raw: 003fffe000001000 ffffea0001200008 ffffea0001200008 0000000000000000
raw: 0000000000000000 0000000000000000 00000001ffffffff 0000000000000000
page dumped because: unmovable page
WARNING: CPU: 25 PID: 1665 at mm/kasan/common.c:665
kasan_mem_notifier+0x34/0x23b
CPU: 25 PID: 1665 Comm: bash Tainted: G        W         5.0.0+ #94
Hardware name: HP ProLiant DL180 Gen9/ProLiant DL180 Gen9, BIOS U20
10/25/2017
RIP: 0010:kasan_mem_notifier+0x34/0x23b
RSP: 0018:ffff8883ec737890 EFLAGS: 00010206
RAX: 0000000000000246 RBX: ff10f0f4435f1000 RCX: f887a7a21af88000
RDX: dffffc0000000000 RSI: 0000000000000020 RDI: ffff8881f221af88
RBP: ffff8883ec737898 R08: ffff888000000000 R09: ffffffffb0bddcd0
R10: ffffed103e857088 R11: ffff8881f42b8443 R12: dffffc0000000000
R13: 00000000fffffff9 R14: dffffc0000000000 R15: 0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000560fbd31d730 CR3: 00000004049c6003 CR4: 00000000001606a0
Call Trace:
 notifier_call_chain+0xbf/0x130
 __blocking_notifier_call_chain+0x76/0xc0
 blocking_notifier_call_chain+0x16/0x20
 memory_notify+0x1b/0x20
 __offline_pages+0x3e2/0x1210
 offline_pages+0x11/0x20
 memory_block_action+0x144/0x300
 memory_subsys_offline+0xe5/0x170
 device_offline+0x13f/0x1e0
 state_store+0xeb/0x110
 dev_attr_store+0x3f/0x70
 sysfs_kf_write+0x104/0x150
 kernfs_fop_write+0x25c/0x410
 __vfs_write+0x66/0x120
 vfs_write+0x15a/0x4f0
 ksys_write+0xd2/0x1b0
 __x64_sys_write+0x73/0xb0
 do_syscall_64+0xeb/0xb78
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x7f14f75cc3b8
RSP: 002b:00007ffe84d01d68 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000008 RCX: 00007f14f75cc3b8
RDX: 0000000000000008 RSI: 0000563f8e433d70 RDI: 0000000000000001
RBP: 0000563f8e433d70 R08: 000000000000000a R09: 00007ffe84d018f0
R10: 000000000000000a R11: 0000000000000246 R12: 00007f14f789e780
R13: 0000000000000008 R14: 00007f14f7899740 R15: 0000000000000008

Fixes: 7960509329c2 ("mm, memory_hotplug: print reason for the offlining failure")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8ffe844766da..1559c1605072 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1703,12 +1703,12 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 failed_removal_isolated:
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 failed_removal:
 	pr_debug("memory offlining [mem %#010llx-%#010llx] failed due to %s\n",
 		 (unsigned long long) start_pfn << PAGE_SHIFT,
 		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1,
 		 reason);
-	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 	/* pushback to free area */
 	mem_hotplug_done();
 	return ret;
-- 
2.17.2 (Apple Git-113)

