Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3396B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:07:05 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a2so181123506pgn.15
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:07:05 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id a64si8013037pfj.160.2017.07.25.05.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 05:07:04 -0700 (PDT)
Date: Tue, 25 Jul 2017 13:06:42 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm, memcg: reset low limit during memcg offlining
Message-ID: <20170725120642.GA12635@castle.DHCP.thefacebook.com>
References: <20170725114047.4073-1-guro@fb.com>
 <20170725115808.GE26723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170725115808.GE26723@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 25, 2017 at 01:58:08PM +0200, Michal Hocko wrote:
> On Tue 25-07-17 12:40:47, Roman Gushchin wrote:
> > A removed memory cgroup with a defined low limit and some belonging
> > pagecache has very low chances to be freed.
> > 
> > If a cgroup has been removed, there is likely no memory pressure inside
> > the cgroup, and the pagecache is protected from the external pressure
> > by the defined low limit. The cgroup will be freed only after
> > the reclaim of all belonging pages. And it will not happen until
> > there are any reclaimable memory in the system. That means,
> > there is a good chance, that a cold pagecache will reside
> > in the memory for an undefined amount of time, wasting
> > system resources.
> > 
> > Fix this issue by zeroing memcg->low during memcg offlining.
> 
> Very well spotted! This goes all the way down to low limit inclusion
> AFAICS. I would be even tempted to mark it for stable because hiding
> some memory from reclaim basically indefinitely is not good. We might
> have been just lucky nobody has noticed that yet.

I believe it's because there are not so many actual low limit users,
and those who do, are using some offstream patches to mitigate this issue.

Thanks!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
