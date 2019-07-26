Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7470C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:21:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7747922BE8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:21:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="pmprGLF2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7747922BE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0ABC16B0006; Fri, 26 Jul 2019 19:21:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 083D98E0003; Fri, 26 Jul 2019 19:21:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDB098E0002; Fri, 26 Jul 2019 19:21:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE90C6B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 19:21:09 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k13so46496460qkj.4
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 16:21:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ds6Pn84xnJTs59aQRjsfc8MfNMObGqVIqTNdYf6jDF8=;
        b=NgJp6VbIgQZJ7DrorpDMtHtl/eFCG3UdK+BUghAfyUpx/JRMhu7iPRy9hs58GpWiBN
         J1Oc+KqpMIbFrtu37XrIskGyn5T/0Z58I8U0F6sCYErNwETzxCuFsU1P/Rvog2aWUa+S
         ejlqi8Rf1puaEsq9gdm0dNJcatvYC0N5gW/qCancaLy+dDMgcpwgmoUUUxsek13a3Wjk
         RDSoxODQt7YxOTMiuOxXu0G6Kho4m6ooqPJ+xCfadvEiifYYOlBouOkJVd2MFMNs5ZDG
         KZNMF1v9Z/bgeVhcuOGBNM0aTba14Bxqq33Zi0W2gadaLed0Gxmnzs7BgF+lgHwCbvt3
         2pww==
X-Gm-Message-State: APjAAAU8B0ZX0pVdRfE09+kSR6TMv0A6UIDJiSOdWMwJWqvSXg40XigQ
	NqFaKzBZUNIUIhWzP48JTHbQs+3UfJ9bb5eIQv9aeWOaOYyat6dSD1f0CGkrZpX+rmdQimQ1yRZ
	Qi8KGvjOPnzMkyAjNiXt+rlD5w0rvGi1DyS7BI6EwuAfxIhqrFj9r1YZw1G5h7HrVDg==
X-Received: by 2002:aed:2e07:: with SMTP id j7mr67566421qtd.379.1564183269590;
        Fri, 26 Jul 2019 16:21:09 -0700 (PDT)
X-Received: by 2002:aed:2e07:: with SMTP id j7mr67566402qtd.379.1564183269100;
        Fri, 26 Jul 2019 16:21:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564183269; cv=none;
        d=google.com; s=arc-20160816;
        b=xmEgaL9L0+0im0nW7R32rP0+bdX2Fioc/ija6q1EedMLF2xcqLjKiPUnNf4Naqx9j7
         6r74uHVWRG0JEUrXX+0GytVqkAzCFe3QojOm/tSW2CsuNH31ctdOpGZoWmVAoP/qYssN
         pu2BI2/00VoXhaY0ReOgAF3fTkRL4KK4Go/u4ynyrSPEdZPCxKkL9fgvUOjCq7aPjwjT
         cUaarTesKM0R2ThyqWLQMhDJtb+ZGkZ30JCvJZ1WpKCjUgHkXkzwll/4zILYmns/L+BE
         y6dDdUSSBW0xGNJU3L5uo+sipyemwDUtoVA4mlyuwG7oPb5SyvrOSD6wg3jcC3Kh+Dy6
         hqIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ds6Pn84xnJTs59aQRjsfc8MfNMObGqVIqTNdYf6jDF8=;
        b=deBSjo8+6ld28m756juBSuEif487TBYBX5yXgfqb6Lu5Fl+L+yl4YIXpdzQXKFyNf3
         iaBAvJ9AVsg2gNAa7i5RWnK8blyxSm3I5VkgME42njgKyCsJsFaxYrGDgbgdYzvofjhD
         P6/US48M1sTqd2ATe6bd+E1fclhOFwO8vs5a10bWDdsd/aSP3wOsfg1pYrhulmjGFg1w
         rn34axh3+asLCQtJ9hhGKeWYLWWV+v56LAR2s74MPm1G6B+2vHIkdX+yN0s8pQ/lXj5z
         M+adEl37l0gdJWCH7cmX8uF4eSJngS43ETMpm5K8xQDZ8XvLHJwWc0XuJFoxKmZRZoHo
         WmwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pmprGLF2;
       spf=pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jwadams@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c19sor31139062qkl.84.2019.07.26.16.21.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 16:21:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pmprGLF2;
       spf=pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jwadams@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ds6Pn84xnJTs59aQRjsfc8MfNMObGqVIqTNdYf6jDF8=;
        b=pmprGLF2LW0+Sp8wpilnKxyQ9fpy3RtVaI/uwKChRR6jU8kYntVB/SBwjs2iJ/Ef8t
         AgoaxKSIaFJe7S7BnUBMzaU5bXb26v3v8TOCHBgGl7orVWxAEikEx7zs9FYVRZ2Kuhq4
         LSTUWhQCKjMaQS5eEZ+BcJitwk4cPKvlrXSZDX1iHbS8B0nL0AA6pOZy4QXcTcQMysE5
         AythhYvQwGo01Exhcg+nMLtnS5XdBJBKrjciS0HpJOZvZWTfMOeSAbBRtlq3DFoVJ+4G
         xBuI0RwArlsSejlPmK0YyqwlQDzixITgfEA6xxl4awy3u7kqIvjgYTSSMEYLmZZ99w5Y
         y/EA==
