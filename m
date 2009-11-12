Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0D81A6B004D
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 03:22:21 -0500 (EST)
Date: Thu, 12 Nov 2009 17:05:10 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 3/3] memcg: remove memcg_tasklist
Message-Id: <20091112170510.e635df1f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091111160134.GM3314@balbir.in.ibm.com>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091111103533.c634ff8d.nishimura@mxp.nes.nec.co.jp>
	<20091111103906.5c3563bb.nishimura@mxp.nes.nec.co.jp>
	<20091111160134.GM3314@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009 21:31:34 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-11-11 10:39:06]:
> 
> > memcg_tasklist was introduced at commit 7f4d454d(memcg: avoid deadlock caused
> > by race between oom and cpuset_attach) instead of cgroup_mutex to fix a deadlock
> > problem.  The cgroup_mutex, which was removed by the commit, in
> > mem_cgroup_out_of_memory() was originally introduced at commit c7ba5c9e
> > (Memory controller: OOM handling).
> > 
> > IIUC, the intention of this cgroup_mutex was to prevent task move during
> > select_bad_process() so that situations like below can be avoided.
> > 
> >   Assume cgroup "foo" has exceeded its limit and is about to trigger oom.
> >   1. Process A, which has been in cgroup "baa" and uses large memory, is just
> >      moved to cgroup "foo". Process A can be the candidates for being killed.
> >   2. Process B, which has been in cgroup "foo" and uses large memory, is just
> >      moved from cgroup "foo". Process B can be excluded from the candidates for
> >      being killed.
> > 
> > But these race window exists anyway even if we hold a lock, because
> > __mem_cgroup_try_charge() decides wether it should trigger oom or not outside
> > of the lock. So the original cgroup_mutex in mem_cgroup_out_of_memory and thus
> > current memcg_tasklist has no use. And IMHO, those races are not so critical
> > for users.
> > 
> > This patch removes it and make codes simpler.
> >
> 
> Could you please test for side-effects like concurrent OOM. An idea of
> how the patchset was tested would be good to have, given the
> implications of these changes.
> 
hmm, I'm not sure what is your concern.

My point is, __mem_cgroup_try_charge() decides wether it should trigger oom or not
outside of this mutex. mem_cgroup_out_of_memory(selecting a target task and killing it)
itself would be serialized by this mutex, but the decision wether we should trigger
oom or not is made outside of this mutex, so this mutex has no meaning(oom will happen anyway).

Actually, I tested following scenario.

- make a cgroup with mem.limit == memsw.limit == 128M.
- under the cgroup, run a test program which consumes about 8MB as anonymous for each.
- I can run up to 15 instances of this test program, but when I started 16th one,
  oom is triggered. The number of processes being kill is random(not necessarily one process).

This behavior doesn't change before and after this patch.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
