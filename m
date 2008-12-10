Date: Wed, 10 Dec 2008 23:08:24 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][RFT] memcg fix cgroup_mutex deadlock when cpuset reclaims
 memory
Message-Id: <20081210230824.726ec508.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20081210130607.GD25467@balbir.in.ibm.com>
References: <20081210051947.GH7593@balbir.in.ibm.com>
	<20081210151948.9a83f70a.nishimura@mxp.nes.nec.co.jp>
	<20081210164126.8b3be761.nishimura@mxp.nes.nec.co.jp>
	<20081210171836.b959d19b.kamezawa.hiroyu@jp.fujitsu.com>
	<20081210205337.3ed3db2c.d-nishimura@mtf.biglobe.ne.jp>
	<20081210130607.GD25467@balbir.in.ibm.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: d-nishimura@mtf.biglobe.ne.jp, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, menage@google.com, Daisuke Miyakawa <dmiyakawa@google.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 2008 18:36:07 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> [2008-12-10 20:53:37]:
> 
> > On Wed, 10 Dec 2008 17:18:36 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Wed, 10 Dec 2008 16:41:26 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > On Wed, 10 Dec 2008 15:19:48 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > On Wed, 10 Dec 2008 10:49:47 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > > > Hi,
> > > > > > 
> > > > > > Here is a proposed fix for the memory controller cgroup_mutex deadlock
> > > > > > reported. It is lightly tested and reviewed. I need help with review
> > > > > > and test. Is the reported deadlock reproducible after this patch? A
> > > > > > careful review of the cpuset impact will also be highly appreciated.
> > > > > > 
> > > > > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > > > > 
> > > > > > cpuset_migrate_mm() holds cgroup_mutex throughout the duration of
> > > > > > do_migrate_pages(). The issue with that is that
> > > > > > 
> > > > > > 1. It can lead to deadlock with memcg, as do_migrate_pages()
> > > > > >    enters reclaim
> > > > > > 2. It can lead to long latencies, preventing users from creating/
> > > > > >    destroying other cgroups anywhere else
> > > > > > 
> > > > > > The patch holds callback_mutex through the duration of cpuset_migrate_mm() and
> > > > > > gives up cgroup_mutex while doing so.
> > > > > > 
> > > > > I agree changing cpuset_migrate_mm not to hold cgroup_mutex to fix the dead lock
> > > > > is one choice, and it looks good to me at the first impression.
> > > > > 
> > > > > But I'm not sure it's good to change cpuset(other subsystem) code because of memcg.
> > > > > 
> > > > > Anyway, I'll test this patch and report the result tomorrow.
> > > > > (Sorry, I don't have enough time today.)
> > > > > 
> > > > Unfortunately, this patch doesn't seem enough.
> > > > 
> > > > This patch can fix dead lock caused by "circular lock of cgroup_mutex",
> > > > but cannot that of caused by "race between page reclaim and cpuset_attach(mpol_rebind_mm)".
> > > > 
> > > > (The dead lock I fixed in memcg-avoid-dead-lock-caused-by-race-between-oom-and-cpuset_attach.patch
> > > > was caused by "race between memcg's oom and mpol_rebind_mm, and was independent of hierarchy.)
> > > > 
> > > > I attach logs I got in testing this patch.
> > > > 
> > > Hmm, ok then, what you  mention to is this race.
> > > --
> > > 	cgroup_lock()
> > > 		-> cpuset_attach()
> > > 			-> down_write(&mm->mmap_sem);
> > > 
> > > 	down_read()
> > > 		-> page fault
> > > 			-> reclaim in memcg
> > > 				-> cgroup_lock().
> > > --
> > > What this patch tries to fix is this recursive locks
> > > --
> > > 	cgroup_lock()
> > > 		-> cpuset_attach()
> > > 			-> cpuset_migrate_mm()
> > > 				-> charge to migration
> > > 					-> go to reclaim and meet cgroup_lock.
> > > --
> > > 
> > > 
> > > Right ?
> > > 
> > Yes.
> > Thank you for explaining in detail.
> > 
> 
> Sorry, I don't understand the context, I am unable to figure out
> 
> 1. How to reproduce the problem that Daisuke-San reported
Ah.. sorry.

1) mount memory cgroup and cpuset.
   (I mount them on different mount points, but I think this can also happen
   even when mounting on the same hierarchy.)
2) make directories
2-1) memory
  - make a directory(/cgroup/memory/01)
    - set memory.limit_in_bytes(no need to set memsw.limit_in_bytes).
    - enable hierarchy(no need to make a child).
2-2) cpuset
  - make 2(at least) directories(/cgroup/cpuset/01,02)
    - set different "mems".
    - set memory_migrate on.
3) attach shell to /cgroup/*/01
4) run some programs enough to cause swap out/in
5) trigger page migration by cpuset between 01 and 02 repeatedly.
   I think Documentation/controllers/memcg_test.txt would help.

feel free to ask me if you need additional information.

> 2. Whether the patch is correct or causing more problems or needs more
>    stuff to completely fix the race.
> 
I should consider more to tell whether it's all right to release cgroup_mutex
under attach_task, but some more stuff is needed at least.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