X-Google-Smtp-Source: APXvYqxKsvOaZxq1HqBf7Rf4YiQTcQkrpQGtj9XSIYZVHNSOdDHelqirkEJK9WTuzvgEgdBC2jX6zOfxq5cVBDabxl8=
X-Received: by 2002:a37:9ac9:: with SMTP id c192mr65323076qke.30.1564183268223;
 Fri, 26 Jul 2019 16:21:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190726224810.79660-1-henryburns@google.com> <20190726224810.79660-2-henryburns@google.com>
In-Reply-To: <20190726224810.79660-2-henryburns@google.com>
From: Jonathan Adams <jwadams@google.com>
Date: Fri, 26 Jul 2019 16:20:32 -0700
Message-ID: <CA+VK+GPC+akF0qGrKFivtNneweEfdC9uEx=QgmztB4M_xvMeKQ@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Fix z3fold_destroy_pool() race condition
To: Henry Burns <henryburns@google.com>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Shakeel Butt <shakeelb@google.com>, David Howells <dhowells@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@zeniv.linux.org.uk>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 3:48 PM Henry Burns <henryburns@google.com> wrote:
>
> The constraint from the zpool use of z3fold_destroy_pool() is there are no
> outstanding handles to memory (so no active allocations), but it is possible
> for there to be outstanding work on either of the two wqs in the pool.
>
> Calling z3fold_deregister_migration() before the workqueues are drained
> means that there can be allocated pages referencing a freed inode,
> causing any thread in compaction to be able to trip over the bad
> pointer in PageMovable().
>
> Fixes: 1f862989b04a ("mm/z3fold.c: support page migration")
>
> Signed-off-by: Henry Burns <henryburns@google.com>

Reviewed-by: Jonathan Adams <jwadams@google.com>

> Cc: <stable@vger.kernel.org>
> ---
>  mm/z3fold.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 43de92f52961..ed19d98c9dcd 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -817,16 +817,19 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
>  static void z3fold_destroy_pool(struct z3fold_pool *pool)
>  {
>         kmem_cache_destroy(pool->c_handle);
> -       z3fold_unregister_migration(pool);
>
>         /*
>          * We need to destroy pool->compact_wq before pool->release_wq,
>          * as any pending work on pool->compact_wq will call
>          * queue_work(pool->release_wq, &pool->work).
> +        *
> +        * There are still outstanding pages until both workqueues are drained,
> +        * so we cannot unregister migration until then.
>          */
>
>         destroy_workqueue(pool->compact_wq);
>         destroy_workqueue(pool->release_wq);
> +       z3fold_unregister_migration(pool);
>         kfree(pool);
>  }
>
> --
> 2.22.0.709.g102302147b-goog
>

