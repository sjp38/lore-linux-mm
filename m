Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3BCBC04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:40:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AE282173C
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:40:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="hK2eyv+R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AE282173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C62C6B000A; Mon, 20 May 2019 17:40:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 376226B0266; Mon, 20 May 2019 17:40:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28D316B0269; Mon, 20 May 2019 17:40:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0660C6B000A
	for <linux-mm@kvack.org>; Mon, 20 May 2019 17:40:49 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id b46so15448800qte.6
        for <linux-mm@kvack.org>; Mon, 20 May 2019 14:40:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=IThQGlwZN4WtsbLkk3oukuwrzsnq23H8GMI8BgIL1f8=;
        b=M+zkTtCXxhHFGUooV108d1qPEiTTiM0DpFpGzr9hGu79NhCQU+626+4LHAWFbxh14o
         mLk4t2DwBGSWQU8DgmCFcwoXy5KSOvhKKsaMSqxeQ0EWY/hIgf62QDSjAG9RtYDxJStU
         T0w11qh2ghj/A7PvVagVuOnh0KLB+GXw+6+kQHux6RnCihJC1TWu1obd60LXvGdgbDJv
         2Bjh4Qs3sUoOPnyOZxhWjV10U1Lj7q2i3EhJeZdsylJxHfe3Zc0BkUZcJzBQNvHtTfrW
         ozKzSqZHe1g1g3EBQW/eEfsyTA+64eHV0E0/3TdNcbpasBHUPjLpRH2M+Uivc7gwn27f
         OTvg==
X-Gm-Message-State: APjAAAWKcBYjg3OdQ0lmsvZGjK9QSgNjDKvqIzffdTmEtMMOBjh2wayZ
	Fuv3IWY2JH1DBWlVz1sY1wshSR+XtzB1H9S/xhvq4L7We2jykmVCCCTByCKBmSrehFikVYtctUW
	wEpaDYDgKXKchRJ7A00pqk93zSJPXCIUe0hnrIY1S8Kr8D0Eddweu/EjarHbgvEYt2w==
X-Received: by 2002:a0c:d17d:: with SMTP id c58mr52671668qvh.172.1558388448793;
        Mon, 20 May 2019 14:40:48 -0700 (PDT)
X-Received: by 2002:a0c:d17d:: with SMTP id c58mr52671642qvh.172.1558388448215;
        Mon, 20 May 2019 14:40:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558388448; cv=none;
        d=google.com; s=arc-20160816;
        b=PLjjODCVB0goQpMZpQ8r1S2ZifRyfNwl+m3tDMq0yvHGlbKJDV+FyMN8Tb1lWaTQC5
         SW09KQBsEvBQuFbojh7evpf5oYYd+zo8PPH6aV4iubrk+zSO+UxrgvPUPOBuanFCOe8O
         g3oQA7xDLsrV07SWXPtYQuRfOZeSBK3TZHgSkyGP+lEvZcI9kD1rLrjf0JhKAjPTxann
         CD8dzGoL3H1iwxuFRvxkhaCd8aQgW04aWdfLUhWELlY22RtiPMLh+Fvvdf8SEdRswgZk
         osFduHzDUnbVQ+EeGpBzuFtPqhQZ8Vqil4lllloqQvoMnPoNO81g1rOyNJfEcMwYyqfF
         TA6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=IThQGlwZN4WtsbLkk3oukuwrzsnq23H8GMI8BgIL1f8=;
        b=cwZs+8uoXoYEhsvKf4po2VQCBDYLyGCle/5Fg1bO7TNy/Q75NksBkGs7zICoCO9Viw
         khyvsjFDBwTwT9BxchpqG0GRpR8FBbKkAOQ1Bew0veh5Nm0bxaWVNXJM+ivYitWyma46
         Ad4dIlDfAQZugdacSdZ5MZfoZU16XpNW+OKvrszk4Z6t2MFNaxCo8B8CDYmqn2pr+a0S
         wJtosBQUvf51eCeI6eUqTvjiNbioiPhXbktQhV473ruTsZF0w34WcLG86DLXFIgDdxfU
         uHmacHJ260KelIrvBRGxExJsrPdg7NeNRO9XeasHHMGozYpeTkjoMj7FB4vAZ61tgTRf
         Pg4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=hK2eyv+R;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u6sor10260674qkk.56.2019.05.20.14.40.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 14:40:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=hK2eyv+R;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=IThQGlwZN4WtsbLkk3oukuwrzsnq23H8GMI8BgIL1f8=;
        b=hK2eyv+RmjhJBhO9xW7nmAOoLOTUPMU93WRuMaB8KV1/Ipcsc6fF4RwDKaRanXgiiQ
         1moFfP9ko3eAH7gEqqzVhMRmuadceiV7qXi2MurSlIpZ9Llv91z5GHWZ/1aX3y7jM18+
         IGN5yM1LK6mMLNa40n1/AIP0iJDcB2m08JUvM=
