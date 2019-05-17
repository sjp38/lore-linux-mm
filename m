Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E36F4C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:01:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0A8A20873
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:01:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0A8A20873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25ED76B0005; Fri, 17 May 2019 10:01:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20DC66B0006; Fri, 17 May 2019 10:01:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D6BD6B0007; Fri, 17 May 2019 10:01:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B70256B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 10:01:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g36so10864608edg.8
        for <linux-mm@kvack.org>; Fri, 17 May 2019 07:01:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NB1cq8zZpFASXPyLo69JYKNUdcP82wH7trmE42ZkrbE=;
        b=oPCsbK8F0q/ACjPH7eXNF2zqiqo8i5jNrfJgpdszl7YdIBA2Vr0g7BtOieD3mIAWgL
         BrhxOevRG0QV6I1Koylp6kjCyv7g+aqr5CDySL9XOePjAkdNmva2jxONJB6S4iMWV/jO
         fXImxO7tKIDQLo5AXgzP4/JKdqQwbsFsMUdtCLrNyB2Jyek2ZUmN04tXdL6a5MkTj1cF
         Zipfps8y96h1/RC2FvjSsT8voZ1sHzJeRpMfZtgQc6DSruCGQ2adtBeJ0sE5iEEq78IL
         Oj3zAez8jJjLKdQrrYZknLAZ8nPVp+pCg1u4c5q87+YGnw3K/CYy+3x2WBn8ee141ZIv
         SQlA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUChDydL+2Sto7akBR4e4kixdcbiNdIvAwiSbiqo9PUweEAwYbm
	2WAEEHhI4TphsTIKQQXBSAMLKgNt9yKWPWcesburGSlKP5/ckVAGCf8dM5eSsSTGRQVSBsQ6pMt
	u9NF9WKG7tQALGgcbR8JMVTOziEGFjH0KaRpwTCrfsh7P/hA9YTLvaoxFWCgcfEE=
X-Received: by 2002:a50:ae84:: with SMTP id e4mr58465242edd.33.1558101674796;
        Fri, 17 May 2019 07:01:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpWhvzfnbNN6RIYBMbBWOjDw0GPFBFl2RraTHuKayEObTl8jis3zUsUcg0zdIgNABSQVhE
X-Received: by 2002:a50:ae84:: with SMTP id e4mr58465082edd.33.1558101673447;
        Fri, 17 May 2019 07:01:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558101673; cv=none;
        d=google.com; s=arc-20160816;
        b=rIClt8M4zjOpxrYeKGNEoE6kcUh/2USerdpxnONr+qamxj+hjkh48vzk7ZFEqnQ69p
         BF0h7Hdz77vI8cu7RXPNp2DCH/Mu1Q4KdEN72qmICo+wLhDbMdchz2izecNphdAAYzOG
         QwlpOdSvSLdNLlXrybrn+Z/K/GMDyB3mWHlr510mrRPP/gCcFJFuUAXZxmOSzFnaSv9J
         pXZ8wRZQ9CdGOYvDExWSfXs7GSpP5+cNcIBnudvw9YR/ZrAyES5qJvxtJgTDt50sqyLT
         Qhf9c9g61IJe/riRoO9uBTeZ5Q8HzrHmZw6KYWnqUNg4zvA+84oM8vDT3HesdDfzANaG
         Nmqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NB1cq8zZpFASXPyLo69JYKNUdcP82wH7trmE42ZkrbE=;
        b=p0DgBOsJnC9Nf06wMQ1I/EbbGO6nBOAOiCnelqL0BYfm4V0TPpSbrrX9htAGpr5spL
         hed1nX8+z7lYH5r2bkyMYDJjwXmVYg5eYp4qBxCRkrbLvPoNBg0A4wWizRHZpjuXWQBe
         2i92YkgZRBbj0YkP95vYsrvONakCuhn373Gcms0cDIYOO4iIB6nsJz8wk2154HpYVHO9
         GLDxnB/FzPRAv+Mt5VwFgefw6UAEhQRUWPFfb/J0CBGcgUBqM1vG6mJUBroOYLnzVzd7
         HieIy0D0Myag8B/QSTcODZToHK9zDABC/d4MURtwYxgjuN5F4LzKUYMqxAGvUVSBkZIn
         29tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3si5562178ejb.301.2019.05.17.07.01.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 07:01:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3B69CAF85;
	Fri, 17 May 2019 14:01:12 +0000 (UTC)
