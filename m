Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4B68D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 02:57:28 -0500 (EST)
Date: Fri, 28 Jan 2011 08:57:24 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [BUGFIX][PATCH 2/4] memcg: fix charge path for THP and allow
 early retirement
Message-ID: <20110128075724.GB2213@cmpxchg.org>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
 <20110128122608.cf9be26b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110128122608.cf9be26b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 12:26:08PM +0900, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> When THP is used, Hugepage size charge can happen. It's not handled
> correctly in mem_cgroup_do_charge(). For example, THP can fallback
> to small page allocation when HUGEPAGE allocation seems difficult
> or busy, but memory cgroup doesn't understand it and continue to
> try HUGEPAGE charging. And the worst thing is memory cgroup
> believes 'memory reclaim succeeded' if limit - usage > PAGE_SIZE.
> 
> By this, khugepaged etc...can goes into inifinite reclaim loop
> if tasks in memcg are busy.
> 
> After this patch 
>  - Hugepage allocation will fail if 1st trial of page reclaim fails.
> 
> Changelog:
>  - make changes small. removed renaming codes.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   28 ++++++++++++++++++++++++----
>  1 file changed, 24 insertions(+), 4 deletions(-)

Was there something wrong with my oneline fix?

Really, there is no way to make this a beautiful fix.  The way this
function is split up makes no sense, and the constant addition of more
and more flags just to correctly communicate with _one callsite_
should be an obvious hint.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
