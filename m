Date: Mon, 1 Sep 2008 19:21:30 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 14/14]memcg: mem+swap accounting
Message-Id: <20080901192130.b13e29b9.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080901185347.cfbc1817.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822204455.922f87dc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080901161501.2cba948e.nishimura@mxp.nes.nec.co.jp>
	<20080901165827.e21f9104.kamezawa.hiroyu@jp.fujitsu.com>
	<20080901175302.737bca2e.nishimura@mxp.nes.nec.co.jp>
	<20080901185347.cfbc1817.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Sep 2008 18:53:47 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 1 Sep 2008 17:53:02 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Mon, 1 Sep 2008 16:58:27 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Mon, 1 Sep 2008 16:15:01 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > Hi, Kamezawa-san.
> > > > 
> > > > I'm testing these patches on mmotm-2008-08-29-01-08
> > > > (with some trivial fixes I've reported and some debug codes),
> > This problem happens on the kernel without debug codes I added.
> > 
> > > > but swap_in_bytes sometimes becomes very huge(it seems that
> > > > over uncharge is happening..) and I can see OOM
> > > > if I've set memswap_limit.
> > > > 
> > > > I'm digging this now, but have you also ever seen it?
> > > > 
> > > I didn't see that.
> > I see, thanks.
> > 
> > > But, as you say, maybe over-uncharge. Hmm..
> > > What kind of test ? Just use swap ? and did you use shmem or tmpfs ?
> > > 
> > I don't do anything special, and this can happen without shmem/tmpfs
> > (can happen with shmem/tmpfs, too).
> > 
> > For example:
> > 
> > - make swap out/in activity for a while(I used page01 of ltp).
> > - stop the test.
> > 
> > [root@localhost ~]# cat /cgroup/memory/01/memory.swap_in_bytes
> > 4096
> > 
> > - swapoff
> > 
> > [root@localhost ~]# swapoff -a
> > [root@localhost ~]# cat /cgroup/memory/01/memory.swap_in_bytes
> > 18446744073709395968
> > 
> > 
> Hmm ? can happen without swapoff ?
> It seems "accounted" flag is on by mistake.
> 
Yes.

I used the example above just to show over-uncharging is happening.

Actually, I've not yet seen OOM when running only page01,
but I saw OOM when I run page01 and shmem_test_02 at the same time,

Below is the log showing usage periodically when I got OOM.

----- 2008年 9月 1日 月曜日 17:38:00 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
20480
### /cgroup/memory/01/memory.swap_in_bytes ###
0
----- 2008年 9月 1日 月曜日 17:38:01 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
20480
### /cgroup/memory/01/memory.swap_in_bytes ###
0
----- 2008年 9月 1日 月曜日 17:38:03 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
20480
### /cgroup/memory/01/memory.swap_in_bytes ###
0
----- 2008年 9月 1日 月曜日 17:38:04 JST -----    <- start test
### /cgroup/memory/01/memory.usage_in_bytes ###
9269248
### /cgroup/memory/01/memory.swap_in_bytes ###
0
----- 2008年 9月 1日 月曜日 17:38:06 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
33546240
### /cgroup/memory/01/memory.swap_in_bytes ###
921600
----- 2008年 9月 1日 月曜日 17:38:08 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
33464320
### /cgroup/memory/01/memory.swap_in_bytes ###
11104256
----- 2008年 9月 1日 月曜日 17:38:09 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
33087488
### /cgroup/memory/01/memory.swap_in_bytes ###
9048064
----- 2008年 9月 1日 月曜日 17:38:11 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
33304576
### /cgroup/memory/01/memory.swap_in_bytes ###
5992448
----- 2008年 9月 1日 月曜日 17:38:12 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
33517568
### /cgroup/memory/01/memory.swap_in_bytes ###
3706880
----- 2008年 9月 1日 月曜日 17:38:14 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
33427456
### /cgroup/memory/01/memory.swap_in_bytes ###
1368064
----- 2008年 9月 1日 月曜日 17:38:16 JST -----    <- over-uncharge
### /cgroup/memory/01/memory.usage_in_bytes ###
33312768
### /cgroup/memory/01/memory.swap_in_bytes ###
18446744073696366592
----- 2008年 9月 1日 月曜日 17:38:17 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
33464320
### /cgroup/memory/01/memory.swap_in_bytes ###
18446744073694580736
----- 2008年 9月 1日 月曜日 17:38:19 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
33542144
### /cgroup/memory/01/memory.swap_in_bytes ###
18446744073696337920
----- 2008年 9月 1日 月曜日 17:38:21 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
33480704
### /cgroup/memory/01/memory.swap_in_bytes ###
18446744073696149504
----- 2008年 9月 1日 月曜日 17:38:22 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
30011392
### /cgroup/memory/01/memory.swap_in_bytes ###
18446744073684623360
----- 2008年 9月 1日 月曜日 17:38:26 JST -----    <- got OOM
### /cgroup/memory/01/memory.usage_in_bytes ###
0
### /cgroup/memory/01/memory.swap_in_bytes ###
18446744073675382784
----- 2008年 9月 1日 月曜日 17:38:28 JST -----
### /cgroup/memory/01/memory.usage_in_bytes ###
0
### /cgroup/memory/01/memory.swap_in_bytes ###
18446744073675382784


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