Date: Fri, 17 May 2019 16:01:08 +0200
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
Message-ID: <20190517140108.GK6836@dhcp22.suse.cz>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-4-glider@google.com>
 <20190517125916.GF1825@dhcp22.suse.cz>
 <CAG_fn=VG6vrCdpEv0g73M-Au4wW07w8g0uydEiHA96QOfcCVhA@mail.gmail.com>
 <20190517132542.GJ6836@dhcp22.suse.cz>
 <CAG_fn=Ve88z2ezFjV6CthufMUhJ-ePNMT2=3m6J3nHWh9iSgsg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=Ve88z2ezFjV6CthufMUhJ-ePNMT2=3m6J3nHWh9iSgsg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 17-05-19 15:37:14, Alexander Potapenko wrote:
> On Fri, May 17, 2019 at 3:25 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 17-05-19 15:18:19, Alexander Potapenko wrote:
> > > On Fri, May 17, 2019 at 2:59 PM Michal this flag Hocko
> > > <mhocko@kernel.org> wrote:
> > > >
> > > > [It would be great to keep people involved in the previous version in the
> > > > CC list]
> > > Yes, I've been trying to keep everyone in the loop, but your email
> > > fell through the cracks.
> > > Sorry about that.
> >
> > No problem
> >
> > > > On Tue 14-05-19 16:35:36, Alexander Potapenko wrote:
> > > > > When passed to an allocator (either pagealloc or SL[AOU]B),
> > > > > __GFP_NO_AUTOINIT tells it to not initialize the requested memory if the
> > > > > init_on_alloc boot option is enabled. This can be useful in the cases
> > > > > newly allocated memory is going to be initialized by the caller right
> > > > > away.
> > > > >
> > > > > __GFP_NO_AUTOINIT doesn't affect init_on_free behavior, except for SLOB,
> > > > > where init_on_free implies init_on_alloc.
> > > > >
> > > > > __GFP_NO_AUTOINIT basically defeats the hardening against information
> > > > > leaks provided by init_on_alloc, so one should use it with caution.
> > > > >
> > > > > This patch also adds __GFP_NO_AUTOINIT to alloc_pages() calls in SL[AOU]B.
> > > > > Doing so is safe, because the heap allocators initialize the pages they
> > > > > receive before passing memory to the callers.
> > > >
> > > > I still do not like the idea of a new gfp flag as explained in the
> > > > previous email. People will simply use it incorectly or arbitrarily.
> > > > We have that juicy experience from the past.
> > >
> > > Just to preserve some context, here's the previous email:
> > > https://patchwork.kernel.org/patch/10907595/
> > > (plus the patch removing GFP_TEMPORARY for the curious ones:
> > > https://lwn.net/Articles/729145/)
> >
> > Not only. GFP_REPEAT being another one and probably others I cannot
> > remember from the top of my head.
> >
> > > > Freeing a memory is an opt-in feature and the slab allocator can already
> > > > tell many (with constructor or GFP_ZERO) do not need it.
> > > Sorry, I didn't understand this piece. Could you please elaborate?
> >
> > The allocator can assume that caches with a constructor will initialize
> > the object so additional zeroying is not needed. GFP_ZERO should be self
> > explanatory.
> Ah, I see. We already do that, see the want_init_on_alloc()
> implementation here: https://patchwork.kernel.org/patch/10943087/
> > > > So can we go without this gfp thing and see whether somebody actually
> > > > finds a performance problem with the feature enabled and think about
> > > > what can we do about it rather than add this maint. nightmare from the
> > > > very beginning?
> > >
> > > There were two reasons to introduce this flag initially.
> > > The first was double initialization of pages allocated for SLUB.
> >
> > Could you elaborate please?
> When the kernel allocates an object from SLUB, and SLUB happens to be
> short on free pages, it requests some from the page allocator.
> Those pages are initialized by the page allocator

... when the feature is enabled ...

> and split into objects. Finally SLUB initializes one of the available
> objects and returns it back to the kernel.
> Therefore the object is initialized twice for the first time (when it
> comes directly from the page allocator).
> This cost is however amortized by SLUB reusing the object after it's been freed.

OK, I see what you mean now. Is there any way to special case the page
allocation for this feature? E.g. your implementation tries to make this
zeroying special but why cannot you simply do this


struct page *
____alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
							nodemask_t *nodemask)
{
	//current implementation
}

struct page *
__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
							nodemask_t *nodemask)
{
	if (your_feature_enabled)
		gfp_mask |= __GFP_ZERO;
	return ____alloc_pages_nodemask(gfp_mask, order, preferred_nid,
					nodemask);
}

and use ____alloc_pages_nodemask from the slab or other internal
allocators?
-- 
Michal Hocko
SUSE Labs

