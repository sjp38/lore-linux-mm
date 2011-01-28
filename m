Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AAB688D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 03:20:51 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5F7853EE0AE
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:20:48 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A80645DE4E
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:20:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3386045DE4D
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:20:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 22D801DB803B
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:20:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D9AB41DB803A
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:20:47 +0900 (JST)
Date: Fri, 28 Jan 2011 17:14:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH 2/4] memcg: fix charge path for THP and allow
 early retirement
Message-Id: <20110128171447.1b5b19f3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110128075724.GB2213@cmpxchg.org>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128122608.cf9be26b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128075724.GB2213@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jan 2011 08:57:24 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Fri, Jan 28, 2011 at 12:26:08PM +0900, KAMEZAWA Hiroyuki wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > When THP is used, Hugepage size charge can happen. It's not handled
> > correctly in mem_cgroup_do_charge(). For example, THP can fallback
> > to small page allocation when HUGEPAGE allocation seems difficult
> > or busy, but memory cgroup doesn't understand it and continue to
> > try HUGEPAGE charging. And the worst thing is memory cgroup
> > believes 'memory reclaim succeeded' if limit - usage > PAGE_SIZE.
> > 
> > By this, khugepaged etc...can goes into inifinite reclaim loop
> > if tasks in memcg are busy.
> > 
> > After this patch 
> >  - Hugepage allocation will fail if 1st trial of page reclaim fails.
> > 
> > Changelog:
> >  - make changes small. removed renaming codes.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   28 ++++++++++++++++++++++++----
> >  1 file changed, 24 insertions(+), 4 deletions(-)
> 
> Was there something wrong with my oneline fix?
> 
I thought your patch was against RHEL6.

> Really, there is no way to make this a beautiful fix.  The way this
> function is split up makes no sense, and the constant addition of more
> and more flags just to correctly communicate with _one callsite_
> should be an obvious hint.
> 

Your version has to depend on oom_check flag to work fine.
I think it's complicated.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
