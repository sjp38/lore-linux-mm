Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D3B5C4646B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 10:39:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34C3E21530
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 10:39:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oaiG/My2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34C3E21530
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC0526B0005; Fri, 21 Jun 2019 06:39:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E708A8E0002; Fri, 21 Jun 2019 06:39:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5FC88E0001; Fri, 21 Jun 2019 06:39:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id B52FD6B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:39:24 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id x22so2032718vsj.1
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 03:39:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=/GyhlxzDlZ/c+fwrm+Fm2Dc67r0DcAh+69Mb7gFlO3k=;
        b=nDwd4hEZf9pgClVMsL1wSE0MAtwsMHy7M2KvNe415xmKJpysUn2lKFzCjgyI5fDEsb
         HiYP9iJFFXv2WIFA9xLJd6YrT2FP0pdzIT2eY8zPm1bOgQ6qWFq0+OLDmDJKAmQ+Rmbw
         LRXnbzbOAFGQoyu+MFYKT0JvhbYRZl5s29M+DgaHG+aDiQxGtHlXoki+WwQNaxv9qIX7
         eQk7L8i0kTA3/BxcXHhogeL5DFmNEtZ5D57ocyfsFdpgpIqX8FkRx5e8KRvhREgBM0E0
         SdisC9DT4V0bbAE+FQm96Kx6yagbn56BMfCBaRz38Hn6Q9Ml3XiKtfOxzyh7OihF4PQS
         +oww==
X-Gm-Message-State: APjAAAW/G4zjnXHuEJhSiip4SCn648UnxHefPJwH6KrV5m+nKhtrAKwE
	DL8Ss4WT1aRVk4qjymj43B/aWF6Klx8iLUcLMls45o5t08wh/FJjwHMZfPxSrJZhPbaRuyauGtG
	UzlyaoKF0rTLFIpTqJFSKs4ZcaRgyzLu5gPlC+YYS1ng3hJlB8UzAssAeYqXZrET8Bw==
X-Received: by 2002:a67:8c02:: with SMTP id o2mr42730566vsd.167.1561113564367;
        Fri, 21 Jun 2019 03:39:24 -0700 (PDT)
X-Received: by 2002:a67:8c02:: with SMTP id o2mr42730546vsd.167.1561113563788;
        Fri, 21 Jun 2019 03:39:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561113563; cv=none;
        d=google.com; s=arc-20160816;
        b=KsCB4W2r3zV1SaNabdV52x8xgBMrE5Cg2k0H6QkXEtFCLJlV6+FWuN2t1jF8Z8GkP8
         0n9uKLwlRxbdCNeFpRNURRhPIddkyDnyj7qbIwR7BJ2Fh8Npl1tLAVDEWtR81KOdZ35i
         P6mmOxo3JNERC0x8yJ1119ALh5LEDT1uNsvCtvkmMLnufny+TTtugHkWStVR5VOt4CbN
         ucI2mC1bH9UhUAaxN6FYUtYlaLfNsiUaozTnnIvnsLG+khT/FiynQyDbnrKjiXypbTc4
         JMNgKRT8l1preZpXZkQmYY9IAz/djoLWzaIyRQo0wZQ8k83ID6cusiLGWc7cX8aU40SP
         2NkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=/GyhlxzDlZ/c+fwrm+Fm2Dc67r0DcAh+69Mb7gFlO3k=;
        b=cQFybdevMa5cJrukwbtc4bAEJUiM6bfUR9LbjLdEMT13UiyyltVfTyCL5KfDPHZlLi
         LjX8Atq3PFW6g+K9hC9f/MVX9l4o3ukGIacdZcO/E1YRzim/qddVD9rMPG+aQZeWMsK0
         cjPZC0XcX6ThqzOSXE60iPavGsPCNiyh13ayr0vffmCZ2T8x5I0rJiYEbC/dT4MnjBVN
         ptzCN3BJQrBU+slBKlL8gcQctDZrTtf9qSebMLEENaSwxpXFE2UIoDT1dOFVZolv5v00
         Jsc7hdTNGeUkQGFu4hYSG9hlTButIYyl1V7oow2P8dy0S9Hr93M3sQjwp19NpnvTqGmg
         HRgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="oaiG/My2";
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i29sor1172726vsj.60.2019.06.21.03.39.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 03:39:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="oaiG/My2";
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=/GyhlxzDlZ/c+fwrm+Fm2Dc67r0DcAh+69Mb7gFlO3k=;
        b=oaiG/My2zmbB65WJe4cbDgNEyrknHvYXILox7hiJ7FCYFHhGY5Ff2YL8ONaBwKx5pD
         XqoJmqRKroXwJjHa9xBaqoaLTOCQGZV5FpjwkJxfn9y/UtvQwI7HwI35PuXIvHGQXQMW
         PPy/o8z6jZB7YHc42y4AmyBoe8FUmw1cL/TdSrfZBegjqTUoN5uXmKFTTAqPmTYzO+Yh
         iHRr5uouh3j4VajNERh78oQowHtY+GbXUfdYfPUkKjEO0pX1EDgHhSrJ7oaJP8XpWkV1
         8eBFW06bEbggFrMHGcvfsQzuNt3ZJtb8vqeS7577k5UXarwpSnqZTtQi3CfG945NDDcZ
         eMLw==
