Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 802A1C48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:55:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52E6220665
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:55:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52E6220665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAB806B0008; Fri, 21 Jun 2019 11:54:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5C0E8E0005; Fri, 21 Jun 2019 11:54:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C254C8E0002; Fri, 21 Jun 2019 11:54:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 78C8A6B0008
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 11:54:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so9735349edv.16
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:54:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4gfTGugbp82eE8puXCzw34engT4+sr54Lbh8rBuxtqs=;
        b=R2ZgTOxl1M2ZHG6/vCol25OAbiDBGhGjpWyC443Xuqd9pTwp5GQhP2tfsBCHjTfBM+
         wkVdljUJV0S6Pa9VtGkzpBKNw+jl4OPA52ULrWmr7/zTguGbqJNh0vdD6shdfOEtwPqc
         oBD3cSJqvzFIzZ8JkdvpnymWeFpnSNykC8ksy2KDaLCr2HQTVd9WdjQaoZ/Ghj78Vaqu
         7LqPwcvNyxnrbXpAxO2vPPNMedPINsUHX5squHDwSkXFCq75i9BmuuXCS1j55yU6341j
         gtt+zD45glHCmlKBoPgk/dFVWn3zfsy/2QNARm5Aezz6rVbNRzMU6lWZFbt2Vh+Nb75O
         iBuw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVJNuQCx7lyB4TqbqdhHz10IxH0yuHfR8r6NATNq80VitvcUjWW
	KiI8mPzERDRI/GjuCm8SX738mixUwlmAYNxzrDbdBR7GeSohBuGbqcDmpDSJUIHP9kAu+8mZRaV
	ujIZmOaZWpNd/QFufeytUhAqm+QJAXlAgBJLMIoa9zHwcwYkXeCr5M8ALv31Zc7g=
X-Received: by 2002:a50:ac12:: with SMTP id v18mr122596179edc.232.1561132499051;
        Fri, 21 Jun 2019 08:54:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydFYzCQsDVdEOc2tw+dqy8gLnpC1EtD+DUAK91ZzNtLZ3RpI+UZFyTRWfHHcjB9YtPNGTg
X-Received: by 2002:a50:ac12:: with SMTP id v18mr122596114edc.232.1561132498288;
        Fri, 21 Jun 2019 08:54:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561132498; cv=none;
        d=google.com; s=arc-20160816;
        b=MnPlUFZOwWSDHVzy6XTY3hZ0Z2anJnBJ8f2qfZcLuZ3VVInAWvY5fUx0SEEQcutGQu
         FGa44fEPzFE2JhgA8reHtuo9m6EDUFGoNFPcYh1d0X9JuArIhU1gcbvGdkKXrmiF6ZaY
         bPW/UKOUZ/BPVFOmFWnMG87TChBhRmmsQeE+YNUsBdk+YUX4CAzK6u3Gt5qf0HqPHqBy
         W5F15RF9+6zT4mBIbw3GIAgALhutgKSX8I3WSAXxPeRz9XurO6iEF/FPug9ouVGqp/Ib
         17Gkc2LQGAiCWZ0rvAWtMELFgm2FSOVKHhbyCC+EEv5/ZmLReTreluQTDOI8Gx6pykdV
         Ck2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4gfTGugbp82eE8puXCzw34engT4+sr54Lbh8rBuxtqs=;
        b=SpMBFci0sSuW/MVcE42ZSL+glJM20HfSM9rnaO7RCEck793y0hg/KA0NuVVMdkAeSf
         /XXbgrLtAqGdyIAsweVLkiJEVIn3xyBqtfElG6NBtfQ2vbm17OBtnp3rf4cP/wNSs6F9
         LVIklu+04y/NSkmXK4ChUUj4WZw0Bv18kVQNS6NuJwJfm5kWcp5kMuLdkEDkM+QPjbko
         gP8wq183Zrg7wcgLE3eMZ4rtf2ktcv5nsH+kK7we6SqR149jRV7Ym1n3EzBA4JxdyHCQ
         0X0X4dwibFC3eYUhCM5IidkvbNWTBlmhrkFPJdse+H+COmO0IfRmII1DerrLToxqSVL8
         mLIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m57si2863798edd.12.2019.06.21.08.54.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 08:54:58 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5EDC2AFF4;
	Fri, 21 Jun 2019 15:54:57 +0000 (UTC)
