Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 0671D6B0006
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 05:31:46 -0400 (EDT)
Date: Fri, 22 Mar 2013 10:31:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130322093141.GE31457@dhcp22.suse.cz>
References: <514A60CD.60208@huawei.com>
 <20130321090849.GF6094@dhcp22.suse.cz>
 <20130321102257.GH6094@dhcp22.suse.cz>
 <514BB23E.70908@huawei.com>
 <20130322080749.GB31457@dhcp22.suse.cz>
 <514C1388.6090909@huawei.com>
 <514C14BF.3050009@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <514C14BF.3050009@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 22-03-13 12:22:23, Glauber Costa wrote:
> On 03/22/2013 12:17 PM, Li Zefan wrote:
> >> GFP_TEMPORARY groups short lived allocations but the mem cache is not
> >> > an ideal candidate of this type of allocations..
> >> > 
> > I'm not sure I'm following you...
> > 
> > char *memcg_cache_name()
> > {
> > 	char *name = alloc();
> > 	return name;
> > }
> > 
> > kmem_cache_dup()
> > {
> > 	name = memcg_cache_name();
> > 	kmem_cache_create_memcg(name);
> > 	free(name);
> > }
> > 
> > Isn't this a short lived allocation?
> > 
> 
> Hi,
> 
> Thanks for identifying and fixing this.
> 
> Li is right. The cache name will live long, but this is because the
> slab/slub caches will strdup it internally. So the actual memcg
> allocation is short lived.

OK, I have totally missed that. Sorry about the confusion. Then all the
churn around the allocation is pointless, no?
What about:
---
