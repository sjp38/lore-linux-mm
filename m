Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 49C716B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 10:57:05 -0400 (EDT)
Date: Tue, 24 Apr 2012 16:56:55 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120424145655.GA1474@quack.suse.cz>
References: <20120410210505.GE4936@quack.suse.cz>
 <20120410212041.GP21801@redhat.com>
 <20120410222425.GF4936@quack.suse.cz>
 <20120411154005.GD16692@redhat.com>
 <20120411192231.GF16008@quack.suse.cz>
 <20120412203719.GL2207@redhat.com>
 <20120412205148.GA24056@google.com>
 <20120414143639.GA31241@localhost>
 <20120416145744.GA15437@redhat.com>
 <20120424113340.GA12509@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120424113340.GA12509@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Tue 24-04-12 19:33:40, Wu Fengguang wrote:
> On Mon, Apr 16, 2012 at 10:57:45AM -0400, Vivek Goyal wrote:
> > On Sat, Apr 14, 2012 at 10:36:39PM +0800, Fengguang Wu wrote:
> > 
> > [..]
> > > Yeah the backpressure idea would work nicely with all possible
> > > intermediate stacking between the bdi and leaf devices. In my attempt
> > > to do combined IO bandwidth control for
> > > 
> > > - buffered writes, in balance_dirty_pages()
> > > - direct IO, in the cfq IO scheduler
> > > 
> > > I have to look into the cfq code in the past days to get an idea how
> > > the two throttling layers can cooperate (and suffer from the pains
> > > arise from the violations of layers). It's also rather tricky to get
> > > two previously independent throttling mechanisms to work seamlessly
> > > with each other for providing the desired _unified_ user interface. It
> > > took a lot of reasoning and experiments to work the basic scheme out...
> > > 
> > > But here is the first result. The attached graph shows progress of 4
> > > tasks:
> > > - cgroup A: 1 direct dd + 1 buffered dd
> > > - cgroup B: 1 direct dd + 1 buffered dd
> > > 
> > > The 4 tasks are mostly progressing at the same pace. The top 2
> > > smoother lines are for the buffered dirtiers. The bottom 2 lines are
> > > for the direct writers. As you may notice, the two direct writers are
> > > somehow stalled for 1-2 times, which increases the gaps between the
> > > lines. Otherwise, the algorithm is working as expected to distribute
> > > the bandwidth to each task.
> > > 
> > > The current code's target is to satisfy the more realistic user demand
> > > of distributing bandwidth equally to each cgroup, and inside each
> > > cgroup, distribute bandwidth equally to buffered/direct writes. On top
> > > of which, weights can be specified to change the default distribution.
> > > 
> > > The implementation involves adding "weight for direct IO" to the cfq
> > > groups and "weight for buffered writes" to the root cgroup. Note that
> > > current cfq proportional IO conroller does not offer explicit control
> > > over the direct:buffered ratio.
> > > 
> > > When there are both direct/buffered writers in the cgroup,
> > > balance_dirty_pages() will kick in and adjust the weights for cfq to
> > > execute. Note that cfq will continue to send all flusher IOs to the
> > > root cgroup.  balance_dirty_pages() will compute the overall async
> > > weight for it so that in the above test case, the computed weights
> > > will be
> > 
> > I think having separate weigths for sync IO groups and async IO is not
> > very appealing. There should be one notion of group weight and bandwidth
> > distrubuted among groups according to their weight.
> 
> There have to be some scheme, either explicitly or implicitly. Maybe
> you are baring in mind some "equal split among queues" policy? For
> example, if the cgroup has 9 active sync queues and 1 async queue,
> split the weight equally to the 10 queues?  So the sync IOs get 90%
> share, and the async writes get 10% share.
  Maybe I misunderstand but there doesn't have to be (and in fact isn't)
any split among sync / async IO in CFQ. At each moment, we choose a queue
with the highest score and dispatch a couple of requests from it. Then we
go and choose again. The score of the queue depends on several factors
(like age of requests, whether the queue is sync or async, IO priority,
etc.).

Practically, over a longer period system will stabilize on some ratio
but that's dependent on the load so your system should not impose some
artificial direct/buffered split but rather somehow deal with the reality
how IO scheduler decides to dispatch requests...

> For dirty throttling w/o cgroup awareness, balance_dirty_pages()
> splits the writeout bandwidth equally among all dirtier tasks. Since
> cfq works with queues, it seems most natural for it to do equal split
> among all queues (inside the cgroup).
  Well, but we also have IO priorities which change which queue should get
preference.

> I'm not sure when there are N dd tasks doing direct IO, cfq will
> continuously run N sync queues for them (without many dynamic queue
> deletion and recreations). If that is the case, it should be trivial
> to support the queue based fair split in the global async queue
> scheme. Otherwise I'll have some trouble detecting the N value when
> trying to do the N:1 sync:async weight split.
  And also sync queues for several processes can get merged when CFQ
observes these processes cooperate together on one area of disk and get
split again when processes stop cooperating. I don't think you really want
to second-guess what CFQ does inside...

> Look at this graph, the 4 dd tasks are granted the same weight (2 of
> them are buffered writes). I guess the 2 buffered dd tasks managed to
> progress much faster than the 2 direct dd tasks just because the async
> IOs are much more efficient than the bs=64k direct IOs.
  Likely because 64k is too low to get good bandwidth with direct IO. If
it was 4M, I believe you would get similar throughput for buffered and
direct IO. So essentially you are right, small IO benefits from caching
effects since they allow you to submit larger requests to the device which
is more efficient.

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
