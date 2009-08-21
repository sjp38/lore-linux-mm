Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0F5046B009E
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:41:07 -0400 (EDT)
Date: Fri, 21 Aug 2009 09:46:28 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH -v2] mm: do batched scans for mem_cgroup
Message-ID: <20090821014628.GA31483@localhost>
References: <20090820024929.GA19793@localhost> <20090820121347.8a886e4b.kamezawa.hiroyu@jp.fujitsu.com> <20090820040533.GA27540@localhost> <20090820051656.GB26265@balbir.in.ibm.com> <20090821013926.GA30823@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090821013926.GA30823@localhost>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 21, 2009 at 09:39:26AM +0800, Wu Fengguang wrote:
> On Thu, Aug 20, 2009 at 01:16:56PM +0800, Balbir Singh wrote:
> > * Wu Fengguang <fengguang.wu@intel.com> [2009-08-20 12:05:33]:
> > 
> > > On Thu, Aug 20, 2009 at 11:13:47AM +0800, KAMEZAWA Hiroyuki wrote:
> > > > On Thu, 20 Aug 2009 10:49:29 +0800
> > > > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > > 
> > > > > For mem_cgroup, shrink_zone() may call shrink_list() with nr_to_scan=1,
> > > > > in which case shrink_list() _still_ calls isolate_pages() with the much
> > > > > larger SWAP_CLUSTER_MAX.  It effectively scales up the inactive list
> > > > > scan rate by up to 32 times.
> > > > > 
> > > > > For example, with 16k inactive pages and DEF_PRIORITY=12, (16k >> 12)=4.
> > > > > So when shrink_zone() expects to scan 4 pages in the active/inactive
> > > > > list, it will be scanned SWAP_CLUSTER_MAX=32 pages in effect.
> > > > > 
> > > > > The accesses to nr_saved_scan are not lock protected and so not 100%
> > > > > accurate, however we can tolerate small errors and the resulted small
> > > > > imbalanced scan rates between zones.
> > > > > 
> > > > > This batching won't blur up the cgroup limits, since it is driven by
> > > > > "pages reclaimed" rather than "pages scanned". When shrink_zone()
> > > > > decides to cancel (and save) one smallish scan, it may well be called
> > > > > again to accumulate up nr_saved_scan.
> > > > > 
> > > > > It could possibly be a problem for some tiny mem_cgroup (which may be
> > > > > _full_ scanned too much times in order to accumulate up nr_saved_scan).
> > > > > 
> > > > > CC: Rik van Riel <riel@redhat.com>
> > > > > CC: Minchan Kim <minchan.kim@gmail.com>
> > > > > CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > > > CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > > CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > > > ---
> > > > 
> > > > Hmm, how about this ? 
> > > > ==
> > > > Now, nr_saved_scan is tied to zone's LRU.
> > > > But, considering how vmscan works, it should be tied to reclaim_stat.
> > > > 
> > > > By this, memcg can make use of nr_saved_scan information seamlessly.
> > > 
> > > Good idea, full patch updated with your signed-off-by :)
> > > 
> > > Thanks,
> > > Fengguang
> > > ---
> > > mm: do batched scans for mem_cgroup
> > > 
> > > For mem_cgroup, shrink_zone() may call shrink_list() with nr_to_scan=1,
> > > in which case shrink_list() _still_ calls isolate_pages() with the much
> > > larger SWAP_CLUSTER_MAX.  It effectively scales up the inactive list
> > > scan rate by up to 32 times.
> > > 
> > > For example, with 16k inactive pages and DEF_PRIORITY=12, (16k >> 12)=4.
> > > So when shrink_zone() expects to scan 4 pages in the active/inactive
> > > list, it will be scanned SWAP_CLUSTER_MAX=32 pages in effect.
> > > 
> > > The accesses to nr_saved_scan are not lock protected and so not 100%
> > > accurate, however we can tolerate small errors and the resulted small
> > > imbalanced scan rates between zones.
> > > 
> > > This batching won't blur up the cgroup limits, since it is driven by
> > > "pages reclaimed" rather than "pages scanned". When shrink_zone()
> > > decides to cancel (and save) one smallish scan, it may well be called
> > > again to accumulate up nr_saved_scan.
> > > 
> > > It could possibly be a problem for some tiny mem_cgroup (which may be
> > > _full_ scanned too much times in order to accumulate up nr_saved_scan).
> > >
> > 
> > Looks good to me, how did you test it?
> 
> I observed the shrink_inactive_list() calls with this patch:
> 
>         @@ -1043,6 +1043,13 @@ static unsigned long shrink_inactive_lis
>                 struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
>                 int lumpy_reclaim = 0;
> 
>         +       if (!scanning_global_lru(sc))
>         +               printk("shrink inactive %s count=%lu scan=%lu\n",
>         +                      file ? "file" : "anon",
>         +                      mem_cgroup_zone_nr_pages(sc->mem_cgroup, zone,
>         +                                               LRU_INACTIVE_ANON + 2 * !!file),
>         +                      max_scan);
> 
> and these commands:
> 
>         mkdir /cgroup/0
>         echo 100M > /cgroup/0/memory.limit_in_bytes
>         echo $$ > /cgroup/0/tasks
>         cp /tmp/10G /dev/null

And I can reduce the limit to 1M and 500K without triggering OOM:


[  963.329746] shrink inactive file count=201 scan=32
[  963.335076] shrink inactive file count=177 scan=15
[  963.350719] shrink inactive file count=201 scan=32
[  963.356020] shrink inactive file count=177 scan=15
[  963.371914] shrink inactive file count=201 scan=32
[  963.377225] shrink inactive file count=177 scan=15
[  963.393022] shrink inactive file count=201 scan=32
[  963.398362] shrink inactive file count=177 scan=15


[ 1103.951251] shrink inactive file count=70 scan=32
[ 1104.054242] shrink inactive file count=46 scan=32
[ 1104.077381] shrink inactive file count=70 scan=32
[ 1104.083095] shrink inactive file count=73 scan=32
[ 1104.088513] shrink inactive file count=45 scan=2
[ 1104.113545] shrink inactive file count=70 scan=32
[ 1104.118915] shrink inactive file count=73 scan=32
[ 1104.124612] shrink inactive file count=45 scan=2
[ 1104.130093] shrink inactive file count=69 scan=32

So the patch is pretty safe for tiny mem cgroups.

Thanks,
Fengguang

> before patch:
> 
>         [ 3682.646008] shrink inactive file count=25535 scan=6
>         [ 3682.661548] shrink inactive file count=25535 scan=6
>         [ 3682.666933] shrink inactive file count=25535 scan=6
>         [ 3682.682865] shrink inactive file count=25535 scan=6
>         [ 3682.688572] shrink inactive file count=25535 scan=6
>         [ 3682.703908] shrink inactive file count=25535 scan=6
>         [ 3682.709431] shrink inactive file count=25535 scan=6
> 
> after patch:
> 
>         [  223.146544] shrink inactive file count=25531 scan=32
>         [  223.152060] shrink inactive file count=25507 scan=10
>         [  223.167503] shrink inactive file count=25531 scan=32
>         [  223.173426] shrink inactive file count=25507 scan=10
>         [  223.188764] shrink inactive file count=25531 scan=32
>         [  223.194270] shrink inactive file count=25507 scan=10
>         [  223.209885] shrink inactive file count=25531 scan=32
>         [  223.215388] shrink inactive file count=25507 scan=10
> 
> Before patch, the inactive list is over scanned by 30/6=5 times;
> After patch, it is over scanned by 64/42=1.5 times. It's much better,
> and can be further improved if necessary.
> 
> > Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
