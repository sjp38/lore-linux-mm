Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2099F8D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 23:03:01 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAG42wbU010111
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Nov 2010 13:02:59 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AEAA245DE79
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:02:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D49A45DE60
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:02:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 74A501DB803F
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:02:58 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BB7C1DB803E
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:02:58 +0900 (JST)
Date: Tue, 16 Nov 2010 12:57:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/6] memcg: make throttle_vm_writeout() memcg aware
Message-Id: <20101116125726.db42723c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <xr93wroixomw.fsf@ninji.mtv.corp.google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
	<1289294671-6865-4-git-send-email-gthelen@google.com>
	<20101112081754.GE9131@cmpxchg.org>
	<xr93wroixomw.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Nov 2010 12:39:35 -0800
Greg Thelen <gthelen@google.com> wrote:

> > Odd branch ordering, but I may be OCDing again.
> >
> > 	if (mem_cgroup && memcg_dirty_info())
> > 		do_mem_cgroup_stuff()
> > 	else
> > 		do_global_stuff()
> >
> > would be more natural, IMO.
> 
> I agree.  I will resubmit this series with your improved branch ordering.
> 

Hmm. I think this patch is troublesome.

This patch will make memcg's pageout routine _not_ throttoled even when the whole
system vmscan's pageout is throttoled.

So, one idea is....

Make this change 
==
+++ b/mm/vmscan.c
@@ -1844,7 +1844,7 @@ static void shrink_zone(int priority, struct zone *zone,
 	if (inactive_anon_is_low(zone, sc))
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
-	throttle_vm_writeout(sc->gfp_mask);
+	throttle_vm_writeout(sc->gfp_mask, sc->mem_cgroup);
 }
==
as

==
	
if (!sc->mem_cgroup || throttle_vm_writeout(sc->gfp_mask, sc->mem_cgroup) == not throttled)
	throttole_vm_writeout(sc->gfp_mask, NULL);

Then, both of memcg and global dirty thresh will be checked.


-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
