Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 384B9900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 05:38:08 -0400 (EDT)
Date: Thu, 18 Aug 2011 11:38:00 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
Message-ID: <20110818093800.GA2268@redhat.com>
References: <1313650253-21794-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1313650253-21794-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Wed, Aug 17, 2011 at 11:50:53PM -0700, Greg Thelen wrote:
> Both mem_cgroup_charge_statistics() and mem_cgroup_move_account() were
> unnecessarily disabling preemption when adjusting per-cpu counters:
>     preempt_disable()
>     __this_cpu_xxx()
>     __this_cpu_yyy()
>     preempt_enable()
> 
> This change does not disable preemption and thus CPU switch is possible
> within these routines.  This does not cause a problem because the total
> of all cpu counters is summed when reporting stats.  Now both
> mem_cgroup_charge_statistics() and mem_cgroup_move_account() look like:
>     this_cpu_xxx()
>     this_cpu_yyy()

Note that on non-x86, these operations themselves actually disable and
reenable preemption each time, so you trade a pair of add and sub on
x86

-	preempt_disable()
	__this_cpu_xxx()
	__this_cpu_yyy()
-	preempt_enable()

with

	preempt_disable()
	__this_cpu_xxx()
+	preempt_enable()
+	preempt_disable()
	__this_cpu_yyy()
	preempt_enable()

everywhere else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
