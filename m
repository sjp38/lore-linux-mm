Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id C318E6B0092
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 18:30:52 -0500 (EST)
Received: by mail-vc0-f177.google.com with SMTP id hy4so17772772vcb.8
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 15:30:52 -0800 (PST)
Received: from mail-vc0-x233.google.com (mail-vc0-x233.google.com. [2607:f8b0:400c:c03::233])
        by mx.google.com with ESMTPS id k12si11945364vdj.96.2015.02.03.15.30.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 15:30:52 -0800 (PST)
Received: by mail-vc0-f179.google.com with SMTP id la4so17982268vcb.10
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 15:30:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150202194608.GA8169@htj.dyndns.org>
References: <20150130044324.GA25699@htj.dyndns.org> <xr93h9v8yfrv.fsf@gthelen.mtv.corp.google.com>
 <20150130062737.GB25699@htj.dyndns.org> <20150130160722.GA26111@htj.dyndns.org>
 <54CFCF74.6090400@yandex-team.ru> <20150202194608.GA8169@htj.dyndns.org>
From: Greg Thelen <gthelen@google.com>
Date: Tue, 3 Feb 2015 15:30:31 -0800
Message-ID: <CAHH2K0aSPjNgt30uJQa_6r=AXZso3SitjWOm96dtJF32CumZjQ@mail.gmail.com>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>

On Mon, Feb 2, 2015 at 11:46 AM, Tejun Heo <tj@kernel.org> wrote:
> Hey,
>
> On Mon, Feb 02, 2015 at 10:26:44PM +0300, Konstantin Khlebnikov wrote:
>
>> Keeping shared inodes in common ancestor is reasonable.
>> We could schedule asynchronous moving when somebody opens or mmaps
>> inode from outside of its current cgroup. But it's not clear when
>> inode should be moved into opposite direction: when inode should
>> become private and how detect if it's no longer shared.
>>
>> For example each inode could keep yet another pointer to memcg where
>> it will track subtree of cgroups where it was accessed in past 5
>> minutes or so. And sometimes that informations goes into moving thread.
>>
>> Actually I don't see other options except that time-based estimation:
>> tracking all cgroups for each inode is too expensive, moving pages
>> from one lru to another is expensive too. So, moving inodes back and
>> forth at each access from the outside world is not an option.
>> That should be rare operation which runs in background or in reclaimer.
>
> Right, what strategy to use for migration is up for debate, even for
> moving to the common ancestor.  e.g. should we do that on the first
> access?  In the other direction, it get more interesting.  Let's say
> if we decide to move back an inode to a descendant, what if that
> triggers OOM condition?  Do we still go through it and cause OOM in
> the target?  Do we even want automatic moving in this direction?
>
> For explicit cases, userland can do FADV_DONTNEED, I suppose.
>
> Thanks.
>
> --
> tejun

I don't have any killer objections, most of my worries are isolation concerns.

If a machine has several top level memcg trying to get some form of
isolation (using low, min, soft limit) then a shared libc will be
moved to the root memcg where it's not protected from global memory
pressure.  At least with the current per page accounting such shared
pages often land into some protected memcg.

If two cgroups collude they can use more memory than their limit and
oom the entire machine.  Admittedly the current per-page system isn't
perfect because deleting a memcg which contains mlocked memory
(referenced by a remote memcg) moves the mlocked memory to root
resulting in the same issue.  But I'd argue this is more likely with
the RFC because it doesn't involve the cgroup deletion/reparenting.  A
possible tweak to shore up the current system is to move such mlocked
pages to the memcg of the surviving locker.  When the machine is oom
it's often nice to examine memcg state to determine which container is
using the memory.  Tracking down who's contributing to a shared
container is non-trivial.

I actually have a set of patches which add a memcg=M mount option to
memory backed file systems.  I was planning on proposing them,
regardless of this RFC, and this discussion makes them even more
appealing.  If we go in this direction, then we'd need a similar
notion for disk based filesystems.  As Konstantin suggested, it'd be
really nice to specify charge policy on a per file, or directory, or
bind mount basis.  This allows shared files to be deterministically
charged to a known container.  We'd need to flesh out the policies:
e.g. if two bind mound each specify different charge targets for the
same inode, I guess we just pick one.  Though the nature of this
catch-all shared container is strange.  Presumably a machine manager
would need to create it as an unlimited container (or at least as big
as the sum of all shared files) so that any app which decided it wants
to mlock all shared files has a way to without ooming the shared
container.  In the current per-page approach it's possible to lock
shared libs.  But the machine manager would need to decide how much
system ram to set aside for this catch-all shared container.

When there's large incidental sharing, then things get sticky.  A
periodic filesystem scanner (e.g. virus scanner, or grep foo -r /) in
a small container would pull all pages to the root memcg where they
are exposed to root pressure which breaks isolation.  This is
concerning.  Perhaps the such accesses could be decorated with
(O_NO_MOVEMEM).

So this RFC change will introduce significant change to user space
machine managers and perturb isolation.  Is the resulting system
better?  It's not clear, it's the devil know vs devil unknown.  Maybe
it'd be easier if the memcg's I'm talking about were not allowed to
share page cache (aka copy-on-read) even for files which are jointly
visible.  That would provide today's interface while avoiding the
problematic sharing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
