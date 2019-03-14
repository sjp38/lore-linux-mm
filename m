Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD22AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 18:00:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 989822184C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 18:00:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 989822184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3238D6B0003; Thu, 14 Mar 2019 14:00:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D4BB6B0005; Thu, 14 Mar 2019 14:00:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E9256B0006; Thu, 14 Mar 2019 14:00:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFDA26B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 14:00:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 29so2709670eds.12
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 11:00:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:from:to:cc:subject:in-reply-to:references:user-agent
         :mime-version;
        bh=bhuYisQ5HQiE3+UUbioR0DUSjV1hKuGx4g9fHCUDVdw=;
        b=I5b2sP+eLVgmaU16tgFkZ7z9MA9WkNeH5eFFKka6DLFUMmu3TVAXTor8o3p70tbbYf
         fwV29WW/4bnfBuouM9+hE5XKrPddooF8X79gBr84HwpNofdNzz82QL0C19cDBSb4Ui7M
         cT8vNb8CcBgwfGK26OBns0zu3DewjofV1DrA1ONZlxI2rlJZxi4gGtqjqjRpKD81ayCZ
         2KE5Ko6tWJ1orqn7Rk1ZLH6zI1ggNYLsUOBvSq/oUvyoqqGsRksiqKGHyS1cJYYqKEkg
         j9WHid7+t+/skVmiGLllhJ4i7g8Tym1CPfWIG0D//4JH7l5LUIfpsoa6vVC3eaDF3TFx
         Wf6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
X-Gm-Message-State: APjAAAV/No+cTMpavr+hKxDE1TnqhKFPwTqA8QSmONJEm9lrIjKEOyTy
	WVaVasDNt9c7wmi7/sDrYCh6jeVVC307d/17pzt/wvOvUsjbR4iXwkOj5LfFhU/YdPOqwCyt6Tq
	5MrRTyHFy+vL5qEijGveThGkfv/AYUtIQocxnwAr6SyjfcHhKyxBKULioAH7SiJON9w==
X-Received: by 2002:a17:906:28c9:: with SMTP id p9mr33211281ejd.43.1552586419315;
        Thu, 14 Mar 2019 11:00:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEfoGUZANwbvhXQtXjmj32yiDXNQBQ3vWGmEQqXwl1tgPe0jBRiW136YNsaOzlJYobQ192
X-Received: by 2002:a17:906:28c9:: with SMTP id p9mr33211235ejd.43.1552586418216;
        Thu, 14 Mar 2019 11:00:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552586418; cv=none;
        d=google.com; s=arc-20160816;
        b=hqy6JK7hkZSyFp8eumH4Al4AvrIWIDdh7cLB0dorChzlY2ILr4KBGHRTM/BbbVfZYr
         8bMsgz8InafKjwJjc84zL1TlOV6pMH20zA8D6oEMmgPDgfnD7KRU0/+b5kOfRaZClHrG
         KIYmlO9hRl0l1ZsC18kvertsaad7ja2fkE7KPA3SAqudYsx8r9L/qZB4kNGo4/CgcEEE
         DvEl8uiNS8SjHJRaE2T4PAIOBbKiyLPLOaqxQJo01ARBW9nR1Kly732n9b+nGeRuXCBZ
         KSWc8EPsWcHLiclJTjh2sc4N/E2uR5+gDta6Iui91+pT7D6XJQgD68cRlbM7PTHzVyix
         Gx8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:subject:cc:to:from
         :message-id:date;
        bh=bhuYisQ5HQiE3+UUbioR0DUSjV1hKuGx4g9fHCUDVdw=;
        b=QzZLBHRCl+lg7MriIe/Xdh5s28o3pgt8vUlff6RrUxsxnpp9Z3G7mhp2JQBNSedo0G
         nQsKa1arcWA3+eYVjccueOoOnO3cggqximf9b0YO52nXGc8XhY8t4E717B4PPh7yt6/U
         HMOZLxn6xdJfZzo9u4EAfPQj4kyzPEp0lOKiqUXMDnoioexa6iDkP0jbVauxPV49ifdH
         Wf4d6UobxtADvYI3uNOjcsARkYj6LdLskmtNAqX680djRYEDiLMjX4stUsg7zAyko/ZP
         uiRzv4lpz8iMzxb0JvzqO2Ro9UAYMCJ53vVR1SPEhvuHWH/e1AEwtd2WQtAfm+Mz8HxQ
         r4gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k27si2007476ejb.162.2019.03.14.11.00.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 11:00:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 44AFAAFD6;
	Thu, 14 Mar 2019 18:00:17 +0000 (UTC)
