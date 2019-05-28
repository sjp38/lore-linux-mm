Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ED99C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:42:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FFEF2075B
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:42:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FFEF2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF64E6B0272; Tue, 28 May 2019 04:42:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCD0B6B0273; Tue, 28 May 2019 04:42:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE2386B0275; Tue, 28 May 2019 04:42:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 828646B0272
	for <linux-mm@kvack.org>; Tue, 28 May 2019 04:42:46 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p14so32067751edc.4
        for <linux-mm@kvack.org>; Tue, 28 May 2019 01:42:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uuLRQ7XS5jFrWN8OlnUspauj6DTO5Q4Ic76ad5i5rb0=;
        b=dT3EHrAJdYSbu/HNXrAwnEniDuHCk093qVVGv2+SPoMyPQCsdC1Rvm2naP0xOsL+FX
         K7lwGUnJOv8m+MRfN6zALTMe8Q8JkectER+KJwAXKu/rEvKqbJt1rR2dpBL4zrD71M1o
         AyUtcb/1NS3acK72PGTjXx7QMRkCK/3bdz5CmY07ZGAdopYBF201S0EkW5zexZ89VXwg
         /xml61i3By2dhevtd5DORbHd5C4uKgkqI79uLEMHZfLNqwWNnGl52ff6WKQq4tkksKHT
         EELzyEJZF8YijT/rvNUuJxMfQgjjqe1f2pe/blorMPIbQ5zZ+kZXg+0Zb+IhkM1R0NrP
         QgCQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWcXR7vxML7pXSRXv3YZI1haaTQ1UxLM7NPQLyADijKOQ/eeI/m
	k1aKslmi3FH3TgmaNfC8nglAYFdidZ98pOnWmFB10tr2IpSHshegwXAYAJC6s1b5j4kz6ByXp1W
	lh6UUKAgbQtZwedDoqvZWuT51bR4mvZPiOabWgRcOyo239hrXtJCPFcq+dO0LrvU=
X-Received: by 2002:a17:906:1942:: with SMTP id b2mr33545314eje.272.1559032966096;
        Tue, 28 May 2019 01:42:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5kp2NuibQfhSVOFBxtpFOgLUSWDDX1VeRwzF5NUgCsDh+zJM7o9Aw1nYwNWrXba+AyaBR
X-Received: by 2002:a17:906:1942:: with SMTP id b2mr33545273eje.272.1559032965394;
        Tue, 28 May 2019 01:42:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559032965; cv=none;
        d=google.com; s=arc-20160816;
        b=ueJKzTvWO18HlIjp44DozTp0KjpnSAliO9/l5j+okGhTZB4BnWDYpTscP/yxUn9oRt
         4akE9oa+YIsFb4+Mhxv4l4egvYubVdlT+Tm6/320h9iBLX1s+i0AfEhxqDrtikLX7jED
         4v5ovrayNEdauTne24ms5ykNKfoy5dnn1oVx/RzC2aqNFd+Qnm0Mjfkp8TmfcOl9ZZuE
         4HuMsJmsY+aLsaCkW0nVFzdWe0RJ8AszUZX0ce7h0RY/JX1nsUEAXwtgvXJ1Ja0Sh1hD
         wre6bRkUOSnconL8Dz/nJLgTYoKIJuJvu0qW9vWG24nryO/AE0dQNppwPIfudj3jTMWq
         5HNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uuLRQ7XS5jFrWN8OlnUspauj6DTO5Q4Ic76ad5i5rb0=;
        b=EfP2k6/T/fO1LOuy8YKbcmxdm9BpQOHPgVPOEa/rs+wZuIoDaCiW0aZI7tVTRYink5
         PxgaHz4MJi7I4t3ZEDq4H0VDl5d749M68S1Hk0J4MFLA1AwpQscxOC9BxSchMJb5Qfv+
         sj/5/4YVnvkmBbpEWGGKZzp+jWQ69Y0nB2l26ijq0NB70Um+jrrF+1nmLL7GApQ8NDSW
         tLoCF0/fXix3GtyYrCW2hVzWYdmM5aQbjJ7CT6SBxbXxnaPrOgaH8f1wi6DhdIx3kx/H
         wHKtI7jgtY5eGnHAv2Imwl9O+yW4iGXlzVscPBErTHe9CcfV9BD34izHZYuZWjdtbcPp
         Bsxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p28si4720349edc.405.2019.05.28.01.42.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 01:42:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 83E45ADD4;
	Tue, 28 May 2019 08:42:44 +0000 (UTC)
Date: Tue, 28 May 2019 10:42:43 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Roman Gushchin <guro@fb.com>, linux-api@vger.kernel.org
Subject: Re: [PATCH RFC] mm/madvise: implement MADV_STOCKPILE (kswapd from
 user space)
Message-ID: <20190528084243.GT1658@dhcp22.suse.cz>
References: <155895155861.2824.318013775811596173.stgit@buzz>
 <20190527141223.GD1658@dhcp22.suse.cz>
 <20190527142156.GE1658@dhcp22.suse.cz>
 <20190527143926.GF1658@dhcp22.suse.cz>
 <9c55a343-2a91-46c6-166d-41b94bf5e9c8@yandex-team.ru>
 <20190528065153.GB1803@dhcp22.suse.cz>
 <a4e5eeb8-3560-d4b4-08a0-8a22c677c0f7@yandex-team.ru>
 <20190528073835.GP1658@dhcp22.suse.cz>
 <5af1ba69-61d1-1472-4aa3-20beb4ae44ae@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5af1ba69-61d1-1472-4aa3-20beb4ae44ae@yandex-team.ru>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 11:04:46, Konstantin Khlebnikov wrote:
> On 28.05.2019 10:38, Michal Hocko wrote:
[...]
> > Could you define the exact semantic? Ideally something for the manual
> > page please?
> > 
> 
> Like kswapd which works with thresholds of free memory this one reclaims
> until 'free' (i.e. memory which could be allocated without invoking
> direct recliam of any kind) is lower than passed 'size' argument.

s@lower@higher@ I guess

> Thus right after madvise(NULL, size, MADV_STOCKPILE) 'size' bytes
> could be allocated in this memory cgroup without extra latency from
> reclaimer if there is no other memory consumers.
> 
> Reclaimed memory is simply put into free lists in common buddy allocator,
> there is no reserves for particular task or cgroup.
> 
> If overall memory allocation rate is smooth without rough spikes then
> calling MADV_STOCKPILE in loop periodically provides enough room for
> allocations and eliminates direct reclaim from all other tasks.
> As a result this eliminates unpredictable delays caused by
> direct reclaim in random places.

OK, this makes it more clear to me. Thanks for the clarification!
I have clearly misunderstood and misinterpreted target as the reclaim
target rather than free memory target.  Sorry about the confusion.
I sill think that this looks like an abuse of the madvise but if there
is a wider consensus this is acceptable I will not stand in the way.

-- 
Michal Hocko
SUSE Labs

