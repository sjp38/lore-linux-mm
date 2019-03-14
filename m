Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78CCEC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 17:37:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0202C2184C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 17:37:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="XYJ8zCgZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0202C2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CDFC6B0003; Thu, 14 Mar 2019 13:37:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 558BD6B0005; Thu, 14 Mar 2019 13:37:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46AAE6B0006; Thu, 14 Mar 2019 13:37:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2A856B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 13:37:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n10so6961336pgp.21
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 10:37:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=ZkTJrTQ3hMlkmg3pUqqdNa3XJNkqNISlHCc525RNvFg=;
        b=eEBHl5LWhynmE4/XmOCKllus/iD0k9VPiCfM6xA6sN3uOwZQJgYv3b9oAzbRYWA8eS
         YM9mZwlIimtH2s1tTEe23NEn8B5ce4mcgnjgDoxlZw0CHSsAavurjNEeyZKWE2jrVve2
         eSn3QjZJII6P9o5e4+pQ6ALoJBS4+up1B9/mhH6yvykVBoV90nkmnRJ2QOTSJoiZ65Tt
         +UUjgG/Gr3YVYu97PPHQvh+18gPwNaBPRZQkO4pUYaYy2PIJ/Ug3GIFy/9RvqFuPvS7d
         lmRABnGjF/FMyOBhlaR/cap8wpaV0vX9OgSPdgPU0PoVQ4BX3VEVk3rRgfYWfNLms/K0
         QdqA==
X-Gm-Message-State: APjAAAV4EgPFDPnckpjEJmeKUEJ+E2d8CBnzaBCeSDKGFPC9vMgp+dsf
	LB/FKV+iw+2ppOOJ6Vffzz7ih6HzOXlSe8aExAGdsfM5ES7EsW0bUH9qu1PyUJb0kb8gV9pf747
	ioIFPDNgOFGpTXylUzlhzA4+aR4AKLgi0TKlkcPop511hg7wRZ7gi28ggNjvWANaBKmubHUraE2
	FG6mFOaIDDl2bzheES5z9PgpobmifncFkQ0kw/zNQMAvkujcW9zAE3eYyJ6Vyai1Hh9jwn0XjcN
	Ac+h8EoXRWmBOazJvWPxn6IWjDmtLIxcBOPeCy/Cx9qY26F8l0+bnIxng4Q7YJ+sc09A0tC2WuS
	JImDmfb4rqH9z580Y0NyXoSbhGRx4FyjsS9TbpcZ+waxi3UG4gAUt4UHH3w1UnPkX02pUV/QIpe
	x
X-Received: by 2002:a65:50cc:: with SMTP id s12mr45734730pgp.130.1552585050654;
        Thu, 14 Mar 2019 10:37:30 -0700 (PDT)
X-Received: by 2002:a65:50cc:: with SMTP id s12mr45734632pgp.130.1552585049265;
        Thu, 14 Mar 2019 10:37:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552585049; cv=none;
        d=google.com; s=arc-20160816;
        b=MQ7LUrp9fSVP2BYCOd0aoH5N7URBwO3f4zw2IQGaXwRoWzvCh2bQx8TWDNljFa/Rzd
         n6Iae2OUh/mnc8J6IcA9/TYlu6cr6g9xWc0xdjkwm2zC6pkEi6v/1GOABRJ42U9fOQtA
         kw+ZwTi8i3qTTP6sEJBenr4XMu8KWgHNuvgH04YwCYWa+uJrsYRV87MTLPHaz9YhYBr8
         2UBblRJIk4B3wwz/7G05SArN4oRYyPDDfcyyEhSTB31WZocO2p+xugFK6wzBBGmMb/Hs
         +2WewJfeoalIHmPEYu/K0zDK53KrbGF8fUHUhzzAjA5m+6/WigeszWsDoeuZMbL81oA9
         +rTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=ZkTJrTQ3hMlkmg3pUqqdNa3XJNkqNISlHCc525RNvFg=;
        b=X5h0FaNEu8SouozJB6uZSAY1wZsDE59/piDs0VrkZ2ro1iyC8PoR7oA4LvFU91QBMr
         ABA1eqKj1eU6hxe3OiPqCHq+7Yyl6l8cQguhIEidZFoPDPuDKGidhagRD5t47wLs2Xw9
         UqL6v3BkTvKXBH52FuU4s+vUWGhe6fOdWh9lK03M555t+l+kC9vZK1QtX9N21X/y6gnn
         a2BN7UZf21b/eutdv4TqvGUnAxXDg64Si1Zqgzn5SEdXcAiGEEvFwyGkIEwG58URN2Fr
         0Y7DeuN6zcSTp9NixwbXV/VcgcDwCdeRGLvI3TIiR1+EZdVQtyioQMU6e/SvyhBhh0oh
         kt1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XYJ8zCgZ;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor7047718plk.26.2019.03.14.10.37.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 10:37:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XYJ8zCgZ;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=ZkTJrTQ3hMlkmg3pUqqdNa3XJNkqNISlHCc525RNvFg=;
        b=XYJ8zCgZqNOTemCJ55t9857D1QADwX8OUo4MoqeV5sislSPpi9q4q1eNQh56fo8E23
         c/wZCrmAEsQPMXCivpcTv/0/nSXg/H1vc5mpfup78cDuiwLqHjw4QSSXpurIYDTb5ZJg
         RoC6FggvH/L5xwz0Wb5knOVPe4RHslU7Pqx1PkeDj6H7SgFa1PpIdUZdqFtkjwwUB6te
         nHjeDtS9uaIoRKd0eSB5kohtXIOWWOaFUyjS0XR5V8UTuSMtCSzoU9n1a6iggO2+9o4Y
         8X15qyQLVj+VmbCRT5gk+hKAct2BarL4GUe76pVHVVafMWkrvLzwaa4ZCWmaU7llfNYe
         0Syg==
