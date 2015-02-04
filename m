Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 48F00900015
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 12:07:01 -0500 (EST)
Received: by mail-yk0-f171.google.com with SMTP id 10so1159437ykt.2
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 09:07:01 -0800 (PST)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com. [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id v129si614439ykv.170.2015.02.04.09.07.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 09:07:00 -0800 (PST)
Received: by mail-qg0-f45.google.com with SMTP id q107so2183808qgd.4
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 09:07:00 -0800 (PST)
Date: Wed, 4 Feb 2015 12:06:56 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <20150204170656.GA18858@htj.dyndns.org>
References: <20150130044324.GA25699@htj.dyndns.org>
 <xr93h9v8yfrv.fsf@gthelen.mtv.corp.google.com>
 <20150130062737.GB25699@htj.dyndns.org>
 <20150130160722.GA26111@htj.dyndns.org>
 <54CFCF74.6090400@yandex-team.ru>
 <20150202194608.GA8169@htj.dyndns.org>
 <CAHH2K0aSPjNgt30uJQa_6r=AXZso3SitjWOm96dtJF32CumZjQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHH2K0aSPjNgt30uJQa_6r=AXZso3SitjWOm96dtJF32CumZjQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>

Hello,

On Tue, Feb 03, 2015 at 03:30:31PM -0800, Greg Thelen wrote:
> If a machine has several top level memcg trying to get some form of
> isolation (using low, min, soft limit) then a shared libc will be
> moved to the root memcg where it's not protected from global memory
> pressure.  At least with the current per page accounting such shared
> pages often land into some protected memcg.

Yes, it becomes interesting with the low limit as the pressure
direction is reversed but at the same time overcommitting low limits
doesn't lead to a sane setup to begin with as it's asking for global
OOMs anyway, which means that things like libc would end up competing
at least fairly with other pages for global pressure and should stay
in memory under most circumstances, which may or may not be
sufficient.

Hmm.... need to think more about it but this only becomes a problem
with the root cgroup because it doesn't have min setting which is
expected to be inclusive of all descendants, right?  Maybe the right
thing to do here is treating the inodes which get pushed to the root
as a special case and we can implement a mechanism where the root is
effectively borrowing from the mins of its children which doesn't have
to be completely correct - e.g. just charge it against all children
repeatedly and if any has min protection, put it under min protection.
IOW, make it the baseload for all of them.

> If two cgroups collude they can use more memory than their limit and
> oom the entire machine.  Admittedly the current per-page system isn't
> perfect because deleting a memcg which contains mlocked memory
> (referenced by a remote memcg) moves the mlocked memory to root
> resulting in the same issue.  But I'd argue this is more likely with

Hmmm... why does it do that?  Can you point me to where it's
happening?

> the RFC because it doesn't involve the cgroup deletion/reparenting.  A

One approach could be expanding on the forementioned scheme and make
all sharing cgroups to get charged for the shared inodes they're
using, which should render such collusions entirely pointless.
e.g. let's say we start with the following.

	A   (usage=48M)
	+-B (usage=16M)
	\-C (usage=32M)

And let's say, C starts accessing an inode which is 8M and currently
associated with B.

	A   (usage=48M, hosted= 8M)
	+-B (usage= 8M, shared= 8M)
	\-C (usage=32M, shared= 8M)

The only extra charging that we'd be doing is charing C with extra
8M.  Let's say another cgroup D gets created and uses 4M.

	A   (usage=56M, hosted= 8M)
	+-B (usage= 8M, shared= 8M)
	+-C (usage=32M, shared= 8M)
	\-D (usage= 8M)

and it also accesses the inode.

	A   (usage=56M, hosted= 8M)
	+-B (usage= 8M, shared= 8M)
	+-C (usage=32M, shared= 8M)
	\-D (usage= 8M, shared= 8M)

We'd need to track the shared charges separately as they should count
only once in the parent but that shouldn't be too hard.  The problem
here is that we'd need to track which inodes are being accessed by
which children, which can get painful for things like libc.  Maybe we
can limit it to be level-by-level - track sharing only from the
immediate children and always move a shared inode at one level at a
time.  That would lose some ability to track the sharing beyond the
immediate children but it should be enough to solve the root case and
allow us to adapt to changing usage pattern over time.  Given that
sharing is mostly a corner case, this could be good enough.

Now, if D accesses 4M area of the inode which hasn't been accessed by
others yet.  We'd want it to look like the following.

	A   (usage=64M, hosted=16M)
	+-B (usage= 8M, shared=16M)
	+-C (usage=32M, shared=16M)
	\-D (usage= 8M, shared=16M)

But charging it to B, C at the same time prolly wouldn't be
particularly convenient.  We can prolly just do D -> A charging and
let B and C sort themselves out later.  Note that such charging would
still maintain the overall integrity of memory limits.  The only thing
which may overflow is the pseudo shared charges to keep sharing in
check and dealing with them later when B and C try to create further
charges should be completely fine.

Note that we can also try to split the shared charge across the users;
however, charging the full amount seems like the better approach to
me.  We don't have any way to tell how the usage is distributed
anyway.  For use cases where this sort of sharing is expected, I think
it's perfectly reasonable to provision the sharing children to have
enough to accomodate the possible full size of the shared resource.

> possible tweak to shore up the current system is to move such mlocked
> pages to the memcg of the surviving locker.  When the machine is oom
> it's often nice to examine memcg state to determine which container is
> using the memory.  Tracking down who's contributing to a shared
> container is non-trivial.
> 
> I actually have a set of patches which add a memcg=M mount option to
> memory backed file systems.  I was planning on proposing them,
> regardless of this RFC, and this discussion makes them even more
> appealing.  If we go in this direction, then we'd need a similar
> notion for disk based filesystems.  As Konstantin suggested, it'd be
> really nice to specify charge policy on a per file, or directory, or
> bind mount basis.  This allows shared files to be deterministically

I'm not too sure about that.  We might add that later if absolutely
justifiable but designing assuming that level of intervention from
userland may not be such a good idea.

> When there's large incidental sharing, then things get sticky.  A
> periodic filesystem scanner (e.g. virus scanner, or grep foo -r /) in
> a small container would pull all pages to the root memcg where they
> are exposed to root pressure which breaks isolation.  This is
> concerning.  Perhaps the such accesses could be decorated with
> (O_NO_MOVEMEM).

If such thing is really necessary, FADV_NOREUSE would be a better
indicator; however, yes, such incidental sharing is easier to handle
with per-page scheme as such scanner can be limited in the number of
pages it can carry throughout its operation regardless of which cgroup
it's looking at.  It still has the nasty corner case where random
target cgroups can latch onto pages faulted in by the scanner and
keeping accessing them tho, so, even now, FADV_NOREUSE would be a good
idea.  Note that such scanning, if repeated on cgroups under high
memory pressure, is *likely* to accumulate residue escaped pages and
if such a management cgroup is transient, those escaped pages will
accumulate over time outside any limit in a way which is unpredictable
and invisible.

> So this RFC change will introduce significant change to user space
> machine managers and perturb isolation.  Is the resulting system
> better?  It's not clear, it's the devil know vs devil unknown.  Maybe
> it'd be easier if the memcg's I'm talking about were not allowed to
> share page cache (aka copy-on-read) even for files which are jointly
> visible.  That would provide today's interface while avoiding the
> problematic sharing.

Yeah, compatibility would be the stickiest part.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
