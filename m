Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3889C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:58:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D3492147C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:58:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D3492147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 390EC8E0004; Wed, 13 Mar 2019 10:58:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EF558E0001; Wed, 13 Mar 2019 10:58:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 191D88E0004; Wed, 13 Mar 2019 10:58:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id E6D4B8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 10:58:01 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g17so2071811qte.17
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 07:58:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=FQNhrABgTfNbI3LjNPG9bpOQrem4pejdVK1i3DBdroE=;
        b=qGbuDQ17JkiQvvTbac9t00lb7X2d7hlxcpYpx57DKkJTmoBPtquHj0Pv/CE+jpP14H
         Y6/pwCnkl0HnW3Hlf3Wb9KUm+oDWg+dEPxQGLwzifiSENTgjydtxEr7nSWQyh9VDTKiP
         iaGXFr6O2tSUrYtjkM7r3jViTRk95AfmLnHN74etd7OU8Cz+akufMegNN5HJQOZlZiO3
         N3vAguTZX6qi41gCYWobSMULGgJZk6J3zst4ignXaRBs794R6cThd8Cr84qt/+qcvyK4
         c0V++pxBGx+1xhNdidjNVjIvbaBPFeQ4SVHddwLFb0TUuRsrl8CazEpvYIH4n2kTYa5C
         rAEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAUGIBss6bTIg2H0YNhTRbwz9R/7eq1uSCMhA7QZMT9fhd+Vanjm
	TJ6ZWxRw3/Ra7LQxeQmkivX6lAd6wnLubRkyqXdYgUEclqTp/EB64Ki73QbmlTF6wpMUqi3+EWO
	o7k469/87xap/44uMVaswgfxfaOODZVQq7JFsX/7b2s4bSf5EYlsthV6jKuG6OmANx62IGgUPgd
	HnUnF+fMmZqGTHj/PJ8qxzHobXh35RF4NiIcH7d2Qy9Mzp+5mnTJHypk/SzLbX1My+yHNmmsK8/
	gjuDc/jvZOXzjajtMAhaOesKp4Dg5rK8XGNTdyAfYnFc8mIjn3+t7Zr9mvAWcxXpGiCPP1vLYFY
	KbOwXEFRHGC7XcsnN0WQRd0sm7Ocls8nU60Clwk0GunJmM4fdFCHplhOxmxwFsi6WycG9wkNIQ=
	=
X-Received: by 2002:a0c:80c4:: with SMTP id 62mr7184243qvb.140.1552489081769;
        Wed, 13 Mar 2019 07:58:01 -0700 (PDT)
X-Received: by 2002:a0c:80c4:: with SMTP id 62mr7184202qvb.140.1552489081128;
        Wed, 13 Mar 2019 07:58:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552489081; cv=none;
        d=google.com; s=arc-20160816;
        b=0BtinLfj26FNBfDcpv0vW6ExyoT+Y0y32l5yyWbnBghKnTs7HsHdastUgJe1DFdQPg
         t6ArTqwyG08YU7A/8t7esTVwqvw472AD5e/IF0xv/6QsNma6LPEaHIkB3ggaVOE0rewi
         jwj1lUAXlctpZLRkU2F5KDI04f2NGAFzfKxcqrwIBu6VPPs/37YZg2zaxkTQ2CKXuHz7
         C/v4xAs0G1UcWK5iFTbDj0+5tq/EbcJGkM+NYHFuv+fl31aQOwuqn1o9PZGB9x2lKVcv
         p6aTWCDxjOIkZ73pD+URHkE3nSHjimLtniH3GI8c7j+PGrKTn8zVTLlw0tQCTKIdXnF/
         Qrpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=FQNhrABgTfNbI3LjNPG9bpOQrem4pejdVK1i3DBdroE=;
        b=C9t3nyRgyG+diCXs0yK1iM665RTeKlWHVwt2Fc5Ibhcul42fc/rU1Pt0aod6unr9vc
         k0FbDGzbi5jr/bv+dRYo3GbcB2Nd8moiLqXR+cAzpEbo+YdrhNsT7rtcnRJpZBx5dN6v
         zUn993h7jrl8aUCmLKcD//ZuLf3vKLHY4DsgaYwSojaiUSpXQ0iea8fE4uoS1peE4wSK
         ww0ijrLldKsm6dRJTMpSmfGci1nWxCbhmM5LsneO0kk0/n8f048fYUkmwFDF4cZJa5h1
         2gAU4l3CMAlzmFWZQQqbnaRxYjy8BDh7/FFewHQuFMVn6vSqA29Z6zPZ7T4uPklmOSHd
         A/Zg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j50sor14617497qtk.15.2019.03.13.07.58.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 07:58:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqxAwi30bfPTT3u25hrNOi9+bcXAk5HJ1yq3tsV9ZE74+fJ6CPVYNafDodO0LougzCN+mHiKI0mjqaB91VUJc9g=
X-Received: by 2002:ac8:237b:: with SMTP id b56mr34620996qtb.343.1552489080454;
 Wed, 13 Mar 2019 07:58:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190310183051.87303-1-cai@lca.pw> <20190311035815.kq7ftc6vphy6vwen@linux-r8p5>
 <20190311122100.GF22862@mellanox.com> <1552312822.7087.11.camel@lca.pw>
 <CAK8P3a0QB7+oPz4sfbW_g2EGZZmC=LMEnkMNLCW_FD=fEZoQPA@mail.gmail.com>
 <20190313091844.GA24390@hirez.programming.kicks-ass.net> <20190313143552.GA39315@lakrids.cambridge.arm.com>
In-Reply-To: <20190313143552.GA39315@lakrids.cambridge.arm.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 13 Mar 2019 15:57:42 +0100
Message-ID: <CAK8P3a3V+1sQJfTAipYyOeV5b379eYZXasRFjWnf9oKPtCTviQ@mail.gmail.com>
Subject: Re: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
To: Mark Rutland <mark.rutland@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>, Jason Gunthorpe <jgg@mellanox.com>, 
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 3:36 PM Mark Rutland <mark.rutland@arm.com> wrote:
> On Wed, Mar 13, 2019 at 10:18:44AM +0100, Peter Zijlstra wrote:
> > On Mon, Mar 11, 2019 at 03:20:04PM +0100, Arnd Bergmann wrote:
> > > On Mon, Mar 11, 2019 at 3:00 PM Qian Cai <cai@lca.pw> wrote:
>
> I think that using s64 consistently (with any necessary alignment
> annotation) makes the most sense. That's unambigious, and what the
> common headers now use.
>
> Now that the scripted atomics are merged, I'd like to move arches over
> to arch_atomic_*(), so the argument and return types will become s64
> everywhere.

Yes, that sounds like the easiest way, especially if we don't touch the
internal implementation but simply rename all the symbols provided
by the architectures. Is that what you had in mind, or would you go
beyond the minimum changes here?

        Arnd

