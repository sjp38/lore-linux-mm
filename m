Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EFAA76B004D
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 07:38:36 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id n9CBQtXK029598
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 22:26:55 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9CBcWnn446526
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 22:38:32 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n9CBcVbj008578
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 22:38:32 +1100
Date: Mon, 12 Oct 2009 17:08:29 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/2] memcg: improving scalability by reducing lock
 contention at charge/uncharge
Message-ID: <20091012113829.GD3007@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091002135531.3b5abf5c.kamezawa.hiroyu@jp.fujitsu.com>
 <604427e00910091737s52e11ce9p256c95d533dc2837@mail.gmail.com>
 <f82dee90d0ab51d5bd33a6c01a9feb17.squirrel@webmail-b.css.fujitsu.com>
 <604427e00910111134o6f22f0ddg2b87124dd334ec02@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <604427e00910111134o6f22f0ddg2b87124dd334ec02@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* Ying Han <yinghan@google.com> [2009-10-11 11:34:39]:

> 2009/10/10 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> > Ying Han wrote:
> > > Hi KAMEZAWA-san: I tested your patch set based on 2.6.32-rc3 but I don't
> > > see
> > > much improvement on the page-faults rate.
> > > Here is the number I got:
> > >
> > > [Before]
> > >  Performance counter stats for './runpause.sh 10' (5 runs):
> > >
> > >   226272.271246  task-clock-msecs         #      3.768 CPUs    ( +-
> > > 0.193%
> > > )
> > >            4424  context-switches         #      0.000 M/sec   ( +-
> > > 14.418%
> > > )
> > >              25  CPU-migrations           #      0.000 M/sec   ( +-
> > > 23.077%
> > > )
> > >        80499059  page-faults              #      0.356 M/sec   ( +-
> > > 2.586%
> > > )
> > >    499246232482  cycles                   #   2206.396 M/sec   ( +-
> > > 0.055%
> > > )
> > >    193036122022  instructions             #      0.387 IPC     ( +-
> > > 0.281%
> > > )
> > >     76548856038  cache-references         #    338.304 M/sec   ( +-
> > > 0.832%
> > > )
> > >       480196860  cache-misses             #      2.122 M/sec   ( +-
> > > 2.741%
> > > )
> > >
> > >    60.051646892  seconds time elapsed   ( +-   0.010% )
> > >
> > > [After]
> > >  Performance counter stats for './runpause.sh 10' (5 runs):
> > >
> > >   226491.338475  task-clock-msecs         #      3.772 CPUs    ( +-
> > > 0.176%
> > > )
> > >            3377  context-switches         #      0.000 M/sec   ( +-
> > > 14.713%
> > > )
> > >              12  CPU-migrations           #      0.000 M/sec   ( +-
> > > 23.077%
> > > )
> > >        81867014  page-faults              #      0.361 M/sec   ( +-
> > > 3.201%
> > > )
> > >    499835798750  cycles                   #   2206.865 M/sec   ( +-
> > > 0.036%
> > > )
> > >    196685031865  instructions             #      0.393 IPC     ( +-
> > > 0.286%
> > > )
> > >     81143829910  cache-references         #    358.265 M/sec   ( +-
> > > 0.428%
> > > )
> > >       119362559  cache-misses             #      0.527 M/sec   ( +-
> > > 5.291%
> > > )
> > >
> > >    60.048917062  seconds time elapsed   ( +-   0.010% )
> > >
> > > I ran it on an 4 core machine with 16G of RAM. And I modified
> > > the runpause.sh to fork 4 pagefault process instead of 8. I mounted
> > cgroup
> > > with only memory subsystem and start running the test on the root cgroup.
> > >
> > > I believe that we might have different running environment including the
> > > cgroup configuration.  Any suggestions?
> > >
> >
> > This patch series is only for "child" cgroup. Sorry, I had to write it
> > clearer. No effects to root.
> >
> 
> Ok, Thanks for making it clearer. :) So Do you mind post the cgroup+memcg
> configuration
> while you are running on your host?
> 
> Thanks
>

Yes, root was fixed by another patchset now in mainline. Another check
is to see if resource_counter lock shows up in /proc/lock_stats.
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
