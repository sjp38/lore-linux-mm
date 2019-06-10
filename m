Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 524EEC43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 18:53:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0DCC20862
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 18:53:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0DCC20862
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B0ED6B026A; Mon, 10 Jun 2019 14:53:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5614E6B026B; Mon, 10 Jun 2019 14:53:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42A536B026C; Mon, 10 Jun 2019 14:53:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EABE36B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 14:53:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so11698476edv.16
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 11:53:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=f7QJNPySFGeY+lFjbIYw3D9O6qEXybnKvvtV9HtTm4Q=;
        b=NvMZ6VvRlYVkah63CJIUHqyg9a/OVA5z9xPHrcyhFs60slYJyYFkbNYpeSeg7Dehz/
         qGhFkrYUxJ+jqXEHqKyRPM7WVZYTmnQcUDbYIoBBly6oFfPkzSJhVJEcPdqGm/SIS2eq
         IIBCD8tQEPzicFCj3U/a8eOTtBmvoSjhiCf0yOEZLV4I3jsm1+NPPukD86Rtlcd4T2w3
         8NXGZHlxfKqKOP0nxJJdpHURbZ3p2HMj67IulQYFmWEicAr6wbhVVhoUk8j6M/Q9c6L8
         jzJzkv6tC8azu6/Qivj21x7OjW7VLjqnCBfCVzc8usmLyITlTBg0rCXz1YZY2q33X15Q
         V42Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAV3pLWhEubJ8of7fvjfoeXuP1eDAEkufWI+LrRB1hvm/vdeRN3U
	E2kmNYNDtJxD7d8afxgeOM7JMKsTXJb8P7gaI3cTsSLZU0yWmSKcNychaO8TzydGREqcB6EL8ve
	yrAIKWGEGGPrMDLAUQbVFbKCEZ0t9oxmTTzeD4L50P7ZzglJBZ+to701D0HX6nI1TNQ==
X-Received: by 2002:a05:6402:1213:: with SMTP id c19mr50348776edw.63.1560192819546;
        Mon, 10 Jun 2019 11:53:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzter/gADtOf+tzj83sqYeh0fxpJvEBhf4jmUoZl9TsHT6rTVipSTeDaClqFsQZLC+d9sQc
X-Received: by 2002:a05:6402:1213:: with SMTP id c19mr50348701edw.63.1560192818682;
        Mon, 10 Jun 2019 11:53:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560192818; cv=none;
        d=google.com; s=arc-20160816;
        b=GGHHuXqycLDs7ND9JXXcITQT78Y5W/qHYFvn+75pAgIJuaJLlOvppadjxeNllNGho1
         jOBOS6CbhaANeiehO5TlT0CgikPUi3qyBGDE1Rd8qNw05sihYFqZI0qrKsAskZEvUDqT
         eIQbJBTKSFBGJaEH8WsdK9lJg9lG8cP8qQhJP7Pbiriyr2LYYB+v3uZ3bAGUUQBTjm+s
         9mCrnajBAH1rdVjppB54zVNVtkOyjHfbupjTycmOp2GBFs5Igy2XVS9ms6tMcYQTegYg
         L2C+XRvin5NgU9MGqa/Jk9NVLxxXGkIA9+QI2aDCzmQqKDdbwXWGPz7B1G037fDU7m/2
         NvPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=f7QJNPySFGeY+lFjbIYw3D9O6qEXybnKvvtV9HtTm4Q=;
        b=C1ckzXOSAo28wLWwvcs7+vykh6ZUU2uCSyL8f8WU/NNbw9ynWkw0698YwK/86K0mWj
         N9uln1Ccvk1uK05+OAKEpp1pW9zHHD1Wj11zN13ZN4gva5vhnBVnlDol1xPdhSBzqvXd
         FVk2qRhusX1ofEZxZPoPqmzlu1fS7Gnhw8DOjD+fP7fvdy7OujfaMLRmMRsAmtaTcIrV
         MjUIErBTMJ8IkXcBDnDiHri9dtFOHGRlBJ1UkpHCIQdZz1mQYVkZOkz96tNyUU2Oxj9z
         yV1Z5SqohOlc7dcvKVkMFSL9Yd4Cf5USyhsCz5noJS0+goGWwEVhzF4xMjE3Qa/KJaDs
         cqEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id c55si8756269edc.323.2019.06.10.11.53.38
        for <linux-mm@kvack.org>;
        Mon, 10 Jun 2019 11:53:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 822ED337;
	Mon, 10 Jun 2019 11:53:37 -0700 (PDT)
Received: from mbp (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 631F83F246;
	Mon, 10 Jun 2019 11:53:32 -0700 (PDT)
Date: Mon, 10 Jun 2019 19:53:30 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Kees Cook <keescook@chromium.org>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 02/16] arm64: untag user pointers in access_ok and
 __uaccess_mask_ptr
Message-ID: <20190610185329.xhjawzfy4uddrkrj@mbp>
References: <cover.1559580831.git.andreyknvl@google.com>
 <4327b260fb17c4776a1e3c844f388e4948cfb747.1559580831.git.andreyknvl@google.com>
 <20190610175326.GC25803@arrakis.emea.arm.com>
 <201906101106.3CA50745E3@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201906101106.3CA50745E3@keescook>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 11:07:03AM -0700, Kees Cook wrote:
> On Mon, Jun 10, 2019 at 06:53:27PM +0100, Catalin Marinas wrote:
> > On Mon, Jun 03, 2019 at 06:55:04PM +0200, Andrey Konovalov wrote:
> > > diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> > > index e5d5f31c6d36..9164ecb5feca 100644
> > > --- a/arch/arm64/include/asm/uaccess.h
> > > +++ b/arch/arm64/include/asm/uaccess.h
> > > @@ -94,7 +94,7 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
> > >  	return ret;
> > >  }
> > >  
> > > -#define access_ok(addr, size)	__range_ok(addr, size)
> > > +#define access_ok(addr, size)	__range_ok(untagged_addr(addr), size)
[...]
> > diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
> > index 3767fb21a5b8..fd191c5b92aa 100644
> > --- a/arch/arm64/kernel/process.c
> > +++ b/arch/arm64/kernel/process.c
> > @@ -552,3 +552,18 @@ void arch_setup_new_exec(void)
> >  
> >  	ptrauth_thread_init_user(current);
> >  }
> > +
> > +/*
> > + * Enable the relaxed ABI allowing tagged user addresses into the kernel.
> > + */
> > +int untagged_uaddr_set_mode(unsigned long arg)
> > +{
> > +	if (is_compat_task())
> > +		return -ENOTSUPP;
> > +	if (arg)
> > +		return -EINVAL;
> > +
> > +	set_thread_flag(TIF_UNTAGGED_UADDR);
> > +
> > +	return 0;
> > +}
> 
> I think this should be paired with a flag clearing in copy_thread(),
> yes? (i.e. each binary needs to opt in)

It indeed needs clearing though not in copy_thread() as that's used on
clone/fork but rather in flush_thread(), called on the execve() path.

And a note to myself: I think PR_UNTAGGED_ADDR (not UADDR) looks better
in a uapi header, the user doesn't differentiate between uaddr and
kaddr.

-- 
Catalin

