Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id DDEA56B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 03:08:21 -0500 (EST)
Received: by qcse1 with SMTP id e1so23887qcs.2
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 00:08:20 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [ATTEND] [LSF/MM TOPIC] Buffered writes throttling
References: <4F507453.1020604@suse.com> <20120302153322.GB26315@redhat.com>
	<20120305192226.GA3670@localhost> <20120305211114.GF18546@redhat.com>
	<20120305225801.GB7545@thinkpad> <20120307205209.GK13430@redhat.com>
Date: Thu, 08 Mar 2012 00:08:20 -0800
In-Reply-To: <20120307205209.GK13430@redhat.com> (Vivek Goyal's message of
	"Wed, 7 Mar 2012 15:52:09 -0500")
Message-ID: <xr93pqcno6q3.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrea Righi <andrea@betterlinux.com>, Fengguang Wu <fengguang.wu@intel.com>, Suresh Jayaraman <sjayaraman@suse.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>

Vivek Goyal <vgoyal@redhat.com> writes:
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
>
> 	- Exising direct write limtis are per device and implemented in
> 	  block layer.
>
> 	- I personally think that both kind of limits might make sense.
> 	  But a global limit for async write might make more sense at
> 	  least for the workloads like backup which can run on a throttled
>   	  speed.
>
> 	- Absolute throttling IO will make most sense on top level device
> 	  in the IO stack.
>
> 	- For per device rate throttling, do we want a common limit for
> 	  direct write and buffered write or a separate limit just for
> 	  buffered writes.

Another aspect to this problem is 'dirty memory limiting'.  First a
quick refresher on memory.soft_limit_in_bytes...  In memcg the
soft_limit_in_bytes can be used as a way to overcommit a machine's
memory.  The idea is that the memory.limit_in_bytes (aka hard limit)
specified a absolute maximum amount of memory a memcg can use, while the
soft_limit_in_bytes indicates the working set of the container.  The
simplified equation is that if the sum(*/memory.soft_limit_in_bytes) <
MemTotal, then all containers should be guaranteed their working set.
Jobs are allowed to allocate more than soft_limit_in_bytes so long as
they fit within limit_in_bytes.  This attempts to provide a min and max
amount of memory for a cgroup.

The soft_limit_in_bytes is related to this discussion because it is
desirable if all container memory above soft_limit_in_bytes is
reclaimable (i.e. clean file cache).  Using previously posted memcg
dirty limiting and memcg writeback logic we have been able to set a
container's dirty_limit to its soft_limit.  While not perfect, this
approximates the goal of providing min guaranteed memory while allowing
for usage of best effort memory, so long as that best effort memory can
be quickly reclaimed to satisfy another container's min guarantee.

> - Proportional IO for async writes
> 	- Will probably make most sense on bottom most devices in the IO
> 	  stack (If we are able to somehow retain the submitter's context).
> 	
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
>
>
> 	- I thought that most of the people cared about not impacting
> 	  sync latencies badly while buffered writes are happening. Not
> 	  many complained that buffered writes of one application should
> 	  happen faster than other application. 
>
> 	- If we agree that not many people require service differentation
> 	  between buffered writes, then we probably don't have to do
> 	  anything in this space and we can keep things simple. I
> 	  personally prefer this option. Trying to provide proportional
> 	  IO for async writes will make things complicated and we might
> 	  not achieve much. 
>
> 	- CFQ already does a very good job of prioritizing sync over async
> 	  (at the cost of reduced throuhgput on fast devices). So what's
> 	  the use case of proportion IO for async writes.
>
> Once we figure out what are the requirements, we can discuss the
> implementation details.
>
> Thanks
> Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
