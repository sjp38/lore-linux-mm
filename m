Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 425BCC43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 20:36:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2B7C206E0
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 20:36:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="aypLgRrX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2B7C206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FCF96B026C; Mon, 10 Jun 2019 16:36:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AD746B026D; Mon, 10 Jun 2019 16:36:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 674866B026E; Mon, 10 Jun 2019 16:36:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 30A2D6B026C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 16:36:07 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f25so7938657pfk.14
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 13:36:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=QIiaElKbYG7X2iRY6VXsdeM4+31zgx4vPIFfu4hUJug=;
        b=quTBcBLnbEwXd2HBra2S2TuP3K+6fKp1KhcblqWxbCezCV3SlJ0wQQH4xxUBWZKMz8
         SL9wUQnHkcImcgmCIVQ1UGx9AjNGC6IID/nQSn+SrwzeX8EOubz2+O0AalGoyovd5bt6
         us094F7a6RH9/qRzouVRHzjHNnXX4TO0FNUB822NmR0ZCMy/G3LsXVb+YBgk6V4vIhvo
         aUac+OUBAG/jBjvak91DrChBotzpqlARMrN8pu4AxJGseNMDSIzstDviVrnZX9uK+JkA
         Tk8O9WSX319m0d9y4cJKtqWu4YDhPs8U8XwjeCZg0p0qzYq3m0tLYCsVRJLmLdURWGHr
         7AZQ==
X-Gm-Message-State: APjAAAXZg8CKRUGzfEfDxkuda/t1/81VY8QtNdZkjrUA2SfiIx4qRUDO
	ZpI3AtleIKXmETG3DNfxH5+CwQw6ZPGGkfG92E/DssnXNcV965jmQY9eHokUYRdaJM5srV8jQ76
	Z/UU+qTMwPsAMZ+r+Skg7TA04+ehYM3bKI9wT4ofqhXAR5mkHlln9RQhZyti1RCeBjg==
X-Received: by 2002:a17:902:7295:: with SMTP id d21mr57120598pll.299.1560198966818;
        Mon, 10 Jun 2019 13:36:06 -0700 (PDT)
X-Received: by 2002:a17:902:7295:: with SMTP id d21mr57120559pll.299.1560198966141;
        Mon, 10 Jun 2019 13:36:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560198966; cv=none;
        d=google.com; s=arc-20160816;
        b=K4EZHeLbaqG8G4Fe7pj95TBQVERt54nGOdmoNegndW9QpBNm5Hoi0DjTC/7UCOicI5
         J42ZHO3HN+VfY57hSbDrqQTv9QJ4TdrtsqDoSsXfoPa+5T3OoX2YYZIV62nP50TqKiAS
         uzBUm5ADtkiQxtDppd57sJXYvzcEMF5Dcz8tY496HRpJVxA4QOVlU5g26in5uzyILsfc
         JE2xomWvx8IcwSLrcq8jEwn9ZC3Aan/8YBSvMHUkkwbsBoBUx6sJ0HwmeZuOKcUQOQcy
         JQW7dUN6tTYVw1J6IlFeV2QS00ZFdJQF4edoQgDaw+rxSgfe3NdJ6V2BVVN70zoacCIP
         fvGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=QIiaElKbYG7X2iRY6VXsdeM4+31zgx4vPIFfu4hUJug=;
        b=T6HUTRrnjQ72Ps8NIaB/cgs2lbLyfBM1mnb0bDo/xGTCAACh/Auo609/p3+WRivMP4
         cW6NzOz3xPytBAmzXqdlrZr5OoNvgWY4jy4bQB6kvP7FMzFpBh4Fimyo2mDVB1XKQ6dp
         0cmqRhATJ40gxN7csgjhYgacYQvOxfnWg3fJzwReZl/HhYNt9f0PhCgE5IIei4cbggfz
         dUYOXqlcX80sgLJ8tSBy4W+7tjV5iCWAjKsEv3kNRIBRcRXJ77oJZxr6gu5pe5eFqaR1
         3iej3TX1SEIaVKpI+D0C9aWCygyleJKlvYsGTkQJJpfapvEj3yEp3MyDqjsikP3jytjG
         7JRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=aypLgRrX;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v3sor10880505pfb.36.2019.06.10.13.36.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 13:36:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=aypLgRrX;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=QIiaElKbYG7X2iRY6VXsdeM4+31zgx4vPIFfu4hUJug=;
        b=aypLgRrX0btLwkQ78UmSd30OW9UF0AUZJnAd3r2/5HqpTZB7t9pPjkr79taehwRSBe
         Uf3LjKJsRGeyWW7niEs4BHLmd/27Tp++YcV8xUIXVrHXkWkhfr39ad2bGk73/2ccXpRd
         Krrfs143htc/xGI+Ppm9VimNWGnjKhQyxh//k=
