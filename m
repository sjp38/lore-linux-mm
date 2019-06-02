Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB309C282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 13:12:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1741327915
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 13:11:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1741327915
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=chris-wilson.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7548E6B000E; Sun,  2 Jun 2019 09:11:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72A646B0010; Sun,  2 Jun 2019 09:11:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61A576B0266; Sun,  2 Jun 2019 09:11:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1844E6B000E
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 09:11:59 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id v125so232512wmf.4
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 06:11:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:to:from:in-reply-to:cc:references
         :message-id:user-agent:subject:date;
        bh=t9R9n+PAawYfwHuFQwCdyR2k8DvW9GwiFzk1ovH8A9s=;
        b=fCOgQWw2VLsecnQ8wm6i6YCEnHx0PvINJT7g/vOtROSaVQQ3P1uwyeftXz10dHTVI1
         RfF1rrTUArEd/ZJUQsACZ4LjmSyf44MN0G7mhMFZg9PFfTsyZWYhZkCvEFBNA9ESvkth
         jIb5UtQxSW0lvJPM3QrThGyJ2b9OkSMvt9iVIF+nVzdFL34dq1DINL8MOihkMWU5087b
         i+o8R8hQA8vzcKm/WoTiDkWCh4LAMpj+0R4Rt+20blCXx0SHNewbVuQYP9JTkUQ92SiD
         zbNWD1ItV1wRT5L2C0B4CXD0BqhV3TwIN7BIYE0jakCI7BrcpGhMgi6fLwMDEpbyISyI
         4Riw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Gm-Message-State: APjAAAUYGdhYe8tjW5ttxOnYmlccb90zUkjC0RS8gP0BqU7uydSWWreQ
	Bvbg8sTsbBRhuWb/sfiHq/HRfoCFYHjCgNXj3nBZAAxehzFdNMrmanaLBRgEMRUpDgumWvJk33V
	W4oGpcDgXx6oHsPOPQRnnLK/fSJZEnr8FZgGDI9YC+GXhw07IHoVI7HOJOl199HE=
X-Received: by 2002:a1c:238e:: with SMTP id j136mr10597585wmj.4.1559481118659;
        Sun, 02 Jun 2019 06:11:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyk3BKYZHNBpxwTL+7X3fpxTuyskFN9ELxF2bDXF620rGn0pHJ05ZZfVA7dG5wZdBo2MbMI
X-Received: by 2002:a1c:238e:: with SMTP id j136mr10597547wmj.4.1559481117583;
        Sun, 02 Jun 2019 06:11:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559481117; cv=none;
        d=google.com; s=arc-20160816;
        b=sQYdxp0mUA4l/9Jiz48hfim7D3gwCAB49ZOw43SvQ6aj3eM+76NC5lXVBuwQ9HMymD
         sZ4XGBXo7rSauuSP6tK8MwjnN1RudG3skvN0MWT29Sg1TyPWnFeNcvOazxdHzsBmFhxb
         EfO60iEodnIDT9BPJr0Jm6ZUU9dwHI4MdDoekzv/DjHqlVtarDJjURKx+u7fEGI3iLsd
         uz/fOD408FkY1/VA9F7bruP1Jha543brYU+7bqsllgw2M9YPWzYuS2LlNkKGEFsg6lL0
         E4U0ve30gLwiEfNdhULKzMHTKHIy+XUt/NSG3QGh4nKdxHLwfFcoUd267CCnUUA+mwmw
         GYiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:subject:user-agent:message-id:references:cc:in-reply-to:from
         :to:content-transfer-encoding:mime-version;
        bh=t9R9n+PAawYfwHuFQwCdyR2k8DvW9GwiFzk1ovH8A9s=;
        b=Q7jRKmDpROXgDbC0TbhFojedZ67UkrvW8+gNztuNH/3+kDydu09sBsIYrLpdOhE6p6
         0pCmAM9k6DwXGbQ+u1KoamIAJHhgMlmJZ0oBLx00OW+DJrZWRSAqjao3+2AppANyKAf4
         pp7CC9OYzT3L8qvalVA+SqxMbpUxkuzpakxODzeP+k6TEvlNCzsPIsI20dlG/T7qzXB7
         zZ73h4tFMya5MCT6LbjQXUkQ7Li63/qryVKr+BhL2/TV+XH4XRf0NJXAqwB2gKe4gxv3
         2Sh1OFGu5x+uvcagadKR5yNjZkr7hzFN3MIkCRcqYe2kb5xaz0SftISocLXyGV3BPEEf
         aGTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id j133si7729104wmj.165.2019.06.02.06.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 06:11:57 -0700 (PDT)
Received-SPF: neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) client-ip=109.228.58.192;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Default-Received-SPF: pass (skip=forwardok (res=PASS)) x-ip-name=78.156.65.138;
Received: from localhost (unverified [78.156.65.138]) 
	by fireflyinternet.com (Firefly Internet (M1)) with ESMTP (TLS) id 16766024-1500050 
	for multiple; Sun, 02 Jun 2019 14:11:48 +0100
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
To: Matthew Wilcox <willy@infradead.org>
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20190602105150.GB23346@bombadil.infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>,
 Jan Kara <jack@suse.cz>, Song Liu <liu.song.a23@gmail.com>
References: <20190307153051.18815-1-willy@infradead.org>
 <155938118174.22493.11599751119608173366@skylake-alporthouse-com>
 <155938946857.22493.6955534794168533151@skylake-alporthouse-com>
 <20190602105150.GB23346@bombadil.infradead.org>
Message-ID: <155948110413.22493.13971476014077289998@skylake-alporthouse-com>
User-Agent: alot/0.6
Subject: Re: [PATCH v4] page cache: Store only head pages in i_pages
Date: Sun, 02 Jun 2019 14:11:44 +0100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting Matthew Wilcox (2019-06-02 11:51:50)
> Thanks for the reports, Chris.
> =

