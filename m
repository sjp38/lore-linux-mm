Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DCD8C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 18:32:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 307A12080A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 18:32:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 307A12080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C70A96B0003; Tue, 18 Jun 2019 14:32:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C20F08E0002; Tue, 18 Jun 2019 14:32:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE9C68E0001; Tue, 18 Jun 2019 14:32:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 61C466B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 14:32:11 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so22403782eda.9
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 11:32:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Pgi3eh8l4DYLjZNJqe2mrfbOJhFUtRxuZv018W11OCE=;
        b=fB5cilCneXI8ikaq2WL1Vi6sB7kBWMMAhwi16Mr+obFudT4/T+XMBcUPUOckAeVJji
         0AIS9YaLKtDnLFCzzHSMHT8OUMV/5y54t4JK/cp70AUodIZryBnmyXTpTvbYcaiD9+Sp
         5yWCrFNBYWDXg5SfZhGnjq0hRf96oS/xu8ntBTrKMX1jvyZ77PZSG6At/ifhAnoM9oAK
         R7eXiFM4Sjkf4RQp0+e4c7OoBV8JmTWsaWkWd0odHSViJpVwBkQpNlz2kiocvMMj2oaJ
         O+sRIbiLK3iQdRlXibDW9+Gef8IDx2rEXzVUj/LWN/VLU5wQeHhjtP01krfb+3qogBpj
         Ofiw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUlCHI9T4EHdm6zweuTNSn/RmLg6b1T+GssgbzKMceVK64KLDIh
	I/6daASxm3j0uNmOK4VryLHLYTcBNweZqhDy6vOSKAGOQNQhY2W9GSJJD50Ho6y8uLhO5wo8+kd
	I/+e4L8Gi3li0wKZhH626xPqIPP9spKlZhSpJxZ3lImcK6/0AFarIU2msi6EiZjk=
X-Received: by 2002:a50:94d9:: with SMTP id t25mr92727251eda.32.1560882730974;
        Tue, 18 Jun 2019 11:32:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7Z3UkQaTQE192rEWBoqGa1D2hofHoudGbd9kdO76jlfQp8mgfpL8bk9rcVElBnz9CPYr0
X-Received: by 2002:a50:94d9:: with SMTP id t25mr92727192eda.32.1560882730394;
        Tue, 18 Jun 2019 11:32:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560882730; cv=none;
        d=google.com; s=arc-20160816;
        b=iGc5/820Ulm+accSaLk9NcsANB99HOzzd2pxapdZNsU3Zcg/EOhL5RRR3lD/4ZtEmx
         /dD9FBbTYVniRWnntPvS7r9MyyQsETzrqb3b7IMvqYUjk6vjRtJZOy/9Hsu7jzj7Jnwr
         tLHwFldW/tNrA+aag6T1ml5TzLTCDn1XiWlDJL4vV+uR/e3anVamhc/JbFjGmkzA5c1n
         9dk4lRUyfJKY2/nh+SfVnSXCPGIzBvOXZCQGIBewv8BszuHn60hl540pIoBY3J68zsRt
         Vxt86TA9etFWLf7FqZyD5xi/D+ggLQs1YavXkN2d48i/TnZyTwz5JrEWNQlO9EZhfvqP
         r/LA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Pgi3eh8l4DYLjZNJqe2mrfbOJhFUtRxuZv018W11OCE=;
        b=c5q+GTI7oQoRSKss+2AVM4OHOBA42eCwayWy1p2V7hmkdjFVu5LvckmS9NFPD5BwKK
         sL7Bn1TENpaiYmIYxUhVlN+f3CkZaw92dqphr1vDhOALuNi63+d5RHxAlhQu89r7sncw
         2OmbH8l9y8R7nOOZDTPUkuvg/myTVQvyz1/NjFN29+fSAEfBF/qT7+LkMuLxMrNSJ9Ss
         6LyO/NaZZSe9V3A611DlSh5Ael/vuMLnHcnNQu4KWlrdRUw8xbFutw5fHeIFKuEP2Bw7
         C0A6hj7oB3sKzbo9Bsuemgc3RuveIT96jvr+roBYqhsNic5lfadk9r4zbHcotXLQADob
         2Gww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j2si7669300edh.405.2019.06.18.11.32.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 11:32:10 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E7E15AF56;
	Tue, 18 Jun 2019 18:32:09 +0000 (UTC)
Date: Tue, 18 Jun 2019 20:32:08 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	linux-api@vger.kernel.org
Subject: Re: [PATCH] mm, memcg: Report number of memcg caches in slabinfo
Message-ID: <20190618183208.GK3318@dhcp22.suse.cz>
References: <20190617142149.5245-1-longman@redhat.com>
 <20190617143842.GC1492@dhcp22.suse.cz>
 <9e165eae-e354-04c4-6362-0f80fe819469@redhat.com>
 <20190618123750.GG3318@dhcp22.suse.cz>
 <dee4dee2-1f4f-a7c9-0014-dca54b991377@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dee4dee2-1f4f-a7c9-0014-dca54b991377@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 18-06-19 12:59:24, Waiman Long wrote:
> On 6/18/19 8:37 AM, Michal Hocko wrote:
[...]
> > Is this useful enough to put into slabinfo? Doesn't this sound more like
> > a debugfs kinda a thing?
> 
> I guess it is probably more on the debug side of things. I add it to
> slabinfo as the data is readily available. It will be much more work if
> we need to export the data via debugfs.
> 
> We are seeing the kmem_cache slab growing continuously overtime when
> running a container-based workloads. Roman's kmem_cache reparenting
> patch will hopefully solve a major part of the problem, but we still
> need a way to confirm that by looking at how many memcg kmem_caches are
> associated with each root kmem_cache.

I am not disputing usefulness. Dead memcgs are showing up as a problem
for a longer time and having a more debugging information is definitely
useful. I am just not really sure that /proc/slabinfo is the proper
vehicle for that information. It might be just easier to stick it there
but that is not the best justification for adding something we will have
to maintain for ever. Not to mention that the number of dead memcgs
might not be enough to debug further when we can easily end up needing
to provide more in something less "carved in stone" kinda interface like
debugfs.

-- 
Michal Hocko
SUSE Labs

