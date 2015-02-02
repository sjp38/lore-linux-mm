Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id C09926B0032
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 14:46:12 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id s11so32000425qcv.2
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 11:46:12 -0800 (PST)
Received: from mail-qa0-x22e.google.com (mail-qa0-x22e.google.com. [2607:f8b0:400d:c00::22e])
        by mx.google.com with ESMTPS id hs4si23843075qcb.18.2015.02.02.11.46.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 11:46:11 -0800 (PST)
Received: by mail-qa0-f46.google.com with SMTP id j7so30749882qaq.5
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 11:46:11 -0800 (PST)
Date: Mon, 2 Feb 2015 14:46:08 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <20150202194608.GA8169@htj.dyndns.org>
References: <20150130044324.GA25699@htj.dyndns.org>
 <xr93h9v8yfrv.fsf@gthelen.mtv.corp.google.com>
 <20150130062737.GB25699@htj.dyndns.org>
 <20150130160722.GA26111@htj.dyndns.org>
 <54CFCF74.6090400@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54CFCF74.6090400@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, hughd@google.com

Hey,

On Mon, Feb 02, 2015 at 10:26:44PM +0300, Konstantin Khlebnikov wrote:
> Removing memcg pointer from struct page might be tricky.
> It's not clear what to do with truncated pages: either link them
> with lru differently or remove from lru right at truncate.
> Swap cache pages have the same problem.

Hmmm... idk, maybe play another trick with low bits of page->mapping
and make it point to the cgroup after truncation?  Do we even care
tho?  Can't we just push them to the root and forget about them?  They
are pretty transient after all, no?

> Process of moving inodes from memcg to memcg is more or less doable.
> Possible solution: keep at inode two pointers to memcg "old" and "new".
> Each page will be accounted (and linked into corresponding lru) to one
> of them. Separation to "old" and "new" pages could be done by flag on
> struct page or by bordering page index stored in inode: pages where
> index < border are accounted to the new memcg, the rest to the old.

Yeah, pretty much the same scheme that the per-page cgroup writeback
is using with lower bits of page->mem_cgroup should work with the bits
moved to page->flags.

> Keeping shared inodes in common ancestor is reasonable.
> We could schedule asynchronous moving when somebody opens or mmaps
> inode from outside of its current cgroup. But it's not clear when
> inode should be moved into opposite direction: when inode should
> become private and how detect if it's no longer shared.
> 
> For example each inode could keep yet another pointer to memcg where
> it will track subtree of cgroups where it was accessed in past 5
> minutes or so. And sometimes that informations goes into moving thread.
> 
> Actually I don't see other options except that time-based estimation:
> tracking all cgroups for each inode is too expensive, moving pages
> from one lru to another is expensive too. So, moving inodes back and
> forth at each access from the outside world is not an option.
> That should be rare operation which runs in background or in reclaimer.

Right, what strategy to use for migration is up for debate, even for
moving to the common ancestor.  e.g. should we do that on the first
access?  In the other direction, it get more interesting.  Let's say
if we decide to move back an inode to a descendant, what if that
triggers OOM condition?  Do we still go through it and cause OOM in
the target?  Do we even want automatic moving in this direction?

For explicit cases, userland can do FADV_DONTNEED, I suppose.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
