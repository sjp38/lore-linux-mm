Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 586116B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 09:50:26 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id n186so98206553wmn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 06:50:26 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id us2si2359329wjc.170.2015.12.15.06.50.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 06:50:25 -0800 (PST)
Date: Tue, 15 Dec 2015 09:50:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
Message-ID: <20151215145011.GA20355@cmpxchg.org>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz>
 <20151214194258.GH28521@esperanza>
 <566F8781.80108@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <566F8781.80108@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 15, 2015 at 12:22:41PM +0900, Kamezawa Hiroyuki wrote:
> On 2015/12/15 4:42, Vladimir Davydov wrote:
> >Anyway, if you don't trust a container you'd better set the hard memory
> >limit so that it can't hurt others no matter what it runs and how it
> >tweaks its sub-tree knobs.
> 
> Limiting swap can easily cause "OOM-Killer even while there are available swap"
> with easy mistake. Can't you add "swap excess" switch to sysctl to allow global
> memory reclaim can ignore swap limitation ?

That never worked with a combined memory+swap limit, either. How could
it? The parent might swap you out under pressure, but simply touching
a few of your anon pages causes them to get swapped back in, thrashing
with whatever the parent was trying to do. Your ability to swap it out
is simply no protection against a group touching its pages.

Allowing the parent to exceed swap with separate counters makes even
less sense, because every page swapped out frees up a page of memory
that the child can reuse. For every swap page that exceeds the limit,
the child gets a free memory page! The child doesn't even have to
cause swapin, it can just steal whatever the parent tried to free up,
and meanwhile its combined memory & swap footprint explodes.

The answer is and always should have been: don't overcommit untrusted
cgroups. Think of swap as a resource you distribute, not as breathing
room for the parents to rely on. Because it can't and could never.

And the new separate swap counter makes this explicit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