X-Google-Smtp-Source: APXvYqyh48CTqAoGqpwVNMKP36hE0e9kEq/4FyzDdnT36MjTnjH0TKMAT7VqOvhq6sV6TIPCijvxp5d7rVv7RHf3YhM=
X-Received: by 2002:a67:8d8a:: with SMTP id p132mr10336981vsd.103.1561113563011;
 Fri, 21 Jun 2019 03:39:23 -0700 (PDT)
MIME-Version: 1.0
References: <1561063566-16335-1-git-send-email-cai@lca.pw> <201906201801.9CFC9225@keescook>
In-Reply-To: <201906201801.9CFC9225@keescook>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 21 Jun 2019 12:39:11 +0200
Message-ID: <CAG_fn=VRehbrhvNRg0igZ==YvONug_nAYMqyrOXh3kO2+JaszQ@mail.gmail.com>
Subject: Re: [PATCH -next v2] mm/page_alloc: fix a false memory corruption
To: Kees Cook <keescook@chromium.org>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 3:01 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Thu, Jun 20, 2019 at 04:46:06PM -0400, Qian Cai wrote:
> > The linux-next commit "mm: security: introduce init_on_alloc=3D1 and
> > init_on_free=3D1 boot options" [1] introduced a false positive when
> > init_on_free=3D1 and page_poison=3Don, due to the page_poison expects t=
he
> > pattern 0xaa when allocating pages which were overwritten by
> > init_on_free=3D1 with 0.
> >
> > Fix it by switching the order between kernel_init_free_pages() and
> > kernel_poison_pages() in free_pages_prepare().
>
> Cool; this seems like the right approach. Alexander, what do you think?
Can using init_on_free together with page_poison bring any value at all?
Isn't it better to decide at boot time which of the two features we're
going to enable?

> Reviewed-by: Kees Cook <keescook@chromium.org>
>
> -Kees
>
> >
> > [1] https://patchwork.kernel.org/patch/10999465/
> >
> > Signed-off-by: Qian Cai <cai@lca.pw>
> > ---
> >
> > v2: After further debugging, the issue after switching order is likely =
a
> >     separate issue as clear_page() should not cause issues with future
> >     accesses.
> >
> >  mm/page_alloc.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 54dacf35d200..32bbd30c5f85 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1172,9 +1172,10 @@ static __always_inline bool free_pages_prepare(s=
truct page *page,
> >                                          PAGE_SIZE << order);
> >       }
> >       arch_free_page(page, order);
> > -     kernel_poison_pages(page, 1 << order, 0);
> >       if (want_init_on_free())
> >               kernel_init_free_pages(page, 1 << order);
> > +
> > +     kernel_poison_pages(page, 1 << order, 0);
> >       if (debug_pagealloc_enabled())
> >               kernel_map_pages(page, 1 << order, 0);
> >
> > --
> > 1.8.3.1
> >
>
> --
> Kees Cook



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