X-Google-Smtp-Source: APXvYqxrcY50GOdhwTO0ekexLgTZzsiaioJF5owWL2QiRJHGOYKMURV2b85NUvVAcG+7UgYY3a3ixQ==
X-Received: by 2002:a17:902:8690:: with SMTP id g16mr52039279plo.284.1552585048510;
        Thu, 14 Mar 2019 10:37:28 -0700 (PDT)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id q78sm28849180pfa.138.2019.03.14.10.37.27
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Mar 2019 10:37:27 -0700 (PDT)
Date: Thu, 14 Mar 2019 10:37:06 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Takashi Iwai <tiwai@suse.de>
cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, 
    linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
    Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in
 alloc_pages_exact()
In-Reply-To: <s5h5zslqtyv.wl-tiwai@suse.de>
Message-ID: <alpine.LSU.2.11.1903141021550.1591@eggly.anvils>
References: <20190314093944.19406-1-vbabka@suse.cz> <20190314094249.19606-1-vbabka@suse.cz> <20190314101526.GH7473@dhcp22.suse.cz> <1dc997a3-7573-7bd5-9ce6-3bfbf77d1194@suse.cz> <20190314113626.GJ7473@dhcp22.suse.cz> <s5hd0mtsm84.wl-tiwai@suse.de>
 <20190314120939.GK7473@dhcp22.suse.cz> <s5ha7hxsikl.wl-tiwai@suse.de> <20190314132933.GL7473@dhcp22.suse.cz> <s5h5zslqtyv.wl-tiwai@suse.de>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Mar 2019, Takashi Iwai wrote:
> On Thu, 14 Mar 2019 14:29:33 +0100,
> Michal Hocko wrote:
> > 
> > On Thu 14-03-19 14:15:38, Takashi Iwai wrote:
> > > On Thu, 14 Mar 2019 13:09:39 +0100,
> > > Michal Hocko wrote:
> > > > 
> > > > On Thu 14-03-19 12:56:43, Takashi Iwai wrote:
> > > > > On Thu, 14 Mar 2019 12:36:26 +0100,
> > > > > Michal Hocko wrote:
> > > > > > 
> > > > > > On Thu 14-03-19 11:30:03, Vlastimil Babka wrote:
> > [...]
> > > > > > > I initially went with 2 as well, as you can see from v1 :) but then I looked at
> > > > > > > the commit [2] mentioned in [1] and I think ALSA legitimaly uses __GFP_COMP so
> > > > > > > that the pages are then mapped to userspace. Breaking that didn't seem good.
> > > > > > 
> > > > > > It used the flag legitimately before because they were allocating
> > > > > > compound pages but now they don't so this is just a conversion bug.
> > > > > 
> > > > > We still use __GFP_COMP for allocation of the sound buffers that are
> > > > > also mmapped to user-space.  The mentioned commit above [2] was
> > > > > reverted later.
> > > > 
> > > > Yes, I understand that part. __GFP_COMP makes sense on a comound page.
> > > > But if you are using alloc_pages_exact then the flag doesn't make sense
> > > > because split out should already do what you want. Unless I am missing
> > > > something.
> > > 
> > > The __GFP_COMP was taken as a sort of workaround for the problem wrt
> > > mmap I already forgot.  If it can be eliminated, it's all good.
> > 
> > Without __GFP_COMP you would get tail pages which are not setup properly
> > AFAIU. With alloc_pages_exact you should get an "array" of head pages
> > which are properly reference counted. But I might misunderstood the
> > original problem which __GFP_COMP tried to solve.
> 
> I only vaguely remember that it was about a Bad Page error for the
> reserved pages, but forgot the all details, sorry.
> 
> Hugh, could you confirm whether we still need __GFP_COMP in the sound
> buffer allocations?  FWIW, it's the change introduced by the ancient
> commit f3d48f0373c1.

I'm not confident in finding all "the sound buffer allocations".
Where you're using alloc_pages_exact() for them, you do not need
__GFP_COMP, and should not pass it.  But if there are other places
where you use one of those page allocators with an "order" argument
non-zero, and map that buffer into userspace (without any split_page()),
there you would still need the __GFP_COMP - zap_pte_range() and others
do the wrong thing on tail ptes if the non-zero-order page has neither
been set up as compound nor split into zero-order pages.

Hugh

