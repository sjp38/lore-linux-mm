Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29301C04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:11:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC104216C4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:11:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC104216C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E6A26B0005; Fri, 17 May 2019 13:11:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 797F16B0006; Fri, 17 May 2019 13:11:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 686756B0008; Fri, 17 May 2019 13:11:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2976B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 13:11:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c24so11581517edb.6
        for <linux-mm@kvack.org>; Fri, 17 May 2019 10:11:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MAX8I4AKxVGijBEgwEEtPpFlG/giqHjECqXRaTtivlc=;
        b=ZGSQFFu/ksm1U0W0EqbSVzj0aZGuA+cKUK5jgSD8eGS33KEcbs1zmIqfh2/mjJruWp
         iCf22iPc7rNB79xEhA81pBq0yg7dmot03FHSNJ4xfV2NzYCnJM5G4w+cE5NILg6K85sU
         BpsvKOlVdS+zCFBxQSiS/WXqlhby2EkhlQhoW/FjDlKW5X+LJLolz5lq7vk9DSZdRfV0
         Lg1LT/uBTi6mkJB4s/IkLvVj/l2ePz4yt4t/yBOak4VUFpAFAT4ElPaOXdvvD6rNZnkl
         RWCgcxTtnZ/s90/nR6ixjqOC9Vzi1DNVMASSs8lyHhsS2zY7vpWO/4lX/N+YTgegIoQQ
         e5hw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXFNtaD72zF4m6nODxcV9iLfJyAmf4QTvOdvH95oxit6Jn6c7nn
	UGhT+ztlhkTE0djsS7Ftl4p93Uj/I5y3yODniKJAaRqtzIWlCzTMHCxe62DoDUSft8wJlrr8Y8P
	4zCFX9ZDh7IjoYPq7bXR6tX/U2Rih5ftjn2sCLcjMYwiDxYGja0fPk6cZ9UjG3+M=
X-Received: by 2002:a17:906:1e0f:: with SMTP id g15mr45656559ejj.241.1558113069588;
        Fri, 17 May 2019 10:11:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqb5Qjl6t+7l1QzUclvKXqotVRbk5T7b1oFdM16i3F5mpNCit4z5VyB+516bZnKmMEwUTQ
X-Received: by 2002:a17:906:1e0f:: with SMTP id g15mr45656466ejj.241.1558113068432;
        Fri, 17 May 2019 10:11:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558113068; cv=none;
        d=google.com; s=arc-20160816;
        b=002pGPXOz0a3S82BZN2V0UZPukqm+6GGf7llwEoLuQ8Gb8fmowGVCRdcv9Wzgx5JVY
         5IkBRm3383UDos1EWnyQmtiOVGO49nG1PK1Q79WfFavyJxMSgZb3qymmLkbTKUX5JOEs
         6pTjoZIqwa8fBe4iO1lZljgfboy3cgNmmVtkXEnqFNdjM1wMoXgm+SfaNSrEJhit7MpT
         1zCBO+jZIoklqowa3Ct0qacs+zkrGPELocEYWec6RvCNQW180K8CfKA0LQcPjlbg6UoS
         1Jx881q8r/g3S6YZX001BnRlqFiGtjIHAN14hZYxSmbbXGOvRzdawDLNk7Vd2Pb8tmSk
         DmNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MAX8I4AKxVGijBEgwEEtPpFlG/giqHjECqXRaTtivlc=;
        b=s3ZLdpA6TxqlHTZ6VLVMn5nnwDR1fHNzFMe98uXTNseZ4RYfJDY+mJ4TVJTnPAFzhQ
         a62Vhegp6zu70hKj3w71oLaNf+gGEStiWPAsnKcaBrzXXJEp6rGB7ZXZUC41N4HKCAcN
         TqjfV1Hlv4NXkpz6kYsV9+I9rOvpYgz5b5E6WJaflLpckPK3Smp4yr05pNwKb7iHKP5m
         UcBmME40EF6UHXjDicR4FOVVkX7BxlG0WWGekJZfWVizW2Uxxo6OdeLU8FNUKTcV98qX
         pzNXlJiD0slUyR4lKTniVxSnEFQDLOy5hZq+IDGnzassAM4Yk9jfqNkyVvGp/uWRPMHV
         1CUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w14si3368798edw.79.2019.05.17.10.11.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 10:11:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9A57EADEA;
	Fri, 17 May 2019 17:11:07 +0000 (UTC)
