Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F122DC04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 16:13:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6A012087E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 16:13:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="dxB5PWDK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6A012087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A7376B0006; Fri, 17 May 2019 12:13:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 356796B0008; Fri, 17 May 2019 12:13:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21D6D6B000A; Fri, 17 May 2019 12:13:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB94C6B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 12:13:18 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 14so4698377pgo.14
        for <linux-mm@kvack.org>; Fri, 17 May 2019 09:13:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=m02iPOvo556PAupUnS9qzquFGaL67NVm3EjfgL2dy5A=;
        b=R0Gj64vNlBhAZhLhQCF0XDrpvkTc0Ojw7FYo0T0qBQ/h2WOGUj78sVHelxfxylhetB
         tH2kNRj9ngggsQcHjqORlqgpkFUUsT1v8tzceGuUIIXh4nP0zmcYFcKTAI9+zahY++C1
         1rzSGr+zmJl4O8ykuWSshz7w9xlaczsbLWXKiL9z/vVZwpMaGdCU/TDLes9dEiUobVAg
         1LXApYdN0RGWkxph3hkL3BDJI36+N06mApqMwlJdrZM6DyUfgyvZ4OS5vvKBXVypZ9sA
         aV6XvnVDQmZJ5VF1E5ScEBDQx/jZ0mBFFM00VMu5PNh3fWvmeCBtHp/INFTXlY8PIDHX
         UbSQ==
X-Gm-Message-State: APjAAAUhrS1rYlOMUVRQTQKlHEJ0DkDXt/03YhvDnFlQyY6yer1eDfFz
	sf7Jg6UnJLdUVb/S73cytUguNW/gMoEYP6JI9EBoIhSqLnw0TA7BbwunTy3XlTznXBqVERZAzgU
	EWFGvDEZieDjCMIZBe15tVlPoqTajoQWuPGI8FKo42Xklmg1XCPBDlcNA32cGC7iGrA==
X-Received: by 2002:a17:902:2beb:: with SMTP id l98mr55869493plb.290.1558109598449;
        Fri, 17 May 2019 09:13:18 -0700 (PDT)
X-Received: by 2002:a17:902:2beb:: with SMTP id l98mr55869411plb.290.1558109597423;
        Fri, 17 May 2019 09:13:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558109597; cv=none;
        d=google.com; s=arc-20160816;
        b=XsGmPwF6gmGkClHK3yzX+lZTuut09XMjwBxOTf2+lRdGkFomtda6pp3jLuz0fYqi66
         m0VvFn9ReAjAf+a6LBfEv9pgQVBkBsOTfWeEigww1erCdD0Trf5MWgD4tMsiwl3G/jIt
         yHe0LNvrK7L/P3aZGP/I5H1BVkde7Qjg1OfqDyGwxwOjam6uOL4rlcIcXqiacNW01aAJ
         S1mdSRkGrdvuS2qGEcR8KTUzUtBWHzO9KNgs5fe02HSZ68sqlwzJFk+wAnM4cVqMSAPK
         NuKPetaubHaVPHYLTkC/IX7Zv4G2MSmcm/US+sYV7L8djxPD8kAHKWGxFLB050CnWAPS
         HxTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=m02iPOvo556PAupUnS9qzquFGaL67NVm3EjfgL2dy5A=;
        b=FKz9geO5RLF+i03cnAIdfZhnkA+HwofhG+PcSVfcdRSk6dzOnLgGxyKooz03QqmUc+
         slSdTgjq4tF+nxABzUKe/P3dbmpHnQPb3cUJK4CvU47uGXGmbfwWb3/nsOeLOxxcTDbK
         C+ruciv3q+EwhutCn7MXCNxtypKy93LtfknLdqmIutDwFu6X6rcjrmtNfo9zHJShXzF3
         o2SzyUYSH05HLV2geC4IVQZKmcZaOK0NXuVUWHAHTwpcKgE0cQ0VgPIy9YJBGcUjacw9
         3jv0HxnvzqSVAuYYfrqB2HfV9ZlsjP/0+UMXjXpTWUWjh4+/+Rd33l0y1ccgA6NHiOzo
         27NQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=dxB5PWDK;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ce5sor10044309plb.17.2019.05.17.09.13.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 09:13:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=dxB5PWDK;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=m02iPOvo556PAupUnS9qzquFGaL67NVm3EjfgL2dy5A=;
        b=dxB5PWDK5Ubq2UYGrAtUPASDCX1nBouaHJnYPPCDht/KwMlctyK5LwRI6KbDJjVvbI
         HqXHsPePvPX1QWUDr1d9ekMHs0Zj5byZfC4wEAdxVtQcEXr/Wtj5v6/zHjqcimjzICBF
         Yvt8t2d/Y9dZzZnkJh8xnV/qjGuh6UppseOIg=
