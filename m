Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 4E85B6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 07:38:57 -0400 (EDT)
Date: Tue, 24 Apr 2012 19:33:40 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120424113340.GA12509@localhost>
References: <20120410180653.GJ21801@redhat.com>
 <20120410210505.GE4936@quack.suse.cz>
 <20120410212041.GP21801@redhat.com>
 <20120410222425.GF4936@quack.suse.cz>
 <20120411154005.GD16692@redhat.com>
 <20120411192231.GF16008@quack.suse.cz>
 <20120412203719.GL2207@redhat.com>
 <20120412205148.GA24056@google.com>
 <20120414143639.GA31241@localhost>
 <20120416145744.GA15437@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120416145744.GA15437@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

Hi Vivek,

On Mon, Apr 16, 2012 at 10:57:45AM -0400, Vivek Goyal wrote:
> On Sat, Apr 14, 2012 at 10:36:39PM +0800, Fengguang Wu wrote:
> 
> [..]
> > Yeah the backpressure idea would work nicely with all possible
> > intermediate stacking between the bdi and leaf devices. In my attempt
> > to do combined IO bandwidth control for
> > 
> > - buffered writes, in balance_dirty_pages()
> > - direct IO, in the cfq IO scheduler
> > 
> > I have to look into the cfq code in the past days to get an idea how
> > the two throttling layers can cooperate (and suffer from the pains
> > arise from the violations of layers). It's also rather tricky to get
> > two previously independent throttling mechanisms to work seamlessly
> > with each other for providing the desired _unified_ user interface. It
> > took a lot of reasoning and experiments to work the basic scheme out...
> > 
> > But here is the first result. The attached graph shows progress of 4
> > tasks:
> > - cgroup A: 1 direct dd + 1 buffered dd
> > - cgroup B: 1 direct dd + 1 buffered dd
> > 
> > The 4 tasks are mostly progressing at the same pace. The top 2
> > smoother lines are for the buffered dirtiers. The bottom 2 lines are
> > for the direct writers. As you may notice, the two direct writers are
> > somehow stalled for 1-2 times, which increases the gaps between the
> > lines. Otherwise, the algorithm is working as expected to distribute
> > the bandwidth to each task.
> > 
> > The current code's target is to satisfy the more realistic user demand
> > of distributing bandwidth equally to each cgroup, and inside each
> > cgroup, distribute bandwidth equally to buffered/direct writes. On top
> > of which, weights can be specified to change the default distribution.
> > 
> > The implementation involves adding "weight for direct IO" to the cfq
> > groups and "weight for buffered writes" to the root cgroup. Note that
> > current cfq proportional IO conroller does not offer explicit control
> > over the direct:buffered ratio.
> > 
> > When there are both direct/buffered writers in the cgroup,
> > balance_dirty_pages() will kick in and adjust the weights for cfq to
> > execute. Note that cfq will continue to send all flusher IOs to the
> > root cgroup.  balance_dirty_pages() will compute the overall async
> > weight for it so that in the above test case, the computed weights
> > will be
> 
> I think having separate weigths for sync IO groups and async IO is not
> very appealing. There should be one notion of group weight and bandwidth
> distrubuted among groups according to their weight.

There have to be some scheme, either explicitly or implicitly. Maybe
you are baring in mind some "equal split among queues" policy? For
example, if the cgroup has 9 active sync queues and 1 async queue,
split the weight equally to the 10 queues?  So the sync IOs get 90%
share, and the async writes get 10% share.

For dirty throttling w/o cgroup awareness, balance_dirty_pages()
splits the writeout bandwidth equally among all dirtier tasks. Since
cfq works with queues, it seems most natural for it to do equal split
among all queues (inside the cgroup).

I'm not sure when there are N dd tasks doing direct IO, cfq will
continuously run N sync queues for them (without many dynamic queue
deletion and recreations). If that is the case, it should be trivial
to support the queue based fair split in the global async queue
scheme. Otherwise I'll have some trouble detecting the N value when
trying to do the N:1 sync:async weight split.

> Now one can argue that with-in a group, there might be one knob in CFQ
> which allows to change the share or sync/async IO.

Yeah. I suspect typical users don't care about the split policy or
fairness inside the cgroup, otherwise there may be complains on any
existing policies: "I want split this way" "I want that way"... ;-)

Anyway I'm not sure about the possible use cases..

