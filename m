Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 657D66B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 05:07:50 -0500 (EST)
Received: from e35131.upc-e.chello.nl ([213.93.35.131] helo=dyad.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1NmlUZ-00035f-PE
	for linux-mm@kvack.org; Wed, 03 Mar 2010 10:07:47 +0000
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100302221434.GB2369@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	 <1267478620-5276-4-git-send-email-arighi@develer.com>
	 <1267537736.25158.54.camel@laptop>  <20100302221434.GB2369@linux>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 03 Mar 2010 11:07:35 +0100
Message-ID: <1267610855.25158.82.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-03-02 at 23:14 +0100, Andrea Righi wrote:
> 
> I agree mem_cgroup_has_dirty_limit() is nicer. But we must do that under
> RCU, so something like:
> 
>         rcu_read_lock();
>         if (mem_cgroup_has_dirty_limit())
>                 mem_cgroup_get_page_stat()
>         else
>                 global_page_state()
>         rcu_read_unlock();
> 
> That is bad when mem_cgroup_has_dirty_limit() always returns false
> (e.g., when memory cgroups are disabled). So I fallback to the old
> interface.

Why is it that mem_cgroup_has_dirty_limit() needs RCU when
mem_cgroup_get_page_stat() doesn't? That is, simply make
mem_cgroup_has_dirty_limit() not require RCU in the same way
*_get_page_stat() doesn't either.

> What do you think about:
> 
>         mem_cgroup_lock();
>         if (mem_cgroup_has_dirty_limit())
>                 mem_cgroup_get_page_stat()
>         else
>                 global_page_state()
>         mem_cgroup_unlock();
> 
> Where mem_cgroup_read_lock/unlock() simply expand to nothing when
> memory cgroups are disabled.

I think you're engineering the wrong way around.

> > 
> > That allows for a 0 dirty limit (which should work and basically makes
> > all io synchronous).
> 
> IMHO it is better to reserve 0 for the special value "disabled" like the
> global settings. A synchronous IO can be also achieved using a dirty
> limit of 1.

Why?! 0 clearly states no writeback cache, IOW sync writes, a 1
byte/page writeback cache effectively reduces to the same thing, but its
not the same thing conceptually. If you want to put the size and enable
into a single variable pick -1 for disable or so.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
