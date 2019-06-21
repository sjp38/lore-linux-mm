Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98D57C48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:12:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67263206B7
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:12:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67263206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 011928E0003; Fri, 21 Jun 2019 11:12:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F03378E0001; Fri, 21 Jun 2019 11:12:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCC528E0003; Fri, 21 Jun 2019 11:12:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9146D8E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 11:12:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i9so9594094edr.13
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:12:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=z3Pct2Z4Qnhh353z2nOFhuGdqMf6mKmIXrxjjfvx8so=;
        b=DsvvQT0WGulXUzizhe8ylV0x7C14ajoeS5xXUuKvkizXS4ZvPaYtEtbtU7qyjW+oK4
         juQKDtSZikalyy8Mn1wHY4/HBVEXY/98CIc5YBMhFdymAFtziTNWuOZS6J3K9FQhzfTo
         QOhwstxm7/mqW2fiAmUYzcsjHRm8hPLFBd9T3kBcZLe9eCHzcAeE8RnOuEAtG2ywy3uy
         SWM05Dco62T6BqnfZO/2yZAUJ15TNQJJQ+ZMbv3OEwjKr6TJCbQo75gzx0zXDQC6ic/U
         gp+doBR0yZGE1YM1cT6xJmWI0J8Gek7xW/zgSjLw36QGOUKupxUnK3h1vRwdq9+pBCf7
         NdhQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVViMgWpXTaW4pSK5rV1EWsxdggkwoa+9fzI1zJJHzoWtLLaMxb
	e672qw7E4o3my9mXMG64ENJn7aIwcbfzEAi7OWjJuLg0VpmQAFvc4BJwvv+XP5vfvHWYoQGL36F
	+XuQkKdreAFO3yPWhnE/qME5BB3Ol0iLd/MoeR7gbSOTl5SnsuGK0S/67GmGCR/Y=
X-Received: by 2002:a50:b7e2:: with SMTP id i31mr98985331ede.229.1561129935120;
        Fri, 21 Jun 2019 08:12:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBpgRaYMhceLaFCvuWwQ9buS5G39NtXgokh90PdZ4+g2piWhKBbKph8gbyL0/wlDlwNgAm
X-Received: by 2002:a50:b7e2:: with SMTP id i31mr98985247ede.229.1561129934413;
        Fri, 21 Jun 2019 08:12:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561129934; cv=none;
        d=google.com; s=arc-20160816;
        b=pdA06haKXG+zV363cUt1+uuLf2vq3V+F7YpYIubh4q9hDbKqmP6W/SVQZejXJ6TC7q
         bKMrQqn6LrFRzqnn0PdhVL19gEUo+xy4ykihavnGqvWBIEnlSl8/1D8jbJn8Qc4MjGPO
         cJw3Dj3LmgxChYHooawop1lI5C+uA1VOCLDd772tyLxajnIYzJIcf6YN1eflf4gaG8J+
         nmRiudy69aPenHOolZTTeSJn7weolShx6K30Y/azYBXdxga0emEkGnSHigmL38iTIN9N
         DrZqgnD4Q36ktRUNmsn54RSGAIqGrUilkTJF31DjDJ+fKPF+ZrQoJ2Zvm8cCz5GhwtsP
         ukSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=z3Pct2Z4Qnhh353z2nOFhuGdqMf6mKmIXrxjjfvx8so=;
        b=Gx5lWn0xsHByBAm0q7JDHTeQX4MnmM/YE9sBhI1XZY84oWDA/iEDiUouw36SBZ1n8m
         IibkGc/5AojA2gbZNoXEWotxU84KJuC/Tjphxu501CkX/zOj6z5wc2zYJH3LDPssASu2
         +eLa/mgFrqkJXcp7QTuEb3lMpxdly/4SpzIdpeGL3ab//MVBJB8pAfcw0NWY/vdtNnIx
         2v8XqGd9JiMgq7pCHF4XfjN+TEG2rMkKT3610v9hRz9heV6DFW2Du6sTLcrQTOmXDRIi
         huG2MOjUJP51LfEtHS+Eg46Z8zNW4vn8Auil1gFly6bDXRU9UvDRqBBTsDJlZWqx39up
         ooYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n12si1959621ejr.105.2019.06.21.08.12.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 08:12:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 863DAABB1;
	Fri, 21 Jun 2019 15:12:13 +0000 (UTC)
Date: Fri, 21 Jun 2019 17:12:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Subject: Re: [PATCH v7 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <20190621151210.GF3429@dhcp22.suse.cz>
References: <20190617151050.92663-1-glider@google.com>
 <20190617151050.92663-2-glider@google.com>
 <20190621070905.GA3429@dhcp22.suse.cz>
 <CAG_fn=UFj0Lzy3FgMV_JBKtxCiwE03HVxnR8=f9a7=4nrUFXSw@mail.gmail.com>
 <CAG_fn=W90HNeZ0UcUctnbUBzJ=_b+gxMGdUoDyO3JPoyy4dGSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=W90HNeZ0UcUctnbUBzJ=_b+gxMGdUoDyO3JPoyy4dGSg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 21-06-19 16:10:19, Alexander Potapenko wrote:
> On Fri, Jun 21, 2019 at 10:57 AM Alexander Potapenko <glider@google.com> wrote:
[...]
> > > > diff --git a/mm/dmapool.c b/mm/dmapool.c
> > > > index 8c94c89a6f7e..e164012d3491 100644
> > > > --- a/mm/dmapool.c
> > > > +++ b/mm/dmapool.c
> > > > @@ -378,7 +378,7 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
> > > >  #endif
> > > >       spin_unlock_irqrestore(&pool->lock, flags);
> > > >
> > > > -     if (mem_flags & __GFP_ZERO)
> > > > +     if (want_init_on_alloc(mem_flags))
> > > >               memset(retval, 0, pool->size);
> > > >
> > > >       return retval;
> > >
> > > Don't you miss dma_pool_free and want_init_on_free?
> > Agreed.
> > I'll fix this and add tests for DMA pools as well.
> This doesn't seem to be easy though. One needs a real DMA-capable
> device to allocate using DMA pools.
> On the other hand, what happens to a DMA pool when it's destroyed,
> isn't it wiped by pagealloc?

Yes it should be returned to the page allocator AFAIR. But it is when we
are returning an object to the pool when you want to wipe the data, no?
Why cannot you do it along the already existing poisoning?
-- 
Michal Hocko
SUSE Labs

