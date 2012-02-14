Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 16C246B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 03:46:11 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A26703EE0BD
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 17:46:09 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B81E45DE59
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 17:46:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 729D545DE56
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 17:46:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 53D291DB804E
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 17:46:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F2E801DB8055
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 17:46:08 +0900 (JST)
Date: Tue, 14 Feb 2012 17:44:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/6 v4] memcg: simplify move_account() check
Message-Id: <20120214174442.3efcb22c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAHH2K0Ynh6o5fMXnkbaYOSwYYvJhc7F3f48TsJ34hki6WDJF6Q@mail.gmail.com>
References: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com>
	<20120214120756.0a42f065.kamezawa.hiroyu@jp.fujitsu.com>
	<CAHH2K0Ynh6o5fMXnkbaYOSwYYvJhc7F3f48TsJ34hki6WDJF6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>

On Mon, 13 Feb 2012 23:21:34 -0800
Greg Thelen <gthelen@google.com> wrote:

> On Mon, Feb 13, 2012 at 7:07 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From 9cdb3b63dc8d08cc2220c54c80438c13433a0d12 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Thu, 2 Feb 2012 10:02:39 +0900
> > Subject: [PATCH 2/6] memcg: simplify move_account() check.
> >
> > In memcg, for avoiding take-lock-irq-off at accessing page_cgroup,
> > a logic, flag + rcu_read_lock(), is used. This works as following
> >
> > A  A  CPU-A A  A  A  A  A  A  A  A  A  A  CPU-B
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  rcu_read_lock()
> > A  A set flag
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  if(flag is set)
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  take heavy lock
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  do job.
> > A  A synchronize_rcu() A  A  A  A rcu_read_unlock()
> 
> I assume that CPU-A will take heavy lock after synchronize_rcu() when
> updating variables read by CPU-B.
> 
Ah, yes. I should wrote that.

> > A memcontrol.c | A  65 ++++++++++++++++++++++-------------------------------------
> > A 1 file changed, 25 insertions(+), 40 deletions(-)
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Acked-by: Greg Thelen <gthelen@google.com>
> 

Thank you!.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
