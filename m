Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 567BB6B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 17:04:14 -0500 (EST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [ATTEND] [LSF/MM TOPIC] Buffered writes throttling
References: <4F507453.1020604@suse.com> <20120302153322.GB26315@redhat.com>
	<20120305192226.GA3670@localhost> <20120305211114.GF18546@redhat.com>
	<20120305225801.GB7545@thinkpad> <20120307205209.GK13430@redhat.com>
Date: Wed, 07 Mar 2012 17:04:06 -0500
In-Reply-To: <20120307205209.GK13430@redhat.com> (Vivek Goyal's message of
	"Wed, 7 Mar 2012 15:52:09 -0500")
Message-ID: <x49399kukyx.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrea Righi <andrea@betterlinux.com>, Fengguang Wu <fengguang.wu@intel.com>, Suresh Jayaraman <sjayaraman@suse.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>

Vivek Goyal <vgoyal@redhat.com> writes:

> On Mon, Mar 05, 2012 at 11:58:01PM +0100, Andrea Righi wrote:
>
> [..]
>> What about this scenario? (Sorry, I've not followed some of the recent
>> discussions on this topic, so I'm sure I'm oversimplifying a bit or
>> ignoring some details):
>> 
>>  - track inodes per-memcg for writeback IO (provided Greg's patch)
>>  - provide per-memcg dirty limit (global, not per-device); when this
>>    limit is exceeded flusher threads are awekened and all tasks that
>>    continue to generate new dirty pages inside the memcg are put to
>>    sleep
>>  - flusher threads start to write some dirty inodes of this memcg (using
>>    the inode tracking feature), let say they start with a chunk of N
>>    pages of the first dirty inode
>>  - flusher threads can't flush in this way more than N pages / sec
>>    (where N * PAGE_SIZE / sec is the blkcg "buffered write rate limit"
>>    on the inode's block device); if a flusher thread exceeds this limit
>>    it won't be blocked directly, it just stops flushing pages for this
>>    memcg after the first chunk and it can continue to flush dirty pages
>>    of a different memcg.
>> 
>
> So, IIUC, the only thing little different here is that throttling is
> implemented by flusher thread. But it is still per device per cgroup. I
> think that is just a implementation detail whether we implement it
> in block layer, or in writeback or somewhere else.  We can very well
> implement it in block layer and provide per bdi/per_group congestion
> flag in bdi so that flusher will stop pushing more IO if group on 
> a bdi is congested (because IO is throttled).
>
> I think first important thing is to figure out what is minimal set of
> requirement (As jan said in another mail), which will solve wide
> variety of cases. I am trying to list some of points. 
>
>
> - Throttling for buffered writes
> 	- Do we want per device throttling limits or global throttling
> 	  limtis.

You can implement global (perhaps in userspace utilities) if you have
the per-device mechanism in the kernel.  So I'd say start with per-device.

> 	- Exising direct write limtis are per device and implemented in
> 	  block layer.
>
> 	- I personally think that both kind of limits might make sense.
> 	  But a global limit for async write might make more sense at
> 	  least for the workloads like backup which can run on a throttled
>   	  speed.

When you say global, do you mean total bandwidth across all devices, or
a maximum bandwidth applied to each device?

> 	- Absolute throttling IO will make most sense on top level device
> 	  in the IO stack.

I'm not sure why you used the word absolute.  I do agree that throttling
at the top-most device in a stack makes the most sense.

> 	- For per device rate throttling, do we want a common limit for
> 	  direct write and buffered write or a separate limit just for
> 	  buffered writes.

That depends, what's the goal?  Direct writes can drive very deep queue
depths, just as buffered writes can.

> - Proportional IO for async writes
> 	- Will probably make most sense on bottom most devices in the IO
> 	  stack (If we are able to somehow retain the submitter's context).

Why does it make sense to have it at the bottom?  Just because that's
where it's implemented today?  Writeback happens to the top-most device,
and that device can have different properties than each of its
components.  So, why don't you think applying policy at the top is the
right thing to do?

> 	- Logically it will make sense to keep sync and async writes in
> 	  same group and try to provide fair share of disk between groups.
> 	  Technically CFQ can do that but in practice I think it will be
>  	  problematic. Writes of one group will take precedence of reads
> 	  of another group. Currently any read is prioritized over 
> 	  buffered writes. So by splitting buffered writes in their own
> 	  cgroups, they can serverly impact the latency of reads in
> 	  another group. Not sure how many people really want to do
> 	  that in practice.
>
> 	- Do we really need proportional IO for async writes. CFQ had
> 	  tried implementing ioprio for async writes but it does not
> 	  work. Should we just care about groups of sync IO and let
> 	  all the async IO on device go in a single queue and lets
> 	  make suere it is not starved while sync IO is going on.

If we get accounting of writeback I/O right, then I think it might make
sense to enforce the proportional I/O policy on aysnc writes.  But, I
guess this also depends on what happens with the mem policy, right?

> 	- I thought that most of the people cared about not impacting
> 	  sync latencies badly while buffered writes are happening. Not
> 	  many complained that buffered writes of one application should
> 	  happen faster than other application. 

Until you are forced to reclaim pages....

> 	- If we agree that not many people require service differentation
> 	  between buffered writes, then we probably don't have to do
> 	  anything in this space and we can keep things simple. I
> 	  personally prefer this option. Trying to provide proportional
> 	  IO for async writes will make things complicated and we might
> 	  not achieve much. 

Again, I think that, in order to consider this, we'd also have to lay
out a plan for how it interacts with the memory cgroup policies.

> 	- CFQ already does a very good job of prioritizing sync over async
> 	  (at the cost of reduced throuhgput on fast devices). So what's
> 	  the use case of proportion IO for async writes.
>
> Once we figure out what are the requirements, we can discuss the
> implementation details.

Nice write-up, Vivek.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
