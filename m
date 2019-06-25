Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B564CC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 16:16:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 798D32080C
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 16:16:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lfU+EkDA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 798D32080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0B5E8E0003; Tue, 25 Jun 2019 12:16:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBA9F8E0002; Tue, 25 Jun 2019 12:16:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA9268E0003; Tue, 25 Jun 2019 12:16:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id B31D28E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 12:16:56 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id z6so7923968vkd.12
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 09:16:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=bxHs3cMUSY/lcnTBaWC9lm65VMyS9xe/CNCPh9Pq+7Y=;
        b=Ee9+6hublxWtsTvwBj3/A1Bdl9sTQoMxA7g77xfEReZ3b5Px5SLo1offC4nrSbife8
         Bp+pMnyxa2mqnKLRReQb/LOF3+A9wHlGc8Ov0huoCX/nedURcYXv30bU6uo/EqG+VwzQ
         KIvBp0xhasPKVqGGe9dGfiqAqgxjuufx5Yr/FjWepDlVW9U0BkPZqg8XuW6zQwhT4XbT
         qaCGaIyyPH8RlB5nt1PxWOfXcg5oXi+wb+YRIrX0bEFj3LFFiZgM32xDWwlkddrfSp1l
         RGepXxqpt89AoaERpqkNV2/t7lFuOOCMeJ+vGjJqEv+1RYE+EUr4bPsgEsFlXSsk3ZMF
         2Qjg==
X-Gm-Message-State: APjAAAU9uw2rIZnY3o0saVqzMwV3CfY9Zdm7++U7KA0cBMsqMe9GsJTj
	wcjIPj/IX7yPXPgn8LtAJm4NOZb/QnpaACq+4884DWF8nNIijcCG9Us4kFvl8Kygrg6Lui+mQjQ
	vJcSy3qA904jc+jBDHFWjbiWfnl0WZVciGdaKY1bWyOg47jXDJCPnrH43wS0p6u22/g==
X-Received: by 2002:a67:d590:: with SMTP id m16mr63163400vsj.76.1561479416402;
        Tue, 25 Jun 2019 09:16:56 -0700 (PDT)
X-Received: by 2002:a67:d590:: with SMTP id m16mr63163367vsj.76.1561479415816;
        Tue, 25 Jun 2019 09:16:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561479415; cv=none;
        d=google.com; s=arc-20160816;
        b=B3TWCVH3Qokn0gbTY+9TMQjDQ2OVt/O28zbF5daL6smv9CBsrbMvp3jwlW6UoYNhWC
         sSGNf4/QqoZFdk2QjVxMIOFT4utqBMwYcuNeQBGRLDS3K/GC1fUUcmq7XlEpg68Ly4ZQ
         Xs1MqBQh0FoosypftDXIh4syqyigZxEYVhpOtEARsHZhG4OY4XMbGcayD1hpXSVv9Isa
         357zDzb0sM8x2PdNBiS1GpJkRyqXjQxv9GAweweZ5y8HDhLFGXn4EnWk01hP4EWKlWPc
         jceYzjhtGtu147RmdfJ+X+qptb6kFtRNIuJtvC8HvrjHmbagGWlzHAOujaISztblAO+w
         YYCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=bxHs3cMUSY/lcnTBaWC9lm65VMyS9xe/CNCPh9Pq+7Y=;
        b=IH2LldZMN1VAIFcBegG2PXdboNwNZDNYFQpr/QfKR1VKoNHCiMLiA12Rh/IX826583
         jeZi4x6eVL4i6W40fDIrvIcoVVe3R2Av0AWqY8I/hQLRmoZqZ1Ze95Ng0fzQOCJ0gQ+e
         NFbc648xH36EHlyLTIn0ubY+O1PFdE/KyZQ9vCpu3xz+BIsRABF15Fy+ynqNQ8Tg5hGE
         nMbtIxu4eF3EiZvUpYn8J1KVU2diFcBYrNfNCPg5H2VbyrOYgHZnbxSECR1+8nfqI0Dd
         Bhs8W2Lpa32sDbmEzvKxzpzy5Uo8h3ezNYXESeNBf1O2hZJ6VsDpO6V5E+ICdC3S/Qrk
         z/nw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lfU+EkDA;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q19sor4492765vkq.52.2019.06.25.09.16.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 09:16:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lfU+EkDA;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=bxHs3cMUSY/lcnTBaWC9lm65VMyS9xe/CNCPh9Pq+7Y=;
        b=lfU+EkDAWcPLRsWFZdyEfPOrokoZXTJOFAaKyF3r6LE750Q13wN0o6eV2p2X6/qNh3
         xlGQrTOAWphdM3tf5Q34V9WcKc5qb9CS3qnIXd4/GggBxU4ZWYv8/urgyGIE/WjwL9wu
         JBhXvzUzCj7LzikrH2PdogJbPcFyLBQSVovo2yg69817e8gHinU5WNLuBem3pzfcgKhm
         uwj1XNHUc/4wK7wKWvtPAIKoXhNIipBITpomNKuKYvub+6wZ7z9/OKSUdHzocg5uIVxn
         gjVsMiEuEbdySUgXhOjJfMxL6lLkNNocT19B5soH7h9dL3yAl4V0IUneDji3O4ZE3idz
         OLlA==
