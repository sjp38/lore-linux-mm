Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 06A436B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 14:58:23 -0400 (EDT)
Received: by bkwj4 with SMTP id j4so37737bkw.2
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 11:58:22 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v2 06/11] memcg: kmem controller infrastructure
References: <1344517279-30646-1-git-send-email-glommer@parallels.com>
	<1344517279-30646-7-git-send-email-glommer@parallels.com>
	<50254475.4000201@jp.fujitsu.com> <5028BA9E.7000302@parallels.com>
Date: Tue, 14 Aug 2012 11:58:10 -0700
In-Reply-To: <5028BA9E.7000302@parallels.com> (Glauber Costa's message of
	"Mon, 13 Aug 2012 12:28:14 +0400")
Message-ID: <xr93ipcl9u7x.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On Mon, Aug 13 2012, Glauber Costa wrote:

>>> > +	WARN_ON(mem_cgroup_is_root(memcg));
>>> > +	size = (1 << order) << PAGE_SHIFT;
>>> > +	memcg_uncharge_kmem(memcg, size);
>>> > +	mem_cgroup_put(memcg);
>> Why do we need ref-counting here ? kmem res_counter cannot work as
>> reference ?
> This is of course the pair of the mem_cgroup_get() you commented on
> earlier. If we need one, we need the other. If we don't need one, we
> don't need the other =)
>
> The guarantee we're trying to give here is that the memcg structure will
> stay around while there are dangling charges to kmem, that we decided
> not to move (remember: moving it for the stack is simple, for the slab
> is very complicated and ill-defined, and I believe it is better to treat
> all kmem equally here)

By keeping memcg structures hanging around until the last referring kmem
page is uncharged do such zombie memcg each consume a css_id and thus
put pressure on the 64k css_id space?  I imagine in pathological cases
this would prevent creation of new cgroups until these zombies are
dereferenced.

Is there any way to see how much kmem such zombie memcg are consuming?
I think we could find these with
for_each_mem_cgroup_tree(root_mem_cgroup).  Basically, I'm wanting to
know where kernel memory has been allocated.  For live memcg, an admin
can cat memory.kmem.usage_in_bytes.  But for zombie memcg, I'm not sure
how to get this info.  It looks like the root_mem_cgroup
memory.kmem.usage_in_bytes is not hierarchically charged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
