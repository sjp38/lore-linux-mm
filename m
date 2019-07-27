Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2238C76191
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 02:34:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85D062086D
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 02:34:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UHjHeqS7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85D062086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23C936B0003; Fri, 26 Jul 2019 22:34:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1ED338E0003; Fri, 26 Jul 2019 22:34:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 103198E0002; Fri, 26 Jul 2019 22:34:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBE376B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 22:34:17 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id w5so30067926otg.0
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 19:34:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=zpeooSg+LQdXjAAfVsZypK0AbbwUv4Ep7JcxnLVryiU=;
        b=e+ONuS5z+nD74ftkg99Cfyrq9OFSDnVy/hVE0dyv5f5w/P4DfQG7ZRzwF7cRSFqNXk
         3APMP8Dnf6t946lFykQuWAmm+4JlVVHRNowoA5oETJbOpWTft7js9psZFxqXr109UEOe
         UzSx2Z5kb4rTB7rRqfzvv96yCQQix/6p/7wKf508oGH4O96BNIQvNgvVMNjmDmsIwi3Y
         eXa8vj+5aI/ULXAGdJk6uxNOgz718pD0GRIi5CXUbIqzlZJ96hDPD0Bd7FYFRdbT1pKj
         KwlQlnjAM/5EVUc6M8rfUTNF/3CEIMZnUsouUYsgPSUSyct5xDs/Ss4B6tbDyvbNYgbA
         zNlw==
X-Gm-Message-State: APjAAAWHFXiExk224tgNbR2dAq0G5uhn/HliWZT0ltesotaQ1EiUchjV
	vWx81JZJiuuu+W7/gveHF4DWTGPG0OvOYm+3n1hLHV4vqNG01FWaclRHLwyg5BzU0qjq3EU9l7w
	3ajogYkjBUsK4mcBgPGdkIFjXTqgVF72dHkvqS0E0mtb/zOFM5FPvnwiXjXDMgqUFbQ==
X-Received: by 2002:a9d:4809:: with SMTP id c9mr11886870otf.199.1564194857506;
        Fri, 26 Jul 2019 19:34:17 -0700 (PDT)
X-Received: by 2002:a9d:4809:: with SMTP id c9mr11886849otf.199.1564194856952;
        Fri, 26 Jul 2019 19:34:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564194856; cv=none;
        d=google.com; s=arc-20160816;
        b=TJwQ+eVjg3zSKL3T8TamXq9Lv/BQuUNq6aR+aaLFgmVSMZJ2A9kSKSKvE/7qlacg5u
         fHT5tk8zXUSTvGGBmafGLjkH3+vQ7Ie0CoB8D+188PsT8Iiax5rNnOk9EG4rGvlfMTTI
         eLQ0pxV/8RShf8TLdjrkItlVgcrYhqG3e36S1812BBvW02pK4LRqUw8ldfZYT6m0OxZF
         bihAf7SeHGva1uTjuIICvqJKc/uSlhA4KzFxnLgmj/iw7Mm0Hcu30jNO7F2nUuxqYhjs
         5wE5/o50CEutygv+IT5BV/38/dGR5s1MZpiO3yJP6u7Wvjr30snYgQ6QSGQWR4kxsNrC
         YKNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=zpeooSg+LQdXjAAfVsZypK0AbbwUv4Ep7JcxnLVryiU=;
        b=jxnSiwjyZqmsO35uW77qc29Z+yFWrhC+LVUHGVxsEJS8bfHjgZKdSeIhoRI1b8+VZL
         JxI4PGLdKbRYEklKkJo9N4kGmsGYfwMm0safqKGWSFZlQOtKh5O+FrfLSLVxOe7Nbvo7
         9RjuNMgvHhKYy7L7JftBWztcnUODsmolRn6WJ+r0nO7Xd4IXKjLN0qVFxVhTX3MF1jXn
         OoQD+cpkUtFu4KbfOF/9wyvQyi1NROtqSAipzH5JRoMgFov+gGike5fdT/FDKG6QzcU2
         06AIQGnr4zxsTyrT4+B0+lxvDLtLCs1lsqDfuUfHLutoXSqwzIBCXPhinlmlqYqYSSd/
         PJeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UHjHeqS7;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 40sor27929114otj.175.2019.07.26.19.34.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 19:34:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UHjHeqS7;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=zpeooSg+LQdXjAAfVsZypK0AbbwUv4Ep7JcxnLVryiU=;
        b=UHjHeqS7q3gd26VS+n85HRyE9GOmIkDj019sXmy+muPSPCkqtq0YR8IcQgl8cJ4hYh
         godJNDBFKBHweclH/CH0P/D5qASWANJ0mqOdL5sYy1fv5cyO4Q+qoy4jgV4iwaNf26z1
         GlPDN12bhXuKuwwbSuvZhFvA9CXrNiu5xbewuMkdR/h1QxDZGThP5h6SHnC0f0hCRpps
         0yD+tHlvgZGsyozrCivNsYxNvWhoJgskpBq7CKkgcvRzmjawYe7keGroLiy5N+I7fdx4
         rM06nkLvvder5FuVPEhTB9KVPQju/81EUxqLUTNK6DEN788mGPfeK2605he49s83yTBK
         8Lrg==
