Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 186018E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 13:13:33 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id 39so34313059edq.13
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 10:13:33 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u16si964396edm.213.2019.01.03.10.13.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 10:13:31 -0800 (PST)
Date: Thu, 3 Jan 2019 19:13:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] mm: memcontrol: delayed force empty
Message-ID: <20190103181329.GW31793@dhcp22.suse.cz>
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190103101215.GH31793@dhcp22.suse.cz>
 <b3ad06ed-f620-7aa0-5697-a1bbe2d7bfe1@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b3ad06ed-f620-7aa0-5697-a1bbe2d7bfe1@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-01-19 09:33:14, Yang Shi wrote:
> 
> 
> On 1/3/19 2:12 AM, Michal Hocko wrote:
> > On Thu 03-01-19 04:05:30, Yang Shi wrote:
> > > Currently, force empty reclaims memory synchronously when writing to
> > > memory.force_empty.  It may take some time to return and the afterwards
> > > operations are blocked by it.  Although it can be interrupted by signal,
> > > it still seems suboptimal.
> > Why it is suboptimal? We are doing that operation on behalf of the
> > process requesting it. What should anybody else pay for it? In other
> > words why should we hide the overhead?
> 
> Please see the below explanation.
> 
> > 
> > > Now css offline is handled by worker, and the typical usecase of force
> > > empty is before memcg offline.  So, handling force empty in css offline
> > > sounds reasonable.
> > Hmm, so I guess you are talking about
> > echo 1 > $MEMCG/force_empty
> > rmdir $MEMCG
> > 
> > and you are complaining that the operation takes too long. Right? Why do
> > you care actually?
> 
> We have some usecases which create and remove memcgs very frequently, and
> the tasks in the memcg may just access the files which are unlikely accessed
> by anyone else. So, we prefer force_empty the memcg before rmdir'ing it to
> reclaim the page cache so that they don't get accumulated to incur
> unnecessary memory pressure. Since the memory pressure may incur direct
> reclaim to harm some latency sensitive applications.

Yes, this makes sense to me.

> And, the create/remove might be run in a script sequentially (there might be
> a lot scripts or applications are run in parallel to do this), i.e.
> mkdir cg1
> do something
> echo 0 > cg1/memory.force_empty
> rmdir cg1
> 
> mkdir cg2
> ...
> 
> The creation of the afterwards memcg might be blocked by the force_empty for
> long time if there are a lot page caches, so the overall throughput of the
> system may get hurt.

Is there any reason for your scripts to be strictly sequential here? In
other words why cannot you offload those expensive operations to a
detached context in _userspace_?
-- 
Michal Hocko
SUSE Labs
