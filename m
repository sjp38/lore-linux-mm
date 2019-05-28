Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C964C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:51:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C5A82070D
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:51:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C5A82070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4D096B0270; Tue, 28 May 2019 02:51:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD7136B0276; Tue, 28 May 2019 02:51:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B13216B0278; Tue, 28 May 2019 02:51:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 651AD6B0270
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:51:58 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e21so31589777edr.18
        for <linux-mm@kvack.org>; Mon, 27 May 2019 23:51:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gaGdUM5sQCeTg0O9IhoioeaAWOdEdeRwoc2RhdOE+7s=;
        b=qolt6bkO211pp1aToKRcBlkOtjQtv1B6VV4rSREXvUdnpvcIxpixG7au+HnJmyco3S
         1dflz1uitpNGc7kGV4O2GHo+09Tld7EtBmx/zFiIm7O/4Z3H1i2w1e1/jkmm4RUdR1Hf
         0ObsxsRQ6CIrv7e2oz6SmKx/7bBWIHpYmSViHcSZfxfvd/nkW0agDF2yO5imw+N+2zte
         xtYG0DnpIibphf6FX0RHnkiBc4JG2aPuF5k3dSOGc7qYSibZ61OeaAc0eRkw61+Uxa3d
         buI/DYyejWsbTYlgPFiXWBnLVy1ge0rQw4H6uc+nyQvJJTQ/xgJ8ZW84Nw4gRpmEPydL
         Ws4Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW5NeSMroAgOd+gs9+k17N+qoWlO5oExKQMBL3sPhvlW9sZYzO2
	EEj99yHo+1rrFFYyppmPxsicmaWVmCsiyAAi1+dcyFiDBA9A9uOdjKGj4nrkT/A5u0moAswhGJx
	Va3jfova6GJl2ZtZ5kJT09s5DNOs0fW1Zwrgjj9XkxwXRbFqi3cwJZanOe7yE/3w=
X-Received: by 2002:a50:89b7:: with SMTP id g52mr128161590edg.291.1559026317981;
        Mon, 27 May 2019 23:51:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5a4e0tD8INWmn++mzvSOos5FlRUQne48DsaA8wr0Op4NRFM3srbMwRqc1fxzngnlUHiCQ
X-Received: by 2002:a50:89b7:: with SMTP id g52mr128161542edg.291.1559026317266;
        Mon, 27 May 2019 23:51:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559026317; cv=none;
        d=google.com; s=arc-20160816;
        b=mk+FTZzW5sp/KxcvS6Jan7C0oRYZCduSqO91E5s5SfVA1Eg+NAgv4Iva9LAyZ/fUs7
         cXpYMkA5kw24lMlHtAXcfEC8kZWBAQbx/jLHz0SqcqN4QKftE96SYNDcZ3Ibv4jcJ7VR
         qiJX7IUvyAepYDUPx6YTSO3O8WbDuL6oaDTMrSs6m/zjJAueKvkS+SGm9dJaZujKqju3
         cDjeCNy/bzom2JVLwIcOipSmEUO4t2JXip+8YhS7ih8HSYUEyEBh1pg28FmFtzVYXeZa
         gPPxsFiF4k+cY/XTPRd8msOsL7fs6Y5wrSAZwuxSs+XdUt4LwONVaL7NQx1OlDoRRMDQ
         JFdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gaGdUM5sQCeTg0O9IhoioeaAWOdEdeRwoc2RhdOE+7s=;
        b=MYdHuebRO9WLnJciaibK1tZn0q2GI+qTr03EXu6+qdzoZHxz29bKypRDW5D/HqPlgl
         h/DBzXEpFpCvJ85r7lDcMUdZSPnu6g38oFWJWlfSMpVRonDUPgiqygJVkp/ke5+v5fEJ
         3YtiyXuPrxtVTZ+otzPcA3pGcA79WKt/z7GkUlmdZPaKU/KCYReoH0WXoTUy7IWHEI46
         OtUu24shNQiC2nUQpe0U825v61/yvxyaEmAwsVz0C566VKWpvvcKdu/S0bvgvUfKRxmu
         4+OxRbEZYqeeXKDbn8wt+CLqSOnUizkvFflXvSqFzzWt0ImGS3duvasCT0XmkW61z4Nu
         1V4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q8si7730533edg.97.2019.05.27.23.51.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 23:51:57 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 88336AD2B;
	Tue, 28 May 2019 06:51:56 +0000 (UTC)
