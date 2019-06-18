Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45E0AC31E5E
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:50:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08EA020B1F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:50:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08EA020B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EC906B0005; Tue, 18 Jun 2019 12:50:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 877068E0002; Tue, 18 Jun 2019 12:50:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7167A8E0001; Tue, 18 Jun 2019 12:50:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2138A6B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:50:36 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k15so22088147eda.6
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:50:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cbCOm89CaR3G1j2HEC6TT5+yxrz1x0OCp6qaI06DO8k=;
        b=ZxH/O/qbDaCcQl7JIKPZyCh/JXJUEqYbq0fk3OlDPkCTbHRXzK6sQXuz5KqzdDbWzG
         5ZoZaJ9GHFxvWwVzq0ZUqWIE0pk+PGeiEzmRKsC+8xhu1BiS6HJ0KDQfKOZedqdMMKsA
         T078tfZ147hErmakjPf0Hf4Kqx7bwo3nsnG1ohu2HPLGomINJ2c0JtQG9fvzSqabBQkf
         ZwKSYvTTqvSPVZSZ+bOJKuCoaD7b5MmEv4xg+x7d0O7ueeLwmEshwsCDsGGHV4JHKLQT
         +F8R5O+6W3rFvIiUDnlHlUzIF9hUNjrSPaMtVh8uArl3oKIOxTFGTl2kB398ekF/v/pT
         iHOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAUVMvkD5MfdFY3gG8Wxufc0T9hUNkK5DikhYbSqZU1oYX3DrKRK
	Q8nGPPjCexbE3GSSILd8RTPkdfpFSDdJXLRgXXIKQfSVGvzGHH9l0EPsbT4qeN8HqKU/J7KqTag
	K7LERfGJKiNfYWyRYojjSyA0B2pmUkSLp323T2i/d4Vk4NbkGG4BTbdhd9U+8X89hAQ==
X-Received: by 2002:a50:b7bc:: with SMTP id h57mr127090747ede.77.1560876635711;
        Tue, 18 Jun 2019 09:50:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzj3bdGcJdGzmUUaaPk3DAUVKRuEyXn73cdyG9HgligPvQ4M93fOrDLXrmIvBiBlJNwwlZy
X-Received: by 2002:a50:b7bc:: with SMTP id h57mr127090679ede.77.1560876634986;
        Tue, 18 Jun 2019 09:50:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560876634; cv=none;
        d=google.com; s=arc-20160816;
        b=OoGdQgcHPZuY2PhteuoTwExpwThmKP5a23ITW1qTOw0YUhMCZ43EnMRxVjhqqZLeMi
         Zwlkc4SoCMQ+W2DKWdBPC9xJoWBUQmKV9DelcEzxQV5eU5zvZCL2Lc+QtPHARLmh4ct1
         9lP06JCwMbAB88ICm9xQ6NKel1Y8RIqdnXIlObkHXQDK2vkbyeaQ0qhBQ2h3ITMvfcud
         9/nCOFfSt282BYJoLRv/8o7tQIFmBaAC7Qb4rKUVjJkQVnMVpEEnVOV9cAxxEAGc85ox
         XBtzMo1q9aymM7NsC9+C7gvem358Tm0EEXxU2n+zhi0LFO70NcaGhEjv/c5f3vZ/WiPg
         aIqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cbCOm89CaR3G1j2HEC6TT5+yxrz1x0OCp6qaI06DO8k=;
        b=0UqVZrtoW5wm/uYmK8XJ4rWUYgIVoVJtiBPWO5BsBZNe5k2cTrjsFtgnkqCRk/QO18
         ZuQQuUFwqqsxZ0scd5/OOfDmkHdvd8bgE4R/TEaXrgZJ7Kik8XYgM0KzcYmUJWy2zd1D
         p6thjTmD0N+DmTh3VTDTu8yZn2fg8lZmJuihLE9gZufG0NePC4oJLems2DsYTnBPMaS+
         tv7AXySjviiNo93bvfoR7RFWr9f3tt5the9JBDUW1urafdFhTQK5u42Psef2k4tD02hJ
         5Ps/GtuqlgdAhM4+SBS4OImhK7yyC0dVjBwww1ZI1fyuR/cx55BQyKQQGCQghFlIpclv
         RiWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 30si11369527edu.170.2019.06.18.09.50.34
        for <linux-mm@kvack.org>;
        Tue, 18 Jun 2019 09:50:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E2F57344;
	Tue, 18 Jun 2019 09:50:33 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 56B6C3F246;
	Tue, 18 Jun 2019 09:50:30 -0700 (PDT)
Date: Tue, 18 Jun 2019 17:50:28 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Florian Weimer <fweimer@redhat.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
Message-ID: <20190618165027.GG2790@e103592.cambridge.arm.com>
References: <87ef3r9i2j.fsf@oldenburg2.str.redhat.com>
 <20190618125512.GJ3419@hirez.programming.kicks-ass.net>
 <20190618133223.GD2790@e103592.cambridge.arm.com>
 <d54fe81be77b9edd8578a6d208c72cd7c0b8c1dd.camel@intel.com>
 <87pnna7v1d.fsf@oldenburg2.str.redhat.com>
 <1ca57aaae8a2121731f2dcb1a137b92eed39a0d2.camel@intel.com>
 <87blyu7ubf.fsf@oldenburg2.str.redhat.com>
 <b0491cb517ba377da6496fe91a98fdbfca4609a9.camel@intel.com>
 <20190618162005.GF2790@e103592.cambridge.arm.com>
 <8736k67tdc.fsf@oldenburg2.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8736k67tdc.fsf@oldenburg2.str.redhat.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 06:25:51PM +0200, Florian Weimer wrote:
> * Dave Martin:
> 
> > On Tue, Jun 18, 2019 at 09:00:35AM -0700, Yu-cheng Yu wrote:
> >> On Tue, 2019-06-18 at 18:05 +0200, Florian Weimer wrote:
> >> > * Yu-cheng Yu:
> >> > 
> >> > > > I assumed that it would also parse the main executable and make
> >> > > > adjustments based on that.
> >> > > 
> >> > > Yes, Linux also looks at the main executable's header, but not its
> >> > > NT_GNU_PROPERTY_TYPE_0 if there is a loader.
> >> > > 
> >> > > > 
> >> > > > ld.so can certainly provide whatever the kernel needs.  We need to tweak
> >> > > > the existing loader anyway.
> >> > > > 
> >> > > > No valid statically-linked binaries exist today, so this is not a
> >> > > > consideration at this point.
> >> > > 
> >> > > So from kernel, we look at only PT_GNU_PROPERTY?
> >> > 
> >> > If you don't parse notes/segments in the executable for CET, then yes.
> >> > We can put PT_GNU_PROPERTY into the loader.
> >> 
> >> Thanks!
> >
> > Would this require the kernel and ld.so to be updated in a particular
> > order to avoid breakage?  I don't know enough about RHEL to know how
> > controversial that might be.
> 
> There is no official ld.so that will work with the current userspace
> interface (in this patch submission).  Upstream glibc needs to be
> updated anyway, so yet another change isn't much of an issue.  This is
> not a problem; we knew that something like this might happen.
> 
> Sure, people need a new binutils with backports for PT_GNU_PROPERTY, but
> given that only very few people will build CET binaries with older
> binutils, I think that's not a real issue either.

OK, just wanted to check we weren't missing any requirement for x86.

This approach should satisfy the requirement for arm64 nicely.

Cheers
---Dave

