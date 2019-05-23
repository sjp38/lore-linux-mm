Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AF21C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 16:57:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B72C2070D
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 16:57:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B72C2070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B93D6B027F; Thu, 23 May 2019 12:57:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 843646B0280; Thu, 23 May 2019 12:57:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70AC76B0281; Thu, 23 May 2019 12:57:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB686B027F
	for <linux-mm@kvack.org>; Thu, 23 May 2019 12:57:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d15so9892195edm.7
        for <linux-mm@kvack.org>; Thu, 23 May 2019 09:57:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ld+lKZgiu6J6JVmIcVy93cFCEPN8unt8vL7/8dYr5Ns=;
        b=PyVDJtnLdhtBYZ5vI03hDWk1gb5Xk4V+zIcAo6balhU93dUcSDeXmfYhhNFl5cRRiA
         6e63bLazxTYDuRsJKj5mX6nfGR40lF97nHiPJQmmguyNywjaneENeiVS7Jzw3LySj3WW
         IL/e75GeWlDaqSBxkstI++UNZtp92R2PhybHL8FhPnCMLDxGwzQ8dAG5Sqh51nTT29cR
         s0Wt8Y1VVs0b9zNf9xWMaaWKwHClq59tlLA6quKN/te7GO2GKNk46C9rN1PwycdNoAV7
         ggp0at53bRST9aSoOs/vMEDNOYBA4rgRTm3GTHkJePoGHpMnP1juP+1YPvG04nhTQcBE
         J4pQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAX0QlMAO3Npf03CztehSD9VL0/Y3qAhK46cIpe2g7TXH9uPqwcp
	Fsknwj2ZEaOCdMV3dDmGby2eKsll0qC8OWYm7F8U/C2XseCldXfSj8hXZLh4Q4Q4rdr395sU7wZ
	f6RambzFYXib1XijWECasOAgTpG8lWrBXGiNiGkE7GazC+mSbnNDM15mzjNhHzj+lUg==
X-Received: by 2002:a17:906:640b:: with SMTP id d11mr28794940ejm.58.1558630644669;
        Thu, 23 May 2019 09:57:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzheRnMH/D85OSYwoiesr7zKRJlsXWf+AgfnbdycCHdciNWIJIY9s6179vGacjT/0a1RTWI
X-Received: by 2002:a17:906:640b:: with SMTP id d11mr28794849ejm.58.1558630643436;
        Thu, 23 May 2019 09:57:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558630643; cv=none;
        d=google.com; s=arc-20160816;
        b=uxJRBD5oVw1Le7IYgaor2BDq4BnhyZr5sKS3gYu6MeHx8N703nS5qXDOPFOiG0IKWa
         n8ew0vg5+q6Kb9NvZpkquta2WnLDdhQCvUWmDHEccAGybw9aOrsAMwcnbD7KdRrypFGF
         z70TWZLc++H5waMZq8E46KUKP1zizcEw0Kb6CgNTVoEIT4+k29I9vQ1sIurrgqnMWGCa
         X2nTbGvOAIs93aji5ZUP09B+SHVw1CTkANdG9wCr2scVWKloK2lHZ7/J1UGkeJGQ1cbV
         RYOu3/Fdl6taDNxvjyS6hPp0oe9n17dzVse1jUPvERptBKoiddnQBcT3ELefnlp2Ksrl
         2fjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ld+lKZgiu6J6JVmIcVy93cFCEPN8unt8vL7/8dYr5Ns=;
        b=d/5U74Eg/3ND+bwe+FAYFyN5xplZ+JqpJ2bejDLCIJPihw3On0foB3kHjXwYbO2OJR
         mEAeZvNSpUHI/R2OfoPsRCy08oZQHPVko122OZdAvfk7szstH9MGXhV567019A9sjzx3
         AHIJpfWcuZ6ovJi3+Br7vcnOgAtVreOji9ybQDI20k6R8MYzkyj9oE7ztnGSPyNONyQQ
         qstxvYRdwxHQX1sqZHEsHQv6BZTCnpc/Rdir3Wuo4TKMt8xCNJKNViA2gLAcYYg4bnTG
         Xn4cP6cAc4vT7iNENjnGko2XzP1WjXObtPBGwSER8+snYqR+H6QXgPVrvbKCAR8E7ilw
         B5Qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h1si516636ejd.15.2019.05.23.09.57.22
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 09:57:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0774C374;
	Thu, 23 May 2019 09:57:22 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1B06C3F5AF;
	Thu, 23 May 2019 09:57:15 -0700 (PDT)
Date: Thu, 23 May 2019 17:57:09 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Mark Rutland <mark.rutland@arm.com>,
	kvm@vger.kernel.org, Christian Koenig <Christian.Koenig@amd.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, Lee Smith <Lee.Smith@arm.com>,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, linux-arm-kernel@lists.infradead.org,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190523165708.q6ru7xg45aqfjzpr@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <20190521184856.GC2922@ziepe.ca>
 <20190522134925.GV28398@e103592.cambridge.arm.com>
 <20190523002052.GF15389@ziepe.ca>
 <20190523104256.GX28398@e103592.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523104256.GX28398@e103592.cambridge.arm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 11:42:57AM +0100, Dave P Martin wrote:
> On Wed, May 22, 2019 at 09:20:52PM -0300, Jason Gunthorpe wrote:
> > On Wed, May 22, 2019 at 02:49:28PM +0100, Dave Martin wrote:
> > > If multiple people will care about this, perhaps we should try to
> > > annotate types more explicitly in SYSCALL_DEFINEx() and ABI data
> > > structures.
> > > 
> > > For example, we could have a couple of mutually exclusive modifiers
> > > 
> > > T __object *
> > > T __vaddr * (or U __vaddr)
> > > 
> > > In the first case the pointer points to an object (in the C sense)
> > > that the call may dereference but not use for any other purpose.
> > 
> > How would you use these two differently?
> > 
> > So far the kernel has worked that __user should tag any pointer that
> > is from userspace and then you can't do anything with it until you
> > transform it into a kernel something
> 
> Ultimately it would be good to disallow casting __object pointers execpt
> to compatible __object pointer types, and to make get_user etc. demand
> __object.
> 
> __vaddr pointers / addresses would be freely castable, but not to
> __object and so would not be dereferenceable even indirectly.

I think it gets too complicated and there are ambiguous cases that we
may not be able to distinguish. For example copy_from_user() may be used
to copy a user data structure into the kernel, hence __object would
work, while the same function may be used to copy opaque data to a file,
so __vaddr may be a better option (unless I misunderstood your
proposal).

We currently have T __user * and I think it's a good starting point. The
prior attempt [1] was shut down because it was just hiding the cast
using __force. We'd need to work through those cases again and rather
start changing the function prototypes to avoid unnecessary casting in
the callers (e.g. get_user_pages(void __user *) or come up with a new
type) while changing the explicit casting to a macro where it needs to
be obvious that we are converting a user pointer, potentially typed
(tagged), to an untyped address range. We may need a user_ptr_to_ulong()
macro or similar (it seems that we have a u64_to_user_ptr, wasn't aware
of it).

It may actually not be far from what you suggested but I'd keep the
current T __user * to denote possible dereference.

[1] https://lore.kernel.org/lkml/5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com/

-- 
Catalin

