Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3DD006B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 00:55:58 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id a13so976580igq.0
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 21:55:58 -0800 (PST)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com. [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id n67si821162ioi.107.2015.01.29.21.55.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 21:55:57 -0800 (PST)
Received: by mail-ie0-f178.google.com with SMTP id rp18so1342197iec.9
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 21:55:57 -0800 (PST)
References: <20150130044324.GA25699@htj.dyndns.org>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <xr93h9v8yfrv.fsf@gthelen.mtv.corp.google.com>
In-reply-to: <20150130044324.GA25699@htj.dyndns.org>
Date: Thu, 29 Jan 2015 21:55:53 -0800
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, hughd@google.com, Konstantin Khebnikov <khlebnikov@yandex-team.ru>


On Thu, Jan 29 2015, Tejun Heo wrote:

> Hello,
>
> Since the cgroup writeback patchset[1] have been posted, several
> people brought up concerns about the complexity of allowing an inode
> to be dirtied against multiple cgroups is necessary for the purpose of
> writeback and it is true that a significant amount of complexity (note
> that bdi still needs to be split, so it's still not trivial) can be
> removed if we assume that an inode always belongs to one cgroup for
> the purpose of writeback.
>
> However, as mentioned before, this issue is directly linked to whether
> memcg needs to track the memory ownership per-page.  If there are
> valid use cases where the pages of an inode must be tracked to be
> owned by different cgroups, cgroup writeback must be able to handle
> that situation properly.  If there aren't no such cases, the cgroup
> writeback support can be simplified but again we should put memcg on
> the same cadence and enforce per-inode (or per-anon_vma) ownership
> from the beginning.  The conclusion can be either way - per-page or
> per-inode - but both memcg and blkcg must be looking at the same
> picture.  Deviating them is highly likely to lead to long-term issues
> forcing us to look at this again anyway, only with far more baggage.
>
> One thing to note is that the per-page tracking which is currently
> employed by memcg seems to have been born more out of conveninence
> rather than requirements for any actual use cases.  Per-page ownership
> makes sense iff pages of an inode have to be associated with different
> cgroups - IOW, when an inode is accessed by multiple cgroups; however,
> currently, memcg assigns a page to its instantiating memcg and leaves
> it at that till the page is released.  This means that if a page is
> instantiated by one cgroup and then subsequently accessed only by a
> different cgroup, whether the page's charge gets moved to the cgroup
> which is actively using it is purely incidental.  If the page gets
> reclaimed and released at some point, it'll be moved.  If not, it
> won't.
>
> AFAICS, the only case where the current per-page accounting works
> properly is when disjoint sections of an inode are used by different
> cgroups and the whole thing hinges on whether this use case justifies
> all the added overhead including page->mem_cgroup pointer and the
> extra complexity in the writeback layer.  FWIW, I'm doubtful.
> Johannes, Michal, Greg, what do you guys think?
>
> If the above use case - a huge file being actively accssed disjointly
> by multiple cgroups - isn't significant enough and there aren't other
> use cases that I missed which can benefit from the per-page tracking
> that's currently implemented, it'd be logical to switch to per-inode
> (or per-anon_vma or per-slab) ownership tracking.  For the short term,
> even just adding an extra ownership information to those containing
> objects and inherting those to page->mem_cgroup could work although
> it'd definitely be beneficial to eventually get rid of
> page->mem_cgroup.
>
> As with per-page, when the ownership terminates is debatable w/
> per-inode tracking.  Also, supporting some form of shared accounting
> across different cgroups may be useful (e.g. shared library's memory
> being equally split among anyone who accesses it); however, these
> aren't likely to be major and trying to do something smart may affect
> other use cases adversely, so it'd probably be best to just keep it
> dumb and clear the ownership when the inode loses all pages (a cgroup
> can disown such inode through FADV_DONTNEED if necessary).
>
> What do you guys think?  If making memcg track ownership at per-inode
> level, even for just the unified hierarchy, is the direction we can
> take, I'll go ahead and simplify the cgroup writeback patchset.
>
> Thanks.

I find simplification appealing.  But I not sure it will fly, if for no
other reason than the shared accountings.  I'm ignoring intentional
sharing, used by carefully crafted apps, and just thinking about
incidental sharing (e.g. libc).

Example:

$ mkdir small
$ echo 1M > small/memory.limit_in_bytes
$ (echo $BASHPID > small/cgroup.procs && exec sleep 1h) &

$ mkdir big
$ echo 10G > big/memory.limit_in_bytes
$ (echo $BASHPID > big/cgroup.procs && exec mlockall_database 1h) &


Assuming big/mlockall_database mlocks all of libc, then it will oom kill
the small memcg because libc is owned by small due it having touched it
first.  It'd be hard to figure out what small did wrong to deserve the
oom kill.

FWIW we've been using memcg writeback where inodes have a memcg
writeback owner.  Once multiple memcg write to an inode then the inode
becomes writeback shared which makes it more likely to be written.  Once
cleaned the inode is then again able to be privately owned:
https://lkml.org/lkml/2011/8/17/200

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
