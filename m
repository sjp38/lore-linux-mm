Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79DDFC46477
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:08:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35495208C2
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:08:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="VggNUJ7a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35495208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF67D6B0006; Wed, 12 Jun 2019 07:08:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA6196B0007; Wed, 12 Jun 2019 07:08:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B96AD6B0008; Wed, 12 Jun 2019 07:08:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 850876B0006
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:08:48 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so9605915pla.7
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:08:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=w620wCIkG8GXS/KYH0IDoZ7ej5kJ3WmWx8LtN+LbTUQ=;
        b=XwyJ5MrPKNg2+Ij3XKK9P4gxaCUvRua56uP1bCNzK6bdT9We2bFq2l69aOrkwfGbFV
         7GfDNQEcQioMtVeaEiUtE7u5zbb0HnVzt3mDucY5rIwHmjLuniuJ7CysAp5jb0PVetKy
         OEChWBohpl93WF1pkGH/pql9ccVVx+vjm4DSU3sIOEgRahqEqiaGxl7E6kwhU0/JAnxc
         TOtnWLMZbrVwr7ZuFQLD/uyUe6SEft1NcZN4hclDCyr7e4hzsNZqFOAhEU+ltr6z6+c4
         Np6qtoLPxvLNB5LedmjA6AgHuj7PrKnAuIjkT9qal0qmcBaut39sZRSJ3Vrdr9W1dhTc
         Oj9g==
X-Gm-Message-State: APjAAAU9qzfwccF9nvPxxfAr5Mimn1WVkzMrhCOAW8mchofixqvUfswZ
	5diGNgsAnR24GnY2oylpZahlJLcGnao+c0GxzALEU7TTtM2ItVqfilnWGLShraPq03OK8on2ND5
	teYOCJFNGtP0lrRF4v2WIKVurqh9RVNLCC63vWKiLsWpZqPvIoI7OKBfmTm8fUHnTmg==
X-Received: by 2002:a17:90a:9f0b:: with SMTP id n11mr31480185pjp.98.1560337728220;
        Wed, 12 Jun 2019 04:08:48 -0700 (PDT)
X-Received: by 2002:a17:90a:9f0b:: with SMTP id n11mr31480106pjp.98.1560337727242;
        Wed, 12 Jun 2019 04:08:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560337727; cv=none;
        d=google.com; s=arc-20160816;
        b=UX7qxDW92PrceUodFUFSlYMWR6ViA0uPlYbzGrkd7Jc8onfBv/AfWGIpgwZnzsAIOJ
         BmKkxtE5shIR2JE4C/RZmU9Hpp63sebsiHIcZdnUbwVtego2Ubbs9R34VyqURYUKw5k/
         2N9ViwqC0mUuQ+w/uEwijo2hDHlvGFoKEszqQ1YHy5Yf6E0hnItcsHkajOP3Xa2BrNUU
         ocZHYdezv1/+84qGAtMUi7n5/Ksfe1t1/m3DRMvh+CTOurAvku3jQBeB+SauR7Xyb7ch
         dfBoGPZpWRhSsYMvHglm55qdf/HIt9hEPIAmx/OPlHvmBeYRhgbvVtu8snafkcq8pFuF
         FK+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=w620wCIkG8GXS/KYH0IDoZ7ej5kJ3WmWx8LtN+LbTUQ=;
        b=exRU7LWx0snxXz9w+FV4rfTpyU2D67kCpn3ZKBU/zBNER2PTETBh9a9TO1eABYKnZm
         Wxa/FCjIvo5RxyynBqtSCSdHjqIgs2u0FDXICbiRB/Rj7+yuDR+nUivk8z9WFwpOfooA
         jada1piW5ZCmaXcC7u293PTdlSXXfCtHpJXxuqIgN2QGlIO9vlyjn08PFcUeX3R6KAYI
         sSXo4sRmCwiJdPuBHOcZ+eiCYmMR0lvMxsDR8NSuW1K4CatgDEhe4JrxKiV/4gSlPj5m
         wdV8WWssNNeRMmDAVprZ6oSAA0APL4buDzO8oJqHh5vH0atd1qdzn1bqcqeCyw6A6kKO
         8DJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VggNUJ7a;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s13sor15646215pfm.59.2019.06.12.04.08.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:08:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VggNUJ7a;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=w620wCIkG8GXS/KYH0IDoZ7ej5kJ3WmWx8LtN+LbTUQ=;
        b=VggNUJ7a0brq2Ev6nAJQqO2O72gohucw8zeY5YtHck9VQOLSeh4HE1gegC/6IXwwZQ
         yGU57RiXcKZXz6rEKzU45Xf6W2ce+VRfcbyLnBuDiGAB0WY+oQBhpKyfWyvJoxfZX9DP
         yh5EZsvMAI815IqL/1YdyEKkghoO2fuJKDAzd5Q9y/OjjRwPS+GPbIwNDHqKiLuIYdn3
         FS/k/NQyAktrRCCDybeyESanVpXbjmTwdROU2U/U+lx1nc+kfxYxbzF+ximhp+/PoGPk
         LddaTqB/qiSjwgqbl0KdSRDedqW9qTDDWoaJfcFucWGR/PYqdZ87SzwkAPpr4TVyN7Wo
         N3Qg==
X-Google-Smtp-Source: APXvYqxvUwlKkJ1D0n5ZAgi1aKr005PngCLgks22Vr4JdWsBWlki9wY2M2Qsc1xcmNb71INK9Pq98aEQaKS4b6HnOls=
X-Received: by 2002:aa7:97bb:: with SMTP id d27mr18449962pfq.93.1560337726555;
 Wed, 12 Jun 2019 04:08:46 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <e410843d00a4ecd7e525a7a949e605ffc6c394c4.1559580831.git.andreyknvl@google.com>
 <d0dffcf8-d7bf-a7b4-5766-3a6f87437851@oracle.com>
In-Reply-To: <d0dffcf8-d7bf-a7b4-5766-3a6f87437851@oracle.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 12 Jun 2019 13:08:35 +0200
Message-ID: <CAAeHK+yTmU9Vz0OB4b7bcgjU3W1v6NFxgpiy4tud7j0AHXkwtw@mail.gmail.com>
Subject: Re: [PATCH v16 04/16] mm: untag user pointers in do_pages_move
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 10:18 PM Khalid Aziz <khalid.aziz@oracle.com> wrote:
>
> On 6/3/19 10:55 AM, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > do_pages_move() is used in the implementation of the move_pages syscall.
> >
> > Untag user pointers in this function.
> >
> > Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  mm/migrate.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index f2ecc2855a12..3930bb6fa656 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -1617,6 +1617,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
> >               if (get_user(node, nodes + i))
> >                       goto out_flush;
> >               addr = (unsigned long)p;
> > +             addr = untagged_addr(addr);
>
> Why not just "addr = (unsigned long)untagged_addr(p);"

Will do in the next version. I think I'll also merge this commit into
the "untag user pointers passed to memory syscalls" one.

>
> --
> Khalid
>

