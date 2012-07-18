Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 763D16B005C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 17:36:14 -0400 (EDT)
Date: Wed, 18 Jul 2012 14:36:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memcg: wrap mem_cgroup_from_css function
Message-Id: <20120718143612.e34dd3f3.akpm@linux-foundation.org>
In-Reply-To: <1342580730-25703-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <a>
	<1342580730-25703-1-git-send-email-liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

On Wed, 18 Jul 2012 11:05:30 +0800
Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:

> wrap mem_cgroup_from_css function to clarify get mem cgroup
> from cgroup_subsys_state.

This certainly adds clarity.

But it also adds a little more type-safety - these container_of() calls
can be invoked against *any* struct which has a field called "css". 
With your patch, we add a check that the code is indeed using a
cgroup_subsys_state*.  A small thing, but it's all good.


I changed the patch title to the more idiomatic "memcg: add
mem_cgroup_from_css() helper" and rewrote the changelog to

: Add a mem_cgroup_from_css() helper to replace open-coded invokations of
: container_of().  To clarify the code and to add a little more type safety.

> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -396,6 +396,12 @@ static void mem_cgroup_put(struct mem_cgroup *memcg);
>  #include <net/sock.h>
>  #include <net/ip.h>
>  
> +static inline
> +struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
> +{
> +	return container_of(s, struct mem_cgroup, css);
> +}

And with great self-control, I avoided renaming this to
memcg_from_css().  Sigh.  I guess all that extra typing has cardio
benefits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
