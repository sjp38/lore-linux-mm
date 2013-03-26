Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 387246B00CD
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 04:35:19 -0400 (EDT)
Message-ID: <51515DEE.70105@parallels.com>
Date: Tue, 26 Mar 2013 12:35:58 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
References: <514A60CD.60208@huawei.com> <20130321090849.GF6094@dhcp22.suse.cz> <20130321102257.GH6094@dhcp22.suse.cz> <514BB23E.70908@huawei.com> <20130322080749.GB31457@dhcp22.suse.cz> <514C1388.6090909@huawei.com> <514C14BF.3050009@parallels.com> <20130322093141.GE31457@dhcp22.suse.cz> <514EAC41.5050700@huawei.com> <20130325090629.GN2154@dhcp22.suse.cz>
In-Reply-To: <20130325090629.GN2154@dhcp22.suse.cz>
Content-Type: multipart/mixed;
	boundary="------------000309060002060402080600"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

--------------000309060002060402080600
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

>>
>> I doubt it's a win to add 4K to kernel text size instead of adding
>> a few extra lines of code... but it's up to you.
> 
> I will leave the decision to Glauber. The updated version which uses
> kmalloc for the static buffer is bellow.
> 
I prefer to allocate dynamically here. But although I understand why we
need to call cgroup_name, I don't understand what is wrong with
kasprintf if we're going to allocate anyway. It will allocate a string
just big enough. A PAGE_SIZE'd allocation is a lot more likely to fail.

Now, if we really want to be smart here, we can do something like what
I've done for the slub attribute buffers, that can actually have very
long values.

allocate a small buffer that will hold 80 % > of the allocations (256
bytes should be enough for most cache names), and if the string is
bigger than this, we allocate. Once we allocate, we save it in a static
pointer and leave it there. The hope here is that we may be able to
live without ever allocating in many systems.

> +
> +	/*
> +	 * kmem_cache_create_memcg duplicates the given name and
> +	 * cgroup_name for this name requires RCU context.
> +	 * This static temporary buffer is used to prevent from
> +	 * pointless shortliving allocation.
> +	 */
The comment is also no longer true if you don't resort to a static buffer.

The following (untested) patch implements the idea I outlined above.

What do you guys think ?


--------------000309060002060402080600
Content-Type: text/x-patch;
	name="0001-memcg-fix-memcg_cache_name-to-use-cgroup_name.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-memcg-fix-memcg_cache_name-to-use-cgroup_name.patch"


--------------000309060002060402080600--
