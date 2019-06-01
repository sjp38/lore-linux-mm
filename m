Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DCEAC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 16:29:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B059A27757
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 16:29:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="Fa5BzECD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B059A27757
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A0556B0007; Sat,  1 Jun 2019 12:29:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 550516B0008; Sat,  1 Jun 2019 12:29:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A3DF6B000A; Sat,  1 Jun 2019 12:29:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id C77CB6B0007
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 12:29:15 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id v188so185862lfa.20
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 09:29:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WbBlTtzN8zF5Iqk8bw1nVflVKcbi7cIeUDGHN5Yot1E=;
        b=CSWjXrSn7DlIaEvoJCDi2UW4Idp0KaIPygfNQyrPJEvzVbX7D7lV+0GLbmx0on/hB+
         VyJtZQThdZ2eusyZlZvllTswJx6QSmsuXDn65M436saf1qP1Kastzmoh7ZcUjZiIqesd
         xZ5/7cjDxcWp7NswiZqCkC1M3rlVOVodoItEe5AQ2cDSwY50mZutOsN3Nkdh2nAtpPl5
         EnNbT6+h2JUafmw/DZsSQMNrZHTNcowYGPxRPLG/JUArYWeEz9ejU76DCAHn8SIL5W7a
         sG7zkZf35PqiYdm+5QBb28BMy02CxOL+m75dVo0AzLopycwAWhTHFLH9O/Xkjm3ZbUw8
         Z/0g==
X-Gm-Message-State: APjAAAVMVEP/icsclcQKrlnoTTzVxDhOavuAjYVERKg5w8vQg6WxMX4O
	tM3tN94Zynj5GIRRBTKI4U+sRWCqDqDXdgQuVvQ4t+HS6eV88TGpFjIr6bNhtjQRXsTXoxPHa6L
	aBOfSF1kyo2fOF5b7bNitaRg+QV/AzQXoQWplv/rxu9CgcGIgVXLTeP1Y1MVvtUFMZQ==
X-Received: by 2002:ac2:50cd:: with SMTP id h13mr7227419lfm.36.1559406555287;
        Sat, 01 Jun 2019 09:29:15 -0700 (PDT)
X-Received: by 2002:ac2:50cd:: with SMTP id h13mr7227396lfm.36.1559406554299;
        Sat, 01 Jun 2019 09:29:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559406554; cv=none;
        d=google.com; s=arc-20160816;
        b=c+Yph6wm5YJzbQna7pKMTEI47EtypyjcSVpdiYcdkU/NgrEpkwdhUhDdUpwmyBF5Ix
         RFJmMKXvp8IPnqgXHwLBCUkiK5AbpmmW+rbJXi/9pDFSyKx/Z6ig9pBX5bTOQ/IYZhZE
         FCuVemKjWfAeaxOY00RiVo+05bMX62CcV6iFqrtqCOTpZLuUTtDEHf3ZF+NcpLlLh9Fj
         c1FHPr/FydmzO1aBa3c+StIlH8tfB+AOGN9le0LNfXjjATg0ww8WXdm3cqwvJPVzOKcg
         VevozIPaycxZj6qoe2lq6iU7DgaIUojIwloFbIfDOhmln23UqCwuzZWNKCNp8SRdRcew
         cHWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WbBlTtzN8zF5Iqk8bw1nVflVKcbi7cIeUDGHN5Yot1E=;
        b=EXpRh1pIp5RmnqmeP/Z7Up8Y6qMm1KVIN+KNpd5gGwkrZgRqY+SvnTcHj6YIt+WIwl
         1krfLGKVYws0nvJIuUhR6QwoYzz0NKBClXAaHt545S4/DsRM4BRwpPTi2ICrH+ozNixd
         sdxRB5NKeAy3Fgqe585vGFUqfH4EAdmL8CrdwchUEsPMJ1B1N4hm7SsJ2uxePfHFkL+N
         H8Gcg3EGw4XUtlbXICtgnqurM4RHXsltMtEXP1kV5QUXikcuRWW1YlkhcMp1FQk5gJUS
         adNtpXqt6KjFlNpdO8egl/HGXa0f8BKuQy5jq6+OpKg7z2jFJYKtl8p6z+eLnw9HUTSX
         j5QA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=Fa5BzECD;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1sor858345lfm.25.2019.06.01.09.29.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 01 Jun 2019 09:29:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=Fa5BzECD;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WbBlTtzN8zF5Iqk8bw1nVflVKcbi7cIeUDGHN5Yot1E=;
        b=Fa5BzECDkVJJVil3Feep0HbYjDwApJFYj92zZCD6f4aYCxc2Als39M3w9fuXET3xGS
         3dJFRH9YhqCQxcCzt7i+R2DDortv76Hw0c0yls+ilBPK12ky3bwefHhCdXxs096uQvMr
         JNZz4F8UnUXJp5G999kMQlHK92/csNz/XzzF4=
