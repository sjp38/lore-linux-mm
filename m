Date: Wed, 10 Dec 2008 20:53:37 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][RFT] memcg fix cgroup_mutex deadlock when cpuset reclaims
 memory
Message-Id: <20081210205337.3ed3db2c.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20081210171836.b959d19b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081210051947.GH7593@balbir.in.ibm.com>
	<20081210151948.9a83f70a.nishimura@mxp.nes.nec.co.jp>
	<20081210164126.8b3be761.nishimura@mxp.nes.nec.co.jp>
	<20081210171836.b959d19b.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, menage@google.com, Daisuke Miyakawa <dmiyakawa@google.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, d-nishimura@mtf.biglobe.ne.jp, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 2008 17:18:36 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 10 Dec 2008 16:41:26 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Wed, 10 Dec 2008 15:19:48 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > On Wed, 10 Dec 2008 10:49:47 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > Hi,
> > > > 
> > > > Here is a proposed fix for the memory controller cgroup_mutex deadlock
> > > > reported. It is lightly tested and reviewed. I need help with review
> > > > and test. Is the reported deadlock reproducible after this patch? A
> > > > careful review of the cpuset impact will also be highly appreciated.
> > > > 
> > > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > > 
> > > > cpuset_migrate_mm() holds cgroup_mutex throughout the duration of
> > > > do_migrate_pages(). The issue with that is that
> > > > 
> > > > 1. It can lead to deadlock with memcg, as do_migrate_pages()
> > > >    enters reclaim
> > > > 2. It can lead to long latencies, preventing users from creating/
> > > >    destroying other cgroups anywhere else
> > > > 
> > > > The patch holds callback_mutex through the duration of cpuset_migrate_mm() and
> > > > gives up cgroup_mutex while doing so.
> > > > 
> > > I agree changing cpuset_migrate_mm not to hold cgroup_mutex to fix the dead lock
> > > is one choice, and it looks good to me at the first impression.
> > > 
> > > But I'm not sure it's good to change cpuset(other subsystem) code because of memcg.
> > > 
> > > Anyway, I'll test this patch and report the result tomorrow.
> > > (Sorry, I don't have enough time today.)
> > > 
> > Unfortunately, this patch doesn't seem enough.
> > 
> > This patch can fix dead lock caused by "circular lock of cgroup_mutex",
> > but cannot that of caused by "race between page reclaim and cpuset_attach(mpol_rebind_mm)".
> > 
> > (The dead lock I fixed in memcg-avoid-dead-lock-caused-by-race-between-oom-and-cpuset_attach.patch
> > was caused by "race between memcg's oom and mpol_rebind_mm, and was independent of hierarchy.)
> > 
> > I attach logs I got in testing this patch.
> > 
> Hmm, ok then, what you  mention to is this race.
> --
> 	cgroup_lock()
> 		-> cpuset_attach()
> 			-> down_write(&mm->mmap_sem);
> 
> 	down_read()
> 		-> page fault
> 			-> reclaim in memcg
> 				-> cgroup_lock().
> --
> What this patch tries to fix is this recursive locks
> --
> 	cgroup_lock()
> 		-> cpuset_attach()
> 			-> cpuset_migrate_mm()
> 				-> charge to migration
> 					-> go to reclaim and meet cgroup_lock.
> --
> 
> 
> Right ?
> 
Yes.
Thank you for explaining in detail.


Daisuke Nishimura.

> BTW, releasing cgroup_lock() while attach() is going on is finally safe ?
> If not, can this lock for attach be replaced with (new) cgroup private mutex ?
> 
> a new mutex like this ?
> --
> struct cgroup {
> 	.....
> 	mutex_t		attach_mutex; /* for serializing attach() ops. 
> 					 while attach() is going on, rmdir() will fail */
> }
> --
> Do we need the big lock of cgroup_lock for attach(), at last ?
> 
> -Kame
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
