Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id A34C16B0069
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 05:21:26 -0400 (EDT)
Message-ID: <502B6956.5030508@parallels.com>
Date: Wed, 15 Aug 2012 13:18:14 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 06/11] memcg: kmem controller infrastructure
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-7-git-send-email-glommer@parallels.com> <50254475.4000201@jp.fujitsu.com> <5028BA9E.7000302@parallels.com> <xr93ipcl9u7x.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr93ipcl9u7x.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On 08/14/2012 10:58 PM, Greg Thelen wrote:
> On Mon, Aug 13 2012, Glauber Costa wrote:
> 
>>>>> +	WARN_ON(mem_cgroup_is_root(memcg));
>>>>> +	size = (1 << order) << PAGE_SHIFT;
>>>>> +	memcg_uncharge_kmem(memcg, size);
>>>>> +	mem_cgroup_put(memcg);
>>> Why do we need ref-counting here ? kmem res_counter cannot work as
>>> reference ?
>> This is of course the pair of the mem_cgroup_get() you commented on
>> earlier. If we need one, we need the other. If we don't need one, we
>> don't need the other =)
>>
>> The guarantee we're trying to give here is that the memcg structure will
>> stay around while there are dangling charges to kmem, that we decided
>> not to move (remember: moving it for the stack is simple, for the slab
>> is very complicated and ill-defined, and I believe it is better to treat
>> all kmem equally here)
> 
> By keeping memcg structures hanging around until the last referring kmem
> page is uncharged do such zombie memcg each consume a css_id and thus
> put pressure on the 64k css_id space?  I imagine in pathological cases
> this would prevent creation of new cgroups until these zombies are
> dereferenced.

Yes, but although this patch makes it more likely, it doesn't introduce
that. If the tasks, for instance, grab a reference to the cgroup dentry
in the filesystem (like their CWD, etc), they will also keep the cgroup
around.


> Is there any way to see how much kmem such zombie memcg are consuming?
> I think we could find these with
> for_each_mem_cgroup_tree(root_mem_cgroup).

Yes, just need an interface for that. But I think it is something that
can be addressed orthogonaly to this work, in a separate patch, not as
some fundamental limitation.

>  Basically, I'm wanting to
> know where kernel memory has been allocated.  For live memcg, an admin
> can cat memory.kmem.usage_in_bytes.  But for zombie memcg, I'm not sure
> how to get this info.  It looks like the root_mem_cgroup
> memory.kmem.usage_in_bytes is not hierarchically charged.
> 

Not sure what you mean by not being hierarchically charged. It should
be, when use_hierarchy = 1. As a matter of fact, I just tested it, and I
do see kmem being charged all the way to the root cgroup when hierarchy
is used. (we just can't limit it there)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
