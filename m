Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82E92C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 13:15:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F1F920449
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 13:15:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F1F920449
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B61C28E0004; Thu, 14 Mar 2019 09:15:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0F268E0001; Thu, 14 Mar 2019 09:15:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B25A8E0004; Thu, 14 Mar 2019 09:15:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4035F8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:15:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k21so2398877eds.19
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 06:15:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:from:to:cc:subject:in-reply-to:references:user-agent
         :mime-version;
        bh=tBirDlz+euTlAGrV6LDAWbYktkTvbewJc0zl7XwnoV8=;
        b=FReYugIWCU5Vfnpjp1ncge1iV3zEIt+UPayDuevHYUmgk6dd8TUfhaacm0rm7KFE9/
         nIUb6G4x5yCP6X6o/KQRSWBTt4rHTbz337saqTD/Fb0G0rOo2FDJp9t3KLDv64UZFocN
         1E8xx37tfwfsnbKDrGxjVS4llAAWYlpQphknwzAoYvzRugfDwhqw5/RxLjJ9sHxRpO4Y
         kMRA3Nat0GDS5Z1pY19LpLqbMDWMIPmUbXieQPjbBmQ0V6aelw769dmmqG29pmA3fQSu
         k3sOTc5ebNQvTNay223RUDoCgjuN9yytPuHLi8xNuR9uoB3D4sBNP9W1uZWxRva9Em3X
         eOAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
X-Gm-Message-State: APjAAAXh+hJWxX+2HZmpHy7we6H+cVhQlffdyzjTWLTFsSKJefgdoBpM
	KjyLqBFVIlyxv3vYqP0J4Nugy0q5KUmxJ4vIOCUURFB1AqMWRSCE3bxYsrbSfGuhn8DtTcbsze3
	CNlmn48ZsZvBS0vX3sBx9Y6f6BRn1GqmqcYPl2x1OO331NCfp81vULVbDdwva4tlmfA==
X-Received: by 2002:a50:c352:: with SMTP id q18mr11527599edb.175.1552569340820;
        Thu, 14 Mar 2019 06:15:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYAaWHaBJBQ9IyEBePOTtiSS4kgTG/V2NNDtaH/2P5KBsnIKCOLyxZExaBu7m/7e4k8srQ
X-Received: by 2002:a50:c352:: with SMTP id q18mr11527534edb.175.1552569339534;
        Thu, 14 Mar 2019 06:15:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552569339; cv=none;
        d=google.com; s=arc-20160816;
        b=ZY//V6ZLDK2ilOPWHP3ATFyLCTlSlAzxTMEtTW9cB7WJlQ5YY2zfBjKCDnTKuPu/2I
         Gl3GH0HTLFktLKPRyvujxGpXbytHGTFU0J4KIIi6J1EjEiwPwgZlZ6G+vlr0IyusNVCo
         9aWQ9CjZuSTqIzVKFLS22EOQeu5WU8iF6qZtxyD0AWuELCTcas/jkmwKjEwDJhcXakkv
         od8Fs3UO8w5DuUaLll+YchKlCy5TDIimVg7pGjS8bTryz2UqPBJs4FZ5iV2YDuMUgCgz
         uhhaF9O3cA3bkMbKB6THuyctIdcxfJ6856+fC39xzPnI7JiTtT5fdwI+W7l6ctZF+Y7H
         eD0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:subject:cc:to:from
         :message-id:date;
        bh=tBirDlz+euTlAGrV6LDAWbYktkTvbewJc0zl7XwnoV8=;
        b=jaBzkcK05qtH7YF/gfNs3QL8YpUxIFpqSHga20DYHDTy/t+SRgTCmAWvt532fFXeZ0
         CtwybvidfWU9dotHqkVBXdW9hQQnBD1MxZoPt+SgAHiuRDIf3STROWBv0qEVxoCGr5rG
         pdlsC+6hKJjECuqkm3oqUTRqrj6FEBriCtz+a/hlSzQKZlAjLxcWnyVctrrgzksRtvpi
         xYfoheTocsEP1GV6LHhqPSOMSDd+0dQvFK/xqGQFuyDe5PTtNDT6fXh94v8S+1i579M7
         OlFC66DxeVxRh7ic6EKOSblOyfjSAG9sq087b8xIfar0S2qNLaqz9o0b/bWkTiZzoQ4M
         T/Uw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u6si1086147ejm.142.2019.03.14.06.15.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 06:15:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F3CA7AE4B;
	Thu, 14 Mar 2019 13:15:38 +0000 (UTC)
