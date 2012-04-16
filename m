Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 78A6D6B00F2
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 10:57:59 -0400 (EDT)
Date: Mon, 16 Apr 2012 10:57:45 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120416145744.GA15437@redhat.com>
References: <20120407080027.GA2584@quack.suse.cz>
 <20120410180653.GJ21801@redhat.com>
 <20120410210505.GE4936@quack.suse.cz>
 <20120410212041.GP21801@redhat.com>
 <20120410222425.GF4936@quack.suse.cz>
 <20120411154005.GD16692@redhat.com>
 <20120411192231.GF16008@quack.suse.cz>
 <20120412203719.GL2207@redhat.com>
 <20120412205148.GA24056@google.com>
 <20120414143639.GA31241@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120414143639.GA31241@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Sat, Apr 14, 2012 at 10:36:39PM +0800, Fengguang Wu wrote:

[..]
> Yeah the backpressure idea would work nicely with all possible
> intermediate stacking between the bdi and leaf devices. In my attempt
> to do combined IO bandwidth control for
> 
> - buffered writes, in balance_dirty_pages()
> - direct IO, in the cfq IO scheduler
> 
> I have to look into the cfq code in the past days to get an idea how
> the two throttling layers can cooperate (and suffer from the pains
> arise from the violations of layers). It's also rather tricky to get
> two previously independent throttling mechanisms to work seamlessly
> with each other for providing the desired _unified_ user interface. It
> took a lot of reasoning and experiments to work the basic scheme out...
> 
> But here is the first result. The attached graph shows progress of 4
> tasks:
> - cgroup A: 1 direct dd + 1 buffered dd
> - cgroup B: 1 direct dd + 1 buffered dd
> 
> The 4 tasks are mostly progressing at the same pace. The top 2
> smoother lines are for the buffered dirtiers. The bottom 2 lines are
> for the direct writers. As you may notice, the two direct writers are
> somehow stalled for 1-2 times, which increases the gaps between the
> lines. Otherwise, the algorithm is working as expected to distribute
> the bandwidth to each task.
> 
> The current code's target is to satisfy the more realistic user demand
> of distributing bandwidth equally to each cgroup, and inside each
> cgroup, distribute bandwidth equally to buffered/direct writes. On top
> of which, weights can be specified to change the default distribution.
> 
> The implementation involves adding "weight for direct IO" to the cfq
> groups and "weight for buffered writes" to the root cgroup. Note that
> current cfq proportional IO conroller does not offer explicit control
> over the direct:buffered ratio.
> 
> When there are both direct/buffered writers in the cgroup,
> balance_dirty_pages() will kick in and adjust the weights for cfq to
> execute. Note that cfq will continue to send all flusher IOs to the
> root cgroup.  balance_dirty_pages() will compute the overall async
> weight for it so that in the above test case, the computed weights
> will be

I think having separate weigths for sync IO groups and async IO is not
very appealing. There should be one notion of group weight and bandwidth
distrubuted among groups according to their weight.

Now one can argue that with-in a group, there might be one knob in CFQ
which allows to change the share or sync/async IO.

Also Tejun and Jan have expressed the desire that once we have figured
out a way to communicate the submitter's context for async IO, we would
like to account that IO in associated cgroup instead of root cgroup (as
we do today).

> 
> - 1000 async weight for the root cgroup (2 buffered dds)
> - 500 dio weight for cgroup A (1 direct dd)
> - 500 dio weight for cgroup B (1 direct dd)
> 
> The second graph shows result for another test case:
> - cgroup A, weight 300: 1 buffered cp
> - cgroup B, weight 600: 1 buffered dd + 1 direct dd
> - cgroup C, weight 300: 1 direct dd
> which is also working as expected.
> 
> Once the cfq properly grants total async IO share to the flusher,
> balance_dirty_pages() will then do its original job of distributing
> the buffered write bandwidth among the buffered dd tasks.
> 
> It will have to assume that the devices under the same bdi are
> "symmetry". It also needs further stats feedback on IOPS or disk time
> in order to do IOPS/time based IO distribution. Anyway it would be
> interesting to see how far this scheme can go. I'll cleanup the code
> and post it soon.

Your proposal relies on few things.

- Bandwidth needs to be divided eually among sync and async IO.
- Flusher thread async IO will always to go to root cgroup.
- I am not sure how this scheme is going to work when we introduce
  hierarchical blkio cgroups.
- cgroup weights for sync IO seems to be being controlled by user and
  somehow root cgroup weight seems to be controlled by this async IO
  logic silently.

Overall sounds very odd design to me. I am not sure what are we achieving
by this. In current scheme one should be able to just adjust the weight
of root cgroup using cgroup interface and achieve same results which you
are showing. So where is the need of dynamically changing it inside
kernel.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
