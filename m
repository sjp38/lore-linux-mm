Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id C3DF56B004D
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 19:13:58 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 47FD13EE081
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:13:57 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B52745DE68
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:13:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 152A545DD74
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:13:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 07542E08002
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:13:57 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B70A91DB8038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:13:56 +0900 (JST)
Date: Wed, 18 Jan 2012 09:12:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 3/7 v2] memcg: remove PCG_MOVE_LOCK flag from
 pc->flags
Message-Id: <20120118091226.b46e0f6e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120117164605.GB22142@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113174019.8dff3fc1.kamezawa.hiroyu@jp.fujitsu.com>
	<20120117164605.GB22142@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Tue, 17 Jan 2012 17:46:05 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Fri 13-01-12 17:40:19, KAMEZAWA Hiroyuki wrote:
> > 
> > From 1008e84d94245b1e7c4d237802ff68ff00757736 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Thu, 12 Jan 2012 15:53:24 +0900
> > Subject: [PATCH 3/7] memcg: remove PCG_MOVE_LOCK flag from pc->flags.
> > 
> > PCG_MOVE_LOCK bit is used for bit spinlock for avoiding race between
> > memcg's account moving and page state statistics updates.
> > 
> > Considering page-statistics update, very hot path, this lock is
> > taken only when someone is moving account (or PageTransHuge())
> 
> Outdated comment? THP is not an issue here.
> 
Ah, sorry. I reorderd patches.

> > And, now, all moving-account between memcgroups (by task-move)
> > are serialized.
> > 
> > So, it seems too costly to have 1bit per page for this purpose.
> > 
> > This patch removes PCG_MOVE_LOCK and add hashed rwlock array
> > instead of it. This works well enough. Even when we need to
> > take the lock, 
> 
> Hmmm, rwlocks are not popular these days very much. 
> Anyway, can we rather make it (source) memcg (bit)spinlock instead. We
> would reduce false sharing this way and would penalize only pages from
> the moving group.
> 
per-memcg spinlock ? The reason I used rwlock() is to avoid disabling IRQ.
This routine will be called by IRQ context (for dirty ratio support).
So, IRQ disable will be required if we use spinlock.

Thanks,
-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
