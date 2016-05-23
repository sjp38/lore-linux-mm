Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9B06B0253
	for <linux-mm@kvack.org>; Mon, 23 May 2016 06:38:12 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 82so154297723ior.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 03:38:12 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0136.outbound.protection.outlook.com. [104.47.2.136])
        by mx.google.com with ESMTPS id ea9si14503454oeb.37.2016.05.23.03.38.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 May 2016 03:38:10 -0700 (PDT)
Date: Mon, 23 May 2016 13:37:58 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: fix the return in mem_cgroup_margin
Message-ID: <20160523103758.GB7917@esperanza>
References: <1463556255-31892-1-git-send-email-roy.qing.li@gmail.com>
 <20160518073253.GC21654@dhcp22.suse.cz>
 <CAJFZqHwFtZa-Ec_0bie6ORTrgoW1kqGsq49-=ojsT-uyNUBhwg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAJFZqHwFtZa-Ec_0bie6ORTrgoW1kqGsq49-=ojsT-uyNUBhwg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li RongQing <roy.qing.li@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Thu, May 19, 2016 at 09:44:53AM +0800, Li RongQing wrote:
> On Wed, May 18, 2016 at 3:32 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > count should always be smaller than memsw.limit (this is a hard limit).
> > Even if we have some temporary breach then the code should work as
> > expected because margin is initialized to 0 and memsw.limit >= limit.
> 
> is it possible for this case? for example
> 
> memory count is 500, memory limit is 600; the margin is set to 100 firstly,
> then check memory+swap limit, its count(1100) is bigger than its limit(1000),
> then the margin 100 is returned wrongly.

I guess it is possible, because try_charge forces charging __GFP_NOFAIL
allocations, which may result in memsw.limit excess. If we are below
memory.limit and there's nothing to reclaim to reduce memsw.usage, we
might end up looping in try_charge forever. I've never seen that happen
in practice, but I still think the patch is worth applying.

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
