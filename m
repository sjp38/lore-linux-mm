Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id D39EC6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 19:49:40 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5DF673EE0BC
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:49:39 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4353645DE6C
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:49:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 16E15266D12
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:49:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 026BEE08002
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:49:39 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 934C2E08007
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:49:38 +0900 (JST)
Date: Fri, 20 Jan 2012 09:48:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 1/7 v2] memcg: remove unnecessary check in
 mem_cgroup_update_page_stat()
Message-Id: <20120120094821.7f23e5a1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CALWz4iy=hpEbXgjdkD+OH69MHjBorSELB3RZ8BxWNFjk=5yRNw@mail.gmail.com>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113173227.df2baae3.kamezawa.hiroyu@jp.fujitsu.com>
	<20120117151619.GA21348@tiehlicka.suse.cz>
	<20120118085558.6ed1a988.kamezawa.hiroyu@jp.fujitsu.com>
	<20120118130102.GC31112@tiehlicka.suse.cz>
	<CALWz4iy=hpEbXgjdkD+OH69MHjBorSELB3RZ8BxWNFjk=5yRNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Thu, 19 Jan 2012 12:07:22 -0800
Ying Han <yinghan@google.com> wrote:

> On Wed, Jan 18, 2012 at 5:01 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Wed 18-01-12 08:55:58, KAMEZAWA Hiroyuki wrote:
> >> On Tue, 17 Jan 2012 16:16:20 +0100
> >> Michal Hocko <mhocko@suse.cz> wrote:
> >>
> >> > On Fri 13-01-12 17:32:27, KAMEZAWA Hiroyuki wrote:
> >> > >
> >> > > From 788aebf15f3fa37940e0745cab72547e20683bf2 Mon Sep 17 00:00:00 2001
> >> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> > > Date: Thu, 12 Jan 2012 16:08:33 +0900
> >> > > Subject: [PATCH 1/7] memcg: remove unnecessary check in mem_cgroup_update_page_stat()
> >> > >
> >> > > commit 10ea69f1182b removes move_lock_page_cgroup() in thp-split path.
> >> > > So, this PageTransHuge() check is unnecessary, too.
> >> >
> >> > I do not see commit like that in the tree. I guess you meant
> >> > memcg: make mem_cgroup_split_huge_fixup() more efficient which is not
> >> > merged yet, right?
> >> >
> >>
> >> This commit in the linux-next.
> >
> > Referring to commits from linux-next is tricky as it changes all the
> > time. I guess that the full commit subject should be sufficient.
> >
> >> > > Note:
> >> > > A - considering when mem_cgroup_update_page_stat() is called,
> >> > > A  A there will be no race between split_huge_page() and update_page_stat().
> >> > > A  A All required locks are held in higher level.
> >> >
> >> > We should never have THP page in this path in the first place. So why
> >> > not changing this to VM_BUG_ON(PageTransHuge).
> >> >
> >>
> >> Ying Han considers to support mlock stat.
> >
> > OK, got it. What about the following updated changelog instead?
> >
> > ===
> > We do not have to check PageTransHuge in mem_cgroup_update_page_stat
> > and fallback into the locked accounting because both move charge and thp
> 
> one nitpick. Should it be "move account" instead of "move charge"?
> 
Ah, yes. you'r right.
Considering Michal's comment, I'll update and post v3.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
