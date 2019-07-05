Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 943ABC4649B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 11:10:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6023B216FD
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 11:10:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6023B216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E30AF6B0003; Fri,  5 Jul 2019 07:10:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE21E8E0003; Fri,  5 Jul 2019 07:10:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA9878E0001; Fri,  5 Jul 2019 07:10:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3DE6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 07:10:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i9so5446819edr.13
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 04:10:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=V2JhDjtGu+u+nKAmdW5GQ5ijlTDE398y1Wv+eW3SG7s=;
        b=G1dfDsMVxf+vkIGeqKOhWo1bQaKg3ShEwMvDzTLdcqUE8PE4gmNBbD+BV5DPz5AAzA
         FGF1uQugWOVSz4IbbvaFNl7JOVNNwf7sKSFy//inyAIj0aOJBisv9uYrGoqACOVhitks
         yyNhvvqjod+RDJUY/Y7lL2qkW/5UXoL2dQuujIGL7yxPsdD4Mg9f6oHe+v/lB3vvjjiJ
         jKS1mQ+pY7Z5kIYx551gCTq9Xkq607z8LQlxAkV8Q4nKi4DNWsDF2qUfcYG620T+IjmI
         br1Z1ynn+mN3BwIgsrkutiXqnklux2H+7imBMEeB1A57YD1it7WSKGcC9MHNv0cmB23R
         nFlw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUYlU1HByaGo/9PTSyLX6khxb5+6+lLdykVtOWUC5jwpjVEhznT
	4FKTPQ6qnT1H6GtdSVDZ+GWPopldeJevif+JTAaoTpZswC5Fjd5BICdDtwd5wh1YwzH8jkX/1hh
	esXAd/fATCpP5YHXgcyhvQIbQcoy7kY5PEAvhjts5Q9qSNqdNy37oPOJIEMR8Fvw=
X-Received: by 2002:a50:b3b8:: with SMTP id s53mr3803541edd.61.1562325046092;
        Fri, 05 Jul 2019 04:10:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNTarVgHSt4DhbIhyyObtVykxrfG24UGb6RqyKDyJ6zV3BA18JJ+WJY07OgjyD1kcDrgZ1
X-Received: by 2002:a50:b3b8:: with SMTP id s53mr3803492edd.61.1562325045356;
        Fri, 05 Jul 2019 04:10:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562325045; cv=none;
        d=google.com; s=arc-20160816;
        b=srcaD+b8ka5O102LYeEPFqWdpMaJJXAbrWOumUhEzW9tIvqO12TYsRC9oMmER0qDGn
         pcTOCUwR0SOYCDNARE1v9DT2Y1dVkbNbcsWQr9nqEGWg2vrVbUVhwithQ9raJZD0uPNl
         LeLIPguQzuEtugWhXiXR8rt19qHHziRVe3bn+XA6Urbn0prO6ioZa7AUBvsN5o7bR2iE
         XM9YFhAnBvnohN6oJdVmbh7USIJzwLgr7CfXXH8QXTpDIKbBpH9XBzm62NoHVByEDHvi
         9x66hDsjsS3Daepc7lGTTJNPn5VlOV32ogvHIbfCv5m9Vasco64DKXw3cuZeHzZqOpqk
         mf1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=V2JhDjtGu+u+nKAmdW5GQ5ijlTDE398y1Wv+eW3SG7s=;
        b=nSNO0NP/BZpfYaD0jj+Cp6w+VZ8kUQsmCZmdbmICcgqcahBXsiILZJaFzjCSH9hpOH
         ldsC6r3dM+cQ/sSIHBHV3oCG8IWorkvRYCPYySc1rd59tFrZrQ1VlxyRYB+y9UAi9K8X
         t35hQ6C676zimFGpbsHiOzaw3tzYcFlwZHmQ+0JgEyiwvdxGd9LmpB3/PuNoI80hm00O
         tpAh8sMl7iIsAttVCO63OU4x2DcopagrZCY3fmOzv1Uem96CUoQBZRlYTlJptUiLiJ2l
         yznw7PIc7YYOR065QFukDdw8YR2gKagOwczwNLhG/Wkkysk4Ipbn3NW5k95JjAt6L4Od
         OZ8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f44si1092615edb.68.2019.07.05.04.10.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 04:10:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 84179AF47;
	Fri,  5 Jul 2019 11:10:44 +0000 (UTC)
Date: Fri, 5 Jul 2019 13:10:43 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm, memcg: support memory.{min, low} protection in
 cgroup v1
Message-ID: <20190705111043.GJ8231@dhcp22.suse.cz>
References: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
 <20190705090902.GF8231@dhcp22.suse.cz>
 <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 05-07-19 17:41:44, Yafang Shao wrote:
> On Fri, Jul 5, 2019 at 5:09 PM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > Why cannot you move over to v2 and have to stick with v1?
> Because the interfaces between cgroup v1 and cgroup v2 are changed too
> much, which is unacceptable by our customer.

Could you be more specific about obstacles with respect to interfaces
please?

> It may take long time to use cgroup v2 in production envrioment, per
> my understanding.
> BTW, the filesystem on our servers is XFS, but the cgroup  v2
> writeback throttle is not supported on XFS by now, that is beyond my
> comprehension.

Are you sure? I would be surprised if v1 throttling would work while v2
wouldn't. As far as I remember it is v2 writeback throttling which
actually works. The only throttling we have for v1 is reclaim based one
which is a huge hammer.
-- 
Michal Hocko
SUSE Labs

