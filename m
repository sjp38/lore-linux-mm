Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C478C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 04:36:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B540E208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 04:36:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Mhw9cuI3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B540E208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55DFF6B0276; Tue, 28 May 2019 00:36:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50F566B0278; Tue, 28 May 2019 00:36:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D6BF6B027A; Tue, 28 May 2019 00:36:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDB06B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 00:36:15 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id w6so14413134ybp.19
        for <linux-mm@kvack.org>; Mon, 27 May 2019 21:36:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EhZXEPaGOndmbMF7hBpdNSLf/Wn42Ho6pv5iLoXbO8E=;
        b=eKh1SlKxKDi9DpnV4WpvXAjkFCghfrbqJY8PwcS0jx1ZPLKZeFavDvmygazJaid7Lp
         gogrEA0LrJjqkPVkSN5ivionmdamFr9qd1hvdtKYfffJ5/Novrb9FVLln6zaxb4dmKyb
         DqKCX49ktAkwE6grpRyA+QdeHVcFHVc+f34CkZJAMN0VNyijdaUoc2cAqKtfQ3eF7bLm
         6c0BK5CymgC4s9iQqNpQ29qHsw07bC04+klRyg2ZaZE6A64HWuisw3vVI9K7eg6BfTSV
         jknxCAB2wHa8rfwHGyV1fP6S7cEc8O0Bucf9sj07/AXeQM0kwCZ6VWyq8lZUk0P1J5BH
         Ig3w==
X-Gm-Message-State: APjAAAUt5LDIsuK+W6ZT1rsuFxdb10Bf+oP4rYxJt7MmZxypbxQzZ5wb
	dkWDjhXH7OZWhHogy0fqPY/IqNBk/SswZdXEPDs1Di5E30KOyGOzUPSq7TVZ+yPd8ug6U+KQqzn
	hmJqN3nP2WUBJ5QFMjFFsW1HHuO226crjoSWQafUYOlDdAiUo+ftPt1xkZtneRcqznw==
X-Received: by 2002:a25:bd0f:: with SMTP id f15mr9724184ybk.326.1559018174834;
        Mon, 27 May 2019 21:36:14 -0700 (PDT)
X-Received: by 2002:a25:bd0f:: with SMTP id f15mr9724172ybk.326.1559018174051;
        Mon, 27 May 2019 21:36:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559018174; cv=none;
        d=google.com; s=arc-20160816;
        b=R9h1trlgiB8zxlFyJ1qkLHOUGPTaLH4jftSK+dr2XHNXHI8Hq3+wzZWl3ePbWELZKw
         4N4xqbMJbV3a2vXBzxbnuv42x1LJEj2ZovzKU3V/aB9bNMRug6VVj2w5C/kwxPJC8c3S
         7a0Goown0ilUKnlKYXBMM3GQvJ0701RBscLROPXYD7a63EaV5yG85BhPcMarIFYe9zJq
         xTLXkBV9RqCQOEKDPEfrY7vRySsuCRTYGWqEglQNCjO5s/V5TXnQmU4nd65e4fEmJR57
         emb/oXYf3quZwcLI0BIxH5pZm1d4YfztNka/5NvZMORgB2JPe1yW+tt6Uxk5R8bgiw8B
         sb6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EhZXEPaGOndmbMF7hBpdNSLf/Wn42Ho6pv5iLoXbO8E=;
        b=JBkmbUQhrOmV7wQ39ry0AOCofKSlBs7D/iIfx2kog7y8j5zUj968vOidGEEUZnp9kr
         y2hNRWQNmf3/8GrnaygLOLwCsB9PtGGw/lOYP/QODl6ugERa18r6O33IrsTCJJx0t7TW
         FC0SYR4IY/WamcGNpJr/DGZepvjUZVphnZpHYZjtGw46akpjbL29Xt4D1tpLlLvAtuRb
         0c9AiJw7fFqMMtyWKnRUlOeLy69/UI/AD0hVrhKkv7svL2Qso8v+bXSX7Z/vat1he/q2
         qqcDvL5aOCJLvANjCUjn63LCpa7upD0JEWIT+29qvKgkseICnyQ9MAa8u41cVNBTiFmF
         ecvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Mhw9cuI3;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e11sor5709083ybh.187.2019.05.27.21.36.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 21:36:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Mhw9cuI3;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EhZXEPaGOndmbMF7hBpdNSLf/Wn42Ho6pv5iLoXbO8E=;
        b=Mhw9cuI3Uguy91f7l2VsS1lLuaKukCk2S5h+I08iNodfJOgE0KM1cosNBc/F04PqQu
         OHEWYViHOr0kxioEUZKFcp1prBcM6SOtKBwjpHXnmhN09r/m+M7514payGiojqn/p8U7
         WpEF22+fEE4vFWX+KYIWCwDKYsdCuyBkH/Q0f9sLfSb3p+lUcpZ1/a5JE1mcVdFiuMeT
         H0NHYV7z/MJcPmvwGieBAb0xZUVIbRixRKdmjojXoScIPnkOoZVJo8AqmsnVOjwg9/Ji
         xJuUEXtayITVXKX3VCehfJUC4f/luD0DgIhUlHBemNrc9G5BsnERyeaUmecclwm7Ku1r
         sLbA==
