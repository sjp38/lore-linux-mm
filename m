Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B86DC6B01C0
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 06:02:10 -0400 (EDT)
Date: Mon, 15 Mar 2010 11:02:06 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v7)
Message-ID: <20100315100206.GB1653@linux.develer.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
 <20100315113612.8411d92d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100315113612.8411d92d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 11:36:12AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 15 Mar 2010 00:26:37 +0100
> Andrea Righi <arighi@develer.com> wrote:
> 
> > Control the maximum amount of dirty pages a cgroup can have at any given time.
> > 
> > Per cgroup dirty limit is like fixing the max amount of dirty (hard to reclaim)
> > page cache used by any cgroup. So, in case of multiple cgroup writers, they
> > will not be able to consume more than their designated share of dirty pages and
> > will be forced to perform write-out if they cross that limit.
> > 
> > The overall design is the following:
> > 
> >  - account dirty pages per cgroup
> >  - limit the number of dirty pages via memory.dirty_ratio / memory.dirty_bytes
> >    and memory.dirty_background_ratio / memory.dirty_background_bytes in
> >    cgroupfs
> >  - start to write-out (background or actively) when the cgroup limits are
> >    exceeded
> > 
> > This feature is supposed to be strictly connected to any underlying IO
> > controller implementation, so we can stop increasing dirty pages in VM layer
> > and enforce a write-out before any cgroup will consume the global amount of
> > dirty pages defined by the /proc/sys/vm/dirty_ratio|dirty_bytes and
> > /proc/sys/vm/dirty_background_ratio|dirty_background_bytes limits.
> > 
> > Changelog (v6 -> v7)
> > ~~~~~~~~~~~~~~~~~~~~~~
> >  * introduce trylock_page_cgroup() to guarantee that lock_page_cgroup()
> >    is never called under tree_lock (no strict accounting, but better overall
> >    performance)
> >  * do not account file cache statistics for the root cgroup (zero
> >    overhead for the root cgroup)
> >  * fix: evaluate cgroup free pages as at the minimum free pages of all
> >    its parents
> > 
> > Results
> > ~~~~~~~
> > The testcase is a kernel build (2.6.33 x86_64_defconfig) on a Intel Core 2 @
> > 1.2GHz:
> > 
> > <before>
> >  - root  cgroup:	11m51.983s
> >  - child cgroup:	11m56.596s
> > 
> > <after>
> >  - root cgroup:		11m51.742s
> >  - child cgroup:	12m5.016s
> > 
> > In the previous version of this patchset, using the "complex" locking scheme
> > with the _locked and _unlocked version of mem_cgroup_update_page_stat(), the
> > child cgroup required 11m57.896s and 12m9.920s with lock_page_cgroup()+irq_disabled.
> > 
> > With this version there's no overhead for the root cgroup (the small difference
> > is in error range). I expected to see less overhead for the child cgroup, I'll
> > do more testing and try to figure better what's happening.
> > 
> Okay, thanks. This seems good result. Optimization for children can be done under
> -mm tree, I think. (If no nack, this seems ready for test in -mm.)

OK, I'll wait a bit to see if someone has other fixes or issues and post
a new version soon including these small changes.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