Date: Fri, 17 May 2019 19:11:05 +0200
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
	Souptick Joarder <jrdr.linux@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH v2 3/4] gfp: mm: introduce __GFP_NO_AUTOINIT
Message-ID: <20190517171105.GT6836@dhcp22.suse.cz>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-4-glider@google.com>
 <20190517125916.GF1825@dhcp22.suse.cz>
 <CAG_fn=VG6vrCdpEv0g73M-Au4wW07w8g0uydEiHA96QOfcCVhA@mail.gmail.com>
 <20190517132542.GJ6836@dhcp22.suse.cz>
 <CAG_fn=Ve88z2ezFjV6CthufMUhJ-ePNMT2=3m6J3nHWh9iSgsg@mail.gmail.com>
 <20190517140108.GK6836@dhcp22.suse.cz>
 <201905170925.6FD47DDFFF@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201905170925.6FD47DDFFF@keescook>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 17-05-19 09:27:54, Kees Cook wrote:
> On Fri, May 17, 2019 at 04:01:08PM +0200, Michal Hocko wrote:
> > On Fri 17-05-19 15:37:14, Alexander Potapenko wrote:
> > > > > > Freeing a memory is an opt-in feature and the slab allocator can already
> > > > > > tell many (with constructor or GFP_ZERO) do not need it.
> > > > > Sorry, I didn't understand this piece. Could you please elaborate?
> > > >
> > > > The allocator can assume that caches with a constructor will initialize
> > > > the object so additional zeroying is not needed. GFP_ZERO should be self
> > > > explanatory.
> > > Ah, I see. We already do that, see the want_init_on_alloc()
> > > implementation here: https://patchwork.kernel.org/patch/10943087/
> > > > > > So can we go without this gfp thing and see whether somebody actually
> > > > > > finds a performance problem with the feature enabled and think about
> > > > > > what can we do about it rather than add this maint. nightmare from the
> > > > > > very beginning?
> > > > >
> > > > > There were two reasons to introduce this flag initially.
> > > > > The first was double initialization of pages allocated for SLUB.
> > > >
> > > > Could you elaborate please?
> > > When the kernel allocates an object from SLUB, and SLUB happens to be
> > > short on free pages, it requests some from the page allocator.
> > > Those pages are initialized by the page allocator
> > 
> > ... when the feature is enabled ...
> > 
> > > and split into objects. Finally SLUB initializes one of the available
> > > objects and returns it back to the kernel.
> > > Therefore the object is initialized twice for the first time (when it
> > > comes directly from the page allocator).
> > > This cost is however amortized by SLUB reusing the object after it's been freed.
> > 
> > OK, I see what you mean now. Is there any way to special case the page
> > allocation for this feature? E.g. your implementation tries to make this
> > zeroying special but why cannot you simply do this
> > 
> > 
> > struct page *
> > ____alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> > 							nodemask_t *nodemask)
> > {
> > 	//current implementation
> > }
> > 
> > struct page *
> > __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> > 							nodemask_t *nodemask)
> > {
> > 	if (your_feature_enabled)
> > 		gfp_mask |= __GFP_ZERO;
> > 	return ____alloc_pages_nodemask(gfp_mask, order, preferred_nid,
> > 					nodemask);
> > }
> > 
> > and use ____alloc_pages_nodemask from the slab or other internal
> > allocators?
> 
> If an additional allocator function is preferred over a new GFP flag, then
> I don't see any reason not to do this. (Though adding more "__"s seems
> a bit unfriendly to code-documentation.) What might be better naming?

The naminig is the last thing I would be worried about. Let's focus on
the most simplistic implementation first. And means, can we really make
it as simple as above? At least on the page allocator level.

> This would mean that the skb changes later in the series would use the
> "no auto init" version of the allocator too, then.

No, this would be an internal function to MM. I would really like to
optimize once there are numbers from _real_ workloads to base those
optimizations.
-- 
Michal Hocko
SUSE Labs

