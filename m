Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34E04C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 07:56:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E013721905
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 07:56:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E013721905
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68B856B0007; Thu, 11 Apr 2019 03:56:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 614046B0008; Thu, 11 Apr 2019 03:56:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DCCE6B000A; Thu, 11 Apr 2019 03:56:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF12D6B0007
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 03:55:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id j3so2646020edb.14
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 00:55:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FY8VqdDHcmvdr4qx1CHQmIyQ7GBMhlGXTGnA2ywRnLk=;
        b=aYJnlfbyJCoOsxJlPijz/T2aodcUGL+8HLNR2V+iZyyjFssnAhn6vjJgFl0f5O6nOQ
         tkXy0wXVzPxSIH1MocQhHloEidb2EcfXP+NKxh4SUKIIo5OK8McPm+swuqBK7tgi4OX6
         vHKJUA0pJJeH+wWlEDNBtDO40J50sCnO+vtbD99mdE7Up6ZW0u2wWYc9SffDjzDSsAir
         UyudWNMMD6QMfZBT3lEDkE0A1HS353V7scOiDcZAtmuIeWqPSIfIkI8ZO7cKBsePtZuv
         3qg4loyBRye7EsKa2apDYIoHME4ivx/iAkwpu/Kd8HEbjUm/Af7vQLzD8gRHPRKG4hsf
         qH1g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXnh14V7L4CR7ZbgpFKFdHO/HmBmENQngBYk9m2sFvn2HgpZF2N
	Yf1LeCkUbZAH8vQXjuutfBN3xF5eyM9lv8uQvGl9kDP4nAOIRdyg1CD+LNhfdCg83S6uB4rryL1
	L2Qz+k0sHJR3YQ6WMkydhlrpUBVEPbuCuj3ObclWMzsjUtACid8HogD4KiQrnLkI=
X-Received: by 2002:a50:a4e4:: with SMTP id x33mr30451735edb.61.1554969359434;
        Thu, 11 Apr 2019 00:55:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxrDR67XcwgoBMWSvxxmoYiv9rHMGOXh76lqeNu18f8cnudw3eruxWoR1e8h3Vye5OaNtb
X-Received: by 2002:a50:a4e4:: with SMTP id x33mr30451699edb.61.1554969358305;
        Thu, 11 Apr 2019 00:55:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554969358; cv=none;
        d=google.com; s=arc-20160816;
        b=cmirKv9OOseL/qCbYH8QHF3OPTHNGeRal7mLZg3ZDMu1KKv2wYmMvbduNuE1hHZpwS
         ViNCWSWP2MXtlN6ECZzA27AnXBFcNIEybUfx0z59rZoCsGkETSzg0NblSTnr/XcMrJaU
         ktAACjfGMvs/JFb4/Wfb7VgpsZ4mZMA4yhDlEJ7dDuK1hbZNFBIV3BvNz5oOEviYELIx
         89iz19INqie7Y+Gak7RpFhMZfuhjIZ1Y0OkABwJQBXNJ5/SlDJZlyEMZ4lHEiXMVS0TJ
         mwXhPRiDKMay29Y1Ark3ifiPCOpKFiST0+wDQkxTGxcMkuiBb6qgC4C1+o7KhIiRG6R2
         /PbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FY8VqdDHcmvdr4qx1CHQmIyQ7GBMhlGXTGnA2ywRnLk=;
        b=LiTf8nvjJsFcPz5sww7GIesIqH53PMn1Oe58Ha+DjriqpZTHRalHnxP5T8cB6L5d9j
         hOShFN5wA7gwtGAdO0tiNga+f0N4I+KqHjEsVhFcjYIAYN+1Ew+kNmoXlozmHMo5cPUJ
         3RzWaPQYE/tINcdlRtv8gxc0nfTinRgExTNMfSz1g9iEaQ03GSbjfEcfm9ZLJp7YJJeT
         +GA++v+H7zNZDgH2cicvzBEzGzxpm+sWmduslORXyAKAHC7nOw65x8Nomb/kbtE8eRDT
         4Rm5ywAbkLqOuwvgGXsEdXIobhM+gEqnNTK1vDwSnxAtTgrFXyEXlXB0EA3txNWzY7cu
         0Kdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a17si426455eds.424.2019.04.11.00.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 00:55:58 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AFE66ACAE;
	Thu, 11 Apr 2019 07:55:57 +0000 (UTC)
Date: Thu, 11 Apr 2019 09:55:56 +0200
From: Michal Hocko <mhocko@kernel.org>
To: "Tobin C. Harding" <me@tobin.cc>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>,
	Qian Cai <cai@lca.pw>,
	Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 0/1] mm: Remove the SLAB allocator
Message-ID: <20190411075556.GO10383@dhcp22.suse.cz>
References: <20190410024714.26607-1-tobin@kernel.org>
 <f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz>
 <20190410081618.GA25494@eros.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410081618.GA25494@eros.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 10-04-19 18:16:18, Tobin C. Harding wrote:
> On Wed, Apr 10, 2019 at 10:02:36AM +0200, Vlastimil Babka wrote:
> > On 4/10/19 4:47 AM, Tobin C. Harding wrote:
> > > Recently a 2 year old bug was found in the SLAB allocator that crashes
> > > the kernel.  This seems to imply that not that many people are using the
> > > SLAB allocator.
> > 
> > AFAIK that bug required CONFIG_DEBUG_SLAB_LEAK, not just SLAB. That
> > seems to imply not that many people are using SLAB when debugging and
> > yeah, SLUB has better debugging support. But I wouldn't dare to make the
> > broader implication :)
> 
> Point noted.
> 
> > > Currently we have 3 slab allocators.  Two is company three is a crowd -
> > > let's get rid of one. 
> > > 
> > >  - The SLUB allocator has been the default since 2.6.23
> > 
> > Yeah, with a sophisticated reasoning :)
> > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a0acd820807680d2ccc4ef3448387fcdbf152c73
> > 
> > >  - The SLOB allocator is kinda sexy.  Its only 664 LOC, the general
> > >    design is outlined in KnR, and there is an optimisation taken from
> > >    Knuth - say no more.
> > > 
> > > If you are using the SLAB allocator please speak now or forever hold your peace ...
> > 
> > FWIW, our enterprise kernel use it (latest is 4.12 based), and openSUSE
> > kernels as well (with openSUSE Tumbleweed that includes latest
> > kernel.org stables). AFAIK we don't enable SLAB_DEBUG even in general
> > debug kernel flavours as it's just too slow.
> 
> Ok, so that probably already kills this.  Thanks for the response.  No
> flaming, no swearing, man! and they said LKML was a harsh environment ...
> 
> > IIRC last time Mel evaluated switching to SLUB, it wasn't a clear
> > winner, but I'll just CC him for details :)
> 
> Probably don't need to take up too much of Mel's time, if we have one
> user in production we have to keep it, right.

Well, I wouldn't be opposed to dropping SLAB. Especially when this is
not a longterm stable kmalloc implementation anymore. It turned out that
people want to push features from SLUB back to SLAB and then we are just
having two featurefull allocators and double the maintenance cost.

So as long as the performance gap is no longer there and the last data
from Mel (I am sorry but I cannot find a link handy) suggests that there
is no overall winner in benchmarks then why to keep them both?

That being said, if somebody is willing to go and benchmark both
allocators to confirm Mel's observations and current users of SLAB
can confirm their workloads do not regress either then let's just drop
it.

Please please have it more rigorous then what happened when SLUB was
forced to become a default
-- 
Michal Hocko
SUSE Labs

