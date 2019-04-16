Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F97AC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 16:01:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E559206B6
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 16:01:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="p9bIzPtX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E559206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CCA96B027E; Tue, 16 Apr 2019 12:01:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9540D6B0287; Tue, 16 Apr 2019 12:01:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81E566B02A8; Tue, 16 Apr 2019 12:01:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFC26B027E
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 12:01:52 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id j193so4347347vsd.2
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:01:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=hDWSZCo4hVwn0SqOh/8+4ITIl6IlceobuY8Gd3+R1MM=;
        b=rbxelfAaD04i2s+BHzGemKGO5W2D7AroxiVt4GH7xs3NMw9ma8a3+WWM2ukU0Cv6lP
         4Ugvg+W9DkvwFiXn2QpvOOwBR4HfbwxhrbB3G6CQsmAptO6JTSK+U5cFjqnbP6TIULdU
         6yLgBAhADut1Q1J6/MKE8YhIqUVDON5zdyAVgFTLkFPLH2LyXmDr7je/5GCyKOCzlRwP
         SuVQbEVRgBlpvEiHTgl4RInD7jKvRm+Z/SvBDu5NL5ZRq+Ji2ra9//Vrs0C4fBnfiOni
         52ELooeVQvNR0EZPBxhCzCueI4npg7CpI8HMqUCmD5loRA4oEG0tIyFlqiNih8OdSz84
         DJWQ==
X-Gm-Message-State: APjAAAW64lh0p3g78dq6NkTA7HlM2HMzg7rlWvwxHQjxg0wCOw7aakid
	abGyy0qMHFs6mxc0Uv3q0U5/zz0Z2oByfc2tLiRWD1z+APRt8pAcASbJlkBaq0VlS5aQc9UaSN1
	07KO4KuovHWKJIMElQYy/TTU14Sm7Z+TG4p/E7unYnZxDz9nP3w7i2DNAwVh5gs2Exw==
X-Received: by 2002:a67:ea0a:: with SMTP id g10mr4121229vso.77.1555430511967;
        Tue, 16 Apr 2019 09:01:51 -0700 (PDT)
X-Received: by 2002:a67:ea0a:: with SMTP id g10mr4121114vso.77.1555430510643;
        Tue, 16 Apr 2019 09:01:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555430510; cv=none;
        d=google.com; s=arc-20160816;
        b=ORYoDTi+oXj+pXgOSBgVjN1TvHaX++xlT9HKajr92HtHmp1A54iv9BOLUDJLAWFzgE
         MtHEdNLCf0ifNXaOd0UH5M3iHrkUjoVP+egkLxuOfx14WJpFPtTXHpJdRzPLZxe9AN7R
         tJGBqLn3Eq9E945f4lVbd2fCr114COX6DDuBS2MHeBa9OQvaPHW6KrHLKGGM83zep0SR
         AWvvyznhnTFfrynA6rSz7QRKvcFKJrtmdSv7WS9jQqxCoNaNBsKM/68PfAEMNWBADt/F
         W4NInf+idYf+RhK1j39ovGhgE7TWXkcFoJJ/4RYDpceftwPtp4qtocqTfiOtwERHg7JQ
         N6yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=hDWSZCo4hVwn0SqOh/8+4ITIl6IlceobuY8Gd3+R1MM=;
        b=m2xQPdmRxqvmoqxHxPgTLf1q+SbeIne967RkrBI2Xg2UK02YxlXae1gyZjZ0DVJSYB
         vDf4axxKLTHSbTU2hPVLvUJOmJVqxlQJ7T2ivTR2CXgV+6HSriPGC82KcJUTR6XENIuX
         aYeQAwmG7NLTX6T9wly+IkqQ9MdxE51iAXNKPMM9iJVSwGma+1F3Ygo4/ZXhwjb/7iJF
         99NJbVEKjU5tcfA2AyIlccEyOJFnPLbAgMD3TvvfvEr++fdQdfHiyk8Tv0hfhFDVevy6
         SCdlpbEXLrap8R7ZKUBYTM5PZmFbdadxGMRBHfg02zT4ZvcasMZhLmgeqLpabHezUn0i
         bSEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p9bIzPtX;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p65sor31732228vsd.31.2019.04.16.09.01.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 09:01:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p9bIzPtX;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=hDWSZCo4hVwn0SqOh/8+4ITIl6IlceobuY8Gd3+R1MM=;
        b=p9bIzPtXET3z3NKbYtfuYI/FpJ0dQe2rd3zFiSfIhvO8wFtb/pzduy0icSsdsDeim3
         XZiUih1isGFN/ytxANL7PCBufLt2s8MaFfrsOfMDULwb52QuP6jPLc3TtAuz5TYTKd7h
         vFbGjVudiJEYDtMCZcon7GBoHeRTryNZ1CTCvSEyAM/2xdm+ZjD1kc5tB3Ed45RkxeT7
         usXU4xhbqR0c9h43yBeD1bP4/jUv1e5r/BTu38LoulNEylk5TkzylLeMAGgo+BYv8q0W
         Y82yavUJH1gkP1LAB5r3qxwf9NB54Vz5M03aM3Vh/7T804FTvFSaQUD+BD3NMRSQNFqt
         sg+w==
