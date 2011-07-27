Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3B86B00EE
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 05:57:55 -0400 (EDT)
Date: Wed, 27 Jul 2011 11:57:47 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node
 to world
Message-ID: <20110727095747.GA6430@tiehlicka.suse.cz>
References: <BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>
 <4DE8D50F.1090406@redhat.com>
 <BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ@mail.gmail.com>
 <4DEE26E7.2060201@redhat.com>
 <20110608123527.479e6991.kamezawa.hiroyu@jp.fujitsu.com>
 <20110608140951.115ab1dd.akpm@linux-foundation.org>
 <4DF24D04.1080802@redhat.com>
 <20110726141754.c69b96c6.akpm@linux-foundation.org>
 <20110727075845.GA4024@tiehlicka.suse.cz>
 <4E2FDAA0.5020702@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E2FDAA0.5020702@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, Tim Deegan <Tim.Deegan@citrix.com>

On Wed 27-07-11 11:30:08, Igor Mammedov wrote:
> On 07/27/2011 09:58 AM, Michal Hocko wrote:
> >On Tue 26-07-11 14:17:54, Andrew Morton wrote:
> >>On Fri, 10 Jun 2011 18:57:40 +0200
> >>Igor Mammedov<imammedo@redhat.com>  wrote:
> >>
> >>>On 06/08/2011 11:09 PM, Andrew Morton wrote:
> >>>>The original patch:
> >>>>
> >>>>--- a/mm/memcontrol.c
> >>>>+++ b/mm/memcontrol.c
> >>>>@@ -4707,7 +4707,6 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
> >>>>   	if (!pn)
> >>>>   		return 1;
> >>>>
> >>>>-	mem->info.nodeinfo[node] = pn;
> >>>>   	for (zone = 0; zone<   MAX_NR_ZONES; zone++) {
> >>>>   		mz =&pn->zoneinfo[zone];
> >>>>   		for_each_lru(l)
> >>>>@@ -4716,6 +4715,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
> >>>>   		mz->on_tree = false;
> >>>>   		mz->mem = mem;
> >>>>   	}
> >>>>+	mem->info.nodeinfo[node] = pn;
> >>>>   	return 0;
> >>>>   }
> >>>>
> >>>>looks like a really good idea.  But it needs a new changelog and I'd be
> >>>>a bit reluctant to merge it as it appears that the aptch removes our
> >>>>only known way of reproducing a bug.
> >>>>
> >>>>So for now I think I'll queue the patch up unchangelogged so the issue
> >>>>doesn't get forgotten about.
> >>>>
> >>>Problem was in rhel's xen hv.
> >>>It was missing fix for imul emulation.
> >>>Details here
> >>>http://lists.xensource.com/archives/html/xen-devel/2011-06/msg00801.html
> >>>Thanks to Tim Deegan and everyone who was involved in the discussion.
> >>
> >>I really don't want to trawl through a lengthy xen bug report
> >
> >The bug turned out to be Xen specific and this patch just hidden the bug
> >in Xen.
> 
> The problem was in incorrect imul instruction emulation in xen and as
> consequence incorrect attempt to initialize list at invalid memory location.
> 
> >
> >>and write your changelog for you.
> >>
> >>We still have no changelog for this patch.  Please send one.
> >
> >Appart from a better programming style is there any other reason for
> >taking it?  If applied it might hide potential bugs when somebody is
> >touching data too early.
> >
> 
> If it ever happens and somebody is touching data too early, it would be
> a bit easier to diagnose a problem when dereferencing NULL at
> mem->info.nodeinfo[node] than wondering at partly initialized
> mem_cgroup_per_zone. 

Bahh, I have mixed zero initialized with NULL that would blow up. You
are right of course, sorry for confusion.

> Aside from that it is purely cosmetic change.
> 
> Here is proposed change log:
> 
> Subject: Cleanup: memcg: Expose only initialized mem_cgroup_per_node to world
> 
> If somebody is touching data too early, it might be easier to diagnose
> a problem when dereferencing NULL at mem->info.nodeinfo[node] than
> trying to understand why mem_cgroup_per_zone is [un|partly]initialized.
> 
> 
> Michal will you agree with such commit message?

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
