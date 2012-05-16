Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id DD25B6B0082
	for <linux-mm@kvack.org>; Wed, 16 May 2012 16:57:58 -0400 (EDT)
Date: Wed, 16 May 2012 13:57:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
Message-Id: <20120516135755.cdcdf9ba.akpm@linux-foundation.org>
In-Reply-To: <4FB35153.3080309@parallels.com>
References: <1336767077-25351-1-git-send-email-glommer@parallels.com>
	<1336767077-25351-3-git-send-email-glommer@parallels.com>
	<4FB0621C.3010604@huawei.com>
	<4FB35153.3080309@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Li Zefan <lizefan@huawei.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Wed, 16 May 2012 11:03:47 +0400
Glauber Costa <glommer@parallels.com> wrote:

> On 05/14/2012 05:38 AM, Li Zefan wrote:
> >> +static void disarm_static_keys(struct mem_cgroup *memcg)
> > 
> >> +{
> >> +#ifdef CONFIG_INET
> >> +	if (memcg->tcp_mem.cg_proto.activated)
> >> +		static_key_slow_dec(&memcg_socket_limit_enabled);
> >> +#endif
> >> +}
> > 
> > 
> > Move this inside the ifdef/endif below ?
> > 
> > Otherwise I think you'll get compile error if !CONFIG_INET...
> 
> I don't fully get it.
> 
> We are supposed to provide a version of it for
> CONFIG_CGROUP_MEM_RES_CTLR_KMEM and an empty version for
> !CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> 
> Inside the first, we take an action for CONFIG_INET, and no action for
> !CONFIG_INET.
> 
> Bear in mind that the slab patches will add another test to that place,
> and that's why I am doing it this way from the beginning.
> 
> Well, that said, I not only can be wrong, I very frequently am.
> 
> But I just compiled this one with and without CONFIG_INET, and it seems
> to be going alright.
> 

Yes, the ifdeffings in that area are rather nasty.

I wonder if it would be simpler to do away with the ifdef nesting. 
At the top-level, just do

#if defined(CONFIG_CGROUP_MEM_RES_CTLR_KMEM) && defined(CONFIG_INET)
static void disarm_static_keys(struct mem_cgroup *memcg)
{
	if (memcg->tcp_mem.cg_proto.activated)
		static_key_slow_dec(&memcg_socket_limit_enabled);
}
#else
static inline void disarm_static_keys(struct mem_cgroup *memcg)
{
}
#endif


The tcp_proto_cgroup() definition could go inside that ifdef as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
