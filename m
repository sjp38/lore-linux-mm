Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCDC0C04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:11:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83D5F20848
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:11:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83D5F20848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2415F6B0006; Fri, 17 May 2019 13:11:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F1F96B0008; Fri, 17 May 2019 13:11:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BB576B000A; Fri, 17 May 2019 13:11:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B66766B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 13:11:18 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n23so11578343edv.9
        for <linux-mm@kvack.org>; Fri, 17 May 2019 10:11:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+4ze6Vjw9iqrs5snaXgX/vh42SSBU+Q84gO01wZY6oI=;
        b=SVNlK4r8qLFp9Bo265rHLXlIPJnEPjJi60LRIhZpkTltjvZNW8mil5SvBnPYjOdwys
         bPDTgelfXyXCQN/8F1QhKuMsv0HW8ZW4OwaRAwPwrLJVax6xgP5pOeJcGurBwVsMKERk
         wgavEhHZjfjfcB1t13ekTugEV9weTXaOiILhFnj0QSL0MCeRqLPvhMYDQbYyl/J/gYRi
         VE6F58+ZXoGGTx06/NHN4zMYH/Na3VckaMmVx3Kv8GetvNpQw6j6nNHgfyQ8Z6HQhuPR
         vEMcKSjX+tFsJpSn2E1VEJz7Ti66yQ6umkEe+ZqNxS8PL7eiHvFjZ+Abs9cG13ntMygP
         xe5Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXzxkU29nv+CpzWaReNjIxlB0aFX6lrRNafjo8ju7rr24CpnYET
	jXam0prWuLb9hu1bCI/ym0G0oJvGQ/mrKhVOzzoNZf3wfpDZEOcxFcfvmjAJkavG1dW/SzroHin
	CAFf7y6BrFQBDsf6/my/NH831TeQTuWWb5P1heaeMsZG+BRTMVPZ0VZ/kFTdhQnA=
X-Received: by 2002:a17:906:4ed1:: with SMTP id i17mr45497403ejv.118.1558113078296;
        Fri, 17 May 2019 10:11:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/NS53+GR7UGWnlOjckIXjvoZ4Ifi89ECmtw9luXtooBj7r2jpiEDrR8KKngUJaxagEy2r
X-Received: by 2002:a17:906:4ed1:: with SMTP id i17mr45497274ejv.118.1558113076633;
        Fri, 17 May 2019 10:11:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558113076; cv=none;
        d=google.com; s=arc-20160816;
        b=ss2Y6GVRldldBkGK+MSFkonZ88iKd+gXFzRKySPw45l2wQ5jgiMHammKZO7X8O28Va
         1FDgaDpdDp9OIIi2PPMwYBsHS1NSEmSnd05iQ8yvLJWLfw5c8L3P0U0XAyKfgEDAIHi/
         ywpozR3MEyCrBVOawT8fCcxqNostbiNJpBQ6jsnB2X0elMOeBFhZEVENWUANlTeRZO7F
         M5kE9XB1C5E4hQnVa8GJMEselvZncLWsqVPjIV4hzkNaafOye3j6EoLXxyK+/5J3GlwD
         zvVDdAGk4p3i9BXPz0mbNxXghbQWEAXHLdQ1Iah1VKlpc7JbPDHaU5zYuKQpH75hXseJ
         Zhjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+4ze6Vjw9iqrs5snaXgX/vh42SSBU+Q84gO01wZY6oI=;
        b=idZDt2jkgWVOX31bD0r6DJaHcfpgbibDW801ebSCmQreONtmtZMkJjh/04I87Aiwel
         ASMx8e5rOM47D+If/sgNigVkoUBEyNGMWVxgJq7BgH5ymcttjmK3oZeMAvG2GQ9a/zEO
         kf0LJM2TvWZWb1/+Puv3LYrtpekVANBNAxW5Vj4fdk9EMLAyGd1f+/eeXZRhYLX8xFxR
         PDKwidRyVPizEfhIaoLUMS738Qlm5Aste8/UY54UVpRaP0wGRacnQsBSOdy3LBlxIsEa
         pxRJ14FwqZvp11h/Z7lWWbKYAOHRBfPqYvezy7wArX/YKa76uNb4JIVx/AqQjcJ2vck2
         zL4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p56si4942345eda.176.2019.05.17.10.11.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 10:11:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 29A57AEB0;
	Fri, 17 May 2019 17:11:16 +0000 (UTC)
Date: Fri, 17 May 2019 19:11:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Kees Cook <keescook@chromium.org>
Cc: Alexander Potapenko <glider@google.com>,
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
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH v2 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <20190517170805.GS6836@dhcp22.suse.cz>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-2-glider@google.com>
 <20190517140446.GA8846@dhcp22.suse.cz>
 <CAG_fn=W4k=mijnUpF98Hu6P8bFMHU81FHs4Swm+xv1k0wOGFFQ@mail.gmail.com>
 <20190517142048.GM6836@dhcp22.suse.cz>
 <201905170928.A8F3BEC1B1@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201905170928.A8F3BEC1B1@keescook>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 17-05-19 09:36:36, Kees Cook wrote:
> On Fri, May 17, 2019 at 04:20:48PM +0200, Michal Hocko wrote:
> > On Fri 17-05-19 16:11:32, Alexander Potapenko wrote:
> > > On Fri, May 17, 2019 at 4:04 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Tue 14-05-19 16:35:34, Alexander Potapenko wrote:
> > > > > The new options are needed to prevent possible information leaks and
> > > > > make control-flow bugs that depend on uninitialized values more
> > > > > deterministic.
> > > > >
> > > > > init_on_alloc=1 makes the kernel initialize newly allocated pages and heap
> > > > > objects with zeroes. Initialization is done at allocation time at the
> > > > > places where checks for __GFP_ZERO are performed.
> > > > >
> > > > > init_on_free=1 makes the kernel initialize freed pages and heap objects
> > > > > with zeroes upon their deletion. This helps to ensure sensitive data
> > > > > doesn't leak via use-after-free accesses.
> > > >
> > > > Why do we need both? The later is more robust because even free memory
> > > > cannot be sniffed and the overhead might be shifted from the allocation
> > > > context (e.g. to RCU) but why cannot we stick to a single model?
> > > init_on_free appears to be slower because of cache effects. It's
> > > several % in the best case vs. <1% for init_on_alloc.
> > 
> > This doesn't really explain why we need both.
> 
> There are a couple reasons. The first is that once we have hardware with
> memory tagging (e.g. arm64's MTE) we'll need both on_alloc and on_free
> hooks to do change the tags. With MTE, zeroing comes for "free" with
> tagging (though tagging is as slow as zeroing, so it's really the tagging
> that is free...), so we'll need to re-use the init_on_free infrastructure.

I am not sure I follow, but ...
> 
> The second reason is for very paranoid use-cases where in-memory
> data lifetime is desired to be minimized. There are various arguments
> for/against the realism of the associated threat models, but given that
> we'll need the infrastructre for MTE anyway, and there are people who
> want wipe-on-free behavior no matter what the performance cost, it seems
> reasonable to include it in this series.
> 
> All that said, init_on_alloc looks desirable enough that distros will
> likely build with it enabled by default (I hope), and the very paranoid
> users will switch to (or additionally enable) init_on_free for their
> systems.

... this should all be part of the changelog.
-- 
Michal Hocko
SUSE Labs

