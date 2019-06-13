Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF717C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:26:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F31F2082C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:26:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F31F2082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00C6A6B0006; Thu, 13 Jun 2019 11:26:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F006C6B0008; Thu, 13 Jun 2019 11:26:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC8426B000C; Thu, 13 Jun 2019 11:26:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3E96B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:26:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y3so19896742edm.21
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:26:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yBq9Q6KJYj9l9Pr0SLvpOdK5uu3Uc/hn4lESOkilCvA=;
        b=TCVDNxyfDzrzT/MOKKcUodHkqTMGlYfQs792j/vfPqX6GtkUooayBF+E+XDDpd5+9H
         0/8o6kawOpcWL8b2uGMtAi8kU51nrqXNrBp8vaadPd6zDX8P+ph1pp5cIvep2BzE9fHD
         m3LPjWEO+LuVCr6U040h53Tgt+YEQu6QQ92iKPAiR16m5SOkevQlGXKcPsDkEMncndG+
         BB6wLLqRQGT/PImKWOygejSxBtExaUXlHbdPiz6JnHV5xluSyw3SIPziMAj5QY6wSDI8
         MgqcXFDTEVx69i4ax5Iq0OTdRtkYoDF7U99KvZ9KR380JyAb+Huui53AA07CUBcPqxqH
         2IFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAURe4VVY4rySckbJ50EQqMkyIx2Ojpm23XEblmvzw1up+Ti7r2O
	+vHLnEPYel2264obvi8cEZ+A9OVyjONSoX0D0Xfp1jxlfJbXUZxKw1H37dT/9oACrI4GkD8GH6D
	nhkE/CJVGoUIajsejC2GTU19JaV9pfbwgDHi6wwXk7Gf3wmhGo3RtEs5yZ/en47Y+0w==
X-Received: by 2002:a17:906:1f44:: with SMTP id d4mr66382495ejk.195.1560439611978;
        Thu, 13 Jun 2019 08:26:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYadW2LX2yURWWPK0+mKkoVVLiT11zQi2Kdz4aaB7e+xGp2ZZ4X8MuilG8gpNCIgzCk8Zv
X-Received: by 2002:a17:906:1f44:: with SMTP id d4mr66382397ejk.195.1560439610677;
        Thu, 13 Jun 2019 08:26:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560439610; cv=none;
        d=google.com; s=arc-20160816;
        b=EjvPHTXjVCIi/KmxUt31CIVWXIPOHzeIQitJFt8iNOLtNIMI4avL+dHQ05EXiLeYd3
         +Zu7iuNJMk/1DFnIp/YhlguAhC+Gu/R+wDak9SoUl7YCtqLCryDCYcEYix5ZFK0CDyB+
         LOsuPb4cY8RfrO4cT6U/QfuqqYnYkE+VppNxhIIJV1uHMk44DalrTXpNdd8mUToo9wUG
         R0ctHcyjmrNLkJ8bDkqISCfqzNcGi2CvILxuGrlZOgWH82GF0DzgaQyqp/nnGEVWI+fs
         01pSHGZbkL9c0bHcyuhzrTMJ+CKlpRBgcSKvA53TAiafnRvvbSqm+bpVqgGye66EC527
         +oHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yBq9Q6KJYj9l9Pr0SLvpOdK5uu3Uc/hn4lESOkilCvA=;
        b=E7BulSAykfqCIMaienOZLpqWFoJvoFmtp36ksv/oTW4eg6Pnp7xjQGuDzEQtLdzfzI
         zxBZpy7tmJSckDXTKEc2xxdjkkyh6Ybo8tpTPnTiAd75U4QmhQLxw7mPqGExjD/pzQtU
         uHQm4RZqpWF4Brlv9c1wloMS/wy6jbfPCBQJp15G13LRiHKy9t9CVr/lJnRZKftPE4zB
         k0KnjgEj1xs3sgnngt9SKo16ItddmtMk0lkHca6sngYEOgK0oTPy036V1teQdby8vbZb
         /0rbuHCOkKWo7jVkoePQEV+OvKW5s/+5FZE6NNcpSxcC3Z1lrua1Ik/icw+2H+cbtRQG
         o4SA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id d8si175563ejd.259.2019.06.13.08.26.50
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 08:26:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A46BD3EF;
	Thu, 13 Jun 2019 08:26:49 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3FA233F718;
	Thu, 13 Jun 2019 08:26:36 -0700 (PDT)