> Also Tejun and Jan have expressed the desire that once we have figured
> out a way to communicate the submitter's context for async IO, we would
> like to account that IO in associated cgroup instead of root cgroup (as
> we do today).

Understand. Accounting should always be attributed to the corresponding
cgroup. I'll also need this to send feedback information to the async
IO submitter's cgroups.

> > - 1000 async weight for the root cgroup (2 buffered dds)
> > - 500 dio weight for cgroup A (1 direct dd)
> > - 500 dio weight for cgroup B (1 direct dd)
> > 
> > The second graph shows result for another test case:
> > - cgroup A, weight 300: 1 buffered cp
> > - cgroup B, weight 600: 1 buffered dd + 1 direct dd
> > - cgroup C, weight 300: 1 direct dd
> > which is also working as expected.
> > 
> > Once the cfq properly grants total async IO share to the flusher,
> > balance_dirty_pages() will then do its original job of distributing
> > the buffered write bandwidth among the buffered dd tasks.
> > 
> > It will have to assume that the devices under the same bdi are
> > "symmetry". It also needs further stats feedback on IOPS or disk time
> > in order to do IOPS/time based IO distribution. Anyway it would be
> > interesting to see how far this scheme can go. I'll cleanup the code
> > and post it soon.
> 
> Your proposal relies on few things.
> 
> - Bandwidth needs to be divided eually among sync and async IO.

Yeah balance_dirty_pages() always works on the basis of bandwidth. The
plan is that once we get the feedback information on each stream's
bandwidth:disk_time (or IOPS) ratio, the bandwidth target can be
adjusted to achieve disk time or IOPS based fair share among the
buffered dirtiers.

For the sync:async split, it's operating on the cfqg->weight. So it's
automatically disk time based.

Look at this graph, the 4 dd tasks are granted the same weight (2 of
them are buffered writes). I guess the 2 buffered dd tasks managed to
progress much faster than the 2 direct dd tasks just because the async
IOs are much more efficient than the bs=64k direct IOs.

https://github.com/fengguang/io-controller-tests/raw/master/log/bay/xfs/mixed-write-2.2012-04-19-10-42/balance_dirty_pages-task-bw.png

> - Flusher thread async IO will always to go to root cgroup.

Right. This is actually my main target: to avoid splitting up the
async streams throughout the IO path, for the good of performance.

> - I am not sure how this scheme is going to work when we introduce
>   hierarchical blkio cgroups.

I think it's still viable. balance_dirty_pages() works by estimating
the N (number of dd tasks) value and splitting the writeout bandwidth
equally among the tasks:

        task_ratelimit = write_bandwidth / N

It becomes a proportional weight IO controller if change the formula
to
        task_ratelimit = weight * write_bandwidth / N_w

Here lies the beauty of the bdi_update_dirty_ratelimit() algorithm:
it can automatically adapt N to the proper "weighted" N_w to keep
things in balance, given whatever weights applied to each task.

If further use 

        blkcg_ratelimit = weight * write_bandwidth / N_w
        task_ratelimit  = weight * blkcg_ratelimit / M_w

It's turned into a cgroup IO controller.

This change further makes it a hierarchical IO controller:

        blkcg_ratelimit = weight * parent_blkcg_ratelimit / M_w

We'll also need to hierarchically de-compose the async weights from
inner cgroup levels to outer levels, and finally add them to the root
cgroup that holds the async queue. This looks feasible, too.

> - cgroup weights for sync IO seems to be being controlled by user and
>   somehow root cgroup weight seems to be controlled by this async IO
>   logic silently.

In the current state I do assume no IO tasks in the root cgroup except
for the flusher. However in general the root cgroup can be treated the
same as other cgroups: its weight can also be split up into dio_weight
and async weight.

The general idea is
- cfqg->weight is given by user
- cfqg->dio_weight is used for sync slices on vdisktime calculation.
- total_async_weight collects all async IO weights from each cgroup,
  including the root cgroup. They are the "credits" for the flusher
  for doing the async IOs in delegate of all the cgroups.

> Overall sounds very odd design to me. I am not sure what are we achieving
> by this. In current scheme one should be able to just adjust the weight
> of root cgroup using cgroup interface and achieve same results which you
> are showing. So where is the need of dynamically changing it inside
> kernel.

The "dynamically changing weights" are for the in-cgroup equal split
between sync/async IOs. It does feel like an arbitrary added policy..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
