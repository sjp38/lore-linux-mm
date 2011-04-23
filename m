Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CE6748D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 21:36:15 -0400 (EDT)
Date: Sat, 23 Apr 2011 03:35:34 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
Message-ID: <20110423013534.GK2333@cmpxchg.org>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
 <20110421025107.GG2333@cmpxchg.org>
 <20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>
 <20110421050851.GI2333@cmpxchg.org>
 <BANLkTimUQjW_XVdzoLJJwwFDuFvm=Qg_FA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTimUQjW_XVdzoLJJwwFDuFvm=Qg_FA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Wed, Apr 20, 2011 at 10:28:17PM -0700, Ying Han wrote:
> On Wed, Apr 20, 2011 at 10:08 PM, Johannes Weiner <hannes@cmpxchg.org>wrote:
> > On Thu, Apr 21, 2011 at 01:00:16PM +0900, KAMEZAWA Hiroyuki wrote:
> > > I don't think its a good idea to kick kswapd even when free memory is
> > enough.
> >
> > This depends on what kswapd is supposed to be doing.  I don't say we
> > should reclaim from all memcgs (i.e. globally) just because one memcg
> > hits its watermark, of course.
> >
> > But the argument was that we need the watermarks configurable to force
> > per-memcg reclaim even when the hard limits are overcommitted, because
> > global reclaim does not do a fair job to balance memcgs.
> 
> There seems to be some confusion here. The watermark we defined is
> per-memcg, and that is calculated
> based on the hard_limit. We need the per-memcg wmark the same reason of
> per-zone wmart which triggers
> the background reclaim before direct reclaim.

Of course, I am not arguing against the watermarks.  I am just
(violently) against making them configurable from userspace.

> There is a patch in my patchset which adds the tunable for both
> high/low_mark, which gives more flexibility to admin to config the host. In
> over-commit environment, we might never hit the wmark if all the wmarks are
> set internally.

And my point is that this should not be a problem at all!  If the
watermarks are not physically reachable, there is no reason to reclaim
on behalf of them.

In such an environment, global memory pressure arises before the
memcgs get close to their hard limit, and global memory pressure
reduction should do the right thing and equally push back all memcgs.

Flexibility in itself is not an argument.  On the contrary.  We commit
ourselves to that ABI and have to maintain this flexibility forever.
Instead, please find a convincing argument for the flexibility itself,
other than the need to workaround the current global kswapd reclaim.

(I fixed up the following quotation, please be more careful when
replying, this makes it so hard to follow your emails.  thanks!)

> > My counter proposal is to fix global reclaim instead and apply equal
> > pressure on memcgs, such that we never have to tweak per-memcg watermarks
> > to achieve the same thing.
> 
> We still need this and that is the soft_limit reclaim under global
> background reclaim.

I don't understand what you mean by that.  Could you elaborate?

Thanks,

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
