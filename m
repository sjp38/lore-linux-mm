Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 86D156B0024
	for <linux-mm@kvack.org>; Wed, 11 May 2011 23:46:40 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1C39B3EE0C0
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:46:37 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ED4DB45DE96
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:46:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C4FC245DE93
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:46:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B5605E18004
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:46:36 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 805611DB803C
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:46:36 +0900 (JST)
Date: Thu, 12 May 2011 12:39:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] oom: kill younger process first
Message-Id: <20110512123942.4b641e2d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTimWOtKKj+Jq1vqHfOfQ2UvP7Xxa3g@mail.gmail.com>
References: <20110509182110.167F.A69D9226@jp.fujitsu.com>
	<20110510171335.16A7.A69D9226@jp.fujitsu.com>
	<20110510171641.16AF.A69D9226@jp.fujitsu.com>
	<20110512095243.c57e3e83.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=ya1rAqC+nMPHkBaMsoXpsCeHH=w@mail.gmail.com>
	<20110512105351.a57970d7.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimWOtKKj+Jq1vqHfOfQ2UvP7Xxa3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Thu, 12 May 2011 11:23:38 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Thu, May 12, 2011 at 10:53 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 12 May 2011 10:30:45 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:

> > As above implies, (B)->prev pointer is invalid pointer after list_del().
> > So, there will be race with list modification and for_each_list_reverse under
> > rcu_read__lock()
> >
> > So, when you need to take atomic lock (as tasklist lock is) is...
> >
> > A 1) You can't check 'entry' is valid or not...
> > A  A In above for_each_list_rcu(), you may visit an object which is under removing.
> > A  A You need some flag or check to see the object is valid or not.
> >
> > A 2) you want to use list_for_each_safe().
> > A  A You can't do list_del() an object which is under removing...
> >
> > A 3) You want to walk the list in reverse.
> >
> > A 3) Some other reasons. For example, you'll access an object pointed by the
> > A  A 'entry' and the object is not rcu safe.
> >
> > make sense ?
> 
> Yes. Thanks, Kame.
> It seems It is caused by prev poisoning of list_del_rcu.
> If we remove it, isn't it possible to traverse reverse without atomic lock?
> 

IIUC, it's possible (Fix me if I'm wrong) but I don't like that because of 2 reasons.

1. LIST_POISON is very important information at debug.

2. If we don't clear prev pointer, ok, we'll allow 2 directional walk of list
   under RCU.
   But, in following case
   1. you are now at (C). you'll visit (C)->next...(D)
   2. you are now at (D). you want to go back to (C) via (D)->prev.
   3. But (D)->prev points to (B)

  It's not a 2 directional list, something other or broken one.
  Then, the rculist is 1 directional list in nature, I think. 

So, without very very big reason, we should keep POISON.

Thanks,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
