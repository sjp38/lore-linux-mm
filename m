Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3C17A6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 09:25:04 -0500 (EST)
Received: by mail-la0-f43.google.com with SMTP id q1so3787558lam.2
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 06:25:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gh9si4300794wib.92.2015.01.16.06.25.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 06:25:02 -0800 (PST)
Date: Fri, 16 Jan 2015 15:25:01 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCHSET RFC 0/6] memcg: inode-based dirty-set controller
Message-ID: <20150116142501.GI25884@quack.suse.cz>
References: <20150115180242.10450.92.stgit@buzz>
 <20150116093734.GD25884@quack.suse.cz>
 <CALYGNiPrA1D+i+8gvMXZwAR++h7z5QLg2LkDr+zJiYNwoXkGbg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiPrA1D+i+8gvMXZwAR++h7z5QLg2LkDr+zJiYNwoXkGbg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Konstantin Khebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, Roman Gushchin <klamm@yandex-team.ru>, Dave Chinner <david@fromorbit.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri 16-01-15 15:33:48, Konstantin Khlebnikov wrote:
> On Fri, Jan 16, 2015 at 12:37 PM, Jan Kara <jack@suse.cz> wrote:
> >   Hello,
> >
> > On Thu 15-01-15 21:49:10, Konstantin Khebnikov wrote:
> >> This is ressurection of my old RFC patch for dirty-set accounting cgroup [1]
> >> Now it's merged into memory cgroup and got bandwidth controller as a bonus.
> >>
> >> That shows alternative solution: less accurate but much less monstrous than
> >> accurate page-based dirty-set controller from Tejun Heo.
> >>
> >> Memory overhead: +1 pointer into struct address_space.
> >> Perfomance overhead is almost zero, no new locks added.
> >>
> >> Idea is stright forward: link each inode to some cgroup when first dirty
> >> page appers and account all dirty pages to it. Writeback is implemented
> >> as single per-bdi writeback work which writes only inodes which belong
> >> to memory cgroups where amount of dirty memory is beyond thresholds.
> >>
> >> Third patch adds trick for handling shared inodes which have dirty pages
> >> from several cgroups: it marks whole inode as shared and alters writeback
> >> filter for it.
> >>
> >> The rest is an example of bandwith and iops controller build on top of that.
> >> Design is completely original, I bet nobody ever used task-works for that =)
> >   So I like the simplicity of your code but there are a few downsides too
> > (please correct me if I've got something wrong - btw the documentation of
> > high-level design would be welcome so that one doesn't have to understand
> > that from the patches):
> 
> Rate-limiting design uses per-task delay injection when controller sees
> that this task or cgroup have done too much IO. This is similar to
> balance_dirty_pages but this approach extends this logic to any kind of
> IO and doesn't require special point where task checks balance because
> delay ejected in task-work which runs when task returns into userspace.
> 
> > 1) The bandwidth controller simply accounts number of bytes submitted for
> > IO in submit_bio().  This doesn't reflect HW capabilities in any way. There
> > a huge difference between a process submitting single block random IO and a
> > process doing the same amount of sequential IO. This could be somewhat
> > dealt with by not accounting number of bytes but rather time it took to
> > complete a bio (but that somewhat complicates the code and block layer
> > already does similar counting so it would be good you used that).
> 
> Yes, it is. But completion time works accurately only for simple disks
> with single depth queue. For disk with NCQ completion time often have no
> relation to actual complexity of requests.
  Well, in the same way I could say that the number bytes submitted has
often no relation to the actual complexity of requests. :) But the fact
that there are more IO requests running in parallel is the reason why blkcg
code allows only requests from a single blkcg to run in the HW so that we
know to whom the time should be accounted. Of course, this means a
non-trivial overhead when switching between time slices for different
blkcgs so total system throughput is affected. So either approach has its
pros and cons.

> We could use it as third metric in addition to bandwidth and iops or
> combine all of them into some abstract disk utilization, anyway splitting
> accounting and scheduling phases gives more flexibility.
  Yes, I agree that splitting accounting and scheduling of pauses gives
more flexibility.

> > 2) The controller accounts bio to current task - that makes the limiting
> > useless for background writeback. You need to somehow propagate i_memcg
> > into submit_bio() so that IO is properly accounted.
> 
> It would be nice to get information about randomness of issued writeback
> but I think propagation disk bandwidth limit and especially iops limit
> into writeback is almost useless, we must ratelimit task which generates
> data flow before it generations next bunch of dirty memory.
  I think we misunderstand here. The point I was trying to make was that
I don't see how accounting of writes works with your patches. But after
reading your patches again I have notice that you end up inserting delay
from balance_dirty_pages() which is the point I originally missed.

> In some cases it's possible to slowdown writeback but journalled
> filesystems often require write everything to close transaction.
  Well, yes, that's a concern mostly for metadata (which e.g. Tejun keeps
unaccounted) but ext4 can have this problem for data in some cases as well.

> > 3) The controller doesn't seem to guarantee any quality of service at the
> > IO level like blkcg does. The controller limits amount of IO userspace is
> > able to submit to kernel but only after we decide to submit the IO to disk.
> > So at that time cgroup may have generated lots of IO - e.g. by dirtying lots
> > of pages - and there's nothing to protect other cgroups from starvation
> > because of writeback of these pages.
> >
> > Especially the last point seems to be essential to your approach (although
> > you could somewhat mitigate the issue by accounting the IO already when
> > it is entering the kernel) and I'm not sure whether that's really
> > acceptable for potential users of this feature.
> 
> I try to limit amount of dirty memory and speed of generation new dirty
> pages after crossing threshold. Probably it's also possible to limit
> speed of switching pages from "dirty" to "towrite" state. Thus memcg
> could have a lot of dirty pages but couldn't trigger immediate writeback
> for all of them.
  Well, with your way of throttling there's also a possibility to submit
e.g. a large batch of AIO reads or AIO writes and the process will get
blocked only after all the IO is submitted and the system is hogged. So
IMHO it's hard to guarantee anything in the small scale with your patches.

> I think it's possible to build solid io scheduler using that approach:
> this controller proves only single static limits for bandwidth and iops,
> but they might be balanced automatically depending on disk speed and
> estimated load.
  
								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
