Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97B5FC4646D
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 15:35:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B5352080A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 15:35:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sLMq+bA6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B5352080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9129D6B000D; Tue, 11 Jun 2019 11:35:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89C286B0269; Tue, 11 Jun 2019 11:35:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73DB66B026C; Tue, 11 Jun 2019 11:35:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B47D6B000D
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 11:35:45 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id r7so7964446plo.6
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:35:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8h42m3mke7DA8ejB89qFnTkC5cX+aLshhHC5jTwYOa4=;
        b=Qx0UoClTcJaT77ZTrY7Pwfpav9r4wjACKj3pKwanFKnQPFcMFygLPk6KGyeqj6gK4T
         ehaun0uBd4tb6YLzrWYwPyC2+HdVVM293VBxd8eJq79qULfjAux3CHIqp865rINGbtbO
         rImU5XBP8xGRx25XJQJNIUJqgEgihQyAkFNeB+5ujKUSa1PFZl+MMdJNZJScpfBr4khk
         Shzak1Dt6gBE2Mz/ZntNFG7BcTZA1MafBQSKcNk0gREkUCw0JCyR0TJL+5ZIMEJQIv3k
         w49GxuYrXa9+ZemVI7i0PjWnNm8yEj2aPauHCitg3CI+W1kHVonDHhM1ZI7gM1IHBlSq
         3cRw==
X-Gm-Message-State: APjAAAXsKbjop1i4zUHBtVQcODCcuRt9T6I/BmNvHbAJc9bnJ190mM8d
	GEDbvtiVAmeX+yFVcenJKKHfSFVLTnX3rS9O4xdJa0QIXlfAkWMo0AY4gyMU1431THCrefz/7ke
	FI/ybiLjrrByQxWFNX7/l6/ijd8qT+I2/Akcgh/rqQIJpknZO5ehkCfEO2ufthH+AUw==
X-Received: by 2002:a17:902:467:: with SMTP id 94mr20918021ple.131.1560267344661;
        Tue, 11 Jun 2019 08:35:44 -0700 (PDT)
X-Received: by 2002:a17:902:467:: with SMTP id 94mr20917937ple.131.1560267343518;
        Tue, 11 Jun 2019 08:35:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560267343; cv=none;
        d=google.com; s=arc-20160816;
        b=t+hq7Ay4SjAB3L0h4tJtuaGRGVi0xrkzhhQZ5NwtpPzJOFTzhq+76FXrD5tSzKcYEB
         oiFQQdiPCGpyl0H2/6zd9VzosydadJmTvXmnbhDGv+R2OPVgqALNvt4vP5Z2SbMgqHCF
         5cbBTkTR5e8MINjt38jqDFaqLDq8rknnJQoWgzRj1Uo4E/rVM0mZK8NJhEqZVgxbBIGi
         XwLX05WtPYxOBiAw3IqM+IUa2ErUs1u+uw/Gzl/l18BcIEFix4ukocTmLdtR+/uI065j
         s6Ug7HjqQ744qDmJT2jnTeX8THKieXiG1dMXR5qHNz6nCx7gt5RSfIO1IIrNIluDWo/6
         uPzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8h42m3mke7DA8ejB89qFnTkC5cX+aLshhHC5jTwYOa4=;
        b=RHZXcbjNBDV6KHztOgCAgKxRPpz9NH32bQx6gs9x+VzHi7nhuO7fx1dp+Va1QzqgkT
         JqrdaKK9yl+DbmD78n+Szc6Vp36Xl/Ckq9pRHxU9caA+onnze7AVoOlWDITmuAAt5v1/
         QjrI4igdLCFqacYsgP1Y9iGDwrB+40hKylt5k5RpRb/t5v1BZ8zdMZ9ge9cLiEp7JDeu
         Fvlu2tXnphiPKxy7AX/a4LRoA+aqqiEHm7GQRclOOmHISf1M17Z+27SDsrqn3f19kMyo
         DKH2Uu/8HdpGA4ciE1zejrv6kOffs76KFv3v1F8nGGsjJE/8V7R17QO52h6AxZFzn0rn
         y7Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sLMq+bA6;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1sor11937723pgq.52.2019.06.11.08.35.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 08:35:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sLMq+bA6;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8h42m3mke7DA8ejB89qFnTkC5cX+aLshhHC5jTwYOa4=;
        b=sLMq+bA6sOUYAuoQSdZze7aS/o01HRJh37fgBzOaTlULVRlgN1Pzky0WnEt9ggPhRi
         JH1qa8PI3fUsxopnA8vxXjk80emL0gwgHoi/kN+wCfZhW7CtGG3mN+/yxVY59EUBa1rS
         M4cxQ83xr93VSRZJzwzbUXprtAi+dT3meCk3L8KOZ/xZDFb/kZqFJzv63133Zz0lw9er
         v1LYil8+krDw44YMHLuvpYAB34RsEpHwQbuoHBJWYMzgMu6DfV6usjm0aFv9/2YjnuNW
         tz3JzLRCLMzdWSO9grr5tL4TPlHUr6KXqW3Th206n5IMIeoSFDjvZhgTeHCUKYHlgpUu
         bTiw==
X-Google-Smtp-Source: APXvYqwVttVVtet3fqIi0VnES8Ilb/p6V60nSXc7x8WFpoZ7Ynv9ahn+wWxWGukqfJnR2JBKBovfx92r2kGjPnyP20Q=
X-Received: by 2002:a63:1919:: with SMTP id z25mr21205093pgl.440.1560267342622;
 Tue, 11 Jun 2019 08:35:42 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <045a94326401693e015bf80c444a4d946a5c68ed.1559580831.git.andreyknvl@google.com>
 <20190610142824.GB10165@c02tf0j2hf1t.cambridge.arm.com>
In-Reply-To: <20190610142824.GB10165@c02tf0j2hf1t.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 11 Jun 2019 17:35:31 +0200
Message-ID: <CAAeHK+zBDB6i+iEw+TJY14gZeccvWeOBEaU+otn1F+jzDLaRpA@mail.gmail.com>
Subject: Re: [PATCH v16 05/16] arm64: untag user pointers passed to memory syscalls
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
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

On Mon, Jun 10, 2019 at 4:28 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Mon, Jun 03, 2019 at 06:55:07PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > This patch allows tagged pointers to be passed to the following memory
> > syscalls: get_mempolicy, madvise, mbind, mincore, mlock, mlock2, mprotect,
> > mremap, msync, munlock.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>
> I would add in the commit log (and possibly in the code with a comment)
> that mremap() and mmap() do not currently accept tagged hint addresses.
> Architectures may interpret the hint tag as a background colour for the
> corresponding vma. With this:

I'll change the commit log. Where do you you think I should put this
comment? Before mmap and mremap definitions in mm/?

Thanks!

>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
>
> --
> Catalin