Date: Thu, 14 Mar 2019 19:00:17 +0100
Message-ID: <s5hpnqt5ob2.wl-tiwai@suse.de>
From: Takashi Iwai <tiwai@suse.de>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	linux-mm@kvack.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in alloc_pages_exact()
In-Reply-To: <alpine.LSU.2.11.1903141021550.1591@eggly.anvils>
References: <20190314093944.19406-1-vbabka@suse.cz>
	<20190314094249.19606-1-vbabka@suse.cz>
	<20190314101526.GH7473@dhcp22.suse.cz>
	<1dc997a3-7573-7bd5-9ce6-3bfbf77d1194@suse.cz>
	<20190314113626.GJ7473@dhcp22.suse.cz>
	<s5hd0mtsm84.wl-tiwai@suse.de>
	<20190314120939.GK7473@dhcp22.suse.cz>
	<s5ha7hxsikl.wl-tiwai@suse.de>
	<20190314132933.GL7473@dhcp22.suse.cz>
	<s5h5zslqtyv.wl-tiwai@suse.de>
	<alpine.LSU.2.11.1903141021550.1591@eggly.anvils>
User-Agent: Wanderlust/2.15.9 (Almost Unreal) SEMI/1.14.6 (Maruoka)
 FLIM/1.14.9 (=?UTF-8?B?R29qxY0=?=) APEL/10.8 Emacs/25.3
 (x86_64-suse-linux-gnu) MULE/6.0 (HANACHIRUSATO)
MIME-Version: 1.0 (generated by SEMI 1.14.6 - "Maruoka")
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Mar 2019 18:37:06 +0100,
Hugh Dickins wrote:
> 
> On Thu, 14 Mar 2019, Takashi Iwai wrote:
> > On Thu, 14 Mar 2019 14:29:33 +0100,
> > Michal Hocko wrote:
> > > 
> > > On Thu 14-03-19 14:15:38, Takashi Iwai wrote:
> > > > On Thu, 14 Mar 2019 13:09:39 +0100,
> > > > Michal Hocko wrote:
> > > > > 
> > > > > On Thu 14-03-19 12:56:43, Takashi Iwai wrote:
> > > > > > On Thu, 14 Mar 2019 12:36:26 +0100,
> > > > > > Michal Hocko wrote:
> > > > > > > 
> > > > > > > On Thu 14-03-19 11:30:03, Vlastimil Babka wrote:
> > > [...]
> > > > > > > > I initially went with 2 as well, as you can see from v1 :) but then I looked at
> > > > > > > > the commit [2] mentioned in [1] and I think ALSA legitimaly uses __GFP_COMP so
> > > > > > > > that the pages are then mapped to userspace. Breaking that didn't seem good.
> > > > > > > 
> > > > > > > It used the flag legitimately before because they were allocating
> > > > > > > compound pages but now they don't so this is just a conversion bug.
> > > > > > 
> > > > > > We still use __GFP_COMP for allocation of the sound buffers that are
> > > > > > also mmapped to user-space.  The mentioned commit above [2] was
> > > > > > reverted later.
> > > > > 
> > > > > Yes, I understand that part. __GFP_COMP makes sense on a comound page.
> > > > > But if you are using alloc_pages_exact then the flag doesn't make sense
> > > > > because split out should already do what you want. Unless I am missing
> > > > > something.
> > > > 
> > > > The __GFP_COMP was taken as a sort of workaround for the problem wrt
> > > > mmap I already forgot.  If it can be eliminated, it's all good.
> > > 
> > > Without __GFP_COMP you would get tail pages which are not setup properly
> > > AFAIU. With alloc_pages_exact you should get an "array" of head pages
> > > which are properly reference counted. But I might misunderstood the
> > > original problem which __GFP_COMP tried to solve.
> > 
> > I only vaguely remember that it was about a Bad Page error for the
> > reserved pages, but forgot the all details, sorry.
> > 
> > Hugh, could you confirm whether we still need __GFP_COMP in the sound
> > buffer allocations?  FWIW, it's the change introduced by the ancient
> > commit f3d48f0373c1.
> 
> I'm not confident in finding all "the sound buffer allocations".
> Where you're using alloc_pages_exact() for them, you do not need
> __GFP_COMP, and should not pass it.

It was my fault attempt to convert to alloc_pages_exact() and hitting
the incompatibility with __GFP_COMP, so it was reverted in the end.

> But if there are other places
> where you use one of those page allocators with an "order" argument
> non-zero, and map that buffer into userspace (without any split_page()),
> there you would still need the __GFP_COMP - zap_pte_range() and others
> do the wrong thing on tail ptes if the non-zero-order page has neither
> been set up as compound nor split into zero-order pages.

Hm, what if we allocate the whole pages via alloc_pages_exact() (but
without __GFP_COMP)?  Can we mmap them properly to user-space like
before, or it won't work as-is?


thanks,

Takashi

