Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 609326B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 00:36:50 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 552C03EE0AE
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:36:46 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A33B45DE9C
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:36:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B50745DE98
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:36:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F63FE08001
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:36:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF4DA1DB8037
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:36:45 +0900 (JST)
Date: Tue, 31 May 2011 13:29:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm, vmstat: Use cond_resched only when !CONFIG_PREEMPT
Message-Id: <20110531132950.258cd16d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTiksAjyCBAPdCB58tAWhXcdqXM4EcA@mail.gmail.com>
References: <1306774744.4061.5.camel@localhost.localdomain>
	<20110531083859.98e4ff43.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinTqijGxCpZ_nRwWZHYsR-u2zojZA@mail.gmail.com>
	<20110531121815.67523361.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTiksAjyCBAPdCB58tAWhXcdqXM4EcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rakib Mullick <rakib.mullick@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Christoph Lameter <cl@linux.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, 31 May 2011 09:58:40 +0600
Rakib Mullick <rakib.mullick@gmail.com> wrote:

> On Tue, May 31, 2011 at 9:18 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 31 May 2011 09:13:47 +0600
> > Rakib Mullick <rakib.mullick@gmail.com> wrote:
> >
> >> On Tue, May 31, 2011 at 5:38 AM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> > On Mon, 30 May 2011 22:59:04 +0600
> >> > Rakib Mullick <rakib.mullick@gmail.com> wrote:
> >> >
> >> >> commit 468fd62ed9 (vmstats: add cond_resched() to refresh_cpu_vm_stats()) added cond_resched() in refresh_cpu_vm_stats. Purpose of that patch was to allow other threads to run in non-preemptive case. This patch, makes sure that cond_resched() gets called when !CONFIG_PREEMPT is set. In a preemptiable kernel we don't need to call cond_resched().
> >> >>
> >> >> Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
> >> >
> >> > Hmm, what benefit do we get by adding this extra #ifdef in the code directly ?
> >> > Other cond_resched() callers are not guilty in !CONFIG_PREEMPT ?
> >> >
> >> Well, in preemptible kernel this context will get preempted if
> >> requires, so we don't need cond_resched(). If you checkout the git log
> >> of the mentioned commit, you'll find the explanation. It says:
> >> A  A  A  A  "Adding a cond_resched() to allow other threads to run in the
> >> non-preemptive
> >> A  A  case."
> >>
> >
> > IOW, my question is "why only this cond_resched() should be fixed ?"
> 
> cond_resched() forces this thread to be scheduled. I'm just trying
> pointing out the use of cond_resched(), until unless I'm not missing
> anything.
> 
> > What's bad with all cond_resched() in the kernel as no-op in CONFIG_PREEMPT ?
> >
> cond_resched() basically checks whether it needs to be scheduled or
> not. But, we know in advance that we don't need cond_resched in
> CONFIG_PREEMPT.
> 
> Thanks,

Then just remove _all_ cond_resched() by defining noop function in header.
Please don't fix in ugly way.

#ifdef CONFIG_PEERMPT
static void cond_resched()
{
}
#endif

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
