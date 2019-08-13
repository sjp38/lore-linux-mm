Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC460C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 06:33:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EE5F2064A
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 06:33:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Qpq6Ugps"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EE5F2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE8B56B0005; Tue, 13 Aug 2019 02:33:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9AC66B0006; Tue, 13 Aug 2019 02:33:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A87326B0007; Tue, 13 Aug 2019 02:33:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0044.hostedemail.com [216.40.44.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8628B6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 02:33:32 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 2F63A181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 06:33:32 +0000 (UTC)
X-FDA: 75816438264.13.robin94_1b292d971523
X-HE-Tag: robin94_1b292d971523
X-Filterd-Recvd-Size: 6190
Received: from mail-wr1-f68.google.com (mail-wr1-f68.google.com [209.85.221.68])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 06:33:31 +0000 (UTC)
Received: by mail-wr1-f68.google.com with SMTP id y8so714561wrn.10
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 23:33:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=VVsvYDt3mj7dX8a/EvxPE6boAbpFyIkBqrJQ4zdNVaA=;
        b=Qpq6UgpsrPMILFrB7OogQaed26Tyko1oH5aM/k/WQwrN4xU87944N9gfRqIzqnrBlM
         +IwDifP0w59clC3YVHCaMl4uj1A+xVRSaLrJLeAWy2sqxz4zaRc7exIbIfS9S9suPPKK
         BpdK2fRBEbj122H+WjiX2qJQSV/jd0W8uwRezWFZcbTzakdnUb9/6CCIu5yNavDNEdrd
         5XNivdHia8Xxx4XB9PW/wlaSHjILtniCVGAEKBs/vR51Ty7Xn2/pocc1VdvTstc1wqI2
         Mm1lpK+mzvvF0FYQStRCSCDOjVFlEDFNYQIUiV2+LtvhhV8sFIymWnWRqtLAZK9aEvka
         bwGw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=VVsvYDt3mj7dX8a/EvxPE6boAbpFyIkBqrJQ4zdNVaA=;
        b=uKkfFgNMMUd3xsREKC5vM9hXewyWPueZxx1PK1wMCc2XWdZo5nW0wklvjJGC1I0xmD
         s+AywtaYLiKV2WUhYnwHMoFWda0YohgITNGPD8/adIgVaFrUWiT21Jilczx3d+x6ENIs
         llpVPqEghF7beqwMSRP9bq2iF1wHi8x9GBGzLr+nDN9cVLFNTXFgFzejq90wAnvTvEIj
         4AqvFu1k77GWSWM8sLEWeufjuDO6beBkDGZgc7aK/TEncOBKCXJlZ8Lx+Vy5zbHLRkDs
         XqoObCNcN91vlo5ix+CFD89kj2FrA1S0k0hLicjyDYnSaSM+n9KXuKv/tHPLfokyoA/1
         M0Eg==
X-Gm-Message-State: APjAAAW9w7u8mgjDqw8jYWC15D8bPNwNEQc61GUZn3H9ZYLpSeEyQhL4
	wUOHDvNuf7IMnVxvoDbFX88=
X-Google-Smtp-Source: APXvYqx8/SpN3VgGScky2D1iGHdg8pdgBDLR9N0zn3NNrmogHHx3ucRE7UqzaK6Yl3Jhj1q7r5OHeQ==
X-Received: by 2002:adf:f18c:: with SMTP id h12mr17703846wro.47.1565678010135;
        Mon, 12 Aug 2019 23:33:30 -0700 (PDT)
Received: from archlinux-threadripper ([2a01:4f8:222:2f1b::2])
        by smtp.gmail.com with ESMTPSA id o20sm269315559wrh.8.2019.08.12.23.33.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 12 Aug 2019 23:33:29 -0700 (PDT)
Date: Mon, 12 Aug 2019 23:33:27 -0700
From: Nathan Chancellor <natechancellor@gmail.com>
To: Nick Desaulniers <ndesaulniers@google.com>
Cc: Joe Perches <joe@perches.com>, Nathan Huckleberry <nhuck@google.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Michal Marek <michal.lkml@markovi.net>,
	Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	clang-built-linux <clang-built-linux@googlegroups.com>,
	"Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: Re: [PATCH v2] kbuild: Change fallthrough comments to attributes
Message-ID: <20190813063327.GA46858@archlinux-threadripper>
References: <20190812214711.83710-1-nhuck@google.com>
 <20190812221416.139678-1-nhuck@google.com>
 <814c1b19141022946d3e0f7e24d69658d7a512e4.camel@perches.com>
 <CAKwvOdnpXqoQDmHVRCh0qX=Yh-8UpEWJ0C3S=syn1KN8rB3OGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKwvOdnpXqoQDmHVRCh0qX=Yh-8UpEWJ0C3S=syn1KN8rB3OGQ@mail.gmail.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 04:11:26PM -0700, Nick Desaulniers wrote:
> Correct, Nathan is currently implementing support for attribute
> fallthrough in Clang in:
> https://reviews.llvm.org/D64838
> 
> I asked him in person to evaluate how many warnings we'd see in an
> arm64 defconfig with his patch applied.  There were on the order of
> 50k warnings, mostly from these headers.  I asked him to send these
> patches, then land support in the compiler, that way should our CI
> catch fire overnight, we can carry out of tree fixes until they land.
> With the changes here to Makefile.extrawarn, we should not need to
> carry any out of tree patches.

I think that if we are modifying this callsite to be favorable to clang,
we should consider a straight revert of commit bfd77145f35c ("Makefile:
Convert -Wimplicit-fallthrough=3 to just -Wimplicit-fallthrough for
clang"). It would save us a change in scripts/Makefile.extrawarn and
tying testing of this warning to W=1 will make the build noisy from
all of the other warnings that we don't care about plus we will need to
revert that change once we have finished the conversion process anyways.
I think it is cleaner to just pass KCFLAGS=-Wimplicit-fallthrough to
make when testing so that just that additional warning appears but
that is obviously subjective.

> > You might consider trying out the scripted conversion tool
> > attached to this email:
> >
> > https://lore.kernel.org/lkml/61ddbb86d5e68a15e24ccb06d9b399bbf5ce2da7.camel@perches.com/

I gave the script a go earlier today and it does a reasonable job at
convering the comments to the fallthrough keyword. Here is a list of
the warnings I still see in an x86 allyesconfig build with D64838 on
next-20190812:

https://gist.github.com/ffbd71b48ba197837e1bdd9bb863b85f

I have gone through about 20-30 of them and while there are a few missed
conversion spots (which is obviously fine for a treewide conversion),
the majority of them come from a disagreement between GCC and Clang on
emitting a warning when falling through to a case statement that is
either the last one and empty or simply breaks..

Example: https://godbolt.org/z/xgkvIh

I have more information on our issue tracker if anyone else wants to
take a look: https://github.com/ClangBuiltLinux/linux/issues/636

I personally think that GCC is right and Clang should adapt but I don't
know enough about the Clang codebase to know how feasible this is. I
just know there will be even more churn than necessary if we have to
annotate all of those places, taking the conversion process from maybe a
release cycle to several.

Cheers,
Nathan

