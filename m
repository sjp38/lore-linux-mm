Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 133B1C04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:25:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C542820873
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:25:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C542820873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B02D6B000D; Fri, 17 May 2019 09:25:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35FA96B000E; Fri, 17 May 2019 09:25:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 228C06B0010; Fri, 17 May 2019 09:25:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C9BB86B000D
	for <linux-mm@kvack.org>; Fri, 17 May 2019 09:25:44 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h2so10707748edi.13
        for <linux-mm@kvack.org>; Fri, 17 May 2019 06:25:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ul8Nx40rc9PJw1Y5naDvpQpxAK1ZumNOUgihPiYDfVs=;
        b=kPAqJfyZCiIZVoMY04Z+Tg0/9NiPpGXUT9blZFfvI/vUGpP9mv75Gv4+Qihp2qVPCc
         jCuA7MO3hW1m0RH7ebgkMFu5NbY/ruWfrrDdAlDCu1CkdM1qRCIlc3f6jCAtAy2GmD6M
         0DA+6niyXrPbMITnUCIxPPe3NpVOkP7bJUqfKPynAAl+/nmIFlgxY+F/79uqR4ffcdNz
         1jkD2s2vz2qJoSSbANrwaCZyBzSIxhHgPNqj+RYq1e1a7aogIIbjX67C4ZXUOMsTff5/
         i7D/m9D5I0vpOO3ayHs72iqemEqUIApbSf7ZQGAohjpPec+hEMtTQHTcpCSypckakcc2
         GJ9Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWQ/rPZV8i4rx9pfEISjXUNU5zciWxoAEeuTam6dOIuZCUg5ZQw
	XcLJlxb+OOSjH4x/F+vnjyF962g/q+a4fZq7Hq/A6y83PCmPaYzBnWsjF6uPeVAYKegC7JXl7dK
	Yg+uRMpgFHRzRM3/67ZaescDPs+HGU2SHFm014UaohYALWMyn7rZYTlnuYQMBqqk=
X-Received: by 2002:a50:ee11:: with SMTP id g17mr41598022eds.242.1558099544362;
        Fri, 17 May 2019 06:25:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyM7INAJr5QEXMLXTmit3xUMiHpTyT8rR63YhKEEJGwRrzEAqzVF7Sa0DkDWAnRX7rn07E0
X-Received: by 2002:a50:ee11:: with SMTP id g17mr41597954eds.242.1558099543551;
        Fri, 17 May 2019 06:25:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558099543; cv=none;
        d=google.com; s=arc-20160816;
        b=nbnCQw0d/b+Wrr8O7ISDXEIyNZ+LeuHSUrUvJMcLrx56c8cp8460cuWMw6uwYj0PMb
         K9xWTnCE9N33WtzSzUX0yF9P2S/kIQfDfwcU/C2RdhuzyWjnoCyNsEcV5NsKqhNtxsYH
         s0UR4WDBzaP9jsJvgqT07twt/FxjSsnHq26GhZY3g7xirewxUg8t/9+aXZn43/gppylI
         VG+NfY0SaZ0b4gTM17ZdHF0Ykp0ym7H4jA99ergCIBD/+7iV4tA7Oqh+7qgumH0DLI79
         ZCmwhzq0rxyRharFPcHNRZWLboadd8T/YUlaow0M3AfPNNjSyS7B2hvk0AIUV61t18oo
         x+BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ul8Nx40rc9PJw1Y5naDvpQpxAK1ZumNOUgihPiYDfVs=;
        b=DM2NcmnEY9BbNCvK40lO5tRB70NrYx1U9tYhIBaUPgFOQT2z3hAuXpkmTEEjj8nnu6
         PMlh48p05XVta0AL2saH7fj1u/6r3KkLKCZl28lpEt4qUda/lMH/f+yktK3H/RdZs18m
         z/0eghD+QS/rWyUzbJdxnp5iUZIbJD25QIVM29uug40jHbwGdOmVSdKSzxM+B5t4hgxI
         eqxQWlplMSvO6JgHAvgao5afglf/B0sY2RIMdZY3PEfK2whiB+iQxgCK+BAj4DUDsAwO
         GTQIoc+TAUVjahyHJvlTQAYBkXcReF/Ajp7LYGJzWWmSOXsiHbVZhYGIj3+F57E+y5RA
         3OiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l44si5017509edb.410.2019.05.17.06.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 06:25:43 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D31A8AE5A;
	Fri, 17 May 2019 13:25:42 +0000 (UTC)
