Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 172F46B016A
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 19:41:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DC9153EE0BC
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:41:04 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BEB9345DE7E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:41:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9506945DE7F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:41:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 855031DB803E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:41:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 45C181DB803C
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:41:04 +0900 (JST)
Date: Tue, 9 Aug 2011 08:33:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3] memcg: add memory.vmscan_stat
Message-Id: <20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110808124333.GA31739@redhat.com>
References: <20110722171540.74eb9aa7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110808124333.GA31739@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, abrestic@google.com

On Mon, 8 Aug 2011 14:43:33 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Fri, Jul 22, 2011 at 05:15:40PM +0900, KAMEZAWA Hiroyuki wrote:
> > [PATCH] add memory.vmscan_stat
> > 
> > commit log of commit 0ae5e89 " memcg: count the soft_limit reclaim in..."
> > says it adds scanning stats to memory.stat file. But it doesn't because
> > we considered we needed to make a concensus for such new APIs.
> > 
> > This patch is a trial to add memory.scan_stat. This shows
> >   - the number of scanned pages(total, anon, file)
> >   - the number of rotated pages(total, anon, file)
> >   - the number of freed pages(total, anon, file)
> >   - the number of elaplsed time (including sleep/pause time)
> > 
> >   for both of direct/soft reclaim.
> > 
> > The biggest difference with oringinal Ying's one is that this file
> > can be reset by some write, as
> > 
> >   # echo 0 ...../memory.scan_stat
> > 
> > Example of output is here. This is a result after make -j 6 kernel
> > under 300M limit.
> > 
> > [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat
> > [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.vmscan_stat
> > scanned_pages_by_limit 9471864
> > scanned_anon_pages_by_limit 6640629
> > scanned_file_pages_by_limit 2831235
> > rotated_pages_by_limit 4243974
> > rotated_anon_pages_by_limit 3971968
> > rotated_file_pages_by_limit 272006
> > freed_pages_by_limit 2318492
> > freed_anon_pages_by_limit 962052
> > freed_file_pages_by_limit 1356440
> > elapsed_ns_by_limit 351386416101
> > scanned_pages_by_system 0
> > scanned_anon_pages_by_system 0
> > scanned_file_pages_by_system 0
> > rotated_pages_by_system 0
> > rotated_anon_pages_by_system 0
> > rotated_file_pages_by_system 0
> > freed_pages_by_system 0
> > freed_anon_pages_by_system 0
> > freed_file_pages_by_system 0
> > elapsed_ns_by_system 0
> > scanned_pages_by_limit_under_hierarchy 9471864
> > scanned_anon_pages_by_limit_under_hierarchy 6640629
> > scanned_file_pages_by_limit_under_hierarchy 2831235
> > rotated_pages_by_limit_under_hierarchy 4243974
> > rotated_anon_pages_by_limit_under_hierarchy 3971968
> > rotated_file_pages_by_limit_under_hierarchy 272006
> > freed_pages_by_limit_under_hierarchy 2318492
> > freed_anon_pages_by_limit_under_hierarchy 962052
> > freed_file_pages_by_limit_under_hierarchy 1356440
> > elapsed_ns_by_limit_under_hierarchy 351386416101
> > scanned_pages_by_system_under_hierarchy 0
> > scanned_anon_pages_by_system_under_hierarchy 0
> > scanned_file_pages_by_system_under_hierarchy 0
> > rotated_pages_by_system_under_hierarchy 0
> > rotated_anon_pages_by_system_under_hierarchy 0
> > rotated_file_pages_by_system_under_hierarchy 0
> > freed_pages_by_system_under_hierarchy 0
> > freed_anon_pages_by_system_under_hierarchy 0
> > freed_file_pages_by_system_under_hierarchy 0
> > elapsed_ns_by_system_under_hierarchy 0
> >
> > total_xxxx is for hierarchy management.
> > 
> > This will be useful for further memcg developments and need to be
> > developped before we do some complicated rework on LRU/softlimit
> > management.
> > 
> > This patch adds a new struct memcg_scanrecord into scan_control struct.
> > sc->nr_scanned at el is not designed for exporting information. For example,
> > nr_scanned is reset frequentrly and incremented +2 at scanning mapped pages.
> > 
> > For avoiding complexity, I added a new param in scan_control which is for
> > exporting scanning score.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Changelog:
> >   - fixed the trigger for recording nr_freed in shrink_inactive_list()
> > Changelog:
> >   - renamed as vmscan_stat
> >   - handle file/anon
> >   - added "rotated"
> >   - changed names of param in vmscan_stat.
> > ---
> >  Documentation/cgroups/memory.txt |   85 +++++++++++++++++++
> >  include/linux/memcontrol.h       |   19 ++++
> >  include/linux/swap.h             |    6 -
> >  mm/memcontrol.c                  |  172 +++++++++++++++++++++++++++++++++++++--
> >  mm/vmscan.c                      |   39 +++++++-
> >  5 files changed, 303 insertions(+), 18 deletions(-)
> > 
> > Index: mmotm-0710/Documentation/cgroups/memory.txt
> > ===================================================================
> > --- mmotm-0710.orig/Documentation/cgroups/memory.txt
> > +++ mmotm-0710/Documentation/cgroups/memory.txt
> > @@ -380,7 +380,7 @@ will be charged as a new owner of it.
> >  
> >  5.2 stat file
> >  
> > -memory.stat file includes following statistics
> > +5.2.1 memory.stat file includes following statistics
> >  
> >  # per-memory cgroup local status
> >  cache		- # of bytes of page cache memory.
> > @@ -438,6 +438,89 @@ Note:
> >  	 file_mapped is accounted only when the memory cgroup is owner of page
> >  	 cache.)
> >  
> > +5.2.2 memory.vmscan_stat
> > +
> > +memory.vmscan_stat includes statistics information for memory scanning and
> > +freeing, reclaiming. The statistics shows memory scanning information since
> > +memory cgroup creation and can be reset to 0 by writing 0 as
> > +
> > + #echo 0 > ../memory.vmscan_stat
> > +
> > +This file contains following statistics.
> > +
> > +[param]_[file_or_anon]_pages_by_[reason]_[under_heararchy]
> > +[param]_elapsed_ns_by_[reason]_[under_hierarchy]
> > +
> > +For example,
> > +
> > +  scanned_file_pages_by_limit indicates the number of scanned
> > +  file pages at vmscan.
> > +
> > +Now, 3 parameters are supported
> > +
> > +  scanned - the number of pages scanned by vmscan
> > +  rotated - the number of pages activated at vmscan
> > +  freed   - the number of pages freed by vmscan
> > +
> > +If "rotated" is high against scanned/freed, the memcg seems busy.
> > +
> > +Now, 2 reason are supported
> > +
> > +  limit - the memory cgroup's limit
> > +  system - global memory pressure + softlimit
> > +           (global memory pressure not under softlimit is not handled now)
> > +
> > +When under_hierarchy is added in the tail, the number indicates the
> > +total memcg scan of its children and itself.
> 
> In your implementation, statistics are only accounted to the memcg
> triggering the limit and the respectively scanned memcgs.
> 
> Consider the following setup:
> 
> 	A
>        / \
>       B   C
>      /
>     D
> 
> If D tries to charge but hits the limit of A, then B's hierarchy
> counters do not reflect the reclaim activity resulting in D.
> 
yes, as I expected.

> That's not consistent with how hierarchy counters usually operate, and
> neither with how you documented it.
> 
Hmm.

> On a non-technical note: as Ying Han and I were the other two people
> working on reclaim and statistics, it really irks me that neither of
> us were CCd on this.  Especially on such a controversial change.

I always drop CC if no reply/review comes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
