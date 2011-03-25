Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 69D778D0041
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 23:01:26 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 007333EE0BD
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 12:01:22 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D61E245DE98
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 12:01:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B183845DE76
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 12:01:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A0D56E08009
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 12:01:21 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 57C02E08002
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 12:01:21 +0900 (JST)
Date: Fri, 25 Mar 2011 11:54:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] forkbomb killer
Message-Id: <20110325115453.82a9736d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=f3gu7-8uNiT4qz6s=BOhto5s=7g@mail.gmail.com>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110324105222.GA2625@barrios-desktop>
	<20110325090411.56c5e5b2.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=f3gu7-8uNiT4qz6s=BOhto5s=7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Fri, 25 Mar 2011 11:38:19 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Mar 25, 2011 at 9:04 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 24 Mar 2011 19:52:22 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> > To me, the fact "the system _can_ be broken by a normal user program" is the most
> > terrible thing. With Andrey's case or make -j, a user doesn't need to be an admin.
> > I believe it's worth to pay costs.
> > (and I made this function configurable and can be turned off by sysfs.)
> >
> > And while testing Andrey's case, I used KVM finaly becasue cost of rebooting was small.
> > My development server is on other building and I need to push server's button
> > to reboot it when forkbomb happens ;)
> > In some environement, cost of rebooting is not small even if it's a development system.
> >
> 
> Forkbomb is very rare case in normal situation but if it happens, the
> cost like reboot would be big. So we need the such facility. I agree.
> (But I don't know why others don't have a interest if it is important
> task. Maybe they are so busy due to rc1)
> Just a concern is cost.

me, too.

> The approach is we can enhance your approach to minimize the cost but
> apparently it would have a limitation.
> 
agreed. "tracking" always costs.

> Other approach is we can provide new rescue facility.
> What I have thought is new sysrq about killing fork-bomb.
> 
Mine works fine with Sysrq+f. But, I need to go to other building
for pushing Sysrq.....

> If we execute the new sysrq, the kernel freezes all tasks so forkbomb
> can't execute any more and kernel ready to receive the command to show
> the system state. Admin can investigate which is fork-bomb and then he
> kill the tasks. At last, admin restarts all processes with new sysrq
> and processes which received SIGKILL start to die.
> 
> This approach offloads kernel's heuristic forkbomb detection to admin
> and avoid runtime cost in normal situation.
> I don't have any code to implement above the concept so it might be ridiculous.
> 
> What do you think about it?
> 
For usual user, forkbmob killer works better, rather than special console for
fatal system.

I can think of 2 similar works. One is Windows's TaskManager. You can kill tasks
with it (and I guess TaskManager is always on memory...) Another one is
"guarantee" or "preserve XXXX for special apps." which clustering guys wants for
quick server failover. 

If trouble happens,
 - freeze all apps other than HA apps.
 - open the gate for hidden preserved resources (of memory / disks)
 - do safe failover to other server.
 - do necessary jobs and reboot.

So, you need to preserve some resources for recover...IOW, have to pay costs.

BTW, Sysrq/TaskManager/Failover doesn't help me, using development system via network.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
