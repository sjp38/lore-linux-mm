Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21F64C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 11:32:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D06C6212F5
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 11:32:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TlTFwFIx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D06C6212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E4466B0005; Tue, 11 Jun 2019 07:32:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BAFD6B0006; Tue, 11 Jun 2019 07:32:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D05E6B0007; Tue, 11 Jun 2019 07:32:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3DDB26B0005
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:32:30 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id c5so9651193iom.18
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 04:32:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=GJ5KMjkPulVIlquMhDg/I0WD4XAnjse8O6WtWcGUz4E=;
        b=Gvtzny60+TGBscvDEiFmxFfyLTkBkW0TZTs0cJmKxVyxIEIlYAveDCa8vFQzH/eL1y
         uvDiwB/zQOcyZtgJaxF0Q7N09rwA4XlzTHQdB914hCoeeEGXgXryZtCwwh6KdB5XIPFM
         r7rEiHDSpClRRNQCaHb3xbA0ORTSy6VXsTcfaVFNXMuTpeR+yFIGJVfSBexf8uu8GuOn
         SHWfLtNSRjO4LDq7yTIV2kH0OfXSdbfO7b+ZND9WKLC1Qjk5jbvyWXaVV7QIYPBOaUPm
         nD7buv1bg80ulS5ccBCCLEbK2eUnzOwNLDRYIHMAI+z2bqaZ61VDTTALOC6ZNPzydKIo
         CgBA==
X-Gm-Message-State: APjAAAUQjiiCWN2BVzFrq23TNin7iyujfFTYDkqRswS4qLMfA2gUAraa
	cqG0dgT6YWaRAzHgVOls1ulzxLoHbsGyTJ27chyUBvFkyuLBniA1pkPIhdB6BNLyrVvoz68FLoP
	BSpPMxKDhTGnZo7xJcugZLA67pwOiymQ9zpZt4dCNAyfnyiDXvwhWJcOcpooVwfNtTw==
X-Received: by 2002:a5d:9d42:: with SMTP id k2mr21272982iok.45.1560252749934;
        Tue, 11 Jun 2019 04:32:29 -0700 (PDT)
X-Received: by 2002:a5d:9d42:: with SMTP id k2mr21272936iok.45.1560252749119;
        Tue, 11 Jun 2019 04:32:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560252749; cv=none;
        d=google.com; s=arc-20160816;
        b=C+QbGyhXuWLkR7wgsX24JZvf6Q8/vuxXAg5BB62yp1bXiP+EopVw/HPva72fUlWViK
         Q0rJoBhxVxYVNNyVOb89xz+Jj1KYF9c/oCkbSLAyNf41UXCf85huBDzs/P4Ed+6xamS5
         K34YecKbOmYC64q9h/jmupEszGhvPWsR8Lof3TcXnqnNazMDpSAM+3RN4Ao2+49PTpWu
         7iDR2Q2MCgyNlyRQ0WY4qZU0NZsti8VdL0ua4dXHgobknstswPHgUVhNZvkakfmVKP/8
         3R8YkuF+BbHdbG4iCuBIqfD57D1/3rnTU+S+pw3j+e24VWOTteLT4KMYbpv6kzkmhLs6
         1HPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=GJ5KMjkPulVIlquMhDg/I0WD4XAnjse8O6WtWcGUz4E=;
        b=JyGT13u7rU1t57I9NwD6NZolMg0ljsRq8+wfDJxH+JY4CtwsN++W1ZaM79mn/0rvb1
         kWnT9TNxQn5e/ncP1KDkcbWBuFNucssR5thnu9Gbjk8kbmrZ0YZ1JonqAkvk0qov9f/y
         HMiAhfanrHhFwnlGjMWaHZeSbFKprHNbT3Trj98cgh1b4xHzQJOGnqjkvKwqImgEk/sq
         GgA79A3H/kFf+euioex9XPlDrx1w6bBmdsrIvk+pgv9c6Z89Ns0HoAxsB3cNYiuxlidx
         kfGidwAmYKjTuGI9RRwSGcjXO6IVW2U1kCmCrEGVcrlCQRwU52/Fw8db9z5T47fjh3PR
         L2cQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TlTFwFIx;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h145sor6552172iof.56.2019.06.11.04.32.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 04:32:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TlTFwFIx;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GJ5KMjkPulVIlquMhDg/I0WD4XAnjse8O6WtWcGUz4E=;
        b=TlTFwFIxz9etSjSBZdcP2L6srMJb56KWUjVFS4qyFG2NEzpl/ugkDxZGDtevEXvCsu
         d+W4D0EjwpeQWLu6YTAqLlOWtV9+PYCjJ+BGYrb4gKrfG/NPB6ccs074WqJLtEQjGVso
         mSFb2VwUteI3d6rFAZ6+Iy65mgseV0VV/vvswhzRN77Hg3pqpHJnF2CXpEwVpu2pyAM1
         TYGTSH57wWYQoNtEH1TJ7m8hjnzm2XA+44SW/ctJefLRikEX++cKcPTNJGOnwBnKd99X
         sSqqMt8kFPa6rel1VGvJojdPG8wvyJ6Eb5oWIyyaz2xdhEyEUuLc4Detd3tySV6jR7EK
         bwKA==
X-Google-Smtp-Source: APXvYqw9dSSfEyizP9qkfJ/fTJ+bPVpxmMW//LjyNaWWY5U1Qi8nthjbX348yzFM8aZPZ+LmzKj04oxrxcPDI3N9JoU=
X-Received: by 2002:a6b:641a:: with SMTP id t26mr3295112iog.3.1560252747608;
 Tue, 11 Jun 2019 04:32:27 -0700 (PDT)
