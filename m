Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 43F326B00F3
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 17:23:53 -0500 (EST)
Date: Thu, 11 Mar 2010 23:23:48 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Message-ID: <20100311222348.GB2427@linux>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
 <20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 11, 2010 at 09:39:13AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 10 Mar 2010 00:00:31 +0100
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
> > Changelog (v5 -> v6)
> > ~~~~~~~~~~~~~~~~~~~~~~
> >  * always disable/enable IRQs at lock/unlock_page_cgroup(): this allows to drop
> >    the previous complicated locking scheme in favor of a simpler locking, even
> >    if this obviously adds some overhead (see results below)
> >  * drop FUSE and NILFS2 dirty pages accounting for now (this depends on
> >    charging bounce pages per cgroup)
> > 
> > Results
> > ~~~~~~~
> > I ran some tests using a kernel build (2.6.33 x86_64_defconfig) on a
> > Intel Core 2 @ 1.2GHz as testcase using different kernels:
> >  - mmotm "vanilla"
> >  - mmotm with cgroup-dirty-memory using the previous "complex" locking scheme
> >    (my previous patchset + the fixes reported by Kame-san and Daisuke-san)
> >  - mmotm with cgroup-dirty-memory using the simple locking scheme
> >    (lock_page_cgroup() with IRQs disabled)
> > 
> > Following the results:
> > <before>
> >  - mmotm "vanilla", root  cgroup:			11m51.983s
> >  - mmotm "vanilla", child cgroup:			11m56.596s
> > 
> > <after>
> >  - mmotm, "complex" locking scheme, root  cgroup:	11m53.037s
> >  - mmotm, "complex" locking scheme, child cgroup:	11m57.896s
> > 
> >  - mmotm, lock_page_cgroup+irq_disabled, root  cgroup:	12m5.499s
> >  - mmotm, lock_page_cgroup+irq_disabled, child cgroup:	12m9.920s
> > 
> > With the "complex" locking solution, the overhead introduced by the
> > cgroup dirty memory accounting is minimal (0.14%), compared with the overhead
> > introduced by the lock_page_cgroup+irq_disabled solution (1.90%).
> > 
> Hmm....isn't this bigger than expected ?

Consider that I'm not running the kernel build on tmpfs, but on a fs
defined on /dev/sda. So the additional overhead should be normal
compared to the mmotm vanilla, where there's only FILE_MAPPED
accounting.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
