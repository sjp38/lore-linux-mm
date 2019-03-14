Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 926C8C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:52:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 506F72087C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:52:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 506F72087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 022D88E0004; Thu, 14 Mar 2019 12:52:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EED538E0001; Thu, 14 Mar 2019 12:52:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB5508E0004; Thu, 14 Mar 2019 12:52:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD728E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:52:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x21so2312022edr.17
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:52:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:from:to:cc:subject:in-reply-to:references:user-agent
         :mime-version;
        bh=eGFRzave+QEluTw8Vx/SddCMYoI0PlYsomLh293OiLc=;
        b=OaJnt69BvF92LtrL+TvEBX6TLaXDqQ1L/ZNtiKavf9mVizzwNgTuHom/kZsE6SPNWk
         JMW06ZvDXkf2mBu6YAWKTOSr1oD/v4D+YDNzbUN+vRLelYUq+/pQ8EJ4D3QWnJHtrQ3C
         wqrHhTDoKUt8QXiO6RFpK2Jd07hu2BlQIaSdrS9OYzEs5ThBVXzbdlbh/lTYEaK3pA8H
         Cl/fOMGbFh6fIfwKWCjPiz+PG/dneO2ujWwKppG8iQJ8Bi/68kubGOlRu/mWFovZ9Ls/
         PBPV2D6UNHph80TbvETKlRXhQCj6EG1xyJSsikau4VSMcUhHJNZxUciOLEiQ2WoP43rh
         i3vA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
X-Gm-Message-State: APjAAAXb7rWCKCOr6kxZJfsKHW92J2xH0+828pgBZgByelmf/TRrUiz5
	9l93qTPNnKGMG6wEu0NwRh9/T7HgwZT+KxzN5WlPNM39j4GqCMvU+BTyHhD6NIc+VgjqRNXJzt/
	TDt5H2DmGV7f9XuNxZDxGOoKlwV4OGTuIx3tI26ts7c+JToFfTX6LgNRQaYaGFDmygQ==
X-Received: by 2002:a05:6402:1807:: with SMTP id g7mr12219521edy.184.1552582346041;
        Thu, 14 Mar 2019 09:52:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz50VuKUSqmIXteOxO04B5LK9Rk05sDxsIL4O4GuNbEfDQLBo8Ql7qmWyUDRlMRY0iwvrpE
X-Received: by 2002:a05:6402:1807:: with SMTP id g7mr12219464edy.184.1552582345035;
        Thu, 14 Mar 2019 09:52:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552582345; cv=none;
        d=google.com; s=arc-20160816;
        b=tN+poUpVYT39+SyL3jTYEY+xQVLHpaio8z3EzUJc0epTLGokdqxf1G1/NU0XWVuPNN
         QOS2G8oU5BtCMQXC97r2VQfxF1Hu2UrLcTNQtVFCqqPnrRCB0r4d2efZBokM5PyTORYc
         i+KTCWwq5bQre0s00pteCV/YBck6cK8GG5nfrcK4U6WetVJEZd6h48P+F7neQri927K1
         F+huMMrWa67hHX/5uWTZeFqKrg3UAl2vBxYwRvQ2uLgZdqCvFAF5nkvkXzjAWLZDGUpI
         T7+m0V9ews9c3zOPKzL4YXAvIHB3PY1VQF0hfW/SEhGWIoaIA34NoKX0JqsU+py/ryRO
         3m6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:subject:cc:to:from
         :message-id:date;
        bh=eGFRzave+QEluTw8Vx/SddCMYoI0PlYsomLh293OiLc=;
        b=MlqDX7RhIWTH/pmaPhhsiUALj1NM4wILppMBRWZWm3YmCcZ81X6LUA5aeZb/qakWPi
         AEWgJychE4rzG6sA/NzTCkjbBSFGewfFfLnLcKbu94CCZoPl6pBg2mLQCsHmhlqixWc4
         cYBixNA+1fm5Y71Zu2a+xU3in2rqv3fwG8fvjbV/NU552PX9pqrG9ZjVhmmJDb8XfxLB
         UFllxZbz460U6aO19hXbGwVQnd9MIyyZeEXO95qI/51J/zrNltX3PTYXfLieYZvHeU+0
         ZmLuWqNiEhaG3e0kjewdEtoWAJrF4iWD2/MXD0j+Ftc4846mknLYYTkv/k/nZELMOzdC
         /ojw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 41si433153edr.20.2019.03.14.09.52.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 09:52:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8628AAFF0;
	Thu, 14 Mar 2019 16:52:24 +0000 (UTC)
Date: Thu, 14 Mar 2019 17:52:24 +0100
Message-ID: <s5h5zslqtyv.wl-tiwai@suse.de>
From: Takashi Iwai <tiwai@suse.de>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	linux-mm@kvack.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in alloc_pages_exact()
In-Reply-To: <20190314132933.GL7473@dhcp22.suse.cz>
References: <20190314093944.19406-1-vbabka@suse.cz>
	<20190314094249.19606-1-vbabka@suse.cz>
	<20190314101526.GH7473@dhcp22.suse.cz>
	<1dc997a3-7573-7bd5-9ce6-3bfbf77d1194@suse.cz>
	<20190314113626.GJ7473@dhcp22.suse.cz>
	<s5hd0mtsm84.wl-tiwai@suse.de>
	<20190314120939.GK7473@dhcp22.suse.cz>
	<s5ha7hxsikl.wl-tiwai@suse.de>
	<20190314132933.GL7473@dhcp22.suse.cz>
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

On Thu, 14 Mar 2019 14:29:33 +0100,
Michal Hocko wrote:
> 
> On Thu 14-03-19 14:15:38, Takashi Iwai wrote:
> > On Thu, 14 Mar 2019 13:09:39 +0100,
> > Michal Hocko wrote:
> > > 
> > > On Thu 14-03-19 12:56:43, Takashi Iwai wrote:
> > > > On Thu, 14 Mar 2019 12:36:26 +0100,
> > > > Michal Hocko wrote:
> > > > > 
> > > > > On Thu 14-03-19 11:30:03, Vlastimil Babka wrote:
> [...]
> > > > > > I initially went with 2 as well, as you can see from v1 :) but then I looked at
> > > > > > the commit [2] mentioned in [1] and I think ALSA legitimaly uses __GFP_COMP so
> > > > > > that the pages are then mapped to userspace. Breaking that didn't seem good.
> > > > > 
> > > > > It used the flag legitimately before because they were allocating
> > > > > compound pages but now they don't so this is just a conversion bug.
> > > > 
> > > > We still use __GFP_COMP for allocation of the sound buffers that are
> > > > also mmapped to user-space.  The mentioned commit above [2] was
> > > > reverted later.
> > > 
> > > Yes, I understand that part. __GFP_COMP makes sense on a comound page.
> > > But if you are using alloc_pages_exact then the flag doesn't make sense
> > > because split out should already do what you want. Unless I am missing
> > > something.
> > 
> > The __GFP_COMP was taken as a sort of workaround for the problem wrt
> > mmap I already forgot.  If it can be eliminated, it's all good.
> 
> Without __GFP_COMP you would get tail pages which are not setup properly
> AFAIU. With alloc_pages_exact you should get an "array" of head pages
> which are properly reference counted. But I might misunderstood the
> original problem which __GFP_COMP tried to solve.

I only vaguely remember that it was about a Bad Page error for the
reserved pages, but forgot the all details, sorry.

Hugh, could you confirm whether we still need __GFP_COMP in the sound
buffer allocations?  FWIW, it's the change introduced by the ancient
commit f3d48f0373c1.


thanks,

Takashi