Date: Fri, 17 May 2019 15:25:42 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alexander Potapenko <glider@google.com>
Cc: Kees Cook <keescook@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH v2 3/4] gfp: mm: introduce __GFP_NO_AUTOINIT
Message-ID: <20190517132542.GJ6836@dhcp22.suse.cz>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-4-glider@google.com>
 <20190517125916.GF1825@dhcp22.suse.cz>
 <CAG_fn=VG6vrCdpEv0g73M-Au4wW07w8g0uydEiHA96QOfcCVhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=VG6vrCdpEv0g73M-Au4wW07w8g0uydEiHA96QOfcCVhA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 17-05-19 15:18:19, Alexander Potapenko wrote:
> On Fri, May 17, 2019 at 2:59 PM Michal this flag Hocko
> <mhocko@kernel.org> wrote:
> >
> > [It would be great to keep people involved in the previous version in the
> > CC list]
> Yes, I've been trying to keep everyone in the loop, but your email
> fell through the cracks.
> Sorry about that.

No problem

> > On Tue 14-05-19 16:35:36, Alexander Potapenko wrote:
> > > When passed to an allocator (either pagealloc or SL[AOU]B),
> > > __GFP_NO_AUTOINIT tells it to not initialize the requested memory if the
> > > init_on_alloc boot option is enabled. This can be useful in the cases
> > > newly allocated memory is going to be initialized by the caller right
> > > away.
> > >
> > > __GFP_NO_AUTOINIT doesn't affect init_on_free behavior, except for SLOB,
> > > where init_on_free implies init_on_alloc.
> > >
> > > __GFP_NO_AUTOINIT basically defeats the hardening against information
> > > leaks provided by init_on_alloc, so one should use it with caution.
> > >
> > > This patch also adds __GFP_NO_AUTOINIT to alloc_pages() calls in SL[AOU]B.
> > > Doing so is safe, because the heap allocators initialize the pages they
> > > receive before passing memory to the callers.
> >
> > I still do not like the idea of a new gfp flag as explained in the
> > previous email. People will simply use it incorectly or arbitrarily.
> > We have that juicy experience from the past.
> 
> Just to preserve some context, here's the previous email:
> https://patchwork.kernel.org/patch/10907595/
> (plus the patch removing GFP_TEMPORARY for the curious ones:
> https://lwn.net/Articles/729145/)

Not only. GFP_REPEAT being another one and probably others I cannot
remember from the top of my head.

> > Freeing a memory is an opt-in feature and the slab allocator can already
> > tell many (with constructor or GFP_ZERO) do not need it.
> Sorry, I didn't understand this piece. Could you please elaborate?

The allocator can assume that caches with a constructor will initialize
the object so additional zeroying is not needed. GFP_ZERO should be self
explanatory.

> > So can we go without this gfp thing and see whether somebody actually
> > finds a performance problem with the feature enabled and think about
> > what can we do about it rather than add this maint. nightmare from the
> > very beginning?
> 
> There were two reasons to introduce this flag initially.
> The first was double initialization of pages allocated for SLUB.

Could you elaborate please?

> However the benchmark results provided in this and the previous patch
> don't show any noticeable difference - most certainly because the cost
> of initializing the page is amortized.

> The second one was to fine-tune hackbench, for which the slowdown
> drops by a factor of 2.
> But optimizing a mitigation for certain benchmarks is a questionable
> measure, so maybe we could really go without it.

Agreed. Over optimization based on an artificial workloads tend to be
dubious IMHO.

-- 
Michal Hocko
SUSE Labs