X-Google-Smtp-Source: APXvYqz36v1zCKX0GRWb534Z9an9udGHI/NESxPlvuGqVOMCrwC97gsWY6mXQoFhLwcNndoWLde2ZA==
X-Received: by 2002:a62:1b85:: with SMTP id b127mr76850297pfb.165.1560198965895;
        Mon, 10 Jun 2019 13:36:05 -0700 (PDT)
Received: from www.outflux.net (173-164-112-133-Oregon.hfc.comcastbusiness.net. [173.164.112.133])
        by smtp.gmail.com with ESMTPSA id k22sm11148457pfk.178.2019.06.10.13.36.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 10 Jun 2019 13:36:04 -0700 (PDT)
Date: Mon, 10 Jun 2019 13:36:04 -0700
From: Kees Cook <keescook@chromium.org>
To: Catalin Marinas <catalin.marinas@arm.com>
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
Message-ID: <201906101335.DF80D631@keescook>
References: <cover.1559580831.git.andreyknvl@google.com>
 <4327b260fb17c4776a1e3c844f388e4948cfb747.1559580831.git.andreyknvl@google.com>
 <20190610175326.GC25803@arrakis.emea.arm.com>
 <201906101106.3CA50745E3@keescook>
 <20190610185329.xhjawzfy4uddrkrj@mbp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610185329.xhjawzfy4uddrkrj@mbp>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 07:53:30PM +0100, Catalin Marinas wrote:
> On Mon, Jun 10, 2019 at 11:07:03AM -0700, Kees Cook wrote:
> > On Mon, Jun 10, 2019 at 06:53:27PM +0100, Catalin Marinas wrote:
> > > diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
> > > index 3767fb21a5b8..fd191c5b92aa 100644
> > > --- a/arch/arm64/kernel/process.c
> > > +++ b/arch/arm64/kernel/process.c
> > > @@ -552,3 +552,18 @@ void arch_setup_new_exec(void)
> > >  
> > >  	ptrauth_thread_init_user(current);
> > >  }
> > > +
> > > +/*
> > > + * Enable the relaxed ABI allowing tagged user addresses into the kernel.
> > > + */
> > > +int untagged_uaddr_set_mode(unsigned long arg)
> > > +{
> > > +	if (is_compat_task())
> > > +		return -ENOTSUPP;
> > > +	if (arg)
> > > +		return -EINVAL;
> > > +
> > > +	set_thread_flag(TIF_UNTAGGED_UADDR);
> > > +
> > > +	return 0;
> > > +}
> > 
> > I think this should be paired with a flag clearing in copy_thread(),
> > yes? (i.e. each binary needs to opt in)
> 
> It indeed needs clearing though not in copy_thread() as that's used on
> clone/fork but rather in flush_thread(), called on the execve() path.

Ah! Yes, thanks.

> And a note to myself: I think PR_UNTAGGED_ADDR (not UADDR) looks better
> in a uapi header, the user doesn't differentiate between uaddr and
> kaddr.

Good point. I would agree. :)

-- 
Kees Cook

