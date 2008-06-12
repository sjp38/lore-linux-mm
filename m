Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5CDI5LI027015
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 09:18:05 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5CDHrU9085792
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 07:17:53 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5CDHnL8006615
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 07:17:49 -0600
Date: Thu, 12 Jun 2008 08:17:48 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Message-ID: <20080612131748.GB8453@us.ibm.com>
References: <20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830806110017t5ebeda78id1914d179a018422@mail.gmail.com> <20080611164544.94047336.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830806110104n99cdc7h80063e91d16bf0a5@mail.gmail.com> <20080611172714.018aa68c.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830806110148v65df67f8ge0ccdd56c21c89e0@mail.gmail.com> <20080612140806.dc161c77.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080612140806.dc161c77.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

Quoting KAMEZAWA Hiroyuki (kamezawa.hiroyu@jp.fujitsu.com):
> On Wed, 11 Jun 2008 01:48:20 -0700
> "Paul Menage" <menage@google.com> wrote:
> 
> > On Wed, Jun 11, 2008 at 1:27 AM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > Sorry. try another sentense..
> > >
> > > I think cgroup itself is designed to be able to be used without middleware.
> > 
> > True, but it shouldn't be hostile to middleware, since I think that
> > automated use will be much more common. (And certainly if you count
> > the number of servers :-) )
> > 
> > > IOW, whether using middleware or not is the matter of users not of developpers.
> > > There will be a system that system admin controlles all and move tasks by hand.
> > > ex)...personal notebooks etc..
> > >
> > 
> > You think so? I think that at the very least users will be using tools
> > based around config scripts, rule engines and libcgroup, if not a
> > persistent daemon.
> > 
> I believe some users will never use middlewares because of their special
> usage of linux.
> 
> 
> 
> > >> If the common mode for middleware starting a new cgroup is fork() /
> > >> move / exec() then after the fork(), the child will be sharing pages
> > >> with the main daemon process. So the move will pull all the daemon's
> > >> memory into the new cgroup
> > >>
> > > My patch (this patch) just moves Private Anon page to new cgroup. (of mapcount=1)
> > 
> > OK, well that makes it more reasonable regarding the above problem.
> > But I can still see problems if, say, a single thread moves into a new
> > cgroup, you move the entire memory. Perhaps you should only do so if
> > the mm->owner changes task?
> > 
> 
> Thank you for pointing out. I'll add mm->owner check.
> 
> BTW, should we have a cgroup for SYSVIPC resource controller and devide it
> from memory resource controller ?  I think that per-task on-demand usage
> accounting is not suitable for shmem (and hugepage).
> per-creater (caller of shmget()) accounting seems to be better for me.
> 
> Just a question:
> What happens when a thread (not thread-group-leader) changes its ns by
> ns-cgroup ? not-allowed ?

I don't quite understand the question.  I assume you're asking whether
your cgroup, when composed with ns, will refuse a task in cgroup /cg/1/2
from being able to

	mkdir /cg/1/2/3
	echo $$ > /cg/1/2/3/tasks

or

	unshare(CLONE_NEWNS)

which the ns cgroup would allow, and what your cgroup would do in that
case.  If your question ("not-allowed ?") is about ns cgroup behavior
then please rephrase.

thanks,
-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
