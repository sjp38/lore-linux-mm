Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BFEDC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 23:11:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF18021721
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 23:11:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vTrR1jRT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF18021721
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A13E6B0003; Mon, 12 Aug 2019 19:11:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 850D56B0005; Mon, 12 Aug 2019 19:11:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 766146B0006; Mon, 12 Aug 2019 19:11:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0043.hostedemail.com [216.40.44.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5177C6B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 19:11:40 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E97728248AA2
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 23:11:39 +0000 (UTC)
X-FDA: 75815324718.28.glove60_48aa4effd6d2b
X-HE-Tag: glove60_48aa4effd6d2b
X-Filterd-Recvd-Size: 6326
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 23:11:39 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id c81so1456767pfc.11
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:11:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Her0OYFs2zX3q5iZN56afRNSN+fnKJ3NNrx8jJX8o8k=;
        b=vTrR1jRTgL4iRmAZ5fdobfuvth2/y2plNQkF0DzSCYwhlvvdjHuepm8xF+TFmUwYar
         EmuOSOPo44nU4I0F9hv5lbc9SZ9aOQlmbirCC4tApOfimxf+iDHl0fkW74gwmu7xpDGu
         UBpuj9Vl6+ebOYa4MZZ+Alu/34qNOmGyZbVH56rLd3246C9JGdSF+mH4fGTEingXgt6Q
         tl2SKpLTr3kBgYcxUWca8zANYFfFPD68TXaHao/KESX2HTYzLFPN7HR0ccFNZKu9L008
         W4I7E7DbZFW+cJcbjLkMLOE8MTlFM3DZj7gonoRZUO6ZiJfSDu1QnbiHQA2Py09u7gd6
         EX7g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Her0OYFs2zX3q5iZN56afRNSN+fnKJ3NNrx8jJX8o8k=;
        b=Vbo2z81boFk60hkWiYu+2t8lamqzls2e5fahJMm2qDq5tYtB19ei0fe/LeTP9vi/uO
         l+ZZh4vt1EMlfT27+P66m5KmdcEI7omt3YYOJQNHlhDrZ+RCPlPEyfphMEctP+5qug94
         BHVt1Fn6JQN/BDJwgYtX26bu5OLPvJyjV3dOLLp9wgtmqxLmvekw+vk8G80RB0rzGa5C
         NVvKWsa/slK2OWDYGggOifBfXTD9U7ss9an5Q34gOP4Ta5d9qLpFkjb3GZRaQ9cf32Qf
         uMbFKre35AH5HQu7yZQee2Uq2MrthR28CmtS4cAvbORHC10AuKCYopFJVyGO/J6OBn0k
         ISBg==
X-Gm-Message-State: APjAAAVDDDTbPtjFu6GcSBMEk9Xfs16OvgHKKEmVKcKhDgNWMEQZR/75
	YI6p1UwcWHAOfJtdLXHoVoC4y2OHahKuzV7NcDdYSw==
X-Google-Smtp-Source: APXvYqwca6tZ65ZmZZkZUZTAK/puSDKQ1Znn+us2FkoPx+5t5hHQ8l+KdKMU434nDW1cC4UrHfPz8BKtXr2Ign1LyYA=
X-Received: by 2002:a63:f94c:: with SMTP id q12mr31673758pgk.10.1565651497838;
 Mon, 12 Aug 2019 16:11:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190812214711.83710-1-nhuck@google.com> <20190812221416.139678-1-nhuck@google.com>
 <814c1b19141022946d3e0f7e24d69658d7a512e4.camel@perches.com>
In-Reply-To: <814c1b19141022946d3e0f7e24d69658d7a512e4.camel@perches.com>
From: Nick Desaulniers <ndesaulniers@google.com>
Date: Mon, 12 Aug 2019 16:11:26 -0700
Message-ID: <CAKwvOdnpXqoQDmHVRCh0qX=Yh-8UpEWJ0C3S=syn1KN8rB3OGQ@mail.gmail.com>
Subject: Re: [PATCH v2] kbuild: Change fallthrough comments to attributes
To: Joe Perches <joe@perches.com>
Cc: Nathan Huckleberry <nhuck@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, 
	Michal Marek <michal.lkml@markovi.net>, Nathan Chancellor <natechancellor@gmail.com>, 
	Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, clang-built-linux <clang-built-linux@googlegroups.com>, 
	"Gustavo A. R. Silva" <gustavo@embeddedor.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 3:40 PM Joe Perches <joe@perches.com> wrote:
>
> On Mon, 2019-08-12 at 15:14 -0700, Nathan Huckleberry wrote:
> > Clang does not support the use of comments to label
> > intentional fallthrough. This patch replaces some uses
> > of comments to attributesto cut down a significant number
> > of warnings on clang (from ~50000 to ~200). Only comments
> > in commonly used header files have been replaced.
> >
> > Since there is still quite a bit of noise, this
> > patch moves -Wimplicit-fallthrough to
> > Makefile.extrawarn if you are compiling with
> > clang.
>
> Unmodified clang does not emit this warning without a patch.

Correct, Nathan is currently implementing support for attribute
fallthrough in Clang in:
https://reviews.llvm.org/D64838

I asked him in person to evaluate how many warnings we'd see in an
arm64 defconfig with his patch applied.  There were on the order of
50k warnings, mostly from these headers.  I asked him to send these
patches, then land support in the compiler, that way should our CI
catch fire overnight, we can carry out of tree fixes until they land.
With the changes here to Makefile.extrawarn, we should not need to
carry any out of tree patches.

>
> > diff --git a/Makefile b/Makefile
> []
> > @@ -846,7 +846,11 @@ NOSTDINC_FLAGS += -nostdinc -isystem $(shell $(CC) -print-file-name=include)
> >  KBUILD_CFLAGS += -Wdeclaration-after-statement
> >
> >  # Warn about unmarked fall-throughs in switch statement.
> > +# If the compiler is clang, this warning is only enabled if W=1 in
> > +# Makefile.extrawarn
> > +ifndef CONFIG_CC_IS_CLANG
> >  KBUILD_CFLAGS += $(call cc-option,-Wimplicit-fallthrough,)
> > +endif
>
> It'd be better to remove CONFIG_CC_IS_CLANG everywhere
> eventually as it adds complexity and makes .config files
> not portable to multiple systems.
>
> > diff --git a/include/linux/compiler_attributes.h b/include/linux/compiler_attributes.h
> []
> > @@ -253,4 +253,8 @@
> >   */
> >  #define __weak                          __attribute__((__weak__))
> >
> > +#if __has_attribute(fallthrough)
> > +#define __fallthrough                   __attribute__((fallthrough))
>
> This should be __attribute__((__fallthrough__))

Agreed.  I think the GCC documentation on attributes had a point about
why the __ prefix/suffix was important, which is why we went with that
in Miguel's original patchset.

>
> And there is still no agreement about whether this should
> be #define fallthrough or #define __fallthrough
>
> https://lore.kernel.org/patchwork/patch/1108577/
>
> > diff --git a/include/linux/jhash.h b/include/linux/jhash.h
> []
> > @@ -86,19 +86,43 @@ static inline u32 jhash(const void *key, u32 length, u32 initval)
> []
> > +     case 12:
> > +             c += (u32)k[11]<<24;
> > +             __fallthrough;
>
> You might consider trying out the scripted conversion tool
> attached to this email:
>
> https://lore.kernel.org/lkml/61ddbb86d5e68a15e24ccb06d9b399bbf5ce2da7.camel@perches.com/

I guess the thing I'm curious about is why /* fall through */ is being
used vs __attribute__((__fallthrough__))?  Surely there's some
discussion someone can point me to?
-- 
Thanks,
~Nick Desaulniers

