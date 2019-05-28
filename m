Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DF6CC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:38:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39DC72075B
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:38:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39DC72075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D88BF6B0270; Tue, 28 May 2019 03:38:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D388D6B0273; Tue, 28 May 2019 03:38:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C01886B0275; Tue, 28 May 2019 03:38:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7694A6B0270
	for <linux-mm@kvack.org>; Tue, 28 May 2019 03:38:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c26so31722436eda.15
        for <linux-mm@kvack.org>; Tue, 28 May 2019 00:38:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AcLaRZRChUmoRTMKVPGnmvq5xfwWInnjLpKFMK+vA2Y=;
        b=XFuzAOieYJyDaxEOYayGb73r1OFwiCAqmLccRJnqkRyaKVAeIFtGLPi2M6OyrMYeZW
         ts6RtF/6SecTxIiyKnwX7uHNWCk8cCg/8PEfureJGxauA7FY0POmVMUYdp8hFT5s4Wcg
         KUHyNMWD3gvZrP0tgPAD3DU0QusMOhmqmV07oeiZfXVwTcoISwmqHodcOK/x3xJxZa7N
         TtLctoSSgQrfydQmhYoXITnkvEhkmPuBoY909xsECyrVchU9X92Da+RLuE7WkTZJlUot
         CSe7HQpqoANumJ979pjnxBB9YLWwJc21hvjJhS5ScGdR23ZyHrlShPa1kxoOOKSMNNUy
         s7dA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW+jYno+WBrt++eOyng7sn0MOPT/Fxq5wClighwQkmx2aDV6NGF
	iws9zRuvxWETWG7uMFE4/z1L+jjIe0yMPLNJ4Vim6+dslrbZCO2jstCdq2BHr9C9fsCYTBLhhia
	A84NjXbeA9BSBXY8mJtOXzePeSHy0CufwHfgo+TkTIUAgjs+K0KJQH707W5+BEZI=
X-Received: by 2002:a05:6402:1543:: with SMTP id p3mr3394351edx.108.1559029119058;
        Tue, 28 May 2019 00:38:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdBKie8yDXgKJ/8KDTsApb+bZgnyJrKNR3FdWK5mZcAIlx0bivYn8f+xv4fWyXys4kl7Iu
X-Received: by 2002:a05:6402:1543:: with SMTP id p3mr3394304edx.108.1559029118300;
        Tue, 28 May 2019 00:38:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559029118; cv=none;
        d=google.com; s=arc-20160816;
        b=FZkJfCCOsRb5oXcyW4f0JEDqtUw12sodXHuxDmpML0fisBPQ8UiEOFU2zYkym0Me3Y
         3oOgEQFSASWvBt5+I5M1mMd7pRbQ5W8A88LvpEwgU7Wx6215Tsbr3Vr0eyQKeqUR2zR3
         E0YW0nr/wzo7oELuaRXeKzdhvGBbpS5MEZRvBiCBBYc4CvVr3zGpnMVUlSODWTuN8Xn5
         nfN8eO0zpK7dgNpkjTHeL2wlfo7C9B0z62WKX/VZ6697JM+T9r20DlRkY3m/H6qkuBz/
         RZcwpyDS7xFWAF+nhHSGuakJR09XGnkngfLH32KU+qnSwrFPclRTecPjleNsPMcBO0aF
         ws9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AcLaRZRChUmoRTMKVPGnmvq5xfwWInnjLpKFMK+vA2Y=;
        b=d3KILFSAo7YvC3puQrbwOi6WEZ7vgvo/7HRyVl8hB7zu6Q52EylaxAyjlYxle/W4cW
         G3VLhNdmxBLw4J8achSkQc5vxGlaRnMbpus6iWzkBnHmzurz9iVKTmBIjjovXPKu1kfj
         1nOV+1iFvfP4HJm6ntuekZvnY/ofKGxFgLOxUui31PvJpKtszYuB8nlVY6Hqy38lP6c6
         SaDZgLtapS75vTx9yzhB991l8nUeGmMxHo5kxp5RJw9C7cRpMj/d6SLTDkFmW7JTCvb7
         jRo4Kzme6pGKrVwpSf7c7X792PTIfeOkToAnqn5VICfuGc6y5ydwz2Jha7iPZno3yqxf
         BDsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h23si2652354edb.300.2019.05.28.00.38.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 00:38:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 33E0EAE2E;
	Tue, 28 May 2019 07:38:37 +0000 (UTC)
