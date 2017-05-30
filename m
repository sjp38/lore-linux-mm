Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 70B2D6B02FD
	for <linux-mm@kvack.org>; Tue, 30 May 2017 09:21:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 62so95989504pft.3
        for <linux-mm@kvack.org>; Tue, 30 May 2017 06:21:40 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k10si13624229pgn.22.2017.05.30.06.21.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 06:21:39 -0700 (PDT)
Date: Tue, 30 May 2017 14:21:14 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: bump PGSTEAL*/PGSCAN*/ALLOCSTALL counters in memcg
 reclaim
Message-ID: <20170530132114.GA28148@castle>
References: <1496062901-21456-1-git-send-email-guro@fb.com>
 <20170530122436.GE7969@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170530122436.GE7969@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 30, 2017 at 02:24:36PM +0200, Michal Hocko wrote:
> On Mon 29-05-17 14:01:41, Roman Gushchin wrote:
> > Historically, PGSTEAL*/PGSCAN*/ALLOCSTALL counters were used to
> > account only for global reclaim events, memory cgroup targeted reclaim
> > was ignored.
> > 
> > It doesn't make sense anymore, because the whole reclaim path
> > is designed around cgroups. Also, per-cgroup counters can exceed the
> > corresponding global counters, what can be confusing.
> 
> The whole reclaim is designed around cgroups but the source of the
> memory pressure is different. I agree that checking global_reclaim()
> for PGSTEAL_KSWAPD doesn't make much sense because we are _always_ in
> the global reclaim context but counting ALLOCSTALL even for targetted
> memcg reclaim is more confusing than helpful. We usually consider this
> counter to see whether the kswapd catches up with the memory demand
> and the global direct reclaim is indicator it doesn't. The similar
> applies to other counters as well.
> 
> So I do not think this is correct. What is the problem you are trying to
> solve here anyway.

This is a follow-up patch after the discussion here:
https://lkml.org/lkml/2017/5/16/706.

I can agree with you, that a per-cgroup ALLOCSTALL is something different
from a global one, and it's better to keep them separated.

But what about PGSTEAL*/PGSCAN* counters, isn't it better to make them
reflect __all__ reclaim activity, no matter what was a root cause?

Thanks!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
