Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id 333116B0031
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 12:19:39 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so2361683eaj.26
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 09:19:38 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m44si1177071eeo.226.2013.12.16.09.19.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 09:19:38 -0800 (PST)
Date: Mon, 16 Dec 2013 18:19:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: 3.13-rc breaks MEMCG_SWAP
Message-ID: <20131216171937.GG26797@dhcp22.suse.cz>
References: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils>
 <52AEC989.4080509@huawei.com>
 <20131216095345.GB23582@dhcp22.suse.cz>
 <20131216104042.GC23582@dhcp22.suse.cz>
 <20131216163530.GH32509@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131216163530.GH32509@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 16-12-13 11:35:30, Tejun Heo wrote:
> On Mon, Dec 16, 2013 at 11:40:42AM +0100, Michal Hocko wrote:
> > > How would this work? The task which pushed the memory to the swap is
> > > still alive (living in a different group) and the swap will be there
> > > after the last reference to css as well.
> > 
> > Or did you mean to get css reference in swap_cgroup_record and release
> > it in __mem_cgroup_try_charge_swapin?
> > 
> > That would prevent the warning (assuming idr_remove would move to
> > css_free[1]) but I am not sure this is the right thing to do. memsw charges
> > will be accounted to the parent already (assuming there is one) without
> > anybody to uncharge them because all uncharges would fallback to the
> > root memcg after css_offline.
> > 
> > Hugh's approach seems much better.
> 
> Hmmm... I think it's reasonable for css's to expect cgrp->id to not be
> recycled before all css refs are gone.  If Hugh's patches are
> something desriable independent of cgrp->id issues, great, but, if
> not, let's first try to get it right from cgroup core.  Is it enough
> for css_from_id() to return NULL after offline until all refs are
> gone?  That should be an easy fix.

I have to think about it some more (the brain is not working anymore
today). But what we really need is that nobody gets the same id while
the css is alive. So css_from_id returning NULL doesn't seem to be
enough.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
