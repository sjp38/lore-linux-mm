Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0365B6B007B
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 03:55:01 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C8sxSj014539
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Feb 2010 17:54:59 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1948C45DE79
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 17:54:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D38E445DE6F
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 17:54:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AFF9AE18004
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 17:54:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 61E04E18002
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 17:54:58 +0900 (JST)
Date: Fri, 12 Feb 2010 17:51:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg: share event counter rather than duplicate
Message-Id: <20100212175133.7d0cfdb4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <cc557aab1002120049v28322a29sbe11d7f049806115@mail.gmail.com>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212154857.f9d8f28e.kamezawa.hiroyu@jp.fujitsu.com>
	<cc557aab1002120007v1dfdfac0te0c2a8b750919c15@mail.gmail.com>
	<20100212171948.16346836.kamezawa.hiroyu@jp.fujitsu.com>
	<cc557aab1002120049v28322a29sbe11d7f049806115@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010 10:49:45 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Fri, Feb 12, 2010 at 10:19 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 12 Feb 2010 10:07:25 +0200
> > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> >
> >> On Fri, Feb 12, 2010 at 8:48 AM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> > Memcg has 2 eventcountes which counts "the same" event. Just usages are
> >> > different from each other. This patch tries to reduce event counter.
> >> >
> >> > This patch's logic uses "only increment, no reset" new_counter and masks for each
> >> > checks. Softlimit chesk was done per 1000 events. So, the similar check
> >> > can be done by !(new_counter & 0x3ff). Threshold check was done per 100
> >> > events. So, the similar check can be done by (!new_counter & 0x7f)
> >>
> >> IIUC, with this change we have to check counter after each update,
> >> since we check
> >> for exact value.
> >
> > Yes.
> >> So we have to move checks to mem_cgroup_charge_statistics() or
> >> call them after each statistics charging. I'm not sure how it affects
> >> performance.
> >>
> >
> > My patch 1/2 does it.
> >
> > But hmm, move-task does counter updates in asynchronous manner. Then, there are
> > bug. I'll add check in the next version.
> >
> > Maybe calling update_tree and threshold_check at the end of mova_task is
> > better. Does thresholds user take care of batched-move manner in task_move ?
> > Should we check one by one ?
> 
> No. mem_cgroup_threshold() at mem_cgroup_move_task() is enough.
> 
> But... Is task moving a critical path? If no, It's, probably, cleaner to check
> everything at mem_cgroup_charge_statistics().
> 
The trouble is charge_statistics() is called under lock_page_cgroup() and 
I don't want to call something heavy under it.
(And I'm not very sure calling charge_statitics it without lock-page-cgroup is
 dangerous or not. (I think it has some race.)
 But if there is race, it's very difficult one. So, I leave it as it is.)

Maybe, my next one will be enough simple one. Thank you for review.

Regards,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
