Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 0DA536B004F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 18:54:26 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2E59B3EE0BD
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 08:54:25 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 13ABB45DEB5
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 08:54:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EAFA745DE9E
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 08:54:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DA25B1DB803F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 08:54:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 91E921DB803B
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 08:54:24 +0900 (JST)
Date: Thu, 19 Jan 2012 08:53:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 3/7 v2] memcg: remove PCG_MOVE_LOCK flag from
 pc->flags
Message-Id: <20120119085309.616cadb4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120118104703.GA31112@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113174019.8dff3fc1.kamezawa.hiroyu@jp.fujitsu.com>
	<20120117164605.GB22142@tiehlicka.suse.cz>
	<20120118091226.b46e0f6e.kamezawa.hiroyu@jp.fujitsu.com>
	<20120118104703.GA31112@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Wed, 18 Jan 2012 11:47:03 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 18-01-12 09:12:26, KAMEZAWA Hiroyuki wrote:
> > On Tue, 17 Jan 2012 17:46:05 +0100
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > On Fri 13-01-12 17:40:19, KAMEZAWA Hiroyuki wrote:
> [...]
> > > > This patch removes PCG_MOVE_LOCK and add hashed rwlock array
> > > > instead of it. This works well enough. Even when we need to
> > > > take the lock, 
> > > 
> > > Hmmm, rwlocks are not popular these days very much. 
> > > Anyway, can we rather make it (source) memcg (bit)spinlock instead. We
> > > would reduce false sharing this way and would penalize only pages from
> > > the moving group.
> > > 
> > per-memcg spinlock ? 
> 
> Yes
> 
> > The reason I used rwlock() is to avoid disabling IRQ.  This routine
> > will be called by IRQ context (for dirty ratio support).  So, IRQ
> > disable will be required if we use spinlock.
> 
> OK, I have missed the comment about disabling IRQs. It's true that we do
> not have to be afraid about deadlocks if the lock is held only for
> reading from the irq context but does the spinlock makes a performance
> bottleneck? We are talking about the slowpath.
> I could see the reason for the read lock when doing hashed locks because
> they are global but if we make the lock per memcg then we shouldn't
> interfere with other updates which are not blocked by the move.
> 

Hm, ok. In the next version, I'll use per-memcg spinlock (with hash if necessary)

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
