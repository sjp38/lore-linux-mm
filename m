Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 1801C6B007E
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 10:33:28 -0500 (EST)
Date: Fri, 2 Mar 2012 10:33:23 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [ATTEND] [LSF/MM TOPIC] Buffered writes throttling
Message-ID: <20120302153322.GB26315@redhat.com>
References: <4F507453.1020604@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F507453.1020604@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suresh Jayaraman <sjayaraman@suse.com>
Cc: lsf-pc@lists.linux-foundation.org, Andrea Righi <andrea@betterlinux.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>

On Fri, Mar 02, 2012 at 12:48:43PM +0530, Suresh Jayaraman wrote:
> Committee members,
> 
> Please consider inviting me to the Storage, Filesystem, & MM Summit. I
> am working for one of the kernel teams in SUSE Labs focusing on Network
> filesystems and block layer.
> 
> Recently, I have been trying to solve the problem of "throttling
> buffered writes" to make per-cgroup throttling of IO to the device
> possible. Currently the block IO controller does not throttle buffered
> writes. The writes would have lost the submitter's context (I/O comes in
> flusher thread's context) when they are at the block IO layer. I looked
> at the past work and many folks have attempted to solve this problem in
> the past years but this problem remains unsolved so far.
> 
> First, Andrea Righi tried to solve this by limiting the rate of async
> writes at the time a task is generating dirty pages in the page cache.
> 
> Next, Vivek Goyal tried to solve this by throttling writes at the time
> they are entering the page cache.
> 
> Both these approches have limitations and not considered for merging.
> 
> I have looked at the possibility of solving this at the filesystem level
> but the problem with ext* filesystems is that a commit will commit the
> whole transaction at once (which may contain writes from
> processes belonging to more than one cgroup). Making filesystems cgroup
> aware would need redesign of journalling layer itself.
> 
> Dave Chinner thinks this problem should be solved and being solved in a
> different manner by making the bdi-flusher writeback cgroup aware.
> 
> Greg Thelen's memcg writeback patchset (already been proposed for LSF/MM
> summit this year) adds cgroup awareness to writeback. Some aspects of
> this patchset could be borrowed for solving the problem of throttling
> buffered writes.
> 
> As I understand the topic was discussed during last Kernel Summit as
> well and the idea is to get the IO-less throttling patchset into the
> kernel, then do per-memcg dirty memory limiting and add some memcg
> awareness to writeback Greg Thelen and then when these things settle
> down, think how to solve this problem since noone really seem to have a
> good answer to it.
> 
> Having worked on linux filesystem/storage area for a few years now and
> having spent time understanding the various approaches tried and looked
> at other feasible way of solving this problem, I look forward to
> participate in the summit and discussions.
> 
> So, the topic I would like to discuss is solving the problem of
> "throttling buffered writes". This could considered for discussion with
> memcg writeback session if that topic has been allocated a slot.
> 
> I'm aware that this is a late submission and my apologies for not making
> it earlier. But, I want to take chances and see if it is possible still..

This is an interesting and complicated topic. As you mentioned we have had
tried to solve it but nothing has been merged yet. Personally, I am still
interested in having a discussion and see if we can come up with a way
forward.

Because filesystems are not cgroup aware, throtting IO below filesystem
has dangers of IO of faster cgroups being throttled behind slower cgroup
(journalling was one example and there could be others). Hence, I personally
think that this problem should be solved at higher layer and that is when
we are actually writting to the cache. That has the disadvantage of still
seeing IO spikes at the device but I guess we live with that. Doing it
at higher layer also allows to use the same logic for NFS too otherwise
NFS buffered write will continue to be a problem.

In case of memory controller it jsut becomes a write to memory issue,
and not sure if notion of dirty_ratio and dirty_bytes is enough or we 
need to rate limit the write to memory. 

Anyway, ideas to have better control of write rates are welcome. We have
seen issues wheren a virtual machine cloning operation is going on and
we also want a small direct write to be on disk and it can take a long
time with deadline. CFQ should still be fine as direct IO is synchronous
but deadline treats all WRITEs the same way.

May be deadline should be modified to differentiate between SYNC and ASYNC
IO instead of READ/WRITE. Jens?

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
