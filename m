Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1405C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:25:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82A85217D7
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:25:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82A85217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E48E6B0007; Tue, 21 May 2019 10:25:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1950D6B0008; Tue, 21 May 2019 10:25:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 084916B000A; Tue, 21 May 2019 10:25:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0E646B0007
	for <linux-mm@kvack.org>; Tue, 21 May 2019 10:25:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d15so30957693edm.7
        for <linux-mm@kvack.org>; Tue, 21 May 2019 07:25:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rHE52GP7rDGORSMxht/sJty36ZKvXLCb1lf/pCR4QMQ=;
        b=MbGbY37/dzADiNRnkBZb4cC9EBjj2d/rP8Pg3JDtw0ZL/Chswzc9Y/FYuVivupBjn7
         DUeDgsp8eQedOQfoRSRMJhoyDes+AXtypEZXrrKWA4Uv2TpM4wTLUSvSY/eh8bUbHTUk
         GXjFAqiJIIoVDwSarRSJNo7CCxgOzSS5+EsOrboHgb08XAYpONadHcmpP1PsWgHsPTJS
         I784kBZEVqdTt/aI20QU34zqg2013xXgZm8uBAsKQmh+z6NW/0ujDqP2+7yFmitwX+1k
         9JYE9LPUH3ZzfsH8emnP42WaKobzkbrtWpx2kin2BDTgeXQtzOY1sebncW19nNbsNpYy
         ZXRA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUHcFGBU24byR3o3u8S1OzTOn+aC0LEoaznUqdD0HtP7xmdLoqg
	9sVSAU3U/d88OMdZeHe1msm5VzhylWQmSANJy3Rb/C8GJYqEeyNFW3gGKTFoueEXoJfuMa0A2ry
	rCx9+u8jw5+xXPNLLEAvXOEJ/fSK9OtPX8WTRjyUfNOJGz1HunagcMPSujPzZDJg=
X-Received: by 2002:a17:906:e282:: with SMTP id gg2mr9964550ejb.38.1558448745268;
        Tue, 21 May 2019 07:25:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3sQNf3LmfXhJy5tC5/fxe7oFlRU8p4k+81+OWptDnda16kWgXd4jkPeqT+V3KxeSHIfIM
X-Received: by 2002:a17:906:e282:: with SMTP id gg2mr9964479ejb.38.1558448744464;
        Tue, 21 May 2019 07:25:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558448744; cv=none;
        d=google.com; s=arc-20160816;
        b=qnAJeQdM5Rc9gCbDgSh5DHE3DNQ+XsMViMmDbBfePe4plPIdk0gx1OTCnl3nrOhN90
         swuGZaoJB6kdPVYIpJ7+WwJ2Km76nml1Ek4ya1atLwgTwaecDTuHlGYQv1Z2zfYMHJn+
         UAuHmIS6RhaYbqe+UxktDPMy+GkMGcf6sr1assnqGWdXvT/VcjaB5Elzg+6lzFAJNnk0
         +U+7pntZMauVwi5a5bQb/2UdNpL1fw8Xy/fHtri2I2PZoG6/a5UeajnRDmtycyyT1V/x
         Bew3FhD6ilitrtxXkU74C5jUvVK27LcbRlOCG8cRlwQwa1Z+N8VwjsiWGI8ut40jNWZf
         pA7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rHE52GP7rDGORSMxht/sJty36ZKvXLCb1lf/pCR4QMQ=;
        b=LNkE461MsiPFnRP1LGB7RiyEZk0ZyPjhBLPfi0tfO7fUoSPjrfuVa/fQZBqfvwPcVN
         azHD3IYZke5ELNpljM8Tlgx4YXaHNpVp/Bvk+gOgzWwGq0Z1G2BVvxq8DuZl1bCru4Qn
         ceV7Sv3xDe4dWyxUH+8pA3++jcdHDgtiM9H4cdsAmAZJCpiENlfzhz5nNnImqbellD7S
         hX2Qa66nLJkoL2YE02pL9GBKa3sSVn1VGORb2EcKiRVoWbmEUnOcIKX1d0iAGvt7Mc9b
         PjwXapJ/nQ9RYSehqWRSSaEczaFKfqJzL6nns2nGEetNLnqaphCcFk3skFHEK+i4ocdR
         Gg/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q6si15934236edg.394.2019.05.21.07.25.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 07:25:44 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7E995AE91;
	Tue, 21 May 2019 14:25:43 +0000 (UTC)
