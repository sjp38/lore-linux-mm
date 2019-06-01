Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29608C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 11:44:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9BDC271E0
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 11:44:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9BDC271E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=chris-wilson.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 195D16B0005; Sat,  1 Jun 2019 07:44:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 145F36B0006; Sat,  1 Jun 2019 07:44:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00E7A6B0007; Sat,  1 Jun 2019 07:44:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A81A16B0005
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 07:44:48 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id u11so5376184wri.19
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 04:44:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:to:from:in-reply-to:cc:references
         :message-id:user-agent:subject:date;
        bh=ka35Sj+c0xW7GPnQISyxBqgRz0G9Zc6Y29sZS5ggiAQ=;
        b=W3vUdcdHZe3DwpHuSE0g2gq3LIBnxG0DJWAheU9ViInPr8s/8EP/B8md35OUWGIcR1
         nZs5pEcD2KYB044EjsQ13ZmtzKj1/d/H5oGDwOdwSLLL5/pG7sJp7MNt1Au4/1Eh92vP
         KjensTTvgRe1lKjaf42VmSUFeRVYibnMYNzh/+7F2EfmNMAw/nXgNS6qOHQxzWiMBg09
         NGPffNH7SZ5zzgXYTYthSPjE6mD5ERBeY+QMFVebi3dp5S3V6l7tCMbEjAirKAuM8Bp6
         JsPPbwqFzIo9xdxMybSLyc1QyWEGODZcyWPbFmAHt5DES7snpPUQJKy6S0kv0JIcEst1
         N1qQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Gm-Message-State: APjAAAUMjApbQYkLRQzNeaXLLMc+bAGBunhReYk5Roe0zp3mjKqJ5zYI
	Kl02547hkKYIgSf3V6vgotL+BnxM8aTSau1dZpGsNyeJ2wxScmpBnQTWuV9qzH/so5OLLMhmdOh
	gLews4Qz8/bEweBoOBroGhe+3ywemVQWZPfIULal+JSo/www/r+mnHX6ZnwjNDJ4=
X-Received: by 2002:a1c:44d7:: with SMTP id r206mr8955312wma.164.1559389488036;
        Sat, 01 Jun 2019 04:44:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYsZTDT9sVO8FGuZEJcikBZahvL65+CpTL18H/SMmNMBB04zuIel8VKWeajTA9d2DoSHXR
X-Received: by 2002:a1c:44d7:: with SMTP id r206mr8955274wma.164.1559389486762;
        Sat, 01 Jun 2019 04:44:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559389486; cv=none;
        d=google.com; s=arc-20160816;
        b=B+NJYbPwBmyikAau0Vz1ZQ3WqyzipbaTIh0y7hu47q1NARHLDioZjl++tyw87bLa9j
         WM93MDuVUpc17TK6Vgr5d6Gs+2RFN7GgCKg9iF7z0uFa7QvhE0WHZHhScaAyzV3N9835
         oDUAhZrANeJAqC68LULIf34exq78VRF2/gTzCiEZhWSK8b6GeOa3L07XY75OjQ5r55xR
         v1M6066+yVE7YC5qbJ7qLIt4onjHDEpRLNiqOFXMIfEBG5LeDXjrjEi3s4N7m6NW23XA
         qEyKdMBkgzUXCPH0or4NkMZ7SHbaxcXWTDgG2vqm/2m7a2U46tcL2iNfqvoum3Gab60s
         hAZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:subject:user-agent:message-id:references:cc:in-reply-to:from
         :to:content-transfer-encoding:mime-version;
        bh=ka35Sj+c0xW7GPnQISyxBqgRz0G9Zc6Y29sZS5ggiAQ=;
        b=qjK5s+83t6PViDPDUNTHO/Z/gfQ6ny8kXuO0fniWR7xz3bKZtP1WSGkGk8DWY3EUra
         3wkypOsflFxNevEnHCoyNm+3BnpnLyssbLgPDZOqC0eFhxj515OUO774Ly0X4PTWIFHl
         +xSSReEnd35X8iST3R7O6Zw2mS2WDo1KOxEhHJOJn6jcvvql/HarOK7W2jr7GAXUYq1P
         BQlYDQWCAgdUJsyyzXfxDBULa2E6932u+3VjvMRg3nE3ZFo7j4qw3rLdktTZIgj4XDFD
         8DdvGHFvUMXWfSJYmcaZQZ4wr2rvnOmZFO4IM0r7Wg+A+DFE4CXMhHPUMfscANVNZZCg
         qHqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id w12si7305515wra.441.2019.06.01.04.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 04:44:46 -0700 (PDT)
