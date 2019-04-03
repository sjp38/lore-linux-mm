Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFD55C10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 11:24:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EF3E20651
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 11:24:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="R+9wkWKg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EF3E20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04F8F6B0008; Wed,  3 Apr 2019 07:24:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F40BA6B000A; Wed,  3 Apr 2019 07:23:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E55B76B000C; Wed,  3 Apr 2019 07:23:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B0F2D6B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 07:23:59 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y17so12156343plr.15
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 04:23:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CPfPRpR0DWRoEWSeqJqYRQgr1OanxH/3OfZ1+xjn9Qo=;
        b=BXtCd+J455+Re0EiFTdMEBQAtiT3qaSOOnRH0RBq3A6y/QtMS4UtmvyaF7YjIzJLWw
         lBWT82mukJywcXiGXrUQYhOJ2XLczedC8ZpPWZeDzaeO7Vy5yoqt2CI/X4PZlBkroRa4
         j7+QBECsOBm4mmRbgfKwj9UtMU+icrWj9/1Pe3dWQEZwbR3D6/H1gBSO82re5gjQeKpo
         tD3rCn1jPf5L0wf7lPgIxVT6Zt8niHy102hTlZtRn4iMwbaxDmmBYdcBi806FPS3SsDw
         RMoTZzwfMTX+stNC49nJWo3okCqr8Iv2KAEBA3q8vxAy4dLgrQqieeeq9SrmB5sUWuwg
         ahXw==
X-Gm-Message-State: APjAAAXtAvssKSpzX19wOcSi38E/SNg9OXSVFnEGc0nJVCOEJZFMz4C6
	/Ch4dr159KrSKIdeBqPlxr+lQBwRqKGmDq7WbaU8B4XPDWH9BFcQusm1kgjMkDHSlGLNEFcGT9j
	sfVmXa0ObJYxvHVl9DKoxyIdqMEjF+XDLzeP5Gnh0WsnE874qaFfr7OU1hdzTZGfeNg==
X-Received: by 2002:a17:902:aa91:: with SMTP id d17mr11732092plr.43.1554290638412;
        Wed, 03 Apr 2019 04:23:58 -0700 (PDT)
X-Received: by 2002:a17:902:aa91:: with SMTP id d17mr11731967plr.43.1554290636660;
        Wed, 03 Apr 2019 04:23:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554290636; cv=none;
        d=google.com; s=arc-20160816;
        b=JRtS3j8g0lONCZXkAVplczFLxK/J+hyzuWtpfXJ4Gt5PX4DtUvBM5YPMd+8FUdL0dJ
         4dEALyD8QZ5kAXsUYyMHr6rvrnMibwZc/50Nj3iZYyECtjdeGZ/pnBMHZE2It0RqNnPk
         ciMZFf/iFMfYUlFQQaN9een4L8YoX7B1cz0LsC41bJWmna4LaH3hq72HemmKuf9AEo2I
         rCcd4jaSO1/dSSckM3Kjr0q3INKvadt4R4U+tEBxRzz3mAzBXazxq5xX1EASGmz7u+uy
         337wNnQkODEj3LlCFK/ToHFtuTDFlZyIWy40Qp5OwgNI7U9ZJ4cTVAa9D6r7+cOlQEBS
         +HKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CPfPRpR0DWRoEWSeqJqYRQgr1OanxH/3OfZ1+xjn9Qo=;
        b=bQOPZPUfzZIq7xi2GIofYQLcFaCtDAxMiGOQBDg2HvbgzbBsuFQt1PCrpq0E237aYs
         5kU6e1wWT423BRRNyh5V6PCtKapYt20HI6GibfPiRB9J12TjsqjeAd32VlXPuL3Jhb4h
         XlYLIEHireETOrN1Fa25i0NYfPTxz24vjPeh3JITrJCiiq+en9L5fmNFeLxxVctgi4k1
         qdApOgVwOENOVNfDd0DW/Px0R/+PoNB5Z+YaloGtMwZbQD63KJ1S5VNblMcOHaEijaXj
         VRNQXA7ctouowmxq7Y/IWxkxawCyV/NHGuNOeMwMr09ChdEnUbGy6VCFld08rpPDwEp4
         OnZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=R+9wkWKg;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h18sor10109215pgn.39.2019.04.03.04.23.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Apr 2019 04:23:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=R+9wkWKg;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CPfPRpR0DWRoEWSeqJqYRQgr1OanxH/3OfZ1+xjn9Qo=;
        b=R+9wkWKgGuBSaczocubi3DFdzgLZ9daUV9xZZtZU3I7m6i4fspMD1lNC2q0zBScQKx
         5IgADzYVRRYSjedbOg6xhEub0yUzuhRrk8cUHKZzWwLXswBjFF/4/ZZAjTNyoWo3am2H
         FZZSoBpA685YTi5LhjTpRVfRdPkJ3KEN5QV75aR/9IZ7WnASfTHL73T8iIHTpY23QQyR
         ZSRe5gGOevKv7uymxIGtVLYo75ohJ/woRolRddWs6YGmyRRoGVU4PRKI8DbQYiQcMDVO
         usaiyUPMziDtwdny/e8hUuuiu73etZLUZ+0SaZck4GIwEVC5jPo/Nr23FWyE2PaP7pSJ
         BBDw==
