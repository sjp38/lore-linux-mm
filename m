Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id BD8226B004F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 21:19:39 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E6AD73EE0BC
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 11:19:37 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CBF2C45DEBB
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 11:19:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A6CAE45DEB2
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 11:19:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FC651DB8042
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 11:19:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 411431DB803F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 11:19:37 +0900 (JST)
Date: Thu, 19 Jan 2012 11:18:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 1/7 v2] memcg: remove unnecessary check in
 mem_cgroup_update_page_stat()
Message-Id: <20120119111823.2f18f6c6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120118130102.GC31112@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113173227.df2baae3.kamezawa.hiroyu@jp.fujitsu.com>
	<20120117151619.GA21348@tiehlicka.suse.cz>
	<20120118085558.6ed1a988.kamezawa.hiroyu@jp.fujitsu.com>
	<20120118130102.GC31112@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Wed, 18 Jan 2012 14:01:02 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 18-01-12 08:55:58, KAMEZAWA Hiroyuki wrote:
> > On Tue, 17 Jan 2012 16:16:20 +0100
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > On Fri 13-01-12 17:32:27, KAMEZAWA Hiroyuki wrote:
> > > > 
> > > > From 788aebf15f3fa37940e0745cab72547e20683bf2 Mon Sep 17 00:00:00 2001
> > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > Date: Thu, 12 Jan 2012 16:08:33 +0900
> > > > Subject: [PATCH 1/7] memcg: remove unnecessary check in mem_cgroup_update_page_stat()
> > > > 
> > > > commit 10ea69f1182b removes move_lock_page_cgroup() in thp-split path.
> > > > So, this PageTransHuge() check is unnecessary, too.
> > > 
> > > I do not see commit like that in the tree. I guess you meant
> > > memcg: make mem_cgroup_split_huge_fixup() more efficient which is not
> > > merged yet, right?
> > > 
> > 
> > This commit in the linux-next.
> 
> Referring to commits from linux-next is tricky as it changes all the
> time. I guess that the full commit subject should be sufficient.
> 
> > > > Note:
> > > >  - considering when mem_cgroup_update_page_stat() is called,
> > > >    there will be no race between split_huge_page() and update_page_stat().
> > > >    All required locks are held in higher level.
> > > 
> > > We should never have THP page in this path in the first place. So why
> > > not changing this to VM_BUG_ON(PageTransHuge).
> > > 
> > 
> > Ying Han considers to support mlock stat.
> 
> OK, got it. What about the following updated changelog instead?
> 
> ===
> We do not have to check PageTransHuge in mem_cgroup_update_page_stat
> and fallback into the locked accounting because both move charge and thp
> split up are done with compound_lock so they cannot race. update vs.
> move is protected by the mem_cgroup_stealed sufficiently.
> 
> PageTransHuge pages shouldn't appear in this code path currently because
> we are tracking only file pages at the moment but later we are planning
> to track also other pages (e.g. mlocked ones).
> ===

ok, will use this :) Thank you.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
