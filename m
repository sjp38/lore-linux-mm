Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 656866B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 06:11:56 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4AEBA3EE0BD
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 19:11:53 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3127B45DE81
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 19:11:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 194DA45DE7F
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 19:11:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BC0E1DB803C
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 19:11:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C66461DB802C
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 19:11:52 +0900 (JST)
Date: Tue, 6 Sep 2011 19:04:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
Message-Id: <20110906190424.ad5cc647.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110906095852.GA25053@redhat.com>
References: <1313650253-21794-1-git-send-email-gthelen@google.com>
	<20110906095852.GA25053@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Tue, 6 Sep 2011 11:58:52 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Wed, Aug 17, 2011 at 11:50:53PM -0700, Greg Thelen wrote:
> > Both mem_cgroup_charge_statistics() and mem_cgroup_move_account() were
> > unnecessarily disabling preemption when adjusting per-cpu counters:
> >     preempt_disable()
> >     __this_cpu_xxx()
> >     __this_cpu_yyy()
> >     preempt_enable()
> > 
> > This change does not disable preemption and thus CPU switch is possible
> > within these routines.  This does not cause a problem because the total
> > of all cpu counters is summed when reporting stats.  Now both
> > mem_cgroup_charge_statistics() and mem_cgroup_move_account() look like:
> >     this_cpu_xxx()
> >     this_cpu_yyy()
> > 
> > Reported-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Greg Thelen <gthelen@google.com>
> 
> I just noticed that both cases have preemption disabled anyway because
> of the page_cgroup bit spinlock.
> 
> So removing the preempt_disable() is fine but we can even keep the
> non-atomic __this_cpu operations.
> 
> Something like this instead?
> 
> ---
> From: Johannes Weiner <jweiner@redhat.com>
> Subject: mm: memcg: remove needless recursive preemption disabling
> 
> Callsites of mem_cgroup_charge_statistics() hold the page_cgroup bit
> spinlock, which implies disabled preemption.
> 
> The same goes for the explicit preemption disabling to account mapped
> file pages in mem_cgroup_move_account().
> 
> The explicit disabling of preemption in both cases is redundant.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Could you add comments as
"This operation is called under bit spin lock !" ?

Nice catch.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
