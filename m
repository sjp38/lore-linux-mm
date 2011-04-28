Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 29C186B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 09:30:12 -0400 (EDT)
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
From: Mike Galbraith <efault@gmx.de>
In-Reply-To: <20110428102609.GJ2135@linux.vnet.ibm.com>
References: <20110426112756.GF4308@linux.vnet.ibm.com>
	 <20110426183859.6ff6279b@neptune.home>
	 <20110426190918.01660ccf@neptune.home>
	 <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
	 <alpine.LFD.2.02.1104262314110.3323@ionos>
	 <20110427081501.5ba28155@pluto.restena.lu>
	 <20110427204139.1b0ea23b@neptune.home>
	 <alpine.LFD.2.02.1104272351290.3323@ionos>
	 <alpine.LFD.2.02.1104281051090.19095@ionos>
	 <BANLkTinB5S7q88dch78i-h28jDHx5dvfQw@mail.gmail.com>
	 <20110428102609.GJ2135@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 15:30:01 +0200
Message-ID: <1303997401.7819.5.camel@marge.simson.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: sedat.dilek@gmail.com, Bruno =?ISO-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Thu, 2011-04-28 at 03:26 -0700, Paul E. McKenney wrote:
> On Thu, Apr 28, 2011 at 11:45:03AM +0200, Sedat Dilek wrote:
> > Hi,
> > 
> > not sure if my problem from linux-2.6-rcu.git#sedat.2011.04.23a is
> > related to the issue here.
> > 
> > Just FYI:
> > I am here on a Pentium-M (uniprocessor aka UP) and still unsure if I
> > have the correct (optimal?) kernel-configs set.
> > 
> > Paul gave me a script to collect RCU data and I enhanced it with
> > collecting SCHED data.
> > 
> > In the above mentionned GIT branch I applied these two extra commits
> > (0001 requested by Paul and 0002 proposed by Thomas):
> > 
> > patches/0001-Revert-rcu-restrict-TREE_RCU-to-SMP-builds-with-PREE.patch
> > patches/0002-sched-Add-warning-when-RT-throttling-is-activated.patch
> > 
> > Furthermore, I have added my kernel-config file, scripts, patches and
> > logs (also output of 'cat /proc/cpuinfo').
> > 
> > Hope this helps the experts to narrow down the problem.
> 
> Yow!!!
> 
> Now this one might well be able to hit the 950 millisecond limit.
> There are no fewer than 1,314,958 RCU callbacks queued up at the end of
> the test.  And RCU has indeed noticed this and cranked up the number
> of callbacks to be handled by each invocation of rcu_do_batch() to
> 2,147,483,647.  And only 15 seconds earlier, there were zero callbacks
> queued and the rcu_do_batch() limit was at the default of 10 callbacks
> per invocation.

Yeah, yow.  Once the RT throttle hit, it stuck.

  .clock                         : 1386824.201768
  .rt_nr_running                 : 2
  .rt_throttled                  : 1
  .rt_time                       : 950.132427
  .rt_runtime                    : 950.000000
           rcuc0     7         0.034118     10857    98         0.034118      1472.309646         0.000000 /
FF    1      1 R    R 0 [rcuc0]
  .clock                         : 1402450.997994
  .rt_nr_running                 : 2
  .rt_throttled                  : 1
  .rt_time                       : 950.132427
  .rt_runtime                    : 950.000000
           rcuc0     7         0.034118     10857    98         0.034118      1472.309646         0.000000 /
FF    1      1 R    R 0 [rcuc0]

...

  .clock                         : 2707432.862374
  .rt_nr_running                 : 2
  .rt_throttled                  : 1
  .rt_time                       : 950.132427
  .rt_runtime                    : 950.000000                                                                                              
           rcuc0     7         0.034118     10857    98         0.034118      1472.309646         0.000000 /                               
FF    1      1 R    R 0 [rcuc0]
  .clock                         : 2722572.958381                                                                                          
  .rt_nr_running                 : 2
  .rt_throttled                  : 1
  .rt_time                       : 950.132427
  .rt_runtime                    : 950.000000                                                                                              
           rcuc0     7         0.034118     10857    98         0.034118      1472.309646         0.000000 /
FF    1      1 R    R 0 [rcuc0]                                                                                                            


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
