Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 7CE3E6B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 01:36:37 -0500 (EST)
Date: Tue, 6 Mar 2012 22:31:34 -0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [Lsf-pc] [ATTEND] [LSF/MM TOPIC] Buffered writes throttling
Message-ID: <20120307063134.GA2445@localhost>
References: <4F507453.1020604@suse.com>
 <20120302153322.GB26315@redhat.com>
 <20120305202330.GD11238@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120305202330.GD11238@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Vivek Goyal <vgoyal@redhat.com>, Suresh Jayaraman <sjayaraman@suse.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Andrea Righi <andrea@betterlinux.com>

On Mon, Mar 05, 2012 at 09:23:30PM +0100, Jan Kara wrote:
> On Fri 02-03-12 10:33:23, Vivek Goyal wrote:
> > On Fri, Mar 02, 2012 at 12:48:43PM +0530, Suresh Jayaraman wrote:
> > > Committee members,
> > > 
> > > Please consider inviting me to the Storage, Filesystem, & MM Summit. I
> > > am working for one of the kernel teams in SUSE Labs focusing on Network
> > > filesystems and block layer.
> > > 
> > > Recently, I have been trying to solve the problem of "throttling
> > > buffered writes" to make per-cgroup throttling of IO to the device
> > > possible. Currently the block IO controller does not throttle buffered
> > > writes. The writes would have lost the submitter's context (I/O comes in
> > > flusher thread's context) when they are at the block IO layer. I looked
> > > at the past work and many folks have attempted to solve this problem in
> > > the past years but this problem remains unsolved so far.
> > > 
> > > First, Andrea Righi tried to solve this by limiting the rate of async
> > > writes at the time a task is generating dirty pages in the page cache.
> > > 
> > > Next, Vivek Goyal tried to solve this by throttling writes at the time
> > > they are entering the page cache.
> > > 
> > > Both these approches have limitations and not considered for merging.
> > > 
> > > I have looked at the possibility of solving this at the filesystem level
> > > but the problem with ext* filesystems is that a commit will commit the
> > > whole transaction at once (which may contain writes from
> > > processes belonging to more than one cgroup). Making filesystems cgroup
> > > aware would need redesign of journalling layer itself.
> > > 
> > > Dave Chinner thinks this problem should be solved and being solved in a
> > > different manner by making the bdi-flusher writeback cgroup aware.
> > > 
> > > Greg Thelen's memcg writeback patchset (already been proposed for LSF/MM
> > > summit this year) adds cgroup awareness to writeback. Some aspects of
> > > this patchset could be borrowed for solving the problem of throttling
> > > buffered writes.
> > > 
> > > As I understand the topic was discussed during last Kernel Summit as
> > > well and the idea is to get the IO-less throttling patchset into the
> > > kernel, then do per-memcg dirty memory limiting and add some memcg
> > > awareness to writeback Greg Thelen and then when these things settle
> > > down, think how to solve this problem since noone really seem to have a
> > > good answer to it.
> > > 
> > > Having worked on linux filesystem/storage area for a few years now and
> > > having spent time understanding the various approaches tried and looked
> > > at other feasible way of solving this problem, I look forward to
> > > participate in the summit and discussions.
> > > 
> > > So, the topic I would like to discuss is solving the problem of
> > > "throttling buffered writes". This could considered for discussion with
> > > memcg writeback session if that topic has been allocated a slot.
> > > 
> > > I'm aware that this is a late submission and my apologies for not making
> > > it earlier. But, I want to take chances and see if it is possible still..
> > 
> > This is an interesting and complicated topic. As you mentioned we have had
> > tried to solve it but nothing has been merged yet. Personally, I am still
> > interested in having a discussion and see if we can come up with a way
> > forward.
> > 
> > Because filesystems are not cgroup aware, throtting IO below filesystem
> > has dangers of IO of faster cgroups being throttled behind slower cgroup
> > (journalling was one example and there could be others). Hence, I personally
> > think that this problem should be solved at higher layer and that is when
> > we are actually writting to the cache. That has the disadvantage of still
> > seeing IO spikes at the device but I guess we live with that. Doing it
> > at higher layer also allows to use the same logic for NFS too otherwise
> > NFS buffered write will continue to be a problem.
>   Well, I agree limiting of memory dirty rate has a value but if I look at
> a natural use case where I have several cgroups and I want to make sure
> disk time is fairly divided among them, then limiting dirty rate doesn't
> quite do what I need. Because I'm interested in time it takes disk to
> process the combination of reads, direct IO, and buffered writes the cgroup
> generates. Having the limits for dirty rate and other IO separate means I
> have to be rather pesimistic in setting the bounds so that combination of
> dirty rate + other IO limit doesn't exceed the desired bound but this is
> usually unnecessarily harsh...

Yeah it's quite possible some use cases may need to control read/write
respectively and others may want to simply limit the overall r/w
throughput or disk utilization.

It seems more a matter of interface rather than implementation.  If we
have code to limit the buffered/direct write bandwidth respectively,
it should also be able to limit the overall buffered+direct write
bandwidth or even read+write bandwidth.

However for the "overall" r+w limit interface to work, some implicit
rule of precedences or weight will be necessary, eg. read > DIRECT
write > buffered write, or read:DIRECT write:buffered write=10:10:1 or
whatever. Which the users may not totally agree.

In the end it looks there are always the distinguish of the main
SYNC/ASYNC and read/write I/O types and no chance to hide them from
the I/O controller interfaces. Then we might export interfaces to
allow the users to specify the overall I/O rate limit, the weights for
each type of I/O, the individual rate limits for each type of I/O,
etc. to the users' heart content.

> We agree though (as we spoke together last year) that throttling at block
> layer isn't really an option at least for some filesystems such as ext3/4.
> But what seemed like a plausible idea to me was that we'd account all IO
> including buffered writes at block layer (there we'd need at least

Account buffered write I/O when they reach the block layer? It sounds
too late.

> approximate tracking of originator of the IO - tracking inodes as Greg did
> in his patch set seemed OK) but throttle only direct IO & reads. Limitting
> of buffered writes would then be achieved by
>   a) having flusher thread choose inodes to write depending on how much
> available disk time cgroup has and

The flusher is fundamentally

- coarsely controllable due to the large write chunk size
- not controllable in the case of shared inodes

so any dirty size/rate limiting scheme based on controlling the
flusher behavior is not going to be an exact/reliable solution...

>   b) throttling buffered writers when cgroup has too many dirty pages.

That looks still be throttling at the balance_dirty_pages() level?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
