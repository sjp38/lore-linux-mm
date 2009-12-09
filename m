Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A3DAE60021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 19:25:54 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB90PplD005660
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 9 Dec 2009 09:25:51 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E98945DE4E
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:25:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A80445DE4D
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:25:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E5E751DB8038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:25:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FA6B1DB8037
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:25:50 +0900 (JST)
Date: Wed, 9 Dec 2009 09:21:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 0/7] memcg: move charge at task migration
 (04/Dec)
Message-Id: <20091209092157.473f688b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091207153448.55e11607.nishimura@mxp.nes.nec.co.jp>
References: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
	<20091204155317.2d570a55.kamezawa.hiroyu@jp.fujitsu.com>
	<20091204160042.3e5fd83d.kamezawa.hiroyu@jp.fujitsu.com>
	<20091207153448.55e11607.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Dec 2009 15:34:48 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 4 Dec 2009 16:00:42 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 4 Dec 2009 15:53:17 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Fri, 4 Dec 2009 14:46:09 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > > In this version:
> > > >        |  252M  |  512M  |   1G
> > > >   -----+--------+--------+--------
> > > >    (1) |  0.15  |  0.30  |  0.60
> > > >   -----+--------+--------+--------
> > > >    (2) |  0.15  |  0.30  |  0.60
> > > >   -----+--------+--------+--------
> > > >    (3) |  0.22  |  0.44  |  0.89
> > > > 
> > > Nice !
> > > 
> > 
> > Ah. could you clarify...
> > 
> >  1. How is fork()/exit() affected by this move ?
> I measured using unixbench(./Run -c 1 spawn execl). I used the attached script to do
> task migration infinitly(./switch3.sh /cgroup/memory/01 /cgroup/memory/02 [pid of bash]).
> The script is executed on a different cpu from the unixbench's by taskset.
> 
> (1) no task migration(run on /01)
> 
> Execl Throughput                                192.7 lps   (29.9 s, 2 samples)
> Process Creation                                475.5 lps   (30.0 s, 2 samples)
> 
> Execl Throughput                                191.2 lps   (29.9 s, 2 samples)
> Process Creation                                463.4 lps   (30.0 s, 2 samples)
> 
> Execl Throughput                                191.0 lps   (29.9 s, 2 samples)
> Process Creation                                474.9 lps   (30.0 s, 2 samples)
> 
> 
> (2) under task migration between /01 and /02 w/o setting move_charge_at_immigrate
> 
> Execl Throughput                                150.2 lps   (29.8 s, 2 samples)
> Process Creation                                344.1 lps   (30.0 s, 2 samples)
> 
> Execl Throughput                                146.9 lps   (29.8 s, 2 samples)
> Process Creation                                337.7 lps   (30.0 s, 2 samples)
> 
> Execl Throughput                                150.5 lps   (29.8 s, 2 samples)
> Process Creation                                345.3 lps   (30.0 s, 2 samples)
> 
> 
> (3) under task migration between /01 and /02 w/ setting move_charge_at_immigrate
> 
> Execl Throughput                                142.9 lps   (29.9 s, 2 samples)
> Process Creation                                323.1 lps   (30.0 s, 2 samples)
> 
> Execl Throughput                                146.6 lps   (29.8 s, 2 samples)
> Process Creation                                332.0 lps   (30.0 s, 2 samples)
> 
> Execl Throughput                                150.9 lps   (29.8 s, 2 samples)
> Process Creation                                344.2 lps   (30.0 s, 2 samples)
> 
> 
> (those values seem terrible :(  I run them on KVM guest...)
> (2) seems a bit better than (3), but the impact of task migration itself is
> far bigger.
> 

Thank you for interesting tests. (3) seems faster than I expected.


> 
> >  2. How long cpuset's migration-at-task-move requires ?
> >     I guess much longer than this.
> I measured in the same environment using fakenuma. It took 1.17sec for 256M,
> 2.33sec for 512M, and 4.69sec for 1G.
> 
Wow..

> 
> >  3. If need to reclaim memory for moving tasks, can this be longer ?
> I think so.
> 
> >     If so, we may need some trick to release cgroup_mutex in task moving.
> > 
> hmm, I see your concern but I think it isn't so easy.. IMHO, we need changes
> in cgroup layer and should take care not to cause dead lock.
> 

I agree here. If you can find somewhere good to write this on TO-DO-LIST, please.
No other requests from me, now.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
