Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id E5BBC6B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 20:48:26 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 91C903EE0C1
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 10:48:24 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 769EA45DEF2
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 10:48:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F76945DEEC
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 10:48:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 35F281DB803E
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 10:48:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E06661DB803B
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 10:48:23 +0900 (JST)
Date: Mon, 6 Feb 2012 10:46:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix up documentation on global LRU.
Message-Id: <20120206104649.01a89d66.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CALWz4iz48O2TcGOFaGw1_FyhzJ_7njgZ_p8cELcpDJuuKa=Gxg@mail.gmail.com>
References: <1328233033-14246-1-git-send-email-yinghan@google.com>
	<20120203161140.GC13461@tiehlicka.suse.cz>
	<CALWz4iz48O2TcGOFaGw1_FyhzJ_7njgZ_p8cELcpDJuuKa=Gxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Fri, 3 Feb 2012 12:15:59 -0800
Ying Han <yinghan@google.com> wrote:

> On Fri, Feb 3, 2012 at 8:11 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Thu 02-02-12 17:37:13, Ying Han wrote:
> >> In v3.3-rc1, the global LRU has been removed with commit
> >> "mm: make per-memcg LRU lists exclusive". The patch fixes up the memcg docs.
> >>
> >> Signed-off-by: Ying Han <yinghan@google.com>
> >
> > For the global LRU removal
> > Acked-by: Michal Hocko <mhocko@suse.cz>
> >
> > see the comment about the swap extension bellow.
> >
> > Thanks
> >
> >> ---
> >> A Documentation/cgroups/memory.txt | A  25 ++++++++++++-------------
> >> A 1 files changed, 12 insertions(+), 13 deletions(-)
> >>
> >> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> >> index 4c95c00..847a2a4 100644
> >> --- a/Documentation/cgroups/memory.txt
> >> +++ b/Documentation/cgroups/memory.txt
> > [...]
> >> @@ -209,19 +208,19 @@ In this case, setting memsw.limit_in_bytes=3G will prevent bad use of swap.
> >> A By using memsw limit, you can avoid system OOM which can be caused by swap
> >> A shortage.
> >>
> >> -* why 'memory+swap' rather than swap.
> >> -The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
> >> -to move account from memory to swap...there is no change in usage of
> >> -memory+swap. In other words, when we want to limit the usage of swap without
> >> -affecting global LRU, memory+swap limit is better than just limiting swap from
> >> -OS point of view.
> >> -
> >> A * What happens when a cgroup hits memory.memsw.limit_in_bytes
> >> A When a cgroup hits memory.memsw.limit_in_bytes, it's useless to do swap-out
> >> A in this cgroup. Then, swap-out will not be done by cgroup routine and file
> >> -caches are dropped. But as mentioned above, global LRU can do swapout memory
> >> -from it for sanity of the system's memory management state. You can't forbid
> >> -it by cgroup.
> >> +caches are dropped.
> >> +
> >> +TODO:
> >> +* use 'memory+swap' rather than swap was due to existence of global LRU.
> 
> I wasn't sure about the initial comment while making the patch. Since
> it mentions something about global LRU, which i figured we need to
> revisit it anyway.
> 

The "global LRU" here means 'the health of the whole memory management".
memory+swap guarantees memcg will never be obstacles for routines which
works for system memory management.

soft-limit _is_ a hint for global lru. but memory+swap will never be.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
