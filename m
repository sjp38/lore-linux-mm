Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2814AC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 08:47:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D356A2089E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 08:47:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="reminkYh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D356A2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E9B56B0007; Tue, 11 Jun 2019 04:47:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69A416B0008; Tue, 11 Jun 2019 04:47:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 588386B000A; Tue, 11 Jun 2019 04:47:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A59C6B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 04:47:40 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id m26so9436034ioh.17
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 01:47:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VF1kGVddFpIAC2XDRsCvaPTsWd3oiEHLMIFP7bJNfAA=;
        b=WTKh6wAlQshQr36ZUqynEV+3t3J4Kd3mbCAJutOLKfdxR+KCh8I8MGyfmm1wCwNstC
         qFgKlqpepsQYSYhFjdAX7nLMw0gKHSYW42zX10wgEjz35Uh/WTBcGKcbypRgR7WpSi/f
         hRe8KVy2705jYL7XzB2AvKYqR9yB/pA3BRiIfPGkY5vH+268IfDRoby08ponsbMoqJmE
         KJTCnkSNkILl3MDAC3EMSrncpUQZAuiQwOd6Z+kJoTgsMQ6yDfuvyyh6xclKOefjTbli
         NT0rr4xcD5PvtueBxYF0VGm0RVYvv/+u4WF/fypXaa5CCfchMbwa5372ohJUd4nzrGzK
         Gp8g==
X-Gm-Message-State: APjAAAVcnSddP11Ca1jVudUB46f/7Zy47yGnayli5pexsihxCKPwhfLu
	03BcCBpiOYmq/Up06F6JvX4W4snqkyQQpku8oCyAja6cFdX1gqW5zAqWRtdeW2ANEjgr6iAkb//
	I8JOyOHrTKBzZlJM1sBXsrS27U5iAjKJj5URSWAsB0N2evzOjSXGp/nV703UU6wp2Kg==
X-Received: by 2002:a24:cf46:: with SMTP id y67mr13619901itf.105.1560242859938;
        Tue, 11 Jun 2019 01:47:39 -0700 (PDT)
X-Received: by 2002:a24:cf46:: with SMTP id y67mr13619867itf.105.1560242859123;
        Tue, 11 Jun 2019 01:47:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560242859; cv=none;
        d=google.com; s=arc-20160816;
        b=Y7/VMWhKna3TMoo6vvwJJ+F8aTNmfz2B+KCGVoJnteWESatp7IquwMksQ565RmNqrF
         qUcaqUdKIpIf1BeQjaGCWOfwdcDF2/UnO6heDjx5lu0gPI+EhJR2HaJrDuet/wRngcEC
         GyrYOx0dJ/xYpZOPDHZvzK9jywOUdJvAN8lHUVZ99pCdaqu65jzZ2tWzesOPj6+O7DOa
         SIUMjE/nIya25CWrWIkmB/SQ8mieE9L3/Cf3CLQyxrZ71b/8eunlT0DPAyKZP6DzGQMg
         sHaErk2rEh3rlfnMtat3h+MgtE5iweX06C+IN5avpwFaGg23iQ13QKXPjVmVL8MfyNHg
         iFSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VF1kGVddFpIAC2XDRsCvaPTsWd3oiEHLMIFP7bJNfAA=;
        b=h+uNMFUGOM0Rm+EqM4RMUiQ88WVSfxirDBZoy9npdxkkMDmpdHamh6aAAV3U++cMpM
         YHrRN6fGTqGB/TtjmYq+HHtBQnD6gR0DWrIgRUf0bSC0gB06+y3+1kOAdpjiI68TKKew
         Pqj2mN292VPhPQV+rhGHm1QFh6oKyoiCh5n9RFUWtEdlwPaiBCbjcZjCYva4VND1amT2
         aYa0LeGQM1gaQ7PCp2TdgVSR4PnDO2l2WFrIhEUWwss83gApwa1gpKxh1c/WS2PPIyNo
         uy7Uif5TYf/5zKGvKikjMlt/83tqwty8sWe7Ay3CX+piku2px3FtFxvfYw9Bc4shjyye
         PzRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=reminkYh;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t77sor1960979itb.12.2019.06.11.01.47.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 01:47:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=reminkYh;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VF1kGVddFpIAC2XDRsCvaPTsWd3oiEHLMIFP7bJNfAA=;
        b=reminkYhknpgdw0v9vXBEw95OofOGqApJUgWcHaSh16CgrHXJXS8OtPV36w7Zq70cM
         EmxlFXFUtrBEtCXunBLiYs8kz3hoHrk8fu9usuDrl4n8gSMZIhzmITSjQt7vL7WNLT9M
         zcg0hyYUoXdPC+hessziNzI+NZexuBDumxKk1/MV67daWLoVCe117k1Umb5tsjif7rBu
         0Cqs+UhO1mRfaYY4iANoRoOYkqYLUt5xwIBOI97pT7vweGbyT04VyL0rPXXIV8S6697t
         eaANouGUse1HFf+IpSbgudkBFPxuTYG4PBtcQlvNDFYNBF+Tuj4RY9HsU8dExhxoBOpj
         F/EQ==
X-Google-Smtp-Source: APXvYqwF6zNmNcPE0CVkeRShHOR/TQk7tS5fBa3s4YV+C/yBlnq2caZY5W4qDsUYjoAoh/3qbdw2XofS9YrS5nYofTE=
X-Received: by 2002:a24:4417:: with SMTP id o23mr18107239ita.88.1560242858490;
 Tue, 11 Jun 2019 01:47:38 -0700 (PDT)