Date: Tue, 21 May 2019 16:25:41 +0200
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
Message-ID: <20190521142541.GW32329@dhcp22.suse.cz>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-4-glider@google.com>
 <20190517125916.GF1825@dhcp22.suse.cz>
 <CAG_fn=VG6vrCdpEv0g73M-Au4wW07w8g0uydEiHA96QOfcCVhA@mail.gmail.com>
 <20190517132542.GJ6836@dhcp22.suse.cz>
 <CAG_fn=Ve88z2ezFjV6CthufMUhJ-ePNMT2=3m6J3nHWh9iSgsg@mail.gmail.com>
 <20190517140108.GK6836@dhcp22.suse.cz>
 <201905170925.6FD47DDFFF@keescook>
 <20190517171105.GT6836@dhcp22.suse.cz>
 <CAG_fn=W9Y7=RZREi5S8z-sAMg2GfPsWqrHo+UawXWiRbhrNd0Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=W9Y7=RZREi5S8z-sAMg2GfPsWqrHo+UawXWiRbhrNd0Q@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 16:18:37, Alexander Potapenko wrote:
> On Fri, May 17, 2019 at 7:11 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 17-05-19 09:27:54, Kees Cook wrote:
> > > On Fri, May 17, 2019 at 04:01:08PM +0200, Michal Hocko wrote:
> > > > On Fri 17-05-19 15:37:14, Alexander Potapenko wrote:
> > > > > > > > Freeing a memory is an opt-in feature and the slab allocator can already
> > > > > > > > tell many (with constructor or GFP_ZERO) do not need it.
> > > > > > > Sorry, I didn't understand this piece. Could you please elaborate?
> > > > > >
> > > > > > The allocator can assume that caches with a constructor will initialize
> > > > > > the object so additional zeroying is not needed. GFP_ZERO should be self
> > > > > > explanatory.
> > > > > Ah, I see. We already do that, see the want_init_on_alloc()
> > > > > implementation here: https://patchwork.kernel.org/patch/10943087/
> > > > > > > > So can we go without this gfp thing and see whether somebody actually
> > > > > > > > finds a performance problem with the feature enabled and think about
> > > > > > > > what can we do about it rather than add this maint. nightmare from the
> > > > > > > > very beginning?
> > > > > > >
> > > > > > > There were two reasons to introduce this flag initially.
> > > > > > > The first was double initialization of pages allocated for SLUB.
> > > > > >
> > > > > > Could you elaborate please?
> > > > > When the kernel allocates an object from SLUB, and SLUB happens to be
> > > > > short on free pages, it requests some from the page allocator.
> > > > > Those pages are initialized by the page allocator
> > > >
> > > > ... when the feature is enabled ...
> > > >
> > > > > and split into objects. Finally SLUB initializes one of the available
> > > > > objects and returns it back to the kernel.
> > > > > Therefore the object is initialized twice for the first time (when it
> > > > > comes directly from the page allocator).
> > > > > This cost is however amortized by SLUB reusing the object after it's been freed.
> > > >
> > > > OK, I see what you mean now. Is there any way to special case the page
> > > > allocation for this feature? E.g. your implementation tries to make this
> > > > zeroying special but why cannot you simply do this
> > > >
> > > >
> > > > struct page *
> > > > ____alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> > > >                                                     nodemask_t *nodemask)
> > > > {
> > > >     //current implementation
> > > > }
> > > >
> > > > struct page *
> > > > __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> > > >                                                     nodemask_t *nodemask)
> > > > {
> > > >     if (your_feature_enabled)
> > > >             gfp_mask |= __GFP_ZERO;
> > > >     return ____alloc_pages_nodemask(gfp_mask, order, preferred_nid,
> > > >                                     nodemask);
> > > > }
> > > >
> > > > and use ____alloc_pages_nodemask from the slab or other internal
> > > > allocators?
> Given that calling alloc_pages() with __GFP_NO_AUTOINIT doesn't
> visibly improve the chosen benchmarks,
> and the next patch in the series ("net: apply __GFP_NO_AUTOINIT to
> AF_UNIX sk_buff allocations") only improves hackbench,
> shall we maybe drop both patches altogether?

Ohh, by all means. I was suggesting the same few emails ago. The above
is just a hint on how to implement the feature on the page allocator
level rather than hooking into the prep_new_page and add another branch
to zero memory.
-- 
Michal Hocko
SUSE Labs

