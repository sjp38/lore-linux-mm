Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECAF1C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:02:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B26C2206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:02:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B26C2206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 497096B0005; Thu, 18 Apr 2019 05:02:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 420756B0006; Thu, 18 Apr 2019 05:02:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 311D36B0007; Thu, 18 Apr 2019 05:02:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EA2236B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:02:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e6so878818edi.20
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:02:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DoQyDe4iN4rSDSn59KCg88licv4gudixO5kqMTZt/aM=;
        b=lSu6Q1sfhVG9ZnKHM5Q2gnKBB45z8rqpc+zmMjLnT+Ie0BBQffgS6/glGib11lDvKi
         lJkERgf7OtrS9RZuu/nSWhQj49bE/0op5R+2DI2lkfXouv5mBRXifvVVlZLTOH9RXjpa
         nXJK3kigyJpPOT3m+Lm6+f8wd5Pg9JFa/KG3wKYPjcpAuWkMR3xnvrjeNKBZD5ttsfJJ
         4mjtFnKxx21OTpo/l1uqJcqdGEWu8JAlLPVRdTECja2jFJEuXJqn6FISAO9r01cWlNMA
         lxu4dskoQLqOOQjfEHCx9j27OW0M8Eaw3v4o2KRnABeXEkgB9MzTl9AC1lmKpCdhBlW/
         lKCg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUv/+vQm4EzwVsOf3QSQer8PC+s2txcrVfeHCTenA/zSosBjFSQ
	XYdXajKvs8fFanLrxSJLVFzcBxuE4Yvl1msaXe2jDg6y82Jm7OQnGkzg5Vd71RkRl3w2PjSrZfD
	NBHZCIkd9buxfPp5RKRBrmZYUILeS0dgQi0Ke3p36fO5Y5nX7pq4N3pEWeu2RqXY=
X-Received: by 2002:a50:85c6:: with SMTP id q6mr59789563edh.109.1555578150424;
        Thu, 18 Apr 2019 02:02:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx16jMSMHPUBwpcdXnfwwC4tNpb4SxdaWI3syjzqdVp05TygWuhypaBcY19OZkjlCbQPbsS
X-Received: by 2002:a50:85c6:: with SMTP id q6mr59789501edh.109.1555578149268;
        Thu, 18 Apr 2019 02:02:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578149; cv=none;
        d=google.com; s=arc-20160816;
        b=ycEIKMoJ0qYbEQzD95j19E12B5cGXINQ4bcHkpJDnBRchWuY5EAoZN3YPmdDqZ4WBJ
         VMmqeo/g5thMuBOdVvDA2QSV0IdvctjbjtFcfqLN/BDG2flUhGvtO59s7yhy0SxaiUbJ
         Y6BqgcqcSQfE/YpzfzfSqJeE3RGVKTFJMfukCMiBxDHLAGYZ5KdCYgA/Bgv5lE1QFHBi
         7JQ7PlX8uYAUkYGOoonTvUhOT7UHgUa+WMs5cYE2PvieJTSzU+nMTXdJbFMel0lq02Zd
         0MU8o63MsOaYg3SnrMR+LmGBdxyQoSjQ0q10ZgWV0Q9j6CVW7kkoIs7w93SJJ7YM9wKE
         zLYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DoQyDe4iN4rSDSn59KCg88licv4gudixO5kqMTZt/aM=;
        b=Dz+W+FvKyJnmoAsWTbcP/sN1iygrns0sEmULuVmlHqkUx7Cchqe+d7vnp4bXN1xJtL
         nApU6cEPcmLwBst3Qh0MtrgaDcrrfRK8jNinKEr9Nki0cESoSJx9ZP6gTpwx3RM79s8R
         sXaf7Nm/+UZn6QSljtLG9+AEIuep8y2fZkRZfJECZNaIOGAb+MEsWCHPvZ/xwrobE7CV
         9Zlu7VvddaIMbsynIO/9MWdqaHgV5rQ3tfmGZSbNmTIkVIa3CbMJ4BAseK42R9ta2kdT
         fNjWx3YbDXg2YiUaA/6UedquuUt8VTC5+BBGsTNEQBOExQjwJ7U0bMy6GmUR7/UBfnQ5
         8Mhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l14si766106eje.252.2019.04.18.02.02.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 02:02:29 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8FE47AEBB;
	Thu, 18 Apr 2019 09:02:28 +0000 (UTC)
Date: Thu, 18 Apr 2019 11:02:27 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
	akpm@linux-foundation.org, dave.hansen@intel.com,
	keith.busch@intel.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190418090227.GG6567@dhcp22.suse.cz>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <c0fe0c54-b61a-4f5d-8af5-59818641e747@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c0fe0c54-b61a-4f5d-8af5-59818641e747@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-04-19 13:43:44, Yang Shi wrote:
[...]
> And, I'm wondering whether this optimization is also suitable to general
> NUMA balancing or not.

If there are convincing numbers then this should be a preferable way to
deal with it. Please note that the number of promotions is not the only
metric to watch. The overal performance/access latency would be another one.

-- 
Michal Hocko
SUSE Labs

