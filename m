Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DF66C28CC1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 12:42:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FC1B216FD
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 12:42:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FC1B216FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEE2C6B000D; Wed, 29 May 2019 08:42:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B792B6B000E; Wed, 29 May 2019 08:42:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A40F66B0266; Wed, 29 May 2019 08:42:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52D846B000D
	for <linux-mm@kvack.org>; Wed, 29 May 2019 08:42:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z5so3310818edz.3
        for <linux-mm@kvack.org>; Wed, 29 May 2019 05:42:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=l5G/jTlruDyeF+ZhNhbPDaXYRFhYAJw+sLwsGoy5RMg=;
        b=HHD1q8ejsz8Z4kZhbMSWiIR1ZPnRyZSBPa0e7JDAC+bEYeb+wnqv6YQsZ80c+/CCBc
         /TELLENJ55itDmc7gjrBqIwEXov8AHyb9pG2ow576WS0HSyyP2ZCYpYpYnhaCdbB7Ifu
         M6+QotNhsLtvGH2K3umPO4plOKDbfUiZF+6asMNzkCt3Q/1BBfBx8a3t6pulmj/N3Bjx
         50NSV0bF5/4oIkQwKgPaua9K1/1V991xUVBjpHzuMQK7AArtT51agILH+xL/5P6rL0oJ
         UyW4fjQbyOHi2Iss35Egk33MzRuezvH6qbWlLkHvpjVu2yVajJJ+sZnhgjaZkMiogN6A
         Jl8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAWiotGxV8wzppU5m+KNeUQqTRIvJRqQlt4/EmJobfMEwBOztX8m
	LMkwu0yVhHy65rGZ3/RUUMgA1iwDuktiq9oijcGyvuTNB/mcCv1GtxOqQeRXoWWtYjespquN80M
	a6/EF/G6ReSZbiSDWmjFThU6zpT22kdXNvwcUh2vYhYUQlROvyyJwXVsOFg15hT4ixA==
X-Received: by 2002:a17:906:6a52:: with SMTP id n18mr41179808ejs.93.1559133756872;
        Wed, 29 May 2019 05:42:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVm/ZxLTPMBEcdJAJtJUtm4eIHKJ/dnzGOEc7op8MUmWdCIlqAxq30BXgUI7MuJZ/shm1h
X-Received: by 2002:a17:906:6a52:: with SMTP id n18mr41179676ejs.93.1559133754891;
        Wed, 29 May 2019 05:42:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559133754; cv=none;
        d=google.com; s=arc-20160816;
        b=GvLopkRJ1EpjMfYgj37Ua/u+Rnmue94lNdyfl7kCXaI72N9dqiXUN0nwb+6jpEXk08
         vU1vPbRzV++eDc9lAai8XJOX8pKKnqKw9ts92eCfAY4FRzls7hzBl9qGvYqzDQ0nahA7
         bkK5Jnk+CAuFSmT7kTJYWOjD5e9I/D4BZwfnvVIb/ZWg8K+fWlo/JR4dtrMLZ3kvBUdn
         CASAxDY42DfG/r3mJpMdgvKcVthPGqTaSKzREAzYu8fH5ZAZti74BNph/RSIDjDYbXaq
         N2DTtii8QzG9eLC3whrEjr7+8rjHbkhmKOQjZ7s3qNlRBzdJwkwhvieO6Pck/Y43xsNS
         kk6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=l5G/jTlruDyeF+ZhNhbPDaXYRFhYAJw+sLwsGoy5RMg=;
        b=1DQMZeVR4io25noCgwORNMkepu/yN3YYaeL/iH0eyO18xQyCJnluueSScD03NHzONp
         9HV/TsSGa8oiGHd/e9b4P5Ngz0owHwMyOn9mMcHiL+hL1QEpZ4V3ozxaxlfokAYaDrzn
         /59cP6fTIWxvrpk6ReBcdbGoASOZ/ISDrPuhNVsGmTzFSm2CHB5LuNZTeYlGGVqHVTfk
         PP3BEjRA8AXpeB9GVtFE9e5Aj0yAyab/bdY90KMWGri7SmTCol4ONgAMkVQR0xKpyeCJ
         pZw9MgCzNFlbcEw39/aNsW1s/GrJxPrEIm91to1Y7jGT4vmDIvEvt+bkFJaa09AtD3CH
         p1xw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g28si2716269eda.439.2019.05.29.05.42.34
        for <linux-mm@kvack.org>;
        Wed, 29 May 2019 05:42:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9B58780D;
	Wed, 29 May 2019 05:42:33 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DEF043F59C;
	Wed, 29 May 2019 05:42:27 -0700 (PDT)
Date: Wed, 29 May 2019 13:42:25 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, Dmitry Vyukov <dvyukov@google.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Murray <andrew.murray@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190529124224.GE28398@e103592.cambridge.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
 <20190527143719.GA59948@MBP.local>
 <20190528145411.GA709@e119886-lin.cambridge.arm.com>
 <20190528154057.GD32006@arrakis.emea.arm.com>
 <20190528155644.GD28398@e103592.cambridge.arm.com>
 <20190528163400.GE32006@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528163400.GE32006@arrakis.emea.arm.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 05:34:00PM +0100, Catalin Marinas wrote:
> On Tue, May 28, 2019 at 04:56:45PM +0100, Dave P Martin wrote:
> > On Tue, May 28, 2019 at 04:40:58PM +0100, Catalin Marinas wrote:
> > 
> > [...]
> > 
> > > My thoughts on allowing tags (quick look):
> > >
> > > brk - no
> > 
> > [...]
> > 
> > > mlock, mlock2, munlock - yes
> > > mmap - no (we may change this with MTE but not for TBI)
> > 
> > [...]
> > 
> > > mprotect - yes
> > 
> > I haven't following this discussion closely... what's the rationale for
> > the inconsistencies here (feel free to refer me back to the discussion
> > if it's elsewhere).
> 
> _My_ rationale (feel free to disagree) is that mmap() by default would
> not return a tagged address (ignoring MTE for now). If it gets passed a
> tagged address or a "tagged NULL" (for lack of a better name) we don't
> have clear semantics of whether the returned address should be tagged in
> this ABI relaxation. I'd rather reserve this specific behaviour if we
> overload the non-zero tag meaning of mmap() for MTE. Similar reasoning
> for mremap(), at least on the new_address argument (not entirely sure
> about old_address).
> 
> munmap() should probably follow the mmap() rules.
> 
> As for brk(), I don't see why the user would need to pass a tagged
> address, we can't associate any meaning to this tag.
> 
> For the rest, since it's likely such addresses would have been tagged by
> malloc() in user space, we should allow tagged pointers.

Those arguments seem reasonable.  We should try to capture this
somewhere when documenting the ABI.

To be clear, I'm not sure that we should guarantee anywhere that a
tagged pointer is rejected: rather the behaviour should probably be
left unspecified.  Then we can tidy it up incrementally.

(The behaviour is unspecified today, in any case.)

Cheers
---Dave

