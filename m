Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8DD9C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 12:09:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DC362085A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 12:09:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DC362085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA9968E0003; Thu, 14 Mar 2019 08:09:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D58C58E0001; Thu, 14 Mar 2019 08:09:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C48BE8E0003; Thu, 14 Mar 2019 08:09:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB588E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 08:09:41 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x21so1956362edr.17
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 05:09:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YtQhGcLf73zD1VUq+C1wZwDrq1I3ur2soEPOIur4+xY=;
        b=TeiJSJZCq3pM62d+nkxd8einHilaL56xc1AXybpJkfBBJL+23yJF80Usky1leGoLFl
         KnLRbckoFWiisItPRT73EaMX5mZoeXROJ4F6AiUJ11FQQ87G47jdKvEIXxTzYnROnVw5
         6NnogDoHQ2X7jItI52J+vgfU3bczhvWVIqS+/VQlIAT6P1YxFcGbm1obWC70Wp5EReWE
         A6VjkjhfsJuC1pqObyexkSe5r+3W1Nlq6P+9tcUD64qsd2+PVG2BNYoiETHOe5XWG0PH
         wxrR7qnlbkj4XHFhjeZadcrkARjhmg2oOtGrxWzFgTn0AZNmqlQ38KkOJxCyJBri9bm5
         05LA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAUyXmiSw0uVWXXgCuXf4RVMRZacnYKWWP/vJ+RloReOopQdepvD
	PHDkNNY3uB2ZDX0KvcbEImJLLqVpiKODj2qYKy5m6nPSDlqDlBhQHndvT1EAd2aN83cvz8USjo9
	CtsyHug8Ul2JZQIq36O7YK+991CDDRS8K3O3e75Zisc0kPzAexFeTsU7OGv6+0ek3aA==
X-Received: by 2002:a17:906:5583:: with SMTP id y3mr32589710ejp.42.1552565380988;
        Thu, 14 Mar 2019 05:09:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCtaeWf9m1OvsQo2XP5H9At+eoaQydMvTvMQeX6sH3a1slgkDSutMD/Qfjsx4vAuCDDYGk
X-Received: by 2002:a17:906:5583:: with SMTP id y3mr32589655ejp.42.1552565379999;
        Thu, 14 Mar 2019 05:09:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552565379; cv=none;
        d=google.com; s=arc-20160816;
        b=HQhL80OmUJwvwagQ7RL7e8GuS37EV3TE6jdozDnS64he10veJD/gkaCFIKSbvwQOgR
         zk7vJ7jOD3/zaVM1buqP8YKavH9F1zJaqSzEw5AmLjtX5tCxyL1sqXR2Dd/AjMNC5v6F
         zx/oqfVx4XCR5yCyYPR0TnbC742AWWUM70v2W9CBx922iUcqjsIAG0zbzBCQ0DMWZ22C
         d3njMRs0NY9eNu27QMejCbk/U7snVDxKefW+Ue3zYiLl6+29UHcCanNhU4+YE0QbRyOU
         FIeuDP5k0OXW61amejTQ2N8F2sHlChnJOxrKjuBIcjXLlaiwv55GXPksFricVbbyYwLI
         s6gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YtQhGcLf73zD1VUq+C1wZwDrq1I3ur2soEPOIur4+xY=;
        b=UQgkVUPdzIQR61S4zWx0v1+ADjQSR+tLLK7nAiMZs4ytunJRmAtJefozhTPOjVM2Gj
         w9k4d15wZj8GH4vkU1m44qIj6FvAl3Bg/gjzDu/c9BYVxY28pTsX3zoyUqVcVnbehe7D
         RcBBWtiFzJQOTf3AeibWprfmTB5yzezoF8S6suY0GAkYvY02qUUGAbMLdUjm7TiztTIO
         IWkLTbm/XQbifIPfzAd6kQnUGahovGIN+xeJkY0835BE5z+zUynPlsRuM7hFP8yBdST2
         VMIHbxDyQEqDs6cr6zqVsI4hg7xKNqtN2KiVOCM9PeMOyoItXYmFvbE9yAg8R92I7xBm
         0Fdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hk8si476345ejb.315.2019.03.14.05.09.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 05:09:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8A95DACAE;
	Thu, 14 Mar 2019 12:09:39 +0000 (UTC)
