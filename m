Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 47D386B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 23:43:28 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id s11so18998019qcv.5
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 20:43:28 -0800 (PST)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id v20si12972297qah.64.2015.01.29.20.43.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 20:43:27 -0800 (PST)
Received: by mail-qg0-f43.google.com with SMTP id e89so36736222qgf.2
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 20:43:27 -0800 (PST)
Date: Thu, 29 Jan 2015 23:43:24 -0500
From: Tejun Heo <tj@kernel.org>
Subject: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <20150130044324.GA25699@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, gthelen@google.com, hughd@google.com, Konstantin Khebnikov <khlebnikov@yandex-team.ru>

Hello,

Since the cgroup writeback patchset[1] have been posted, several
people brought up concerns about the complexity of allowing an inode
to be dirtied against multiple cgroups is necessary for the purpose of
writeback and it is true that a significant amount of complexity (note
that bdi still needs to be split, so it's still not trivial) can be
removed if we assume that an inode always belongs to one cgroup for
the purpose of writeback.

However, as mentioned before, this issue is directly linked to whether
memcg needs to track the memory ownership per-page.  If there are
valid use cases where the pages of an inode must be tracked to be
owned by different cgroups, cgroup writeback must be able to handle
that situation properly.  If there aren't no such cases, the cgroup
writeback support can be simplified but again we should put memcg on
the same cadence and enforce per-inode (or per-anon_vma) ownership
from the beginning.  The conclusion can be either way - per-page or
per-inode - but both memcg and blkcg must be looking at the same
picture.  Deviating them is highly likely to lead to long-term issues
forcing us to look at this again anyway, only with far more baggage.

One thing to note is that the per-page tracking which is currently
employed by memcg seems to have been born more out of conveninence
rather than requirements for any actual use cases.  Per-page ownership
makes sense iff pages of an inode have to be associated with different
cgroups - IOW, when an inode is accessed by multiple cgroups; however,
currently, memcg assigns a page to its instantiating memcg and leaves
it at that till the page is released.  This means that if a page is
instantiated by one cgroup and then subsequently accessed only by a
different cgroup, whether the page's charge gets moved to the cgroup
which is actively using it is purely incidental.  If the page gets
reclaimed and released at some point, it'll be moved.  If not, it
won't.

AFAICS, the only case where the current per-page accounting works
properly is when disjoint sections of an inode are used by different
cgroups and the whole thing hinges on whether this use case justifies
all the added overhead including page->mem_cgroup pointer and the
extra complexity in the writeback layer.  FWIW, I'm doubtful.
Johannes, Michal, Greg, what do you guys think?

If the above use case - a huge file being actively accssed disjointly
by multiple cgroups - isn't significant enough and there aren't other
use cases that I missed which can benefit from the per-page tracking
that's currently implemented, it'd be logical to switch to per-inode
(or per-anon_vma or per-slab) ownership tracking.  For the short term,
even just adding an extra ownership information to those containing
objects and inherting those to page->mem_cgroup could work although
it'd definitely be beneficial to eventually get rid of
page->mem_cgroup.

As with per-page, when the ownership terminates is debatable w/
per-inode tracking.  Also, supporting some form of shared accounting
across different cgroups may be useful (e.g. shared library's memory
being equally split among anyone who accesses it); however, these
aren't likely to be major and trying to do something smart may affect
other use cases adversely, so it'd probably be best to just keep it
dumb and clear the ownership when the inode loses all pages (a cgroup
can disown such inode through FADV_DONTNEED if necessary).

What do you guys think?  If making memcg track ownership at per-inode
level, even for just the unified hierarchy, is the direction we can
take, I'll go ahead and simplify the cgroup writeback patchset.

Thanks.

-- 
tejun

[1] http://lkml.kernel.org/g/1420579582-8516-1-git-send-email-tj@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