Date: Thu, 14 Mar 2019 14:15:38 +0100
Message-ID: <s5ha7hxsikl.wl-tiwai@suse.de>
From: Takashi Iwai <tiwai@suse.de>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	linux-mm@kvack.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in alloc_pages_exact()
In-Reply-To: <20190314120939.GK7473@dhcp22.suse.cz>
References: <20190314093944.19406-1-vbabka@suse.cz>
	<20190314094249.19606-1-vbabka@suse.cz>
	<20190314101526.GH7473@dhcp22.suse.cz>
	<1dc997a3-7573-7bd5-9ce6-3bfbf77d1194@suse.cz>
	<20190314113626.GJ7473@dhcp22.suse.cz>
	<s5hd0mtsm84.wl-tiwai@suse.de>
	<20190314120939.GK7473@dhcp22.suse.cz>
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

On Thu, 14 Mar 2019 13:09:39 +0100,
Michal Hocko wrote:
> 
> On Thu 14-03-19 12:56:43, Takashi Iwai wrote:
> > On Thu, 14 Mar 2019 12:36:26 +0100,
> > Michal Hocko wrote:
> > > 
> > > On Thu 14-03-19 11:30:03, Vlastimil Babka wrote:
> > > > On 3/14/19 11:15 AM, Michal Hocko wrote:
> > > > > On Thu 14-03-19 10:42:49, Vlastimil Babka wrote:
> > > > >> alloc_pages_exact*() allocates a page of sufficient order and then splits it
> > > > >> to return only the number of pages requested. That makes it incompatible with
> > > > >> __GFP_COMP, because compound pages cannot be split.
> > > > >> 
> > > > >> As shown by [1] things may silently work until the requested size (possibly
> > > > >> depending on user) stops being power of two. Then for CONFIG_DEBUG_VM, BUG_ON()
> > > > >> triggers in split_page(). Without CONFIG_DEBUG_VM, consequences are unclear.
> > > > >> 
> > > > >> There are several options here, none of them great:
> > > > >> 
> > > > >> 1) Don't do the spliting when __GFP_COMP is passed, and return the whole
> > > > >> compound page. However if caller then returns it via free_pages_exact(),
> > > > >> that will be unexpected and the freeing actions there will be wrong.
> > > > >> 
> > > > >> 2) Warn and remove __GFP_COMP from the flags. But the caller wanted it, so
> > > > >> things may break later somewhere.
> > > > >> 
> > > > >> 3) Warn and return NULL. However NULL may be unexpected, especially for
> > > > >> small sizes.
> > > > >> 
> > > > >> This patch picks option 3, as it's best defined.
> > > > > 
> > > > > The question is whether callers of alloc_pages_exact do have any
> > > > > fallback because if they don't then this is forcing an always fail path
> > > > > and I strongly suspect this is not really what users want. I would
> > > > > rather go with 2) because "callers wanted it" is much less probable than
> > > > > "caller is simply confused and more gfp flags is surely better than
> > > > > fewer".
> > > > 
> > > > I initially went with 2 as well, as you can see from v1 :) but then I looked at
> > > > the commit [2] mentioned in [1] and I think ALSA legitimaly uses __GFP_COMP so
> > > > that the pages are then mapped to userspace. Breaking that didn't seem good.
> > > 
> > > It used the flag legitimately before because they were allocating
> > > compound pages but now they don't so this is just a conversion bug.
> > 
> > We still use __GFP_COMP for allocation of the sound buffers that are
> > also mmapped to user-space.  The mentioned commit above [2] was
> > reverted later.
> 
> Yes, I understand that part. __GFP_COMP makes sense on a comound page.
> But if you are using alloc_pages_exact then the flag doesn't make sense
> because split out should already do what you want. Unless I am missing
> something.

The __GFP_COMP was taken as a sort of workaround for the problem wrt
mmap I already forgot.  If it can be eliminated, it's all good.

> > But honestly speaking, I'm not sure whether we still need the compound
> > pages.  The change was introduced long time ago (commit f3d48f0373c1
> > in 2005).  Is it superfluous nowadays...?
> 
> AFAIU alloc_pages_exact should do do what you need.

OK, I'll try whether it works with alloc_pages_exact() and dropping
__GFP_COMP.


Thanks!

Takashi

