Date: Fri, 6 Jun 2008 12:14:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/3 v2] per-task-delay-accounting: add memory reclaim
 delay
Message-Id: <20080606121416.2cb766cf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48489E71.2060708@linux.vnet.ibm.com>
References: <20080605162759.a6adf291.kobayashi.kk@ncos.nec.co.jp>
	<48489E71.2060708@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, nagar@watson.ibm.com, balbir@in.ibm.com, sekharan@us.ibm.com, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 06 Jun 2008 07:48:25 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Keika Kobayashi wrote:
> > Hi.
> > 
> > This is v2 of accounting memory reclaim patch series.
> > Thanks to Kosaki-san, Kamezawa-san, Andrew for comments and advice!
> > These patches were fixed about the following.
> > 
> > Against: next-20080605
> > 
> > 1) Change Log
> > 
> >  o Add accounting memory reclaim delay from memcgroup.
> >    For accounting both global and cgroup memory reclaim,
> >    accounting point was moved from try_to_free_pages() to do_try_to_free_pages.
> > 
> >  o Drop the patch regarding /proc export for memory reclaim delay.
> >    Because it seems that two separate ways to report are not necessary,
> >    this patch series supports only NETLINK and doesn't add a field to /proc/<pid>/stat.
> > 
> > 
> > 2) Confirm the fix regarding memcgroup.
> > 
> >   o Previous patch can't catch memory reclaim delay from memcgroup.
> > 
> >     $ echo 10M > /cgroups/0/memory.limit_in_bytes
> > 
> >     $ ls -s test.dat
> >     500496 test.dat
> > 
> >     $ time tar cvf test.tar test.dat
> >     real    0m21.957s
> >     user    0m0.032s
> >     sys     0m2.348s
> > 
> >     $ ./delayget -d -p <pid>
> >     CPU             count     real total  virtual total    delay total
> >                      2441     2288143000     2438256954       22371958
> >     IO              count    delay total
> >                      2444    18745251314
> >     SWAP            count    delay total
> >                         0              0
> >     RECLAIM         count    delay total
> >                         0              0
> > 
> >   o Current patch can catch memory reclaim delay from memcgroup.
> > 
> >     $ echo 10M > /cgroups/0/memory.limit_in_bytes
> > 
> >     $ ls -s test.dat
> >     500496 test.dat
> > 
> >     $ time tar cvf test.tar test.dat
> >     real    0m22.563s
> >     user    0m0.028s
> >     sys     0m2.440s
> > 
> >     $ ./delayget -d -p <pid>
> >     CPU             count     real total  virtual total    delay total
> >                      2640     2456153500     2478353004       28366219
> >     IO              count    delay total
> >                      2628    19894214188
> >     SWAP            count    delay total
> >                         0              0
> >     RECLAIM         count    delay total
> >                      6600    10682486085
> > 
> 
> Looks interesting, this data is for the whole system or memcgroup? If it is for
> memcgroup, we should be using cgroupstats.
> 
This patch itself is for per-task-stat. And it seems cgroup_stat doesn't handle
delay accounting now. It just counts # of processes in some status.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
