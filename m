Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AE4A1900138
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 03:57:56 -0400 (EDT)
Date: Mon, 29 Aug 2011 09:57:31 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110829075731.GA32114@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
 <CALWz4iwChnacF061L9vWo7nEA7qaXNJrK=+jsEe9xBtvEBD9MA@mail.gmail.com>
 <20110811210914.GB31229@cmpxchg.org>
 <CALWz4iwJfyWRineMy+W02YBvS0Y=Pv1y8Rb=8i5R=vUCfrO+iQ@mail.gmail.com>
 <CALWz4iwRXBheXFND5zq3ze2PJDkeoxYHD1zOsTyzOe3XqY5apA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4iwRXBheXFND5zq3ze2PJDkeoxYHD1zOsTyzOe3XqY5apA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

On Mon, Aug 29, 2011 at 12:22:02AM -0700, Ying Han wrote:
> fix hierarchy_walk() to hold a reference to first mem_cgroup
> 
> The first mem_cgroup returned from hierarchy_walk() is used to
> terminate a round-trip. However there is no reference hold on
> that which the first could be removed during the walking. The
> patch including the following change:
> 
> 1. hold a reference on the first mem_cgroup during the walk.
> 2. rename the variable "root" to "target", which we found using
> "root" is confusing in this content with root_mem_cgroup. better
> naming is welcomed.

Thanks for the report.

This was actually not the only case that could lead to overlong (not
necessarily endless) looping.

With several scanning threads, a single thread may not encounter its
first cgroup again for a long time, as the other threads would visit
it.

I changed this to use scan generations.  Restarting the scan from id 0
starts the next scan generation.  The iteration function returns NULL
if the generation changed since a loop was started.

This way, iterators can reliably detect whether they should call it
quits without any requirements for previously encountered memcgs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
