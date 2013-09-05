Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 07ED96B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 09:52:21 -0400 (EDT)
Date: Thu, 5 Sep 2013 15:52:19 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: store memcg name for oom kill log consistency
Message-ID: <20130905135219.GE13666@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1308282302450.14291@chino.kir.corp.google.com>
 <20130829133032.GB12077@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130829133032.GB12077@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 29-08-13 15:30:32, Michal Hocko wrote:
> On Wed 28-08-13 23:03:54, David Rientjes wrote:
> > A shared buffer is currently used for the name of the oom memcg and the
> > memcg of the killed process.  There is no serialization of memcg oom
> > kills, so this buffer can easily be overwritten if there is a concurrent
> > oom kill in another memcg.
> 
> Right.
> 
> > This patch stores the names of the memcgs directly in struct mem_cgroup.
> 
> I do not like to make every mem_cgroup larger even if it never sees an
> OOM.
> 
> Wouldn't it be much easier to add a new lock (memcg_oom_info_lock) inside
> mem_cgroup_print_oom_info instead? This would have a nice side effect
> that parallel memcg oom kill messages wouldn't interleave.

What about the following?
---