MIME-Version: 1.0
References: <1559651172-28989-1-git-send-email-walter-zh.wu@mediatek.com>
 <CACT4Y+Y9_85YB8CCwmKerDWc45Z00hMd6Pc-STEbr0cmYSqnoA@mail.gmail.com>
 <1560151690.20384.3.camel@mtksdccf07> <CACT4Y+aetKEM9UkfSoVf8EaDNTD40mEF0xyaRiuw=DPEaGpTkQ@mail.gmail.com>
 <1560236742.4832.34.camel@mtksdccf07>
In-Reply-To: <1560236742.4832.34.camel@mtksdccf07>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 11 Jun 2019 10:47:27 +0200
Message-ID: <CACT4Y+YNG0OGT+mCEms+=SYWA=9R3MmBzr8e3QsNNdQvHNt9Fg@mail.gmail.com>
Subject: Re: [PATCH v2] kasan: add memory corruption identification for
 software tag-based mode
To: Walter Wu <walter-zh.wu@mediatek.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, 
	Vasily Gorbik <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>, 
	"Jason A. Donenfeld" <Jason@zx2c4.com>, =?UTF-8?B?TWlsZXMgQ2hlbiAo6Zmz5rCR5qi6KQ==?= <Miles.Chen@mediatek.com>, 
	kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	"linux-mediatek@lists.infradead.org" <linux-mediatek@lists.infradead.org>, 
	wsd_upstream <wsd_upstream@mediatek.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 9:05 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
>
> On Mon, 2019-06-10 at 13:46 +0200, Dmitry Vyukov wrote:
> > On Mon, Jun 10, 2019 at 9:28 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> > >
> > > On Fri, 2019-06-07 at 21:18 +0800, Dmitry Vyukov wrote:
> > > > > diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> > > > > index b40ea104dd36..be0667225b58 100644
> > > > > --- a/include/linux/kasan.h
> > > > > +++ b/include/linux/kasan.h
> > > > > @@ -164,7 +164,11 @@ void kasan_cache_shutdown(struct kmem_cache *cache);
> > > > >
> > > > >  #else /* CONFIG_KASAN_GENERIC */
> > > > >
> > > > > +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> > > > > +void kasan_cache_shrink(struct kmem_cache *cache);
> > > > > +#else
> > > >
> > > > Please restructure the code so that we don't duplicate this function
> > > > name 3 times in this header.
> > > >
> > > We have fixed it, Thank you for your reminder.
> > >
> > >
> > > > >  static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
> > > > > +#endif
> > > > >  static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
> > > > >
> > > > >  #endif /* CONFIG_KASAN_GENERIC */
> > > > > diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> > > > > index 9950b660e62d..17a4952c5eee 100644
> > > > > --- a/lib/Kconfig.kasan
> > > > > +++ b/lib/Kconfig.kasan
> > > > > @@ -134,6 +134,15 @@ config KASAN_S390_4_LEVEL_PAGING
> > > > >           to 3TB of RAM with KASan enabled). This options allows to force
> > > > >           4-level paging instead.
> > > > >
> > > > > +config KASAN_SW_TAGS_IDENTIFY
> > > > > +       bool "Enable memory corruption idenitfication"
> > > >
> > > > s/idenitfication/identification/
> > > >
> > > I should replace my glasses.
> > >
> > >
> > > > > +       depends on KASAN_SW_TAGS
> > > > > +       help
> > > > > +         Now tag-based KASAN bug report always shows invalid-access error, This
> > > > > +         options can identify it whether it is use-after-free or out-of-bound.
> > > > > +         This will make it easier for programmers to see the memory corruption
> > > > > +         problem.
> > > >
> > > > This description looks like a change description, i.e. it describes
> > > > the current behavior and how it changes. I think code comments should
> > > > not have such, they should describe the current state of the things.
> > > > It should also mention the trade-off, otherwise it raises reasonable
> > > > questions like "why it's not enabled by default?" and "why do I ever
> > > > want to not enable it?".
> > > > I would do something like:
> > > >
> > > > This option enables best-effort identification of bug type
> > > > (use-after-free or out-of-bounds)
> > > > at the cost of increased memory consumption for object quarantine.
> > > >
> > > I totally agree with your comments. Would you think we should try to add the cost?
> > > It may be that it consumes about 1/128th of available memory at full quarantine usage rate.
> >
> > Hi,
> >
> > I don't understand the question. We should not add costs if not
> > necessary. Or you mean why we should add _docs_ regarding the cost? Or
> > what?
> >
> I mean the description of option. Should it add the description for
> memory costs. I see KASAN_SW_TAGS and KASAN_GENERIC options to show the
> memory costs. So We originally think it is possible to add the
> description, if users want to enable it, maybe they want to know its
> memory costs.
>
> If you think it is not necessary, we will not add it.

Full description of memory costs for normal KASAN mode and
KASAN_SW_TAGS should probably go into
Documentation/dev-tools/kasan.rst rather then into config description
because it may be too lengthy.

I mentioned memory costs for this config because otherwise it's
unclear why would one ever want to _not_ enable this option. If it
would only have positive effects, then it should be enabled all the
time and should not be a config option at all.

