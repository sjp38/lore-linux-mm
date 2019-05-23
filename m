Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AB21C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 09:04:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB82F20851
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 09:04:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB82F20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53CF66B0007; Thu, 23 May 2019 05:04:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C5B66B0008; Thu, 23 May 2019 05:04:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3905C6B000A; Thu, 23 May 2019 05:04:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DCB416B0007
	for <linux-mm@kvack.org>; Thu, 23 May 2019 05:04:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b22so8099564edw.0
        for <linux-mm@kvack.org>; Thu, 23 May 2019 02:04:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ofKgwrZSPkiDsP4z2r5c5NiHpp9tAA/wXd0x5kJi4H0=;
        b=Q21wCZVIasafHWEFU8p4Cta75o2WDnQu+1TX90htgujqWuuGeog90aixT2dURbrQgY
         tpnqrPyHXe9uATyNFKAxXusiDHpUgM4guCEuCEl4t8AthkjGbDDvcGCeqatkHld1sVQV
         tCqNNO5e8fatEN1LkVYbySsvccDFh0+f47GDdwAps7c+j+qudPEVcz7DFqkirU6FGA/X
         N66Ox9rdvNHhcey4hsRSj1DTFWh9WcosIIAn7HpKcjZbDaiYeFlLkRsKf2MdvCMRUtlc
         7Z1TLYVvO4jESG3aCRkyHzyv4X8DWnzWSBjQBbDxsovkN6Qex7wpOcoAHxIdPp7By9k2
         4CXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAX3uf8+NXpYXaMGxadkROO46s7Uh7uAWdzZTLdzyeqhgKruNTlC
	Ou0yQthSy+ruLkuTgvmkLrK4Jv/pw6KCs5RvtoS/rTQija1cXe3UyKTPO3p/P9Q9+gKhklQ2/8l
	urq7cbB0HGxoJjehSSXll7iQX6WqrZHcL1unveMjxTaB1itojTAy+Fq93UW1gUhQWWw==
X-Received: by 2002:a50:b56a:: with SMTP id z39mr95715573edd.91.1558602278479;
        Thu, 23 May 2019 02:04:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXTYLsuhAWQzX4YduwLyq3prur+g5EPMlRNbwV1uAKccBNBwJKUL+NFHVAuvEsGjdeEt8w
X-Received: by 2002:a50:b56a:: with SMTP id z39mr95715498edd.91.1558602277716;
        Thu, 23 May 2019 02:04:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558602277; cv=none;
        d=google.com; s=arc-20160816;
        b=eCo0vkOi54atHQbFisVKBfU4fWdrZ4mQn9B0LmUpiTMsEfxMJ7jHtPmDF3LqhGbDxt
         2Zn9ak9GrMtULjj7XtftrTjQF58UdYSuewBIBOi+BnJVD4IOYDRWByc4WMMvFJ+TiXTI
         Q4hPZ/WBoiEaNpW2XhDCgeK/rdvT5bNga9XNQ7abJNzwyU+fU3CAWjfeU5QtIkhtOoeH
         wCJLyw7vTEFkcEVPdbDQesHJj9QhazOr8U72g1kHqut0ZYH7/ilv3aGmB+1FexeOcI26
         3MyNpVx8zJDPSH5yvq8CaDwMNVB9xqF0ULtslb8Zwoz7rOF4qkrE6dlgL8YY54XYRXoO
         3j0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ofKgwrZSPkiDsP4z2r5c5NiHpp9tAA/wXd0x5kJi4H0=;
        b=nArtvihf3w41n5gFzUH1tvm9L4dEFOwGZ10K6Zy0W44qk0MP0kJB86hL4SEhdeO/s1
         uZ9GtZpzus91Qf6VX3M0JEbcQIZUAQ8PhqNLzH5eisr1nUjk9f54/gIsr4KL+huaCvJZ
         08nQCJg7BnDFoLfa0EVhBSRNbib6eZbbtWcJ9/o3eU9w160YFcVGsWu0PFW8A61TU6U3
         cV9m6Az3Xiu+hwmguRl7RC2aPfYAw2Z0NnTYPfvuJ9PL73aiKsAuA4b3a4ScxHEGEdaw
         ENSnFPNsJeC+d/06tVDr3Q9xRAeeB8C6vUy5m1JqbCS/XTweQn/l3P4VMV0npEXgphxT
         9wqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z17si4959206eju.125.2019.05.23.02.04.37
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 02:04:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 409B2341;
	Thu, 23 May 2019 02:04:36 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A78AC3F575;
	Thu, 23 May 2019 02:04:30 -0700 (PDT)
Date: Thu, 23 May 2019 10:04:28 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Evgenii Stepanov <eugenis@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
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
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190523090427.GA44383@arrakis.emea.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
 <20190522114910.emlckebwzv2qz42i@mbp>
 <CAFKCwrjyP+x0JJy=qpBFsp4pub3He6UkvU0qnf1UOKt6W1LPRQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFKCwrjyP+x0JJy=qpBFsp4pub3He6UkvU0qnf1UOKt6W1LPRQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 02:16:57PM -0700, Evgenii Stepanov wrote:
> On Wed, May 22, 2019 at 4:49 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Mon, May 06, 2019 at 06:30:51PM +0200, Andrey Konovalov wrote:
> > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > pass tagged user pointers (with the top byte set to something else other
> > > than 0x00) as syscall arguments.
> > >
> > > This patch allows tagged pointers to be passed to the following memory
> > > syscalls: brk, get_mempolicy, madvise, mbind, mincore, mlock, mlock2,
> > > mmap, mmap_pgoff, mprotect, mremap, msync, munlock, munmap,
> > > remap_file_pages, shmat and shmdt.
> > >
> > > This is done by untagging pointers passed to these syscalls in the
> > > prologues of their handlers.
> >
> > I'll go through them one by one to see if we can tighten the expected
> > ABI while having the MTE in mind.
> >
> > > diff --git a/arch/arm64/kernel/sys.c b/arch/arm64/kernel/sys.c
> > > index b44065fb1616..933bb9f3d6ec 100644
> > > --- a/arch/arm64/kernel/sys.c
> > > +++ b/arch/arm64/kernel/sys.c
> > > @@ -35,10 +35,33 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
> > >  {
> > >       if (offset_in_page(off) != 0)
> > >               return -EINVAL;
> > > -
> > > +     addr = untagged_addr(addr);
> > >       return ksys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
> > >  }
> >
> > If user passes a tagged pointer to mmap() and the address is honoured
> > (or MAP_FIXED is given), what is the expected return pointer? Does it
> > need to be tagged with the value from the hint?
> 
> For HWASan the most convenient would be to use the tag from the hint.
> But since in the TBI (not MTE) mode the kernel has no idea what
> meaning userspace assigns to pointer tags, perhaps it should not try
> to guess, and should return raw (zero-tagged) address instead.

Then, just to relax the ABI for hwasan, shall we simply disallow tagged
pointers on mmap() arguments? We can leave them in for
mremap(old_address), madvise().

> > With MTE, we may want to use this as a request for the default colour of
> > the mapped pages (still under discussion).
> 
> I like this - and in that case it would make sense to return the
> pointer that can be immediately dereferenced without crashing the
> process, i.e. with the matching tag.

This came up from the Android investigation work where large memory
allocations (using mmap) could be more efficiently pre-tagged by the
kernel on page fault. Not sure about the implementation details yet.

-- 
Catalin