X-Google-Smtp-Source: APXvYqydHwrWeTu/eNQDqkwJCphABHgrjGj9nCOmuE1P5OcqkhTB8TU7YiJxThnnIeQncQm5jAV9GD4uGTuOsp7E0lE=
X-Received: by 2002:a05:6830:2098:: with SMTP id y24mr29902120otq.173.1564194856659;
 Fri, 26 Jul 2019 19:34:16 -0700 (PDT)
MIME-Version: 1.0
References: <20190725184253.21160-1-lpf.vector@gmail.com> <20190725184253.21160-3-lpf.vector@gmail.com>
 <ac59714d-74d6-820c-37ea-5bf62cfc33a8@rasmusvillemoes.dk>
In-Reply-To: <ac59714d-74d6-820c-37ea-5bf62cfc33a8@rasmusvillemoes.dk>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Sat, 27 Jul 2019 10:34:04 +0800
Message-ID: <CAD7_sbHTzPrQGEA259HU__-G7dvV_dZ-f3WavPavp-0WQzB4aA@mail.gmail.com>
Subject: Re: [PATCH 02/10] mm/page_alloc: use unsigned int for "order" in __rmqueue_fallback()
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, mhocko@suse.com, 
	vbabka@suse.cz, Qian Cai <cai@lca.pw>, aryabinin@virtuozzo.com, osalvador@suse.de, 
	rostedt@goodmis.org, mingo@redhat.com, pavel.tatashin@microsoft.com, 
	rppt@linux.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 5:36 PM Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
>
> On 25/07/2019 20.42, Pengfei Li wrote:
> > Because "order" will never be negative in __rmqueue_fallback(),
> > so just make "order" unsigned int.
> > And modify trace_mm_page_alloc_extfrag() accordingly.
> >
>
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 75c18f4fd66a..1432cbcd87cd 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2631,8 +2631,8 @@ static bool unreserve_highatomic_pageblock(const =
struct alloc_context *ac,
> >   * condition simpler.
> >   */
> >  static __always_inline bool
> > -__rmqueue_fallback(struct zone *zone, int order, int start_migratetype=
,
> > -                                             unsigned int alloc_flags)
> > +__rmqueue_fallback(struct zone *zone, unsigned int order,
> > +             int start_migratetype, unsigned int alloc_flags)
> >  {
>
> Please read the last paragraph of the comment above this function, run
> git blame to figure out when that was introduced, and then read the full
> commit description.

Thanks for your comments.

I have read the commit info of commit b002529d2563 ("mm/page_alloc.c:
eliminate unsigned confusion in __rmqueue_fallback").

And I looked at the discussion at https://lkml.org/lkml/2017/6/21/684 in de=
tail.

> Here be dragons. At the very least, this patch is
> wrong in that it makes that comment inaccurate.

I wonder if you noticed the commit 6bb154504f8b ("mm, page_alloc: spread
allocations across zones before introducing fragmentation").

Commit 6bb154504f8b introduces a local variable min_order in
__rmqueue_fallback().

And you can see

        for (current_order =3D MAX_ORDER - 1; current_order >=3D min_order;
                                --current_order) {

The =E2=80=9Ccurrent_order=E2=80=9D and "min_order"  are int, so here is ok=
.

Since __rmqueue_fallback() is only called by __rmqueue() and "order" is uns=
igned
int in __rmqueue(), then I think that making "order" is also unsigned
int is good.

Maybe I should also modify the comments here?

>
> Rasmus

Thank you again for your review.

--
Pengfei

