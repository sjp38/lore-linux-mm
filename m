Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C1AA56B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 07:42:07 -0400 (EDT)
Date: Thu, 16 Jun 2011 13:41:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 4/8] memcg: rework soft limit reclaim
Message-ID: <20110616114156.GE9840@tiehlicka.suse.cz>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-5-git-send-email-hannes@cmpxchg.org>
 <BANLkTim5TSWpBfeF2dugGZwQmNC-Cf+GCNctraq8FtziJxsd2g@mail.gmail.com>
 <BANLkTimuRks4+h=Kjt2Lzc-s-XsAHCH9vg@mail.gmail.com>
 <20110609150026.GD3994@tiehlicka.suse.cz>
 <BANLkTimbEnEHuxBDzKrEjPY7Y5F_aSoOdXkmjaOY+3xLBLzLdA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTimbEnEHuxBDzKrEjPY7Y5F_aSoOdXkmjaOY+3xLBLzLdA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed 15-06-11 15:48:25, Ying Han wrote:
> On Thu, Jun 9, 2011 at 8:00 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Thu 02-06-11 22:25:29, Ying Han wrote:
[...]
> > yes, this makes sense but I am not sure about the right(tm) value of the
> > MEMCG_SOFTLIMIT_RECLAIM_PRIORITY. 2 sounds too low. You would do quite a
> > lot of loops
> > (DEFAULT_PRIORITY-MEMCG_SOFTLIMIT_RECLAIM_PRIORITY) * zones * memcg_count
> > without any progress (assuming that all of them are under soft limit
> > which doesn't sound like a totally artificial configuration) until you
> > allow reclaiming from groups that are under soft limit. Then, when you
> > finally get to reclaiming, you scan rather aggressively.
> 
> Fair enough, something smarter is definitely needed :)
> 
> >
> > Maybe something like 3/4 of DEFAULT_PRIORITY? You would get 3 times
> > over all (unbalanced) zones and all cgroups that are above the limit
> > (scanning max{1/4096+1/2048+1/1024, 3*SWAP_CLUSTER_MAX} of the LRUs for
> > each cgroup) which could be enough to collect the low hanging fruit.
> 
> Hmm, that sounds more reasonable than the initial proposal.
> 
> For the same worst case where all the memcgs are blow their soft
> limit, we need to scan 3 times of total memcgs before actually doing

it is not scanning what we do. We just walk through all existing memcgs.
I think that the real issue here is how much we scan when we start
doing something useful. Maybe even DEFAULT_PRIORITY-3 is too much as
well. dunno.
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
