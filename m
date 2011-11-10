Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 65D8F6B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 11:07:53 -0500 (EST)
Date: Thu, 10 Nov 2011 17:06:28 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [rfc 2/3] mm: vmscan: treat inactive cycling as neutral
Message-ID: <20111110160628.GM3153@redhat.com>
References: <20110808110658.31053.55013.stgit@localhost6>
 <CAOJsxLF909NRC2r6RL+hm1ARve+3mA6UM_CY9epJaauyqJTG8w@mail.gmail.com>
 <4E3FD403.6000400@parallels.com>
 <20111102163056.GG19965@redhat.com>
 <20111102163213.GI19965@redhat.com>
 <20111107113417.1b7581a5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111107113417.1b7581a5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Konstantin Khlebnikov <khlebnikov@parallels.com>, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Gene Heskett <gene.heskett@gmail.com>

On Mon, Nov 07, 2011 at 11:34:17AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 2 Nov 2011 17:32:13 +0100
> Johannes Weiner <jweiner@redhat.com> wrote:
> 
> > Each page that is scanned but put back to the inactive list is counted
> > as a successful reclaim, which tips the balance between file and anon
> > lists more towards the cycling list.
> > 
> > This does - in my opinion - not make too much sense, but at the same
> > time it was not much of a problem, as the conditions that lead to an
> > inactive list cycle were mostly temporary - locked page, concurrent
> > page table changes, backing device congested - or at least limited to
> > a single reclaimer that was not allowed to unmap or meddle with IO.
> > More important than being moderately rare, those conditions should
> > apply to both anon and mapped file pages equally and balance out in
> > the end.
> > 
> > Recently, we started cycling file pages in particular on the inactive
> > list much more aggressively, for used-once detection of mapped pages,
> > and when avoiding writeback from direct reclaim.
> > 
> > Those rotated pages do not exactly speak for the reclaimability of the
> > list they sit on and we risk putting immense pressure on file list for
> > no good reason.
> > 
> > Instead, count each page not reclaimed and put back to any list,
> > active or inactive, as rotated, so they are neutral with respect to
> > the scan/rotate ratio of the list class, as they should be.
> > 
> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> 
> I think this makes sense.
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> I wonder it may be better to have victim list for written-backed pages..

Do you mean an extra LRU list that holds dirty pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
