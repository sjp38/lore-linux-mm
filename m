Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6477F6B002F
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 04:55:59 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BA2FD3EE0B5
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 17:55:55 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A130A45DEB7
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 17:55:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EBE945DE9E
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 17:55:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 70A8E1DB8037
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 17:55:55 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DD231DB803C
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 17:55:55 +0900 (JST)
Date: Fri, 7 Oct 2011 17:55:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 0/8] per-cgroup tcp buffer pressure settings
Message-Id: <20111007175500.ca280fc6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4E8EB634.9090208@parallels.com>
References: <1317730680-24352-1-git-send-email-glommer@parallels.com>
	<20111005092954.718a0c29.kamezawa.hiroyu@jp.fujitsu.com>
	<4E8C067E.6040203@parallels.com>
	<20111007170522.624fab3d.kamezawa.hiroyu@jp.fujitsu.com>
	<4E8EB634.9090208@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

On Fri, 7 Oct 2011 12:20:04 +0400
Glauber Costa <glommer@parallels.com> wrote:

> >
> >> So what I really mean here with "will integrate later", is that I think
> >> that we'd be better off tracking the allocations themselves at the slab
> >> level.
> >>
> >>>      Can't tcp-limit-code borrows some amount of charges in batch from kmem_limit
> >>>      and use it ?
> >> Sorry, I don't know what exactly do you mean. Can you clarify?
> >>
> > Now, tcp-usage is independent from kmem-usage.
> >
> > My idea is
> >
> >    1. when you account tcp usage, charge kmem, too.
> 
> Absolutely.
> >    Now, your work is
> >       a) tcp use new xxxx bytes.
> >       b) account it to tcp.uage and check tcp limit
> >
> >    To ingegrate kmem,
> >       a) tcp use new xxxx bytes.
> >       b) account it to tcp.usage and check tcp limit
> >       c) account it to kmem.usage
> >
> > ? 2 counters may be slow ?
> 
> Well, the way I see it, 1 counter is slow already =)
> I honestly think we need some optimizations here. But
> that is a side issue.
> 
> To begin with: The new patchset that I intend to spin
> today or Monday, depending on my progress, uses res_counters,
> as you and Kirill requested.
> 
> So what makes res_counters slow IMHO, is two things:
> 
> 1) interrupts are always disabled.
> 2) All is done under a lock.
> 
> Now, we are starting to have resources that are billed to multiple
> counters. One simple way to work around it, is to have child counters
> that has to be accounted for as well everytime a resource is counted.
> 
> Like this:
> 
> 1) tcp has kmem as child. When we bill to tcp, we bill to kmem as well.
>     For protocols that do memory pressure, we then don't bill kmem from
>     the slab.
> 2) When kmem_independent_account is set to 0, kmem has mem as child.
> 

Seems reasonable.


> >
> >
> >>>    - Don't you need a stat file to indicate "tcp memory pressure works!" ?
> >>>      It can be obtained already ?
> >>
> >> Not 100 % clear as well. We can query the amount of buffer used, and the
> >> amount of buffer allowed. What else do we need?
> >>
> >
> > IIUC, we can see the fact tcp.usage is near to tcp.limit but never can see it
> > got memory pressure and how many numbers of failure happens.
> > I'm sorry if I don't read codes correctly.
> 
> IIUC, With res_counters being used, we get at least failcnt for free, right?
> 

Right. you can get failcnt and max_usage and can have soft_limit base
implemenation at the same time.

Thank you.
-Kame



 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
