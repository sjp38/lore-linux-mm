Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CF22A6B0078
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 05:03:39 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 61A873EE0BD
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 18:03:35 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4707345DED4
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 18:03:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2142545DED1
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 18:03:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DE5DE78004
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 18:03:35 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CDBD8E78005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 18:03:34 +0900 (JST)
Date: Tue, 7 Jun 2011 17:56:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 11/12] writeback: make background writeback cgroup
 aware
Message-Id: <20110607175634.b07f2e57.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1307117538-14317-12-git-send-email-gthelen@google.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
	<1307117538-14317-12-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri,  3 Jun 2011 09:12:17 -0700
Greg Thelen <gthelen@google.com> wrote:

> When the system is under background dirty memory threshold but a cgroup
> is over its background dirty memory threshold, then only writeback
> inodes associated with the over-limit cgroup(s).
> 
> In addition to checking if the system dirty memory usage is over the
> system background threshold, over_bground_thresh() also checks if any
> cgroups are over their respective background dirty memory thresholds.
> The writeback_control.for_cgroup field is set to distinguish between a
> system and memcg overage.
> 
> If performing cgroup writeback, move_expired_inodes() skips inodes that
> do not contribute dirty pages to the cgroup being written back.
> 
> After writing some pages, wb_writeback() will call
> mem_cgroup_writeback_done() to update the set of over-bg-limits memcg.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>



> ---
> Changelog since v7:
> - over_bground_thresh() now sets shared_inodes=1.  In -v7 per memcg
>   background writeback did not, so it did not write pages of shared
>   inodes in background writeback.  In the (potentially common) case
>   where the system dirty memory usage is below the system background
>   dirty threshold but at least one cgroup is over its background dirty
>   limit, then per memcg background writeback is queued for any
>   over-background-threshold cgroups.  Background writeback should be
>   allowed to writeback shared inodes.  The hope is that writing such
>   inodes has good chance of cleaning the inodes so they can transition
>   from shared to non-shared.  Such a transition is good because then the
>   inode will remain unshared until it is written by multiple cgroup.
>   Non-shared inodes offer better isolation.

If you post v9,  please adds above explanation as the comments in the code.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