> I think they're both canaries; somehow the page cache / swap cache has
> got corrupted and contains entries that it shouldn't.
> =

> This second one (with the VM_BUG_ON_PAGE in __delete_from_swap_cache)
> shows a regular (non-huge) page at index 1.  There are two ways we might
> have got there; one is that we asked to delete a page at index 1 which is
> no longer in the cache.  The other is that we asked to delete a huge page
> at index 0, but the page wasn't subsequently stored in indices 1-511.
> =

> We dump the page that we found; not the page we're looking for, so I don't
> know which.  If this one's easy to reproduce, you could add:
> =

>         for (i =3D 0; i < nr; i++) {
>                 void *entry =3D xas_store(&xas, NULL);
> +               if (entry !=3D page) {
> +                       printk("Oh dear %d %d\n", i, nr);
> +                       dump_page(page, "deleting page");
> +               }

[  113.423120] Oh dear 0 1
[  113.423141] page:ffffea000911cdc0 refcount:0 mapcount:0 mapping:ffff8882=
6aee7bb1 index:0x7fce6ff37
[  113.423146] anon
[  113.423150] flags: 0x8000000000080445(locked|uptodate|workingset|owner_p=
riv_1|swapbacked)
[  113.423161] raw: 8000000000080445 dead000000000100 dead000000000200 ffff=
88826aee7bb1
[  113.423167] raw: 00000007fce6ff37 0000000000054537 00000000ffffffff 0000=
000000000000
[  113.423171] page dumped because: deleting page
[  113.423176] page:ffffea0009118000 refcount:1 mapcount:0 mapping:ffff8882=
6aee7bb1 index:0x7fce6fe00
[  113.423182] anon
[  113.423183] flags: 0x8000000000080454(uptodate|lru|workingset|owner_priv=
_1|swapbacked)
[  113.423191] raw: 8000000000080454 ffffea0009118048 ffffea000911ce08 ffff=
88826aee7bb1
[  113.423198] raw: 00000007fce6fe00 0000000000054400 00000001ffffffff ffff=
8882693e5000
[  113.423204] page dumped because: VM_BUG_ON_PAGE(entry !=3D page)
[  113.423209] page->mem_cgroup:ffff8882693e5000
[  113.423222] ------------[ cut here ]------------
[  113.423227] kernel BUG at mm/swap_state.c:174!
[  113.423236] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  113.423243] CPU: 1 PID: 131 Comm: kswapd0 Tainted: G     U            5.=
2.0-rc2+ #251
[  113.423248] Hardware name:  /NUC6CAYB, BIOS AYAPLCEL.86A.0029.2016.1124.=
1625 11/24/2016
[  113.423260] RIP: 0010:__delete_from_swap_cache.cold.17+0x30/0x36
[  113.423265] Code: 48 c7 c7 13 94 bf 81 e8 cd 7f f3 ff 48 89 df 48 c7 c6 =
24 94 bf 81 e8 95 6c fd ff 48 c7 c6 32 94 bf 81 4c 89 ff e8 86 6c fd ff <0f=
> 0b 90 90 90 90 48 8b 07 48 8b 16 48 c1 e8 3a 48 c1 ea 3a 29 d0
[  113.423274] RSP: 0018:ffffc900008b3a80 EFLAGS: 00010046
[  113.423280] RAX: 0000000000000000 RBX: ffffea000911cdc0 RCX: 00000000000=
00006
[  113.423285] RDX: 0000000000000007 RSI: 0000000000000092 RDI: ffff888276c=
963c0
[  113.423290] RBP: ffff888265a98d20 R08: 00000000000002ce R09: 00000000000=
00000
[  113.423296] R10: 0000000272bc445c R11: 0000000000000000 R12: 00000000000=
00001
[  113.423301] R13: 0000000000000000 R14: 0000000000000000 R15: ffffea00091=
18000
[  113.423306] FS:  0000000000000000(0000) GS:ffff888276c80000(0000) knlGS:=
0000000000000000
[  113.423313] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  113.423317] CR2: 00007fce7c857000 CR3: 0000000002c09000 CR4: 00000000001=
406e0
[  113.423323] Call Trace:
[  113.423331]  __remove_mapping+0x1c2/0x380
[  113.423337]  shrink_page_list+0x123c/0x1d00
[  113.423343]  shrink_inactive_list+0x130/0x300
[  113.423348]  shrink_node_memcg+0x20e/0x740
[  113.423354]  shrink_node+0xba/0x420
[  113.423359]  balance_pgdat+0x27d/0x4d0
[  113.423365]  kswapd+0x216/0x300
[  113.423372]  ? wait_woken+0x80/0x80
[  113.423378]  ? balance_pgdat+0x4d0/0x4d0
[  113.423384]  kthread+0x106/0x120
[  113.423389]  ? kthread_create_on_node+0x40/0x40
[  113.423398]  ret_from_fork+0x1f/0x30
[  113.423405] Modules linked in: i915 intel_gtt drm_kms_helper
[  113.423414] ---[ end trace 328930613dd77e06 ]---
[  113.454546] RIP: 0010:__delete_from_swap_cache.cold.17+0x30/0x36

>                 VM_BUG_ON_PAGE(entry !=3D page, entry);
>                 set_page_private(page + i, 0);
>                 xas_next(&xas);
>         }
> =

> I'll re-read the patch and see if I can figure out how the cache is getti=
ng
> screwed up.  Given what you said, probably on the swap-in path.

It may be self-incriminating, but this only occurs when i915.ko is also
involved via shrink_slab.
-Chris

