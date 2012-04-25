Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id B1E606B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 11:47:14 -0400 (EDT)
Received: by dadq36 with SMTP id q36so332080dad.8
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 08:47:14 -0700 (PDT)
Date: Wed, 25 Apr 2012 08:47:06 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120425154706.GA6370@google.com>
References: <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120417223854.GG19975@google.com>
 <20120419142343.GA12684@localhost>
 <20120419202635.GA4795@quack.suse.cz>
 <20120420133441.GA7035@localhost>
 <20120420190844.GH32324@google.com>
 <20120422144649.GA7066@localhost>
 <20120423165626.GB5406@google.com>
 <20120424075853.GA8391@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120424075853.GA8391@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>

Hey, Fengguang.

On Tue, Apr 24, 2012 at 03:58:53PM +0800, Fengguang Wu wrote:
> > I have two questions.  Why do we need memcg for this?  Writeback
> > currently works without memcg, right?  Why does that change with blkcg
> > aware bdi?
> 
> Yeah currently writeback does not depend on memcg. As for blkcg, it's
> necessary to keep a number of dirty pages for each blkcg, so that the
> cfq groups' async IO queue does not go empty and lose its turn to do
> IO. memcg provides the proper infrastructure to account dirty pages.
> 
> In a previous email, we have an example of two 10:1 weight cgroups,
> each running one dd. They will make two IO pipes, each holding a number
> of dirty pages. Since cfq honors dd-1 much more IO bandwidth, dd-1's
> dirty pages are consumed quickly. However balance_dirty_pages(),
> without knowing about cfq's bandwidth divisions, is throttling the
> two dd tasks equally. So dd-1 will be producing dirty pages much
> slower than cfq is consuming them. The flusher thus won't send enough
> dirty pages down to fill the corresponding async IO queue for dd-1.
> cfq cannot really give dd-1 more bandwidth share due to lack of data
> feed. The end result will be: the two cgroups get 1:1 bandwidth share
> honored by balance_dirty_pages() even though cfq honors 10:1 weights
> to them.

My question is why can't cgroup-bdi pair be handled the same or
similar way each bdi is handled now?  I haven't looked through the
code yet but something is determining, even inadvertently, the dirty
memory usage among different bdi's, right?  What I'm curious about is
why cgroupfying bdi makes any different to that.  If it's
indeterministic w/o memcg, let it be that way with blkcg too.  Just
treat cgroup-bdi as separate bdis.  So, what changes?

> However if it's a large memory machine whose dirty pages get
> partitioned to 100 cgroups, the flusher will be serving them
> in round robin fashion.

Just treat cgroup-bdi as a separate bdi.  Run an independent flusher
on it.  They're separate channels.

> blkio.weight will be the "number" shared and interpreted by all IO
> controller entities, whether it be cfq, NFS or balance_dirty_pages().

It already isn't.  blk-throttle is an IO controller entity but doesn't
make use of weight.

> > However, this doesn't necessarily translate easily into the actual
> > underlying IO resource.  For devices with spindle, seek time dominates
> > and the same amount of IO may consume vastly different amount of IO
> > and the disk time becomes the primary resource, not the iops or
> > bandwidth.  Naturally, people want to allocate and limit the primary
> > resource, so cfq distributes disk time across different cgroups as
> > configured.
> 
> Right. balance_dirty_pages() is always doing dirty throttling wrt.
> bandwidth, even in your back pressure scheme, isn't it? In this regard,
> there are nothing fundamentally different between our proposals. They

If balance_dirty_pages() fails to keep the IO buffer full, it's
balance_dirty_pages()'s failure (and doing so from time to time could
be fine given enough benefits), but no matter what writeback does,
blkcg *should* enforce the configured limits, so they're quite
different in terms of encapsulation and functionality.

> > Your suggested solution is applying the same a number - the weight -
> > to one portion of a mostly arbitrarily split resource using a
> > different unit.  I don't even understand what that achieves.
> 
> You seem to miss my stated plan: next step, balance_dirty_pages() will
> get some feedback information from cfq to adjust its bandwidth targets
> accordingly. That information will be
> 
>         io_cost = charge/sectors
> 
> The charge value is exactly the value computed in cfq_group_served(),
> which is the slice time or IOs dispatched depending the mode cfq is
> operating in. By dividing ratelimit by the normalized io_cost,
> balance_dirty_pages() will automatically get the same weight
> interpretation as cfq. For example, on spin disks, it will be able to
> allocate lower bandwidth to seeky cgroups due to the larger io_cost
> reported by cfq.

So, cfq is basing its cost calculation on disk time spent by sync IOs
which gets fluctuated by uncategorized async IOs and you're gonna
apply that number to async IOs in some magical way?  What the hell
does that achieve?

Please take a step back and look at the whole stack and think about
what each part is supposed to do and how they are supposed to
interact.  If you still can't see the mess you're trying to make,
ummm... I don't know.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