X-Google-Smtp-Source: APXvYqzfgYWlx9/QVid5RlxkAKFGC41IFGLXDgG2zUutdncRoErF8VDmxEvq4gwP/Ta+vr3S5rGzrv8w5nxXmGEg1dQ=
X-Received: by 2002:a37:4c04:: with SMTP id z4mr43466352qka.195.1558388447854;
 Mon, 20 May 2019 14:40:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190520044951.248096-1-drinkcat@chromium.org> <CAC5umygGsW3Nju-mA-qE8kNBd9SSXeO=YXMkgFsFaceCytoAww@mail.gmail.com>
In-Reply-To: <CAC5umygGsW3Nju-mA-qE8kNBd9SSXeO=YXMkgFsFaceCytoAww@mail.gmail.com>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Tue, 21 May 2019 05:40:36 +0800
Message-ID: <CANMq1KBUKfOdZWAf95nb2UQqLdLCMsLnVTZAZSgN0QfgK3Dbxw@mail.gmail.com>
Subject: Re: [PATCH] mm/failslab: By default, do not fail allocations with
 direct reclaim only
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, 
	Michal Hocko <mhocko@suse.com>, Joe Perches <joe@perches.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, 
	Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 12:29 AM Akinobu Mita <akinobu.mita@gmail.com> wrot=
e:
>
> 2019=E5=B9=B45=E6=9C=8820=E6=97=A5(=E6=9C=88) 13:49 Nicolas Boichat <drin=
kcat@chromium.org>:
> >
> > When failslab was originally written, the intention of the
> > "ignore-gfp-wait" flag default value ("N") was to fail
> > GFP_ATOMIC allocations. Those were defined as (__GFP_HIGH),
> > and the code would test for __GFP_WAIT (0x10u).
> >
> > However, since then, __GFP_WAIT was replaced by __GFP_RECLAIM
> > (___GFP_DIRECT_RECLAIM|___GFP_KSWAPD_RECLAIM), and GFP_ATOMIC is
> > now defined as (__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM).
> >
> > This means that when the flag is false, almost no allocation
> > ever fails (as even GFP_ATOMIC allocations contain
> > __GFP_KSWAPD_RECLAIM).
> >
> > Restore the original intent of the code, by ignoring calls
> > that directly reclaim only (___GFP_DIRECT_RECLAIM), and thus,
> > failing GFP_ATOMIC calls again by default.
> >
> > Fixes: 71baba4b92dc1fa1 ("mm, page_alloc: rename __GFP_WAIT to __GFP_RE=
CLAIM")
> > Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
>
> Good catch.
>
> Reviewed-by: Akinobu Mita <akinobu.mita@gmail.com>
>
> > ---
> >  mm/failslab.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/failslab.c b/mm/failslab.c
> > index ec5aad211c5be97..33efcb60e633c0a 100644
> > --- a/mm/failslab.c
> > +++ b/mm/failslab.c
> > @@ -23,7 +23,8 @@ bool __should_failslab(struct kmem_cache *s, gfp_t gf=
pflags)
> >         if (gfpflags & __GFP_NOFAIL)
> >                 return false;
> >
> > -       if (failslab.ignore_gfp_reclaim && (gfpflags & __GFP_RECLAIM))
> > +       if (failslab.ignore_gfp_reclaim &&
> > +                       (gfpflags & ___GFP_DIRECT_RECLAIM))
> >                 return false;
>
> Should we use __GFP_DIRECT_RECLAIM instead of ___GFP_DIRECT_RECLAIM?
> Because I found the following comment in gfp.h
>
> /* Plain integer GFP bitmasks. Do not use this directly. */

Oh, nice catch. I must say I had no idea I was using the 3-underscore
version, hard to tell them apart depending on the font.

I'll send a v2 with both your tags right away.

Thanks,

