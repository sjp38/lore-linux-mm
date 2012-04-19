Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 966A46B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 16:27:30 -0400 (EDT)
Date: Thu, 19 Apr 2012 22:26:35 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120419202635.GA4795@quack.suse.cz>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120417223854.GG19975@google.com>
 <20120419142343.GA12684@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120419142343.GA12684@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Thu 19-04-12 22:23:43, Wu Fengguang wrote:
> For one instance, splitting the request queues will give rise to
> PG_writeback pages.  Those pages have been the biggest source of
> latency issues in the various parts of the system.
  Well, if we allow more requests to be in flight in total then yes, number
of PG_Writeback pages can be higher as well.

> It's not uncommon for me to see filesystems sleep on PG_writeback
> pages during heavy writeback, within some lock or transaction, which in
> turn stall many tasks that try to do IO or merely dirty some page in
> memory. Random writes are especially susceptible to such stalls. The
> stable page feature also vastly increase the chances of stalls by
> locking the writeback pages. 
> 
> Page reclaim may also block on PG_writeback and/or PG_dirty pages. In
> the case of direct reclaim, it means blocking random tasks that are
> allocating memory in the system.
> 
> PG_writeback pages are much worse than PG_dirty pages in that they are
> not movable. This makes a big difference for high-order page allocations.
> To make room for a 2MB huge page, vmscan has the option to migrate
> PG_dirty pages, but for PG_writeback it has no better choices than to
> wait for IO completion.
> 
> The difficulty of THP allocation goes up *exponentially* with the
> number of PG_writeback pages. Assume PG_writeback pages are randomly
> distributed in the physical memory space. Then we have formula
> 
>         P(reclaimable for THP) = 1 - P(hit PG_writeback)^256
  Well, this implicitely assumes that PG_Writeback pages are scattered
across memory uniformly at random. I'm not sure to which extent this is
true... Also as a nitpick, this isn't really an exponential growth since
the exponent is fixed (256 - actually it should be 512, right?). It's just
a polynomial with a big exponent. But sure, growth in number of PG_Writeback
pages will cause relatively steep drop in the number of available huge
pages.

...
> It's worth to note that running multiple flusher threads per bdi means
> not only disk seeks for spin disks, smaller IO size for SSD, but also
> lock contentions and cache bouncing for metadata heavy workloads and
> fast storage.
  Well, this heavily depends on particular implementation (and chosen
data structures). But yes, we should have that in mind.

...
> > > To me, balance_dirty_pages() is *the* proper layer for buffered writes.
> > > It's always there doing 1:1 proportional throttling. Then you try to
> > > kick in to add *double* throttling in block/cfq layer. Now the low
> > > layer may enforce 10:1 throttling and push balance_dirty_pages() away
> > > from its balanced state, leading to large fluctuations and program
> > > stalls.
> > 
> > Just do the same 1:1 inside each cgroup.
> 
> Sure. But the ratio mismatch I'm talking about is inter-cgroup.
> For example there are only 2 dd tasks doing buffered writes in the
> system. Now consider the mismatch that cfq is dispatching their IO
> requests at 10:1 weights, while balance_dirty_pages() is throttling
> the dd tasks at 1:1 equal split because it's not aware of the cgroup
> weights.
> 
> What will happen in the end? The 1:1 ratio imposed by
> balance_dirty_pages() will take effect and the dd tasks will progress
> at the same pace. The cfq weights will be defeated because the async
> queue for the second dd (and cgroup) constantly runs empty.
  Yup. This just shows that you have to have per-cgroup dirty limits. Once
you have those, things start working again.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
