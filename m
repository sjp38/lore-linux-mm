Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 601456B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 07:06:20 -0500 (EST)
Date: Wed, 3 Mar 2010 13:05:51 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Message-ID: <20100303120551.GB16239@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
 <1267478620-5276-4-git-send-email-arighi@develer.com>
 <1267537736.25158.54.camel@laptop>
 <20100302221434.GB2369@linux>
 <1267610855.25158.82.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1267610855.25158.82.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 03, 2010 at 11:07:35AM +0100, Peter Zijlstra wrote:
> On Tue, 2010-03-02 at 23:14 +0100, Andrea Righi wrote:
> > 
> > I agree mem_cgroup_has_dirty_limit() is nicer. But we must do that under
> > RCU, so something like:
> > 
> >         rcu_read_lock();
> >         if (mem_cgroup_has_dirty_limit())
> >                 mem_cgroup_get_page_stat()
> >         else
> >                 global_page_state()
> >         rcu_read_unlock();
> > 
> > That is bad when mem_cgroup_has_dirty_limit() always returns false
> > (e.g., when memory cgroups are disabled). So I fallback to the old
> > interface.
> 
> Why is it that mem_cgroup_has_dirty_limit() needs RCU when
> mem_cgroup_get_page_stat() doesn't? That is, simply make
> mem_cgroup_has_dirty_limit() not require RCU in the same way
> *_get_page_stat() doesn't either.

OK, I agree we can get rid of RCU protection here (see my previous
email).

BTW the point was that after mem_cgroup_has_dirty_limit() the task might
be moved to another cgroup, but also in this case mem_cgroup_has_dirty_limit()
will be always true, so mem_cgroup_get_page_stat() is always coherent.

> 
> > What do you think about:
> > 
> >         mem_cgroup_lock();
> >         if (mem_cgroup_has_dirty_limit())
> >                 mem_cgroup_get_page_stat()
> >         else
> >                 global_page_state()
> >         mem_cgroup_unlock();
> > 
> > Where mem_cgroup_read_lock/unlock() simply expand to nothing when
> > memory cgroups are disabled.
> 
> I think you're engineering the wrong way around.
> 
> > > 
> > > That allows for a 0 dirty limit (which should work and basically makes
> > > all io synchronous).
> > 
> > IMHO it is better to reserve 0 for the special value "disabled" like the
> > global settings. A synchronous IO can be also achieved using a dirty
> > limit of 1.
> 
> Why?! 0 clearly states no writeback cache, IOW sync writes, a 1
> byte/page writeback cache effectively reduces to the same thing, but its
> not the same thing conceptually. If you want to put the size and enable
> into a single variable pick -1 for disable or so.

I might agree, and actually I prefer this solution.. but in this way we
would use a different interface respect to the equivalent vm_dirty_ratio
/ vm_dirty_bytes global settings (as well as dirty_background_ratio /
dirty_background_bytes).

IMHO it's better to use the same interface to avoid user
misunderstandings.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