Date: Tue, 28 May 2019 08:51:53 +0200
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
Message-ID: <20190528065153.GB1803@dhcp22.suse.cz>
References: <155895155861.2824.318013775811596173.stgit@buzz>
 <20190527141223.GD1658@dhcp22.suse.cz>
 <20190527142156.GE1658@dhcp22.suse.cz>
 <20190527143926.GF1658@dhcp22.suse.cz>
 <9c55a343-2a91-46c6-166d-41b94bf5e9c8@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9c55a343-2a91-46c6-166d-41b94bf5e9c8@yandex-team.ru>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 09:25:13, Konstantin Khlebnikov wrote:
> On 27.05.2019 17:39, Michal Hocko wrote:
> > On Mon 27-05-19 16:21:56, Michal Hocko wrote:
> > > On Mon 27-05-19 16:12:23, Michal Hocko wrote:
> > > > [Cc linux-api. Please always cc this list when proposing a new user
> > > >   visible api. Keeping the rest of the email intact for reference]
> > > > 
> > > > On Mon 27-05-19 13:05:58, Konstantin Khlebnikov wrote:
> > > [...]
> > > > > This implements manual kswapd-style memory reclaim initiated by userspace.
> > > > > It reclaims both physical memory and cgroup pages. It works in context of
> > > > > task who calls syscall madvise thus cpu time is accounted correctly.
> > > 
> > > I do not follow. Does this mean that the madvise always reclaims from
> > > the memcg the process is member of?
> > 
> > OK, I've had a quick look at the implementation (the semantic should be
> > clear from the patch descrition btw.) and it goes all the way up the
> > hierarchy and finally try to impose the same limit to the global state.
> > This doesn't really make much sense to me. For few reasons.
> > 
> > First of all it breaks isolation where one subgroup can influence a
> > different hierarchy via parent reclaim.
> 
> madvise(NULL, size, MADV_STOCKPILE) is the same as memory allocation and
> freeing immediately, but without pinning memory and provoking oom.
>
> So, there is shouldn't be any isolation or security issues.
> 
> At least probably it should be limited with portion of limit (like half)
> instead of whole limit as it does now.

I do not think so. If a process is running inside a memcg then it is
a subject of a limit and that implies an isolation. What you are
proposing here is to allow escaping that restriction unless I am missing
something. Just consider the following setup

		root (total memory = 2G)
		 / \
           (1G) A   B (1G)
                   / \
           (500M) C   D (500M)

all of them used up close to the limit and a process inside D requests
shrinking to 250M. Unless I am misunderstanding this implementation
will shrink D, B root to 250M (which means reclaiming C and A as well)
and then globally if that was not sufficient. So you have allowed D to
"allocate" 1,75G of memory effectively, right?
 
> > 
> > I also have a problem with conflating the global and memcg states. Does
> > it really make any sense to have the same target to the global state
> > as per-memcg? How are you supposed to use this interface to shrink a
> > particular memcg or for the global situation with a proportional
> > distribution to all memcgs?
> 
> For now this is out of my use cease. This could be done in userspace
> with multiple daemons in different contexts and connection between them.
> In this case each daemon should apply pressure only its own level.

Do you expect all daemons to agree on their shrinking target? Could you
elaborate? I simply do not see how this can work with memcgs lower in
the hierarchy having a smaller limit than their parents.
-- 
Michal Hocko
SUSE Labs

