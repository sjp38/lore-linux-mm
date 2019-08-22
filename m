Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B6D4C3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 09:19:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68870233FC
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 09:19:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68870233FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E59586B02EB; Thu, 22 Aug 2019 05:19:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0A6B6B02EC; Thu, 22 Aug 2019 05:19:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF9C86B02ED; Thu, 22 Aug 2019 05:19:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0163.hostedemail.com [216.40.44.163])
	by kanga.kvack.org (Postfix) with ESMTP id AF1536B02EB
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 05:19:05 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 60858181AC9B6
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 09:19:05 +0000 (UTC)
X-FDA: 75849514650.11.hat59_4f48bf06a054f
X-HE-Tag: hat59_4f48bf06a054f
X-Filterd-Recvd-Size: 2684
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 09:19:04 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 00081AD0B;
	Thu, 22 Aug 2019 09:19:02 +0000 (UTC)
Date: Thu, 22 Aug 2019 11:19:02 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm, memcg: introduce per memcg oom_score_adj
Message-ID: <20190822091902.GG12785@dhcp22.suse.cz>
References: <1566464189-1631-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1566464189-1631-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002288, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 22-08-19 04:56:29, Yafang Shao wrote:
> - Why we need a per memcg oom_score_adj setting ?
> This is easy to deploy and very convenient for container.
> When we use container, we always treat memcg as a whole, if we have a per
> memcg oom_score_adj setting we don't need to set it process by process.

Why cannot an initial process in the cgroup set the oom_score_adj and
other processes just inherit it from there? This sounds trivial to do
with a startup script.

> It will make the user exhausted to set it to all processes in a memcg.

Then let's have scripts to set it as they are less prone to exhaustion
;)
But seriously

> In this patch, a file named memory.oom.score_adj is introduced.
> The valid value of it is from -1000 to +1000, which is same with
> process-level oom_score_adj.
> When OOM is invoked, the effective oom_score_adj is as bellow,
>     effective oom_score_adj = original oom_score_adj + memory.oom.score_adj

This doesn't make any sense to me. Say that process has oom_score_adj
-1000 (never kill) then group oom_score_adj will simply break the
expectation and the task becomes killable for any value but -1000.
Why is summing up those values even sensible?

> The valid effective value is also from -1000 to +1000.
> This is something like a hook to re-calculate the oom_score_adj.

Besides that. What is the hierarchical semantic? Say you have hierarchy
	A (oom_score_adj = 1000)
	 \
	  B (oom_score_adj = 500)
	   \
	    C (oom_score_adj = -1000)

put the above summing up aside for now and just focus on the memcg
adjusting?
-- 
Michal Hocko
SUSE Labs