X-Google-Smtp-Source: APXvYqxtPZ9GG8J2wfnElBD5nZyQxKYstxWVNCMBJDV4JIhuFNQQyhgaxJwl5fIqzjHj2WlsYdNxT25/g2x5M7SWwwU=
X-Received: by 2002:a67:ba03:: with SMTP id l3mr26668886vsn.96.1555430509891;
 Tue, 16 Apr 2019 09:01:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190412124501.132678-1-glider@google.com> <0100016a26c711be-b99971ca-49f5-482c-9028-962ee471f733-000000@email.amazonses.com>
In-Reply-To: <0100016a26c711be-b99971ca-49f5-482c-9028-962ee471f733-000000@email.amazonses.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 16 Apr 2019 18:01:38 +0200
Message-ID: <CAG_fn=U6aWfBXdkcWs0_1pqggAC16Yg8Q6rxLiVeiO83q1hOCw@mail.gmail.com>
Subject: Re: [PATCH] mm: security: introduce CONFIG_INIT_HEAP_ALL
To: Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitriy Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, 
	Sandeep Patil <sspatil@android.com>, Laura Abbott <labbott@redhat.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 5:32 PM Christopher Lameter <cl@linux.com> wrote:
>
> On Fri, 12 Apr 2019, Alexander Potapenko wrote:
>
> > diff --git a/mm/slab.h b/mm/slab.h
> > index 43ac818b8592..4bb10af0031b 100644
> > --- a/mm/slab.h
> > +++ b/mm/slab.h
> > @@ -167,6 +167,16 @@ static inline slab_flags_t kmem_cache_flags(unsign=
ed int object_size,
> >                             SLAB_TEMPORARY | \
> >                             SLAB_ACCOUNT)
> >
> > +/*
> > + * Do we need to initialize this allocation?
> > + * Always true for __GFP_ZERO, CONFIG_INIT_HEAP_ALL enforces initializ=
ation
> > + * of caches without constructors and RCU.
> > + */
> > +#define SLAB_WANT_INIT(cache, gfp_flags) \
> > +     ((GFP_INIT_ALWAYS_ON && !(cache)->ctor && \
> > +       !((cache)->flags & SLAB_TYPESAFE_BY_RCU)) || \
> > +      (gfp_flags & __GFP_ZERO))
>
> This is another complex thing to maintain when adding flags to the slab
> allocator.
>
> > +config INIT_HEAP_ALL
> > +     bool "Initialize kernel heap allocations"
>
> "Zero pages and objects allocated in the kernel"
>
> > +     default n
> > +     help
> > +       Enforce initialization of pages allocated from page allocator
> > +       and objects returned by kmalloc and friends.
> > +       Allocated memory is initialized with zeroes, preventing possibl=
e
> > +       information leaks and making the control-flow bugs that depend
> > +       on uninitialized values more deterministic.
>
> Hmmm... But we already have debugging options that poison objects and
> pages?
Laura Abbott mentioned in one of the previous threads
(https://marc.info/?l=3Dkernel-hardening&m=3D155474181528491&w=3D2) that:

"""
I've looked at doing something similar in the past (failing to find
the thread this morning...) and while this will work, it has pretty
serious performance issues. It's not actually the poisoning which
is expensive but that turning on debugging removes the cpu slab
which has significant performance penalties.

I'd rather go back to the proposal of just poisoning the slab
at alloc/free without using SLAB_POISON.
"""
, so slab poisoning is probably off the table.

--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

