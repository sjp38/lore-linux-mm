Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4C7E1600368
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 18:43:19 -0400 (EDT)
Date: Wed, 17 Mar 2010 23:43:15 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 2/5] memcg: dirty memory documentation
Message-ID: <20100317224314.GC8467@linux.develer.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
 <1268609202-15581-3-git-send-email-arighi@develer.com>
 <20100316164121.024e35d8.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100316164121.024e35d8.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 16, 2010 at 04:41:21PM +0900, Daisuke Nishimura wrote:
> On Mon, 15 Mar 2010 00:26:39 +0100, Andrea Righi <arighi@develer.com> wrote:
> > Document cgroup dirty memory interfaces and statistics.
> > 
> > Signed-off-by: Andrea Righi <arighi@develer.com>
> > ---
> >  Documentation/cgroups/memory.txt |   36 ++++++++++++++++++++++++++++++++++++
> >  1 files changed, 36 insertions(+), 0 deletions(-)
> > 
> > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > index 49f86f3..38ca499 100644
> > --- a/Documentation/cgroups/memory.txt
> > +++ b/Documentation/cgroups/memory.txt
> > @@ -310,6 +310,11 @@ cache		- # of bytes of page cache memory.
> >  rss		- # of bytes of anonymous and swap cache memory.
> >  pgpgin		- # of pages paged in (equivalent to # of charging events).
> >  pgpgout		- # of pages paged out (equivalent to # of uncharging events).
> > +filedirty	- # of pages that are waiting to get written back to the disk.
> > +writeback	- # of pages that are actively being written back to the disk.
> > +writeback_tmp	- # of pages used by FUSE for temporary writeback buffers.
> > +nfs		- # of NFS pages sent to the server, but not yet committed to
> > +		  the actual storage.
> >  active_anon	- # of bytes of anonymous and  swap cache memory on active
> >  		  lru list.
> >  inactive_anon	- # of bytes of anonymous memory and swap cache memory on
> > @@ -345,6 +350,37 @@ Note:
> >    - a cgroup which uses hierarchy and it has child cgroup.
> >    - a cgroup which uses hierarchy and not the root of hierarchy.
> >  
> > +5.4 dirty memory
> > +
> > +  Control the maximum amount of dirty pages a cgroup can have at any given time.
> > +
> > +  Limiting dirty memory is like fixing the max amount of dirty (hard to
> > +  reclaim) page cache used by any cgroup. So, in case of multiple cgroup writers,
> > +  they will not be able to consume more than their designated share of dirty
> > +  pages and will be forced to perform write-out if they cross that limit.
> > +
> > +  The interface is equivalent to the procfs interface: /proc/sys/vm/dirty_*.
> > +  It is possible to configure a limit to trigger both a direct writeback or a
> > +  background writeback performed by per-bdi flusher threads.
> > +
> > +  Per-cgroup dirty limits can be set using the following files in the cgroupfs:
> > +
> > +  - memory.dirty_ratio: contains, as a percentage of cgroup memory, the
> > +    amount of dirty memory at which a process which is generating disk writes
> > +    inside the cgroup will start itself writing out dirty data.
> > +
> > +  - memory.dirty_bytes: the amount of dirty memory of the cgroup (expressed in
> > +    bytes) at which a process generating disk writes will start itself writing
> > +    out dirty data.
> > +
> > +  - memory.dirty_background_ratio: contains, as a percentage of the cgroup
> > +    memory, the amount of dirty memory at which background writeback kernel
> > +    threads will start writing out dirty data.
> > +
> > +  - memory.dirty_background_bytes: the amount of dirty memory of the cgroup (in
> > +    bytes) at which background writeback kernel threads will start writing out
> > +    dirty data.
> > +
> >  
> It would be better to note that what those files of root cgroup mean.
> We cannot write any value to them, IOW, we cannot control dirty limit about root cgroup.

OK.

> And they show the same value as the global one(strictly speaking, it's not true
> because global values can change. We need a hook in mem_cgroup_dirty_read()?).

OK, we can just return system-wide value if mem_cgroup_is_root() in
mem_cgroup_dirty_read(). Will change this in the next version.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