Date: Thu, 14 Mar 2019 13:09:39 +0100
From: Michal Hocko <mhocko@suse.com>
To: Takashi Iwai <tiwai@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in
 alloc_pages_exact()
Message-ID: <20190314120939.GK7473@dhcp22.suse.cz>
References: <20190314093944.19406-1-vbabka@suse.cz>
 <20190314094249.19606-1-vbabka@suse.cz>
 <20190314101526.GH7473@dhcp22.suse.cz>
 <1dc997a3-7573-7bd5-9ce6-3bfbf77d1194@suse.cz>
 <20190314113626.GJ7473@dhcp22.suse.cz>
 <s5hd0mtsm84.wl-tiwai@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <s5hd0mtsm84.wl-tiwai@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-03-19 12:56:43, Takashi Iwai wrote:
> On Thu, 14 Mar 2019 12:36:26 +0100,
> Michal Hocko wrote:
> > 
> > On Thu 14-03-19 11:30:03, Vlastimil Babka wrote:
> > > On 3/14/19 11:15 AM, Michal Hocko wrote:
> > > > On Thu 14-03-19 10:42:49, Vlastimil Babka wrote:
> > > >> alloc_pages_exact*() allocates a page of sufficient order and then splits it
> > > >> to return only the number of pages requested. That makes it incompatible with
> > > >> __GFP_COMP, because compound pages cannot be split.
> > > >> 
> > > >> As shown by [1] things may silently work until the requested size (possibly
> > > >> depending on user) stops being power of two. Then for CONFIG_DEBUG_VM, BUG_ON()
> > > >> triggers in split_page(). Without CONFIG_DEBUG_VM, consequences are unclear.
> > > >> 
> > > >> There are several options here, none of them great:
> > > >> 
> > > >> 1) Don't do the spliting when __GFP_COMP is passed, and return the whole
> > > >> compound page. However if caller then returns it via free_pages_exact(),
> > > >> that will be unexpected and the freeing actions there will be wrong.
> > > >> 
> > > >> 2) Warn and remove __GFP_COMP from the flags. But the caller wanted it, so
> > > >> things may break later somewhere.
> > > >> 
> > > >> 3) Warn and return NULL. However NULL may be unexpected, especially for
> > > >> small sizes.
> > > >> 
> > > >> This patch picks option 3, as it's best defined.
> > > > 
> > > > The question is whether callers of alloc_pages_exact do have any
> > > > fallback because if they don't then this is forcing an always fail path
> > > > and I strongly suspect this is not really what users want. I would
> > > > rather go with 2) because "callers wanted it" is much less probable than
> > > > "caller is simply confused and more gfp flags is surely better than
> > > > fewer".
> > > 
> > > I initially went with 2 as well, as you can see from v1 :) but then I looked at
> > > the commit [2] mentioned in [1] and I think ALSA legitimaly uses __GFP_COMP so
> > > that the pages are then mapped to userspace. Breaking that didn't seem good.
> > 
> > It used the flag legitimately before because they were allocating
> > compound pages but now they don't so this is just a conversion bug.
> 
> We still use __GFP_COMP for allocation of the sound buffers that are
> also mmapped to user-space.  The mentioned commit above [2] was
> reverted later.

Yes, I understand that part. __GFP_COMP makes sense on a comound page.
But if you are using alloc_pages_exact then the flag doesn't make sense
because split out should already do what you want. Unless I am missing
something.

> But honestly speaking, I'm not sure whether we still need the compound
> pages.  The change was introduced long time ago (commit f3d48f0373c1
> in 2005).  Is it superfluous nowadays...?

AFAIU alloc_pages_exact should do do what you need.

> > Why should we screw up the helper for that reason? Or put in other words
> > why a silent fix up adds any risk?
> 
> IMO, it's good to catch the incompatible usage as early as possible,
> so that others won't hit the same failure again like I did.  There
> aren't so many users of __GFP_COMP in the whole tree, after all.

Yes, completely agreed and warning with a fixup sounds like the safest
option to me. Returning NULL is risky because it essentially introduces a
permanent failure mode as already pointed out.

-- 
Michal Hocko
SUSE Labs

