Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C90C4C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:01:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97A1120866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:01:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97A1120866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3948C6B0007; Wed, 12 Jun 2019 11:01:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 345236B000A; Wed, 12 Jun 2019 11:01:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E7C76B000D; Wed, 12 Jun 2019 11:01:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C83636B0007
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:01:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b3so25289662edd.22
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:01:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=G/zKbapDCtnkwrIMol1wKOHNLZieInn9CAsEjzT4W5c=;
        b=nO1jlMtdVPPmMVy8lDw+N5gH4oQbtrB+mLXHq2tyiNvTqViQ6aAVD5rq1l9g7Zsh4P
         gycdniDfk35jL6/ewLk2W6wSUFJnGzcN7zimoCL1m54h4rvgwmhjHuL07AyjgC3DhRF1
         kHY9yq5x5D1teoxTSHNiBi/LL+DvxYBGjdIM/fOZiYdslKC2bQ6tz4xPAkBFPmkIOvjL
         ra0HhJ4J2/VLkNdvPHTBZ76qo26uSzDlCyIvVWN2nVO7d+IGjWPy4iJD1kvGy/j8QOzC
         qD/w5FlpvK2ixg3/IjovLR/4hWZwHv0Sr3zY/EzYZgkvaBNETnYVNZooNfHJJBK3U87m
         p+GA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAV0cvXDzCCeBWRtSgiKvXUsUwiOb0iII8diDaeLfT9ee8z41snt
	Fy3VteT69XQ0Z0wLdtbS/6gx5byYS2EfEMxmd31zKIqu8Oq9jeqLcq1cip3AX91uovmX4e4u2uo
	AOnLP3kiUCnidml8rdOoLWPYm+OanlPL0ke1DphraO4b5k7HmC6pgNcfsq3OXtfnusw==
X-Received: by 2002:a17:906:6dc3:: with SMTP id j3mr22461550ejt.258.1560351662349;
        Wed, 12 Jun 2019 08:01:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLjWn3aIccMHdlO4WMHsO0LVh8/jKcw3StcSgGMmx5CAsr83xCRJzAZxa4ETIoLhxPAJ3B
X-Received: by 2002:a17:906:6dc3:: with SMTP id j3mr22461463ejt.258.1560351661383;
        Wed, 12 Jun 2019 08:01:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560351661; cv=none;
        d=google.com; s=arc-20160816;
        b=cLdPBS1wcQ09PqvjfEpxKULEOCwxtXapxd4oYgFoBP1LT1nEjawwwDZfhZFCElZCFC
         nH0bNVzF2ptQGytXwt/zs2PHy/jClz1olC5qMdet7DnegbgS5ABKFjWdaY+tz/a6OF90
         gb4x+rZtZpTyXXh9CJV/+GlUQMXQkt1J66hfBeR/5j9gexDRENGgl7ZzedgxU+G9zjiY
         5r1HYtU1W0zLgkEF1fTIlJahoVLh4ajyVa7X0woTmek5KIJqRmwdgFzJquqqlTguRMUd
         +dCu0YWEORIH8sqyerTi+vY4ghsrF2yPWee5XEf/GNGnGpUM7UFhfPVVM+l/i2JCwxKg
         sjbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=G/zKbapDCtnkwrIMol1wKOHNLZieInn9CAsEjzT4W5c=;
        b=xHVeTfomQJ9fxsAlb2cC2mCHHN4Ly6ZjboFjBVQdU7OMo6pxs+VSOaOlVUet2qFZ1f
         b2vs2iqmI2MA7aF7qMEm4xgqFrSuvSQELQ7Vtsm0Byw+PFGJekE52apre8AiN3G8c9I0
         Nf/pJNkMg3wYk9a7VR8Z+gzN2s3h7azFhIAgA+uoG2TIJW+uXv5KQIj++gp8rQRzAOna
         tbxvTKeak65ErDOQpwKEIrK6WXQBDFPK+EbApeKyZbqF2W/wPHWiVKgwQaU0hN3/nNwY
         vqHf1+LvLQQnoDBjW1lDiqcCPiCLk2UDhCm43y9CeCMFp2M3gDqRJ1wi121b8WjBO3mx
         HeMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id x19si9115063eda.391.2019.06.12.08.01.00
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 08:01:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4B40A2B;
	Wed, 12 Jun 2019 08:01:00 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 71C193F557;
	Wed, 12 Jun 2019 08:00:46 -0700 (PDT)
Date: Wed, 12 Jun 2019 16:00:42 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>,
	nd <nd@arm.com>, Vincenzo Frascino <Vincenzo.Frascino@arm.com>,
	Will Deacon <Will.Deacon@arm.com>,
	Mark Rutland <Mark.Rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave P Martin <Dave.Martin@arm.com>,
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
	Robin Murphy <Robin.Murphy@arm.com>,
	Kevin Brodsky <Kevin.Brodsky@arm.com>
Subject: Re: [PATCH v17 15/15] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
Message-ID: <20190612150040.GH28951@C02TF0J2HF1T.local>
References: <cover.1560339705.git.andreyknvl@google.com>
 <e024234e652f23be4d76d63227de114e7def5dff.1560339705.git.andreyknvl@google.com>
 <7cd942c0-d4c1-0cf4-623a-bce6ef14d992@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7cd942c0-d4c1-0cf4-623a-bce6ef14d992@arm.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 01:30:36PM +0100, Szabolcs Nagy wrote:
> On 12/06/2019 12:43, Andrey Konovalov wrote:
> > --- /dev/null
> > +++ b/tools/testing/selftests/arm64/tags_lib.c
> > @@ -0,0 +1,62 @@
> > +// SPDX-License-Identifier: GPL-2.0
> > +
> > +#include <stdlib.h>
> > +#include <sys/prctl.h>
> > +
> > +#define TAG_SHIFT	(56)
> > +#define TAG_MASK	(0xffUL << TAG_SHIFT)
> > +
> > +#define PR_SET_TAGGED_ADDR_CTRL	55
> > +#define PR_GET_TAGGED_ADDR_CTRL	56
> > +#define PR_TAGGED_ADDR_ENABLE	(1UL << 0)
> > +
> > +void *__libc_malloc(size_t size);
> > +void __libc_free(void *ptr);
> > +void *__libc_realloc(void *ptr, size_t size);
> > +void *__libc_calloc(size_t nmemb, size_t size);
> 
> this does not work on at least musl.
> 
> the most robust solution would be to implement
> the malloc apis with mmap/munmap/mremap, if that's
> too cumbersome then use dlsym RTLD_NEXT (although
> that has the slight wart that in glibc it may call
> calloc so wrapping calloc that way is tricky).
> 
> in simple linux tests i'd just use static or
> stack allocations or mmap.
> 
> if a generic preloadable lib solution is needed
> then do it properly with pthread_once to avoid
> races etc.

Thanks for the feedback Szabolcs. I guess we can go back to the initial
simple test that Andrey had and drop the whole LD_PRELOAD hack (I'll
just use it for my internal testing).

BTW, when you get some time, please review Vincenzo's ABI documentation
patches from a user/libc perspective. Once agreed, they should become
part of this series.

-- 
Catalin