Received-SPF: neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) client-ip=109.228.58.192;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Default-Received-SPF: pass (skip=forwardok (res=PASS)) x-ip-name=78.156.65.138;
Received: from localhost (unverified [78.156.65.138]) 
	by fireflyinternet.com (Firefly Internet (M1)) with ESMTP (TLS) id 16758757-1500050 
	for multiple; Sat, 01 Jun 2019 12:44:32 +0100
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
To: Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <155938118174.22493.11599751119608173366@skylake-alporthouse-com>
Cc: Matthew Wilcox <willy@infradead.org>,
 "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>,
 Jan Kara <jack@suse.cz>, Song Liu <liu.song.a23@gmail.com>
References: <20190307153051.18815-1-willy@infradead.org>
 <155938118174.22493.11599751119608173366@skylake-alporthouse-com>
Message-ID: <155938946857.22493.6955534794168533151@skylake-alporthouse-com>
User-Agent: alot/0.6
Subject: Re: [PATCH v4] page cache: Store only head pages in i_pages
Date: Sat, 01 Jun 2019 12:44:28 +0100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting Chris Wilson (2019-06-01 10:26:21)
> Quoting Matthew Wilcox (2019-03-07 15:30:51)
> > Transparent Huge Pages are currently stored in i_pages as pointers to
> > consecutive subpages.  This patch changes that to storing consecutive
> > pointers to the head page in preparation for storing huge pages more
> > efficiently in i_pages.
> > =

> > Large parts of this are "inspired" by Kirill's patch
> > https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov@lin=
ux.intel.com/
> > =

> > Signed-off-by: Matthew Wilcox <willy@infradead.org>
> > Acked-by: Jan Kara <jack@suse.cz>
> > Reviewed-by: Kirill Shutemov <kirill@shutemov.name>
> > Reviewed-and-tested-by: Song Liu <songliubraving@fb.com>
> > Tested-by: William Kucharski <william.kucharski@oracle.com>
> > Reviewed-by: William Kucharski <william.kucharski@oracle.com>
> =

> I've bisected some new softlockups under THP mempressure to this patch.
> They are all rcu stalls that look similar to:
> [  242.645276] rcu: INFO: rcu_preempt detected stalls on CPUs/tasks:
> [  242.645293] rcu:     Tasks blocked on level-0 rcu_node (CPUs 0-3): P828
> [  242.645301]  (detected by 1, t=3D5252 jiffies, g=3D55501, q=3D221)
> [  242.645307] gem_syslatency  R  running task        0   828    815 0x00=
004000
> [  242.645315] Call Trace:
> [  242.645326]  ? __schedule+0x1a0/0x440
> [  242.645332]  ? preempt_schedule_irq+0x27/0x50
> [  242.645337]  ? apic_timer_interrupt+0xa/0x20
> [  242.645342]  ? xas_load+0x3c/0x80
> [  242.645347]  ? xas_load+0x8/0x80
> [  242.645353]  ? find_get_entry+0x4f/0x130
> [  242.645358]  ? pagecache_get_page+0x2b/0x210
> [  242.645364]  ? lookup_swap_cache+0x42/0x100
> [  242.645371]  ? do_swap_page+0x6f/0x600
> [  242.645375]  ? unmap_region+0xc2/0xe0
> [  242.645380]  ? __handle_mm_fault+0x7a9/0xfa0
> [  242.645385]  ? handle_mm_fault+0xc2/0x1c0
> [  242.645393]  ? __do_page_fault+0x198/0x410
> [  242.645399]  ? page_fault+0x5/0x20
> [  242.645404]  ? page_fault+0x1b/0x20
> =

> Any suggestions as to what information you might want?