X-Google-Smtp-Source: APXvYqzpmnLCOXbPK1tWPjNlTXEyP5BOMbJ27cXAFZ8jzDcM35yx9cTomQz6y6wya6Cj0FLuD1+b0URocoD+vFFBtcY=
X-Received: by 2002:a1f:b0b:: with SMTP id 11mr6742950vkl.64.1561479415224;
 Tue, 25 Jun 2019 09:16:55 -0700 (PDT)
MIME-Version: 1.0
References: <1561058881-9814-1-git-send-email-cai@lca.pw> <201906201812.8B49A36@keescook>
 <201906201818.6C90BC875@keescook> <1561121745.5154.37.camel@lca.pw>
In-Reply-To: <1561121745.5154.37.camel@lca.pw>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 25 Jun 2019 18:16:43 +0200
Message-ID: <CAG_fn=WuEL0ZGdmy3fhY9gW-nBw_qG9_yb3Ut1+17By3h=d0Jg@mail.gmail.com>
Subject: Re: [PATCH -next] slub: play init_on_free=1 well with SLAB_RED_ZONE
To: Qian Cai <cai@lca.pw>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 2:55 PM Qian Cai <cai@lca.pw> wrote:
>
> On Thu, 2019-06-20 at 18:19 -0700, Kees Cook wrote:
> > On Thu, Jun 20, 2019 at 06:14:33PM -0700, Kees Cook wrote:
> > > On Thu, Jun 20, 2019 at 03:28:01PM -0400, Qian Cai wrote:
> > > > diff --git a/mm/slub.c b/mm/slub.c
> > > > index a384228ff6d3..787971d4fa36 100644
> > > > --- a/mm/slub.c
> > > > +++ b/mm/slub.c
> > > > @@ -1437,7 +1437,7 @@ static inline bool slab_free_freelist_hook(st=
ruct
> > > > kmem_cache *s,
> > > >           do {
> > > >                   object =3D next;
> > > >                   next =3D get_freepointer(s, object);
> > > > -                 memset(object, 0, s->size);
> > > > +                 memset(object, 0, s->object_size);
> > >
> > > I think this should be more dynamic -- we _do_ want to wipe all
> > > of object_size in the case where it's just alignment and padding
> > > adjustments. If redzones are enabled, let's remove that portion only.
> >
> > (Sorry, I meant: all of object's "size", not object_size.)
> >
>
> I suppose Alexander is going to revise the series anyway, so he can proba=
bly
> take care of the issue here in the new version as well. Something like th=
is,
>
> memset(object, 0, s->object_size);
> memset(object, 0, s->size - s->inuse);
Looks like we also need to account for the redzone size. I'm testing
the fix right now.


--
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

