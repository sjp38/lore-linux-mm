Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A09F1C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 10:11:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63DFF20659
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 10:11:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63DFF20659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F1A18E0061; Thu, 25 Jul 2019 06:11:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07B568E0059; Thu, 25 Jul 2019 06:11:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E83BB8E0061; Thu, 25 Jul 2019 06:11:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 990578E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 06:11:20 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n3so31829721edr.8
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 03:11:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=u7tKf+2NnKOmU/uZV2Hb861aUCGvvOIpkxVrUNbnFHc=;
        b=remn/N9ul7LwAUHvg5FcUWJSJCLm1J4jcssgDK8LsefGRFjO+eXVaO8S5RIjUgp93n
         PRYzCAdreB9aGEoUceQVwmNd+1U0fZFps8K3kQ2Pw6/QsmNAeHQJmpuXjFtLPgndpACw
         ljUai+CeotUICYkWDwl4j2kMBx5fxvhcpuJm+7IvqqhZEIQUONld5fUf9A/oqWQnxeEz
         46DBx0fD+lVstbVHZZtHCOtgEx/ZqozIwBRwiQhWZHRxzX1t7t5H20g60dQLhrLAItPI
         vZZNxYwLgTl+aILVGqUuGK2oAd0pcbmeTgfoLDF2bTBIyQGX+3sI2LwOFn8R2dabx5lr
         6QUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAXSTRo28/ctRwZSAKtPk4gIvuCL14GItOP+paygpG4FKdYaulG0
	XTGNnvzpLkgMg5MFOSkOJrIqxSryC3V8p1iLQ4hP+EPZMbkKXj34va5jje15552hEdpZJycMxg+
	r7XmxArC+U1mZfNnpsSdXTxRLTu0utQrvbRYDK5YhLdRo3Nc7YK8esG988M9XO7/PKw==
X-Received: by 2002:a17:906:81cb:: with SMTP id e11mr66163855ejx.37.1564049480180;
        Thu, 25 Jul 2019 03:11:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8Lp7MEmlGFaGwAJ4xzZK2ofYfatXuukGjHIMHpwPY1B3/pQjgYEoVGqB4/2VfTaLqZ5dv
X-Received: by 2002:a17:906:81cb:: with SMTP id e11mr66163799ejx.37.1564049479408;
        Thu, 25 Jul 2019 03:11:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564049479; cv=none;
        d=google.com; s=arc-20160816;
        b=t7evs1E+NSMciWHKJjoYSf70Nh42RQE20kkoS4mj7fUH4qtYtpdo6xVUqDH/MLwGbk
         HokIJiED9Um2JR/pWb5GPyWNXTc/upajGXwJMjmMeYC0oqBhEJdq0vSFZJz7AIouT4Ic
         ZSRIzRKHhuw6O4mvdc0bDQLZf2T1//+rt4roct9p5HPkqBmTk51iWOwMadtJ01NPoWhK
         Q1W0SDZ8pn+M/ZcMlxwkiRw7H9GztGigF2RC5oAclE4Zq0reXv4zDQho1KDGdXkYGOPy
         kN9utzIkFSsC74efwRbwQN7B5SLFzA9Zw1attm5tyV5fGwZ+yuNWCeNACoOAEnL28O5P
         nzYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=u7tKf+2NnKOmU/uZV2Hb861aUCGvvOIpkxVrUNbnFHc=;
        b=swK8U+TP9MNlfm0yif52ypn36FXHjUEVnB2qHjQ3xxFS2QezroInk/uvos0B3hf9rW
         FU86K8aPI4zFoCM3xtNvGvgiiysfR0zvQg5LMaSaqXi7VqX+LGYA1tW0Dcq4f02dovEk
         YJOahWEOEdh2AwUz7Ozq9snaBy+jMnQnsIdaazRLdAAWI/hM4IrNWjj4O1OICjVItx06
         69Jrs7n9AJRoRN41Gmr3yaXINKecB8sL6HU0eaKjT5YvTrwNGQdiZo7ejVXHwW1WaMJr
         77AIzNckmWmFpLzaBHfKds+Mygrr6TdC0hN3eunZupkmJdd8VxChegsi0eiQc0TgGR1E
         TFRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id x58si10061161eda.238.2019.07.25.03.11.19
        for <linux-mm@kvack.org>;
        Thu, 25 Jul 2019 03:11:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 49C53344;
	Thu, 25 Jul 2019 03:11:18 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0A9883F694;
	Thu, 25 Jul 2019 03:11:16 -0700 (PDT)