X-Google-Smtp-Source: APXvYqx1VQTCG/UnS6AThG9BjNkeKCGQE7PCGI69f0qKxAYTDlk6+ahK7fgB+i7aY1wQXbC991LPPLne1FifVWwt+VM=
X-Received: by 2002:a63:cf0d:: with SMTP id j13mr37791057pgg.34.1554290635872;
 Wed, 03 Apr 2019 04:23:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190403022858.97584-1-cai@lca.pw>
In-Reply-To: <20190403022858.97584-1-cai@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 3 Apr 2019 13:23:44 +0200
Message-ID: <CAAeHK+y25S6GYMrGUEQJJ5AU1LZ7T-jWrwoDsLXdxuk_E+q5BQ@mail.gmail.com>
Subject: Re: [PATCH] slab: store tagged freelist for off-slab slabmgmt
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 3, 2019 at 4:29 AM Qian Cai <cai@lca.pw> wrote:
>
> The commit 51dedad06b5f ("kasan, slab: make freelist stored without
> tags") calls kasan_reset_tag() for off-slab slab management object
> leading to freelist being stored non-tagged. However, cache_grow_begin()
> -> alloc_slabmgmt() -> kmem_cache_alloc_node() which assigns a tag for
> the address and stores in the shadow address. As the result, it causes
> endless errors below during boot due to drain_freelist() ->
> slab_destroy() -> kasan_slab_free() which compares already untagged
> freelist against the stored tag in the shadow address. Since off-slab
> slab management object freelist is such a special case, so just store it
> tagged. Non-off-slab management object freelist is still stored untagged
> which has not been assigned a tag and should not cause any other
> troubles with this inconsistency.

Hi Qian,

Could you share the config (or other steps) you used to reproduce this?

Thanks!

>
> BUG: KASAN: double-free or invalid-free in slab_destroy+0x84/0x88
> Pointer tag: [ff], memory tag: [99]
>
> CPU: 0 PID: 1376 Comm: kworker/0:4 Tainted: G        W
> 5.1.0-rc3+ #8
> Hardware name: HPE Apollo 70             /C01_APACHE_MB         , BIOS
> L50_5.13_1.0.6 07/10/2018
> Workqueue: cgroup_destroy css_killed_work_fn
> Call trace:
>  dump_backtrace+0x0/0x450
>  show_stack+0x20/0x2c
>  dump_stack+0xe0/0x16c
>  print_address_description+0x74/0x2a4
>  kasan_report_invalid_free+0x80/0xc0
>  __kasan_slab_free+0x204/0x208
>  kasan_slab_free+0xc/0x18
>  kmem_cache_free+0xe4/0x254
>  slab_destroy+0x84/0x88
>  drain_freelist+0xd0/0x104
>  __kmem_cache_shrink+0x1ac/0x224
>  __kmemcg_cache_deactivate+0x1c/0x28
>  memcg_deactivate_kmem_caches+0xa0/0xe8
>  memcg_offline_kmem+0x8c/0x3d4
>  mem_cgroup_css_offline+0x24c/0x290
>  css_killed_work_fn+0x154/0x618
>  process_one_work+0x9cc/0x183c
>  worker_thread+0x9b0/0xe38
>  kthread+0x374/0x390
>  ret_from_fork+0x10/0x18
>
> Allocated by task 1625:
>  __kasan_kmalloc+0x168/0x240
>  kasan_slab_alloc+0x18/0x20
>  kmem_cache_alloc_node+0x1f8/0x3a0
>  cache_grow_begin+0x4fc/0xa24
>  cache_alloc_refill+0x2f8/0x3e8
>  kmem_cache_alloc+0x1bc/0x3bc
>  sock_alloc_inode+0x58/0x334
>  alloc_inode+0xb8/0x164
>  new_inode_pseudo+0x20/0xec
>  sock_alloc+0x74/0x284
>  __sock_create+0xb0/0x58c
>  sock_create+0x98/0xb8
>  __sys_socket+0x60/0x138
>  __arm64_sys_socket+0xa4/0x110
>  el0_svc_handler+0x2c0/0x47c
>  el0_svc+0x8/0xc
>
> Freed by task 1625:
>  __kasan_slab_free+0x114/0x208
>  kasan_slab_free+0xc/0x18
>  kfree+0x1a8/0x1e0
>  single_release+0x7c/0x9c
>  close_pdeo+0x13c/0x43c
>  proc_reg_release+0xec/0x108
>  __fput+0x2f8/0x784
>  ____fput+0x1c/0x28
>  task_work_run+0xc0/0x1b0
>  do_notify_resume+0xb44/0x1278
>  work_pending+0x8/0x10
>
> The buggy address belongs to the object at ffff809681b89e00
>  which belongs to the cache kmalloc-128 of size 128
> The buggy address is located 0 bytes inside of
>  128-byte region [ffff809681b89e00, ffff809681b89e80)
> The buggy address belongs to the page:
> page:ffff7fe025a06e00 count:1 mapcount:0 mapping:01ff80082000fb00
> index:0xffff809681b8fe04
> flags: 0x17ffffffc000200(slab)
> raw: 017ffffffc000200 ffff7fe025a06d08 ffff7fe022ef7b88 01ff80082000fb00
> raw: ffff809681b8fe04 ffff809681b80000 00000001000000e0 0000000000000000
> page dumped because: kasan: bad access detected
> page allocated via order 0, migratetype Unmovable, gfp_mask
> 0x2420c0(__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE)
>  prep_new_page+0x4e0/0x5e0
>  get_page_from_freelist+0x4ce8/0x50d4
>  __alloc_pages_nodemask+0x738/0x38b8
>  cache_grow_begin+0xd8/0xa24
>  ____cache_alloc_node+0x14c/0x268
>  __kmalloc+0x1c8/0x3fc
>  ftrace_free_mem+0x408/0x1284
>  ftrace_free_init_mem+0x20/0x28
>  kernel_init+0x24/0x548
>  ret_from_fork+0x10/0x18
>
> Memory state around the buggy address:
>  ffff809681b89c00: fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe
>  ffff809681b89d00: fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe
> >ffff809681b89e00: 99 99 99 99 99 99 99 99 fe fe fe fe fe fe fe fe
>                    ^
>  ffff809681b89f00: 43 43 43 43 43 fe fe fe fe fe fe fe fe fe fe fe
>  ffff809681b8a000: 6d fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe
>
> Fixes: 51dedad06b5f ("kasan, slab: make freelist stored without tags")
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  mm/slab.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 329bfe67f2ca..46a6e084222b 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2374,7 +2374,6 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
>                 /* Slab management obj is off-slab. */
>                 freelist = kmem_cache_alloc_node(cachep->freelist_cache,
>                                               local_flags, nodeid);
> -               freelist = kasan_reset_tag(freelist);
>                 if (!freelist)
>                         return NULL;
>         } else {
> --
> 2.17.2 (Apple Git-113)
>

