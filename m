Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 114456B004D
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 04:21:44 -0400 (EDT)
Message-ID: <514C14BF.3050009@parallels.com>
Date: Fri, 22 Mar 2013 12:22:23 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
References: <514A60CD.60208@huawei.com> <20130321090849.GF6094@dhcp22.suse.cz> <20130321102257.GH6094@dhcp22.suse.cz> <514BB23E.70908@huawei.com> <20130322080749.GB31457@dhcp22.suse.cz> <514C1388.6090909@huawei.com>
In-Reply-To: <514C1388.6090909@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 03/22/2013 12:17 PM, Li Zefan wrote:
>> GFP_TEMPORARY groups short lived allocations but the mem cache is not
>> > an ideal candidate of this type of allocations..
>> > 
> I'm not sure I'm following you...
> 
> char *memcg_cache_name()
> {
> 	char *name = alloc();
> 	return name;
> }
> 
> kmem_cache_dup()
> {
> 	name = memcg_cache_name();
> 	kmem_cache_create_memcg(name);
> 	free(name);
> }
> 
> Isn't this a short lived allocation?
> 

Hi,

Thanks for identifying and fixing this.

Li is right. The cache name will live long, but this is because the
slab/slub caches will strdup it internally. So the actual memcg
allocation is short lived.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
