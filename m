Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 635F29000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 04:52:30 -0400 (EDT)
Date: Tue, 20 Sep 2011 10:52:19 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 02/11] mm: vmscan: distinguish global reclaim from global
 LRU scanning
Message-ID: <20110920085219.GB11489@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-3-git-send-email-jweiner@redhat.com>
 <20110919132344.GE21847@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110919132344.GE21847@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 19, 2011 at 03:23:44PM +0200, Michal Hocko wrote:
> On Mon 12-09-11 12:57:19, Johannes Weiner wrote:
> > The traditional zone reclaim code is scanning the per-zone LRU lists
> > during direct reclaim and kswapd, and the per-zone per-memory cgroup
> > LRU lists when reclaiming on behalf of a memory cgroup limit.
> > 
> > Subsequent patches will convert the traditional reclaim code to
> > reclaim exclusively from the per-memory cgroup LRU lists.  As a
> > result, using the predicate for which LRU list is scanned will no
> > longer be appropriate to tell global reclaim from limit reclaim.
> > 
> > This patch adds a global_reclaim() predicate to tell direct/kswapd
> > reclaim from memory cgroup limit reclaim and substitutes it in all
> > places where currently scanning_global_lru() is used for that.
> 
> I am wondering about vmscan_swappiness. Shouldn't it use global_reclaim
> instead?

Thanks for noticing, you are right.  Too many rebases...

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 354f125..c2b0903 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1840,7 +1840,7 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 
 static int vmscan_swappiness(struct scan_control *sc)
 {
-	if (scanning_global_lru(sc))
+	if (global_reclaim(sc))
 		return vm_swappiness;
 	return mem_cgroup_swappiness(sc->mem_cgroup);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
