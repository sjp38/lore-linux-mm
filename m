Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9D4B88D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 04:55:50 -0400 (EDT)
Date: Wed, 30 Mar 2011 10:55:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [trivial PATCH v2] Remove pointless next_mz nullification in
 mem_cgroup_soft_limit_reclaim
Message-ID: <20110330085544.GD15394@tiehlicka.suse.cz>
References: <20110329132800.GA3361@tiehlicka.suse.cz>
 <20110330110953.06ea3521.nishimura@mxp.nes.nec.co.jp>
 <20110330070203.GA15394@tiehlicka.suse.cz>
 <20110330161800.2e7dc268.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110330161800.2e7dc268.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Wed 30-03-11 16:18:00, Daisuke Nishimura wrote:
> > From: Michal Hocko <mhocko@suse.cz>
> > Subject: Remove pointless next_mz nullification in mem_cgroup_soft_limit_reclaim
> > 
> > next_mz is assigned to NULL if __mem_cgroup_largest_soft_limit_node selects
> > the same mz. This doesn't make much sense as we assign to the variable
> > right in the next loop.
> > 
> > Compiler will probably optimize this out but it is little bit confusing for
> > the code reading.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks Daisuke.

Andrew, should this go though your mm tree?
--- 
From: Michal Hocko <mhocko@suse.cz>
Subject: Remove pointless next_mz nullification in mem_cgroup_soft_limit_reclaim

next_mz is assigned to NULL if __mem_cgroup_largest_soft_limit_node selects
the same mz. This doesn't make much sense as we assign to the variable
right in the next loop.

Compiler will probably optimize this out but it is little bit confusing for
the code reading.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Index: linux-2.6.38-rc8/mm/memcontrol.c
===================================================================
--- linux-2.6.38-rc8.orig/mm/memcontrol.c	2011-03-28 11:25:14.000000000 +0200
+++ linux-2.6.38-rc8/mm/memcontrol.c	2011-03-30 08:57:52.000000000 +0200
@@ -3347,10 +3347,9 @@ unsigned long mem_cgroup_soft_limit_recl
 				 */
 				next_mz =
 				__mem_cgroup_largest_soft_limit_node(mctz);
-				if (next_mz == mz) {
+				if (next_mz == mz)
 					css_put(&next_mz->mem->css);
-					next_mz = NULL;
-				} else /* next_mz == NULL or other memcg */
+				else /* next_mz == NULL or other memcg */
 					break;
 			} while (1);
 		}
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