MIME-Version: 1.0
References: <1559651172-28989-1-git-send-email-walter-zh.wu@mediatek.com>
 <CACT4Y+Y9_85YB8CCwmKerDWc45Z00hMd6Pc-STEbr0cmYSqnoA@mail.gmail.com>
 <1560151690.20384.3.camel@mtksdccf07> <CACT4Y+aetKEM9UkfSoVf8EaDNTD40mEF0xyaRiuw=DPEaGpTkQ@mail.gmail.com>
 <1560236742.4832.34.camel@mtksdccf07> <CACT4Y+YNG0OGT+mCEms+=SYWA=9R3MmBzr8e3QsNNdQvHNt9Fg@mail.gmail.com>
 <1560249891.29153.4.camel@mtksdccf07>
In-Reply-To: <1560249891.29153.4.camel@mtksdccf07>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 11 Jun 2019 13:32:16 +0200
Message-ID: <CACT4Y+aXqjCMaJego3yeSG1eR1+vkJkx5GB+xsy5cpGvAtTnDA@mail.gmail.com>
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

On Tue, Jun 11, 2019 at 12:44 PM Walter Wu <walter-zh.wu@mediatek.com> wrote:
>
> On Tue, 2019-06-11 at 10:47 +0200, Dmitry Vyukov wrote:
> > On Tue, Jun 11, 2019 at 9:05 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> > >
> > > On Mon, 2019-06-10 at 13:46 +0200, Dmitry Vyukov wrote:
> > > > On Mon, Jun 10, 2019 at 9:28 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> > > > >
> > > > > On Fri, 2019-06-07 at 21:18 +0800, Dmitry Vyukov wrote:
> > > > > > > diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> > > > > > > index b40ea104dd36..be0667225b58 100644
> > > > > > > --- a/include/linux/kasan.h
> > > > > > > +++ b/include/linux/kasan.h
> > > > > > > @@ -164,7 +164,11 @@ void kasan_cache_shutdown(struct kmem_cache *cache);
> > > > > > >
> > > > > > >  #else /* CONFIG_KASAN_GENERIC */
> > > > > > >
> > > > > > > +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> > > > > > > +void kasan_cache_shrink(struct kmem_cache *cache);
> > > > > > > +#else
> > > > > >
> > > > > > Please restructure the code so that we don't duplicate this function
> > > > > > name 3 times in this header.
> > > > > >
> > > > > We have fixed it, Thank you for your reminder.
> > > > >
> > > > >
> > > > > > >  static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
> > > > > > > +#endif
> > > > > > >  static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
> > > > > > >
> > > > > > >  #endif /* CONFIG_KASAN_GENERIC */
> > > > > > > diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> > > > > > > index 9950b660e62d..17a4952c5eee 100644
> > > > > > > --- a/lib/Kconfig.kasan
> > > > > > > +++ b/lib/Kconfig.kasan
> > > > > > > @@ -134,6 +134,15 @@ config KASAN_S390_4_LEVEL_PAGING
> > > > > > >           to 3TB of RAM with KASan enabled). This options allows to force
> > > > > > >           4-level paging instead.
> > > > > > >
> > > > > > > +config KASAN_SW_TAGS_IDENTIFY
> > > > > > > +       bool "Enable memory corruption idenitfication"
> > > > > >
> > > > > > s/idenitfication/identification/
> > > > > >
> > > > > I should replace my glasses.
> > > > >
> > > > >
> > > > > > > +       depends on KASAN_SW_TAGS
> > > > > > > +       help
> > > > > > > +         Now tag-based KASAN bug report always shows invalid-access error, This
> > > > > > > +         options can identify it whether it is use-after-free or out-of-bound.
> > > > > > > +         This will make it easier for programmers to see the memory corruption
> > > > > > > +         problem.
> > > > > >
> > > > > > This description looks like a change description, i.e. it describes
> > > > > > the current behavior and how it changes. I think code comments should
> > > > > > not have such, they should describe the current state of the things.
> > > > > > It should also mention the trade-off, otherwise it raises reasonable
> > > > > > questions like "why it's not enabled by default?" and "why do I ever
> > > > > > want to not enable it?".
> > > > > > I would do something like:
> > > > > >
> > > > > > This option enables best-effort identification of bug type
> > > > > > (use-after-free or out-of-bounds)
> > > > > > at the cost of increased memory consumption for object quarantine.
> > > > > >
> > > > > I totally agree with your comments. Would you think we should try to add the cost?
> > > > > It may be that it consumes about 1/128th of available memory at full quarantine usage rate.
> > > >
> > > > Hi,
> > > >
> > > > I don't understand the question. We should not add costs if not
> > > > necessary. Or you mean why we should add _docs_ regarding the cost? Or
> > > > what?
> > > >
> > > I mean the description of option. Should it add the description for
> > > memory costs. I see KASAN_SW_TAGS and KASAN_GENERIC options to show the
> > > memory costs. So We originally think it is possible to add the
> > > description, if users want to enable it, maybe they want to know its
> > > memory costs.
> > >
> > > If you think it is not necessary, we will not add it.
> >
> > Full description of memory costs for normal KASAN mode and
> > KASAN_SW_TAGS should probably go into
> > Documentation/dev-tools/kasan.rst rather then into config description
> > because it may be too lengthy.
> >
> Thanks your reminder.
>
> > I mentioned memory costs for this config because otherwise it's
> > unclear why would one ever want to _not_ enable this option. If it
> > would only have positive effects, then it should be enabled all the
> > time and should not be a config option at all.
>
> Sorry, I don't get your full meaning.
> You think not to add the memory costs into the description of config ?
> or need to add it? or make it not be a config option(default enabled)?

Yes, I think we need to include mention of additional cost into _this_
new config.