Date: Fri, 21 Jun 2019 17:54:55 +0200
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
Message-ID: <20190621155455.GG3429@dhcp22.suse.cz>
References: <20190617151050.92663-1-glider@google.com>
 <20190617151050.92663-2-glider@google.com>
 <20190621070905.GA3429@dhcp22.suse.cz>
 <CAG_fn=UFj0Lzy3FgMV_JBKtxCiwE03HVxnR8=f9a7=4nrUFXSw@mail.gmail.com>
 <CAG_fn=W90HNeZ0UcUctnbUBzJ=_b+gxMGdUoDyO3JPoyy4dGSg@mail.gmail.com>
 <20190621151210.GF3429@dhcp22.suse.cz>
 <CAG_fn=W2fm5zkAUW8PcTYpfH57H89ukFGAoBHUOmyM-S1agdZg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=W2fm5zkAUW8PcTYpfH57H89ukFGAoBHUOmyM-S1agdZg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 21-06-19 17:24:21, Alexander Potapenko wrote:
> On Fri, Jun 21, 2019 at 5:12 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 21-06-19 16:10:19, Alexander Potapenko wrote:
> > > On Fri, Jun 21, 2019 at 10:57 AM Alexander Potapenko <glider@google.com> wrote:
> > [...]
> > > > > > diff --git a/mm/dmapool.c b/mm/dmapool.c
> > > > > > index 8c94c89a6f7e..e164012d3491 100644
> > > > > > --- a/mm/dmapool.c
> > > > > > +++ b/mm/dmapool.c
> > > > > > @@ -378,7 +378,7 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
> > > > > >  #endif
> > > > > >       spin_unlock_irqrestore(&pool->lock, flags);
> > > > > >
> > > > > > -     if (mem_flags & __GFP_ZERO)
> > > > > > +     if (want_init_on_alloc(mem_flags))
> > > > > >               memset(retval, 0, pool->size);
> > > > > >
> > > > > >       return retval;
> > > > >
> > > > > Don't you miss dma_pool_free and want_init_on_free?
> > > > Agreed.
> > > > I'll fix this and add tests for DMA pools as well.
> > > This doesn't seem to be easy though. One needs a real DMA-capable
> > > device to allocate using DMA pools.
> > > On the other hand, what happens to a DMA pool when it's destroyed,
> > > isn't it wiped by pagealloc?
> >
> > Yes it should be returned to the page allocator AFAIR. But it is when we
> > are returning an object to the pool when you want to wipe the data, no?
> My concern was that dma allocation is something orthogonal to heap and
> page allocator.
> I also don't know how many other allocators are left overboard, e.g.
> we don't do anything to lib/genalloc.c yet.

Well, that really depends what would you like to achieve by this
functionality. There are likely to be all sorts of allocators on top of
the core ones (e.g. mempool allocator). The question is whether you
really want to cover them all. Are they security relevant?

> > Why cannot you do it along the already existing poisoning?
> I can sure keep these bits.
> Any idea how the correct behavior of dma_pool_alloc/free can be tested?

Well, I would say that you have to rely on the review process here more
than any specific testing. In any case other allocators can be handled
incrementally. This is not all or nothing kinda stuff. I have pointed
out dma_pool because it only addresses one half of the work and it was
not clear why. If you want to drop dma_pool then this will be fine by
me. As this is a hardening feature you want to get coverage as large as
possible rather than 100%.

-- 
Michal Hocko
SUSE Labs