Date: Thu, 25 Jul 2019 11:11:14 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Marco Elver <elver@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>,
	kasan-dev <kasan-dev@googlegroups.com>,
	Linux-MM <linux-mm@kvack.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH 1/3] kasan: support backing vmalloc space with real
 shadow memory
Message-ID: <20190725101114.GB14347@lakrids.cambridge.arm.com>
References: <20190725055503.19507-1-dja@axtens.net>
 <20190725055503.19507-2-dja@axtens.net>
 <CACT4Y+Yw74otyk9gASfUyAW_bbOr8H5Cjk__F7iptrxRWmS9=A@mail.gmail.com>
 <CACT4Y+Z3HNLBh_FtevDvf2fe_BYPTckC19csomR6nK42_w8c1Q@mail.gmail.com>
 <CANpmjNNhwcYo-3tMkYPGrvSew633FQW7fCUiTgYUp7iKYY7fpw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANpmjNNhwcYo-3tMkYPGrvSew633FQW7fCUiTgYUp7iKYY7fpw@mail.gmail.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 12:06:46PM +0200, Marco Elver wrote:
> On Thu, 25 Jul 2019 at 09:51, Dmitry Vyukov <dvyukov@google.com> wrote:
> >
> > On Thu, Jul 25, 2019 at 9:35 AM Dmitry Vyukov <dvyukov@google.com> wrote:
> > >
> > > ,On Thu, Jul 25, 2019 at 7:55 AM Daniel Axtens <dja@axtens.net> wrote:
> > > >
> > > > Hook into vmalloc and vmap, and dynamically allocate real shadow
> > > > memory to back the mappings.
> > > >
> > > > Most mappings in vmalloc space are small, requiring less than a full
> > > > page of shadow space. Allocating a full shadow page per mapping would
> > > > therefore be wasteful. Furthermore, to ensure that different mappings
> > > > use different shadow pages, mappings would have to be aligned to
> > > > KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE.
> > > >
> > > > Instead, share backing space across multiple mappings. Allocate
> > > > a backing page the first time a mapping in vmalloc space uses a
> > > > particular page of the shadow region. Keep this page around
> > > > regardless of whether the mapping is later freed - in the mean time
> > > > the page could have become shared by another vmalloc mapping.
> > > >
> > > > This can in theory lead to unbounded memory growth, but the vmalloc
> > > > allocator is pretty good at reusing addresses, so the practical memory
> > > > usage grows at first but then stays fairly stable.
> > > >
> > > > This requires architecture support to actually use: arches must stop
> > > > mapping the read-only zero page over portion of the shadow region that
> > > > covers the vmalloc space and instead leave it unmapped.
> > > >
> > > > This allows KASAN with VMAP_STACK, and will be needed for architectures
> > > > that do not have a separate module space (e.g. powerpc64, which I am
> > > > currently working on).
> > > >
> > > > Link: https://bugzilla.kernel.org/show_bug.cgi?id=202009
> > > > Signed-off-by: Daniel Axtens <dja@axtens.net>
> > >
> > > Hi Daniel,
> > >
> > > This is awesome! Thanks so much for taking over this!
> > > I agree with memory/simplicity tradeoffs. Provided that virtual
> > > addresses are reused, this should be fine (I hope). If we will ever
> > > need to optimize memory consumption, I would even consider something
> > > like aligning all vmalloc allocations to PAGE_SIZE*KASAN_SHADOW_SCALE
> > > to make things simpler.
> > >
> > > Some comments below.
> >
> > Marco, please test this with your stack overflow test and with
> > syzkaller (to estimate the amount of new OOBs :)). Also are there any
> > concerns with performance/memory consumption for us?
> 
> It appears that stack overflows are *not* detected when KASAN_VMALLOC
> and VMAP_STACK are enabled.
> 
> Tested with:
> insmod drivers/misc/lkdtm/lkdtm.ko cpoint_name=DIRECT cpoint_type=EXHAUST_STACK

Could you elaborate on what exactly happens?

i.e. does the test fail entirely, or is it detected as a fault (but not
reported as a stack overflow)?

If you could post a log, that would be ideal!

Thanks,
Mark.

