Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 738BE900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 06:06:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 09DB63EE0AE
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:06:55 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E543B45DE86
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:06:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C382745DE81
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:06:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B0A7B1DB8038
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:06:54 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F2FC1DB803A
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:06:54 +0900 (JST)
Date: Tue, 13 Sep 2011 19:06:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 01/11] mm: memcg: consolidate hierarchy iteration
 primitives
Message-Id: <20110913190608.b0658961.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1315825048-3437-2-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
	<1315825048-3437-2-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 12 Sep 2011 12:57:18 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> Memory control groups are currently bolted onto the side of
> traditional memory management in places where better integration would
> be preferrable.  To reclaim memory, for example, memory control groups
> maintain their own LRU list and reclaim strategy aside from the global
> per-zone LRU list reclaim.  But an extra list head for each existing
> page frame is expensive and maintaining it requires additional code.
> 
> This patchset disables the global per-zone LRU lists on memory cgroup
> configurations and converts all its users to operate on the per-memory
> cgroup lists instead.  As LRU pages are then exclusively on one list,
> this saves two list pointers for each page frame in the system:
> 
> page_cgroup array size with 4G physical memory
> 
>   vanilla: [    0.000000] allocated 31457280 bytes of page_cgroup
>   patched: [    0.000000] allocated 15728640 bytes of page_cgroup
> 
> At the same time, system performance for various workloads is
> unaffected:
> 
> 100G sparse file cat, 4G physical memory, 10 runs, to test for code
> bloat in the traditional LRU handling and kswapd & direct reclaim
> paths, without/with the memory controller configured in
> 
>   vanilla: 71.603(0.207) seconds
>   patched: 71.640(0.156) seconds
> 
>   vanilla: 79.558(0.288) seconds
>   patched: 77.233(0.147) seconds
> 
> 100G sparse file cat in 1G memory cgroup, 10 runs, to test for code
> bloat in the traditional memory cgroup LRU handling and reclaim path
> 
>   vanilla: 96.844(0.281) seconds
>   patched: 94.454(0.311) seconds
> 
> 4 unlimited memcgs running kbuild -j32 each, 4G physical memory, 500M
> swap on SSD, 10 runs, to test for regressions in kswapd & direct
> reclaim using per-memcg LRU lists with multiple memcgs and multiple
> allocators within each memcg
> 
>   vanilla: 717.722(1.440) seconds [ 69720.100(11600.835) majfaults ]
>   patched: 714.106(2.313) seconds [ 71109.300(14886.186) majfaults ]
> 
> 16 unlimited memcgs running kbuild, 1900M hierarchical limit, 500M
> swap on SSD, 10 runs, to test for regressions in hierarchical memcg
> setups
> 
>   vanilla: 2742.058(1.992) seconds [ 26479.600(1736.737) majfaults ]
>   patched: 2743.267(1.214) seconds [ 27240.700(1076.063) majfaults ]
> 
> This patch:
> 
> There are currently two different implementations of iterating over a
> memory cgroup hierarchy tree.
> 
> Consolidate them into one worker function and base the convenience
> looping-macros on top of it.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Seems nice.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