X-Google-Smtp-Source: APXvYqxlGLX0hGvbz3YS/QjwcbuvyttsCokhfzJ5VDEpy0YXYNYGjNH07HgDr9vxxbss9W6b6TRHZZRUBKMopZ+Vj9U=
X-Received: by 2002:a25:1ed6:: with SMTP id e205mr5487694ybe.467.1559018173464;
 Mon, 27 May 2019 21:36:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190528043202.99980-1-shakeelb@google.com>
In-Reply-To: <20190528043202.99980-1-shakeelb@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 27 May 2019 21:36:02 -0700
Message-ID: <CALvZod7Or8diV5i2eayiP9NZHfGn503j+6TpSV1CP9fTmSjEug@mail.gmail.com>
Subject: Re: [PATCH] list_lru: fix memory leak in __memcg_init_list_lru_node
To: Kirill Tkhai <ktkhai@virtuozzo.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	syzbot+f90a420dfe2b1b03cb2c@syzkaller.appspotmail.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 9:32 PM Shakeel Butt <shakeelb@google.com> wrote:
>
> Syzbot reported following memory leak:
>
> ffffffffda RBX: 0000000000000003 RCX: 0000000000441f79
> BUG: memory leak
> unreferenced object 0xffff888114f26040 (size 32):
>   comm "syz-executor626", pid 7056, jiffies 4294948701 (age 39.410s)
>   hex dump (first 32 bytes):
>     40 60 f2 14 81 88 ff ff 40 60 f2 14 81 88 ff ff  @`......@`......
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<0000000018f36b56>] kmemleak_alloc_recursive include/linux/kmemleak.h:55 [inline]
>     [<0000000018f36b56>] slab_post_alloc_hook mm/slab.h:439 [inline]
>     [<0000000018f36b56>] slab_alloc mm/slab.c:3326 [inline]
>     [<0000000018f36b56>] kmem_cache_alloc_trace+0x13d/0x280 mm/slab.c:3553
>     [<0000000055b9a1a5>] kmalloc include/linux/slab.h:547 [inline]
>     [<0000000055b9a1a5>] __memcg_init_list_lru_node+0x58/0xf0 mm/list_lru.c:352
>     [<000000001356631d>] memcg_init_list_lru_node mm/list_lru.c:375 [inline]
>     [<000000001356631d>] memcg_init_list_lru mm/list_lru.c:459 [inline]
>     [<000000001356631d>] __list_lru_init+0x193/0x2a0 mm/list_lru.c:626
>     [<00000000ce062da3>] alloc_super+0x2e0/0x310 fs/super.c:269
>     [<000000009023adcf>] sget_userns+0x94/0x2a0 fs/super.c:609
>     [<0000000052182cd8>] sget+0x8d/0xb0 fs/super.c:660
>     [<0000000006c24238>] mount_nodev+0x31/0xb0 fs/super.c:1387
>     [<0000000006016a76>] fuse_mount+0x2d/0x40 fs/fuse/inode.c:1236
>     [<000000009a61ec1d>] legacy_get_tree+0x27/0x80 fs/fs_context.c:661
>     [<0000000096cd9ef8>] vfs_get_tree+0x2e/0x120 fs/super.c:1476
>     [<000000005b8f472d>] do_new_mount fs/namespace.c:2790 [inline]
>     [<000000005b8f472d>] do_mount+0x932/0xc50 fs/namespace.c:3110
>     [<00000000afb009b4>] ksys_mount+0xab/0x120 fs/namespace.c:3319
>     [<0000000018f8c8ee>] __do_sys_mount fs/namespace.c:3333 [inline]
>     [<0000000018f8c8ee>] __se_sys_mount fs/namespace.c:3330 [inline]
>     [<0000000018f8c8ee>] __x64_sys_mount+0x26/0x30 fs/namespace.c:3330
>     [<00000000f42066da>] do_syscall_64+0x76/0x1a0 arch/x86/entry/common.c:301
>     [<0000000043d74ca0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
>
> This is a simple off by one bug on the error path.
>
> Reported-by: syzbot+f90a420dfe2b1b03cb2c@syzkaller.appspotmail.com
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Forgot to add:

Fixes: 60d3fd32a7a9 ("list_lru: introduce per-memcg lists")
Cc: stable@vger.kernel.org # 4.0+

> ---
>  mm/list_lru.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index 0bdf3152735e..92870be4a322 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -358,7 +358,7 @@ static int __memcg_init_list_lru_node(struct list_lru_memcg *memcg_lrus,
>         }
>         return 0;
>  fail:
> -       __memcg_destroy_list_lru_node(memcg_lrus, begin, i - 1);
> +       __memcg_destroy_list_lru_node(memcg_lrus, begin, i);
>         return -ENOMEM;
>  }
>
> --
> 2.22.0.rc1.257.g3120a18244-goog
>