Date: Tue, 28 May 2019 09:38:35 +0200
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
Message-ID: <20190528073835.GP1658@dhcp22.suse.cz>
References: <155895155861.2824.318013775811596173.stgit@buzz>
 <20190527141223.GD1658@dhcp22.suse.cz>
 <20190527142156.GE1658@dhcp22.suse.cz>
 <20190527143926.GF1658@dhcp22.suse.cz>
 <9c55a343-2a91-46c6-166d-41b94bf5e9c8@yandex-team.ru>
 <20190528065153.GB1803@dhcp22.suse.cz>
 <a4e5eeb8-3560-d4b4-08a0-8a22c677c0f7@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a4e5eeb8-3560-d4b4-08a0-8a22c677c0f7@yandex-team.ru>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 10:30:12, Konstantin Khlebnikov wrote:
> On 28.05.2019 9:51, Michal Hocko wrote:
> > On Tue 28-05-19 09:25:13, Konstantin Khlebnikov wrote:
> > > On 27.05.2019 17:39, Michal Hocko wrote:
> > > > On Mon 27-05-19 16:21:56, Michal Hocko wrote:
> > > > > On Mon 27-05-19 16:12:23, Michal Hocko wrote:
> > > > > > [Cc linux-api. Please always cc this list when proposing a new user
> > > > > >    visible api. Keeping the rest of the email intact for reference]
> > > > > > 
> > > > > > On Mon 27-05-19 13:05:58, Konstantin Khlebnikov wrote:
> > > > > [...]
> > > > > > > This implements manual kswapd-style memory reclaim initiated by userspace.
> > > > > > > It reclaims both physical memory and cgroup pages. It works in context of
> > > > > > > task who calls syscall madvise thus cpu time is accounted correctly.
> > > > > 
> > > > > I do not follow. Does this mean that the madvise always reclaims from
> > > > > the memcg the process is member of?
> > > > 
> > > > OK, I've had a quick look at the implementation (the semantic should be
> > > > clear from the patch descrition btw.) and it goes all the way up the
> > > > hierarchy and finally try to impose the same limit to the global state.
> > > > This doesn't really make much sense to me. For few reasons.
> > > > 
> > > > First of all it breaks isolation where one subgroup can influence a
> > > > different hierarchy via parent reclaim.
> > > 
> > > madvise(NULL, size, MADV_STOCKPILE) is the same as memory allocation and
> > > freeing immediately, but without pinning memory and provoking oom.
> > > 
> > > So, there is shouldn't be any isolation or security issues.
> > > 
> > > At least probably it should be limited with portion of limit (like half)
> > > instead of whole limit as it does now.
> > 
> > I do not think so. If a process is running inside a memcg then it is
> > a subject of a limit and that implies an isolation. What you are
> > proposing here is to allow escaping that restriction unless I am missing
> > something. Just consider the following setup
> > 
> > 		root (total memory = 2G)
> > 		 / \
> >             (1G) A   B (1G)
> >                     / \
> >             (500M) C   D (500M)
> > 
> > all of them used up close to the limit and a process inside D requests
> > shrinking to 250M. Unless I am misunderstanding this implementation
> > will shrink D, B root to 250M (which means reclaiming C and A as well)
> > and then globally if that was not sufficient. So you have allowed D to
> > "allocate" 1,75G of memory effectively, right?
> 
> It shrinks not 'size' memory - only while usage + size > limit.
> So, after reclaiming 250M in D all other levels will have 250M free.

Could you define the exact semantic? Ideally something for the manual
page please?
-- 
Michal Hocko
SUSE Labs

