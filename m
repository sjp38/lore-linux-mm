Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A25CC6B00BF
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 04:44:15 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9C8iE1v013869
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 Oct 2010 17:44:14 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0772945DE4F
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 17:44:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D460B45DE4E
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 17:44:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BBB2D1DB8038
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 17:44:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A5BCE18001
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 17:44:13 +0900 (JST)
Date: Tue, 12 Oct 2010 17:38:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 07/10] memcg: add dirty limits to mem_cgroup
Message-Id: <20101012173849.0ec845d5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <xr931v7vdfxq.fsf@ninji.mtv.corp.google.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-8-git-send-email-gthelen@google.com>
	<20101005094302.GA4314@linux.develer.com>
	<xr93eic4wjlq.fsf@ninji.mtv.corp.google.com>
	<20101007091343.82ca9f7d.kamezawa.hiroyu@jp.fujitsu.com>
	<xr937hhuj19a.fsf@ninji.mtv.corp.google.com>
	<20101007094845.9e6a1b0f.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93bp70febu.fsf@ninji.mtv.corp.google.com>
	<20101012095546.f23bb950.kamezawa.hiroyu@jp.fujitsu.com>
	<xr931v7vdfxq.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrea Righi <arighi@develer.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Oct 2010 00:32:33 -0700
Greg Thelen <gthelen@google.com> wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> >> What are the cases where current->mm->owner->cgroups !=
> >> current->cgroups?
> >> 
> > In that case, assume group A and B.
> >
> >    thread(1) -> belongs to cgroup A  (thread(1) is mm->owner)
> >    thread(2) -> belongs to cgroup B
> > and
> >    a page    -> charnged to cgroup A
> >
> > Then, thread(2) make the page dirty which is under cgroup A.
> >
> > In this case, if page's dirty_pages accounting is added to cgroup B,
> > cgroup B' statistics may show "dirty_pages > all_lru_pages". This is
> > bug.
> 
> I agree that in this case the dirty_pages accounting should be added to
> cgroup A because that is where the page was charged.  This will happen
> because pc->mem_cgroup was set to A when the page was charged.  The
> mark-page-dirty code will check pc->mem_cgroup to determine which cgroup
> to add the dirty page to.
> 
> I think that the current vs current->mm->owner decision is in areas of
> the code that is used to query the dirty limits.  These routines do not
> use this data to determine which cgroup to charge for dirty pages.  The
> usage of either mem_cgroup_from_task(current->mm->owner) or
> mem_cgroup_from_task(current) in mem_cgroup_has_dirty_limit() does not
> determine which cgroup is added for dirty_pages.
> mem_cgroup_has_dirty_limit() is only used to determine if the process
> has a dirty limit.  As discussed, this is a momentary answer that may be
> wrong by the time decisions are made because the task may be migrated
> in-to/out-of root cgroup while mem_cgroup_has_dirty_limit() runs.  If
> the process has a dirty limit, then the process's memcg is used to
> compute dirty limits.  Using your example, I assume that thread(1) and
> thread(2) will git dirty limits from cgroup(A) and cgroup(B)
> respectively.
> 

Ok, thank you for clarification. Throttoling a thread based on its own
cgroup not based on mm->owner makes sense. Could you add a brief comment on
the code ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