X-Google-Smtp-Source: APXvYqxJKjY2KzE+ZUYSjdYNinkHD+jNwTA/49k5oMj4RcNzUxaj50Dm6Z/imVs566ikE3Pnqp/bxw==
X-Received: by 2002:a19:c301:: with SMTP id t1mr9356422lff.137.1559406553472;
        Sat, 01 Jun 2019 09:29:13 -0700 (PDT)
Received: from mail-lj1-f173.google.com (mail-lj1-f173.google.com. [209.85.208.173])
        by smtp.gmail.com with ESMTPSA id f10sm1897451ljk.95.2019.06.01.09.29.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 09:29:10 -0700 (PDT)
Received: by mail-lj1-f173.google.com with SMTP id a10so9223348ljf.6
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 09:29:10 -0700 (PDT)
X-Received: by 2002:a2e:9ad1:: with SMTP id p17mr9481496ljj.147.1559406549964;
 Sat, 01 Jun 2019 09:29:09 -0700 (PDT)
MIME-Version: 1.0
References: <20190601074959.14036-1-hch@lst.de> <20190601074959.14036-9-hch@lst.de>
In-Reply-To: <20190601074959.14036-9-hch@lst.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 1 Jun 2019 09:28:54 -0700
X-Gmail-Original-Message-ID: <CAHk-=wj9w5NxTcJsqpvYUiL3OBOH-J3=4-vXcc3GaG_U8H-gJw@mail.gmail.com>
Message-ID: <CAHk-=wj9w5NxTcJsqpvYUiL3OBOH-J3=4-vXcc3GaG_U8H-gJw@mail.gmail.com>
Subject: Re: [PATCH 08/16] sparc64: add the missing pgd_page definition
To: Christoph Hellwig <hch@lst.de>
Cc: Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, 
	"David S. Miller" <davem@davemloft.net>, Nicholas Piggin <npiggin@gmail.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org, 
	Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, 
	linuxppc-dev@lists.ozlabs.org, Linux-MM <linux-mm@kvack.org>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Both sparc64 and sh had this pattern, but now that I look at it more
closely, I think your version is wrong, or at least nonoptimal.

On Sat, Jun 1, 2019 at 12:50 AM Christoph Hellwig <hch@lst.de> wrote:
>
> +#define pgd_page(pgd)                  virt_to_page(__va(pgd_val(pgd)))

Going through the virtual address is potentially very inefficient, and
might in some cases just be wrong (ie it's definitely wrong for
HIGHMEM style setups).

It would likely be much better to go through the physical address and
use "pfn_to_page()". I realize that we don't have a "pgd to physical",
but neither do we really have a "pgd to virtual", and your
"__va(pgd_val(x))" thing is not at allguaranteed to work. You're
basically assuming that "pgd_val(x)" is the physical address, which is
likely not entirely incorrect, but it should be checked by the
architecture people.

The pgd value could easily have high bits with meaning, which would
also potentially screw up the __va(x) model.

So I thgink this would be better done with

     #define pgd_page(pgd)    pfn_to_page(pgd_pfn(pgd))

where that "pgd_pfn()" would need to be a new (but likely very
trivial) function. That's what we do for pte_pfn().

IOW, it would likely end up something like

  #define pgd_to_pfn(pgd) (pgd_val(x) >> PFN_PGD_SHIFT)

David?

                  Linus

