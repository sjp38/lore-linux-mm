Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 544E76B005C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 05:28:28 -0400 (EDT)
Date: Thu, 19 Jul 2012 12:29:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/memcg: wrap mem_cgroup_from_css function
Message-ID: <20120719092911.GA2606@shutemov.name>
References: <a>
 <1342580730-25703-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20120719091420.GA2549@shutemov.name>
 <20120719092309.GA12409@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120719092309.GA12409@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWAHiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

On Thu, Jul 19, 2012 at 05:23:09PM +0800, Wanpeng Li wrote:
> On Thu, Jul 19, 2012 at 12:14:20PM +0300, Kirill A. Shutemov wrote:
> >On Wed, Jul 18, 2012 at 11:05:30AM +0800, Wanpeng Li wrote:
> >> wrap mem_cgroup_from_css function to clarify get mem cgroup
> >> from cgroup_subsys_state.
> >> 
> >> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> >> Cc: Michal Hocko <mhocko@suse.cz>
> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> Cc: Andrew Morton <akpm@linux-foundation.org>
> >> Cc: Gavin Shan <shangw@linux.vnet.ibm.com>
> >> Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> >> Cc: linux-kernel@vger.kernel.org
> >> ---
> >>  mm/memcontrol.c |   14 ++++++++++----
> >>  1 files changed, 10 insertions(+), 4 deletions(-)
> >> 
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 58a08fc..20f6a15 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -396,6 +396,12 @@ static void mem_cgroup_put(struct mem_cgroup *memcg);
> >>  #include <net/sock.h>
> >>  #include <net/ip.h>
> >>  
> >> +static inline
> >> +struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
> >> +{
> >> +	return container_of(s, struct mem_cgroup, css);
> >> +}
> >> +
> >>  static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
> >>  void sock_update_memcg(struct sock *sk)
> >>  {
> >> @@ -820,7 +826,7 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
> >>  
> >>  struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
> >>  {
> >> -	return container_of(cgroup_subsys_state(cont,
> >> +	return mem_cgroup_from_css(cgroup_subsys_state(cont,
> >>  				mem_cgroup_subsys_id), struct mem_cgroup,
> >>  				css);
> >
> >Hm?.. Here and below too many args to mem_cgroup_from_css().
> >Have you tested the code?
> 
> Hi, what's the meaning of "two many"?
> 
> cgroup_subsys_state(cont, mem_cgroup_subsys_id) and 
> task_subsys_state(p, mem_cgroup_subsys_id) both are 
> just one arg in mem_cgroup_from_css. :-)

Em.. I guess my eyes are broken. %)

By the patch I see that mem_cgroup_from_css() here has tree arguments:

1. cgroup_subsys_state(cont, mem_cgroup_subsys_id)
2. struct mem_cgroup
3. css

Where's my parser is broken?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
