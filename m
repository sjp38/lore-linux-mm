Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CD63C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:07:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F19921852
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:07:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JRm10WCL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F19921852
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98FE58E0007; Fri, 26 Jul 2019 19:07:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9187F8E0002; Fri, 26 Jul 2019 19:07:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B83C8E0007; Fri, 26 Jul 2019 19:07:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 53C378E0002
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 19:07:19 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id f126so41608718ybg.16
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 16:07:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vrtRmk0oRnuWgbrd0YoseM/P5P8a271SeH+Gw2pTm2Y=;
        b=hhfkGdCmmbUo1kIWKKIz5h8+Ruk4PEU/EwiBV9sOsd0yIY9Wgw2v+BVaRS1WyFOMlp
         bU+7fAV4d/nGWPy1NrXTSDAAjymjlabXpyoxRvn0ZODwSwVJhovvTVS9YOEnYPyjswI0
         ReyUFyIb1niO5mEaj/IU+n48k8Cl3eA1P6aHCkssZ3UsMU7YkPuS6uwkEtfgsDsaQf6B
         y1Mc3all0z8W/a3FYizW+h/OwuqdSXzs2I7mxjRxumEHjlN3CIcFjK4iEWNHnil/rCJh
         TqzqkPr9ahQ5CK3tEILcTSUb0Z04mO2dninzGkvPC09JBv1CHv6O+5O1cRme8qREwXK5
         o38A==
X-Gm-Message-State: APjAAAV9nfAIk66JTwXgF0M2ngsfPc/DEVV55I0PGTkkJExVu0X1+nVx
	OfhPDaw+klKjivdiA0gWp3KB7AijmINTzB9WRuowKp5hgTmIz1SgYgg9jpjnFM6n95I9EDBMCMh
	A2xODhjpgV4SlprKdykGPOVGZUsBWBupB1/MrcOWfp5F4r/DSlfQVRus/GntbL9jm2A==
X-Received: by 2002:a81:8187:: with SMTP id r129mr57354747ywf.309.1564182439070;
        Fri, 26 Jul 2019 16:07:19 -0700 (PDT)
X-Received: by 2002:a81:8187:: with SMTP id r129mr57354719ywf.309.1564182438622;
        Fri, 26 Jul 2019 16:07:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564182438; cv=none;
        d=google.com; s=arc-20160816;
        b=Bh2se1kq8XCcXb46+4GE8eK8wUbGDdtmOWr6UyCcCgYYxVF5bpZ23Ef8EExE8ThZT9
         NlQW08I8cmYyCRBySVZ0249uRqJzDPPmt1RcsfRz/SvGHErfRB9hFQ4omwEqvc5ehZYn
         lPWt5FuA0eM0IDjjOJws1Oc0tKRezsgOyK5+bhzQ8BuSHyRSB37O6Ksv6guFYVuAE+nr
         x5yPDirPKjhsWJW3X/+hEy8cWUYiprvXJEIi9HV6MprdC6ytCRkk1/Uq12pwjtHBeVa4
         RCdisfx4piU/EVML4W8KYJiV1Nd+2fKQT8E2Yj9sKg3EitcRXjo7plAAph8Zp0KwYOJL
         w3ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vrtRmk0oRnuWgbrd0YoseM/P5P8a271SeH+Gw2pTm2Y=;
        b=PIMQuA2VLMSUJy3fQf3fXWlFYO/1jHFdrDrb9W3+g+YLpCJxXLzUWVpAtUAoLdlT6G
         I0SEv/wyGo8bz3SRMtEss9VqUoPxVK3VuaMI7i7wbybLbGwsBs8yB977f7rVG8ZmwbCX
         9G84L4uDniAmHtxFg3vlSgf3tBKviLTvmDdEiPLxu8jb6wOvIUxwJJRUJwnOM2jcwWWz
         RSLlulpB+WWGc3jv1+mfUjoFVNZ7h406154H8KYqpK4fidC8tj+LnVXnvPrYYgiU5bIC
         0c6ev9wEchVA51iYJBjbOzYkqaSU2KY5XFbjRT5ZwughhPBbGHYKKt4AV5za5NJnhBJF
         FOSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JRm10WCL;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 84sor8691067ybg.106.2019.07.26.16.07.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 16:07:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JRm10WCL;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vrtRmk0oRnuWgbrd0YoseM/P5P8a271SeH+Gw2pTm2Y=;
        b=JRm10WCLRxh/551IVqtkLiXtX0KmaUMMzhAGaHZ8CHTo4OqCH9YulZg+eNaCbCFaF1
         vHRFjJO6MDfWaNaZZwaPqvQXUI1Mo/YoDwzlG67phmmya2ja/Xk0HJ08MV0+tZ77bDwU
         9RJzYEjTwEn5yB+01dszHApaV8BWH2CEwbBdnWAPnSlPOUV48oWhAZIYEncndioYLBod
         ndL/W9NkkiNTeZJSW8GnFZNdOrFvCY0uG7b3OqrGKUR5EOmrrwxcquwNi2zTGceGAMBu
         U2p4ZLJRoUXCQQUz3Hh6bOgWd9HI0SQwncXmupXj9UvnvPvIwT8418a8vFEdcsH0D3fs
         yVFw==
X-Google-Smtp-Source: APXvYqwEnA4QDIyzPUl/Tt7HDrIuWTWNbMk2HgzNOZ+r5XoUixWIxZY4BQOEKnf9hO0dtzJCFPBZeeB/6Q2L1SHNack=
X-Received: by 2002:a25:9903:: with SMTP id z3mr59762121ybn.293.1564182438043;
 Fri, 26 Jul 2019 16:07:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190726224810.79660-1-henryburns@google.com> <20190726224810.79660-2-henryburns@google.com>
In-Reply-To: <20190726224810.79660-2-henryburns@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 26 Jul 2019 16:07:07 -0700
Message-ID: <CALvZod4QoBsKKg3Ld0Sc5DtQdmjPPJb_tH_yh-N53b3AgSOMrA@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Fix z3fold_destroy_pool() race condition
To: Henry Burns <henryburns@google.com>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Jonathan Adams <jwadams@google.com>, David Howells <dhowells@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@zeniv.linux.org.uk>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
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

Reviewed-by: Shakeel Butt <shakeelb@google.com>

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

