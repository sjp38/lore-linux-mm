Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 824EE6B0005
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 11:40:59 -0500 (EST)
Date: Fri, 8 Feb 2013 17:40:56 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20130208164056.GG7557@dhcp22.suse.cz>
References: <20130125163130.GF4721@dhcp22.suse.cz>
 <20130205134937.GA22804@dhcp22.suse.cz>
 <20130205154947.CD6411E2@pobox.sk>
 <20130205160934.GB22804@dhcp22.suse.cz>
 <xr93wqum4sh4.fsf@gthelen.mtv.corp.google.com>
 <20130205174651.GA3959@dhcp22.suse.cz>
 <xr93a9ri4op6.fsf@gthelen.mtv.corp.google.com>
 <20130205185953.GB3959@dhcp22.suse.cz>
 <xr93ip63ig6j.fsf@gthelen.mtv.corp.google.com>
 <20130208162918.GF7557@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130208162918.GF7557@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 08-02-13 17:29:18, Michal Hocko wrote:
[...]
> OK, I have checked the allocator slow path and you are right even
> GFP_KERNEL will not fail. This can lead to similar deadlocks - e.g.
> OOM killed task blocked on down_write(mmap_sem) while the page fault
> handler holding mmap_sem for reading and allocating a new page without
> any progress.

And now that I think about it some more it sounds like it shouldn't be
possible because allocator would fail because it would see
TIF_MEMDIE (OOM killer kills all threads that share the same mm).
But maybe there are other locks that are dangerous, but I think that the
risk is pretty low.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
