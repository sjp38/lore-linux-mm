Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECD9A6B0260
	for <linux-mm@kvack.org>; Mon, 23 May 2016 08:06:23 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id q17so11589317lbn.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 05:06:23 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id jt7si37007723wjb.123.2016.05.23.05.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 05:06:22 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id a136so18579882wme.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 05:06:22 -0700 (PDT)
Date: Mon, 23 May 2016 14:06:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: fix the return in mem_cgroup_margin
Message-ID: <20160523120620.GP2278@dhcp22.suse.cz>
References: <1463556255-31892-1-git-send-email-roy.qing.li@gmail.com>
 <20160518073253.GC21654@dhcp22.suse.cz>
 <CAJFZqHwFtZa-Ec_0bie6ORTrgoW1kqGsq49-=ojsT-uyNUBhwg@mail.gmail.com>
 <20160523103758.GB7917@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160523103758.GB7917@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li RongQing <roy.qing.li@gmail.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Mon 23-05-16 13:37:58, Vladimir Davydov wrote:
> On Thu, May 19, 2016 at 09:44:53AM +0800, Li RongQing wrote:
> > On Wed, May 18, 2016 at 3:32 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > > count should always be smaller than memsw.limit (this is a hard limit).
> > > Even if we have some temporary breach then the code should work as
> > > expected because margin is initialized to 0 and memsw.limit >= limit.
> > 
> > is it possible for this case? for example
> > 
> > memory count is 500, memory limit is 600; the margin is set to 100 firstly,
> > then check memory+swap limit, its count(1100) is bigger than its limit(1000),
> > then the margin 100 is returned wrongly.
> 
> I guess it is possible, because try_charge forces charging __GFP_NOFAIL
> allocations, which may result in memsw.limit excess. If we are below
> memory.limit and there's nothing to reclaim to reduce memsw.usage, we
> might end up looping in try_charge forever. I've never seen that happen
> in practice, but I still think the patch is worth applying.

You are right. I have completely missed a potential interaction with
__GFP_NOFAIL. We even do not seem to trigger the memcg OOM killer for
these requests to sort the situation out.

Can we have updated patch with all this useful information in the
changelog, please?

Thanks Vladimir!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
