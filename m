Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id D57F86B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 12:19:53 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id l109so3962008yhq.19
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 09:19:53 -0800 (PST)
Received: from mail-yh0-x234.google.com (mail-yh0-x234.google.com [2607:f8b0:4002:c01::234])
        by mx.google.com with ESMTPS id r46si13262193yhm.97.2013.12.16.09.19.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 09:19:53 -0800 (PST)
Received: by mail-yh0-f52.google.com with SMTP id i7so3933200yha.11
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 09:19:52 -0800 (PST)
Date: Mon, 16 Dec 2013 12:19:41 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: 3.13-rc breaks MEMCG_SWAP
Message-ID: <20131216171941.GI32509@htj.dyndns.org>
References: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils>
 <52AEC989.4080509@huawei.com>
 <20131216095345.GB23582@dhcp22.suse.cz>
 <20131216104042.GC23582@dhcp22.suse.cz>
 <20131216164154.GX21724@cmpxchg.org>
 <20131216171527.GF26797@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131216171527.GF26797@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, Michal, Johannes.

On Mon, Dec 16, 2013 at 06:15:27PM +0100, Michal Hocko wrote:
> > We already do that, swap records hold a css reference.  We do the put
> > in mem_cgroup_uncharge_swap().
> 
> Dohh! You are right I have totally missed that the css_get is burried in
> __mem_cgroup_uncharge_common and the counterpart is in mem_cgroup_uncharge_swap
> (which is less unexpected).
> 
> > It really strikes me as odd that we recycle the cgroup ID while there
> > are still references to the cgroup in circulation.
> 
> That is true but even with this fixed I still think that the Hugh's
> approach makes a lot of sense.

I thought about this a bit and I think the id really should be per
subsystem - ie. like css_id but just a dumb id as cgrp->id.  The
reason is that cgroup's lifetime and css's lifetime will soon be
decoupled.  ie. if a css is disabled and re-enabled on the same
cgroup, there can be two css's associated with a single cgroup.
cgroup_css() and css iterators should block accesses to css's which
are being drained but it does make sense for id lookup to work until
the css is actually released.

That said, for now, whatever works is fine and if Hugh's suggested
change is desirable anyway, that should do for now.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