Perhaps,
[   76.175502] page:ffffea00098e0000 count:0 mapcount:0 mapping:00000000000=
00000 index:0x1
[   76.175525] flags: 0x8000000000000000()
[   76.175533] raw: 8000000000000000 ffffea0004a7e988 ffffea000445c3c8 0000=
000000000000
[   76.175538] raw: 0000000000000001 0000000000000000 00000000ffffffff 0000=
000000000000
[   76.175543] page dumped because: VM_BUG_ON_PAGE(entry !=3D page)
[   76.175560] ------------[ cut here ]------------
[   76.175564] kernel BUG at mm/swap_state.c:170!
[   76.175574] invalid opcode: 0000 [#1] PREEMPT SMP
[   76.175581] CPU: 0 PID: 131 Comm: kswapd0 Tainted: G     U            5.=
1.0+ #247
[   76.175586] Hardware name:  /NUC6CAYB, BIOS AYAPLCEL.86A.0029.2016.1124.=
1625 11/24/2016
[   76.175598] RIP: 0010:__delete_from_swap_cache+0x22e/0x340
[   76.175604] Code: e8 b7 3e fd ff 48 01 1d a8 7e 04 01 48 83 c4 30 5b 5d =
41 5c 41 5d 41 5e 41 5f c3 48 c7 c6 03 7e bf 81 48 89 c7 e8 92 f8 fd ff <0f=
> 0b 48 c7 c6 c8 7c bf 81 48 89 df e8 81 f8 fd ff 0f 0b 48 c7 c6
[   76.175613] RSP: 0000:ffffc900008dba88 EFLAGS: 00010046
[   76.175619] RAX: 0000000000000032 RBX: ffffea00098e0040 RCX: 00000000000=
00006
[   76.175624] RDX: 0000000000000007 RSI: 0000000000000000 RDI: ffffffff81b=
f6d4c
[   76.175629] RBP: ffff888265ed8640 R08: 00000000000002c2 R09: 00000000000=
00000
[   76.175634] R10: 0000000273a4626d R11: 0000000000000000 R12: 00000000000=
00001
[   76.175639] R13: 0000000000000040 R14: 0000000000000000 R15: ffffea00098=
e0000
[   76.175645] FS:  0000000000000000(0000) GS:ffff888277a00000(0000) knlGS:=
0000000000000000
[   76.175651] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   76.175656] CR2: 00007f24e4399000 CR3: 0000000002c09000 CR4: 00000000001=
406f0
[   76.175661] Call Trace:
[   76.175671]  __remove_mapping+0x1c2/0x380
[   76.175678]  shrink_page_list+0x11db/0x1d10
[   76.175684]  shrink_inactive_list+0x14b/0x420
[   76.175690]  shrink_node_memcg+0x20e/0x740
[   76.175696]  shrink_node+0xba/0x420
[   76.175702]  balance_pgdat+0x27d/0x4d0
[   76.175709]  kswapd+0x216/0x300
[   76.175715]  ? wait_woken+0x80/0x80
[   76.175721]  ? balance_pgdat+0x4d0/0x4d0
[   76.175726]  kthread+0x106/0x120
[   76.175732]  ? kthread_create_on_node+0x40/0x40
[   76.175739]  ret_from_fork+0x1f/0x30
[   76.175745] Modules linked in: i915 intel_gtt drm_kms_helper
[   76.175754] ---[ end trace 8faf2ec849d50724 ]---
[   76.206689] RIP: 0010:__delete_from_swap_cache+0x22e/0x340
[   76.206708] Code: e8 b7 3e fd ff 48 01 1d a8 7e 04 01 48 83 c4 30 5b 5d =
41 5c 41 5d 41 5e 41 5f c3 48 c7 c6 03 7e bf 81 48 89 c7 e8 92 f8 fd ff <0f=
> 0b 48 c7 c6 c8 7c bf 81 48 89 df e8 81 f8 fd ff 0f 0b 48 c7 c6
[   76.206718] RSP: 0000:ffffc900008dba88 EFLAGS: 00010046
[   76.206723] RAX: 0000000000000032 RBX: ffffea00098e0040 RCX: 00000000000=
00006
[   76.206729] RDX: 0000000000000007 RSI: 0000000000000000 RDI: ffffffff81b=
f6d4c
[   76.206734] RBP: ffff888265ed8640 R08: 00000000000002c2 R09: 00000000000=
00000
[   76.206740] R10: 0000000273a4626d R11: 0000000000000000 R12: 00000000000=
00001
[   76.206745] R13: 0000000000000040 R14: 0000000000000000 R15: ffffea00098=
e0000
[   76.206750] FS:  0000000000000000(0000) GS:ffff888277a00000(0000) knlGS:=
0000000000000000
[   76.206757] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
-Chris