X-Google-Smtp-Source: APXvYqzxdYYkC4Vm6qLkhkpXpaHS6hS+/bNgbbir5gqCgNKRQ20zMhl2VQQoGk52iRa1FhEBt45aSg==
X-Received: by 2002:a17:902:8214:: with SMTP id x20mr35601151pln.308.1558109597070;
        Fri, 17 May 2019 09:13:17 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id 37sm13381620pgn.21.2019.05.17.09.13.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 17 May 2019 09:13:16 -0700 (PDT)
Date: Fri, 17 May 2019 09:13:14 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
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
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH v2 4/4] net: apply __GFP_NO_AUTOINIT to AF_UNIX sk_buff
 allocations
Message-ID: <201905170900.BFA80ED@keescook>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-5-glider@google.com>
 <201905160923.BD3E530EFC@keescook>
 <201905161714.A53D472D9@keescook>
 <CAG_fn=Vj6Jk_DY_-0+x6EpbsVh+abpEVcjycBhJxeMH3wuy9rw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=Vj6Jk_DY_-0+x6EpbsVh+abpEVcjycBhJxeMH3wuy9rw@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 10:49:03AM +0200, Alexander Potapenko wrote:
> On Fri, May 17, 2019 at 2:26 AM Kees Cook <keescook@chromium.org> wrote:
> > On Thu, May 16, 2019 at 09:53:01AM -0700, Kees Cook wrote:
> > > On Tue, May 14, 2019 at 04:35:37PM +0200, Alexander Potapenko wrote:
> > > > Add sock_alloc_send_pskb_noinit(), which is similar to
> > > > sock_alloc_send_pskb(), but allocates with __GFP_NO_AUTOINIT.
> > > > This helps reduce the slowdown on hackbench in the init_on_alloc mode
> > > > from 6.84% to 3.45%.
> > >
> > > Out of curiosity, why the creation of the new function over adding a
> > > gfp flag argument to sock_alloc_send_pskb() and updating callers? (There
> > > are only 6 callers, and this change already updates 2 of those.)
> > >
> > > > Slowdown for the initialization features compared to init_on_free=0,
> > > > init_on_alloc=0:
> > > >
> > > > hackbench, init_on_free=1:  +7.71% sys time (st.err 0.45%)
> > > > hackbench, init_on_alloc=1: +3.45% sys time (st.err 0.86%)
> >
> > So I've run some of my own wall-clock timings of kernel builds (which
> > should be an pretty big "worst case" situation, and I see much smaller
> > performance changes:
> How many cores were you using? I suspect the numbers may vary a bit
> depending on that.

I was using 4.

> > init_on_alloc=1
> >         Run times: 289.72 286.95 287.87 287.34 287.35
> >         Min: 286.95 Max: 289.72 Mean: 287.85 Std Dev: 0.98
> >                 0.25% faster (within the std dev noise)
> >
> > init_on_free=1
> >         Run times: 303.26 301.44 301.19 301.55 301.39
> >         Min: 301.19 Max: 303.26 Mean: 301.77 Std Dev: 0.75
> >                 4.57% slower
> >
> > init_on_free=1 with the PAX_MEMORY_SANITIZE slabs excluded:
> >         Run times: 299.19 299.85 298.95 298.23 298.64
> >         Min: 298.23 Max: 299.85 Mean: 298.97 Std Dev: 0.55
> >                 3.60% slower
> >
> > So the tuning certainly improved things by 1%. My perf numbers don't
> > show the 24% hit you were seeing at all, though.
> Note that 24% is the _sys_ time slowdown. The wall time slowdown seen
> in this case was 8.34%

Ah! Gotcha. Yeah, seems the impact for init_on_free is pretty
variable. The init_on_alloc appears close to free, though.

-- 
Kees Cook