Date: Thu, 13 Jun 2019 16:26:32 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Mark Rutland <mark.rutland@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control
 the tagged user addresses ABI
Message-ID: <20190613152632.GT28951@C02TF0J2HF1T.local>
References: <cover.1560339705.git.andreyknvl@google.com>
 <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
 <20190613110235.GW28398@e103592.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613110235.GW28398@e103592.cambridge.arm.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dave,

On Thu, Jun 13, 2019 at 12:02:35PM +0100, Dave P Martin wrote:
> On Wed, Jun 12, 2019 at 01:43:20PM +0200, Andrey Konovalov wrote:
> > +/*
> > + * Global sysctl to disable the tagged user addresses support. This control
> > + * only prevents the tagged address ABI enabling via prctl() and does not
> > + * disable it for tasks that already opted in to the relaxed ABI.
> > + */
> > +static int zero;
> > +static int one = 1;
> 
> !!!
> 
> And these can't even be const without a cast.  Yuk.
> 
> (Not your fault though, but it would be nice to have a proc_dobool() to
> avoid this.)

I had the same reaction. Maybe for another patch sanitising this pattern
across the kernel.

> > --- a/include/uapi/linux/prctl.h
> > +++ b/include/uapi/linux/prctl.h
> > @@ -229,4 +229,9 @@ struct prctl_mm_map {
> >  # define PR_PAC_APDBKEY			(1UL << 3)
> >  # define PR_PAC_APGAKEY			(1UL << 4)
> >  
> > +/* Tagged user address controls for arm64 */
> > +#define PR_SET_TAGGED_ADDR_CTRL		55
> > +#define PR_GET_TAGGED_ADDR_CTRL		56
> > +# define PR_TAGGED_ADDR_ENABLE		(1UL << 0)
> > +
> 
> Do we expect this prctl to be applicable to other arches, or is it
> strictly arm64-specific?

I kept it generic, at least the tagged address part. The MTE bits later
on would be arm64-specific.

> > @@ -2492,6 +2498,16 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
> >  			return -EINVAL;
> >  		error = PAC_RESET_KEYS(me, arg2);
> >  		break;
> > +	case PR_SET_TAGGED_ADDR_CTRL:
> > +		if (arg3 || arg4 || arg5)
> 
> <bikeshed>
> 
> How do you anticipate these arguments being used in the future?

I don't expect them to be used at all. But since I'm not sure, I'd force
them as zero for now rather than ignored. The GET is supposed to return
the SET arg2, hence I'd rather not used the other arguments.

> For the SVE prctls I took the view that "get" could only ever mean one
> thing, and "put" already had a flags argument with spare bits for future
> expansion anyway, so forcing the extra arguments to zero would be
> unnecessary.
> 
> Opinions seem to differ on whether requiring surplus arguments to be 0
> is beneficial for hygiene, but the glibc prototype for prctl() is
> 
> 	int prctl (int __option, ...);
> 
> so it seemed annoying to have to pass extra arguments to it just for the
> sake of it.  IMHO this also makes the code at the call site less
> readable, since it's not immediately apparent that all those 0s are
> meaningless.

It's fine by me to ignore the other arguments. I just followed the
pattern of some existing prctl options. I don't have a strong opinion
either way.

> > +			return -EINVAL;
> > +		error = SET_TAGGED_ADDR_CTRL(arg2);
> > +		break;
> > +	case PR_GET_TAGGED_ADDR_CTRL:
> > +		if (arg2 || arg3 || arg4 || arg5)
> > +			return -EINVAL;
> > +		error = GET_TAGGED_ADDR_CTRL();
> 
> Having a "get" prctl is probably a good idea, but is there a clear
> usecase for it?

Not sure, maybe some other library (e.g. a JIT compiler) would like to
check whether tagged addresses have been enabled during application
start and decide to generate tagged pointers for itself. It seemed
pretty harmless, unless we add more complex things to the prctl() that
cannot be returned in one request).

-- 
Catalin

