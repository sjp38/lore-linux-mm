Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0AB8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 17:17:20 -0500 (EST)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p22M0ZaC001960
	for <linux-mm@kvack.org>; Wed, 2 Mar 2011 14:00:35 -0800
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by hpaq2.eem.corp.google.com with ESMTP id p22M0UuX001257
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 2 Mar 2011 14:00:33 -0800
Received: by qwc9 with SMTP id 9so544111qwc.40
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 14:00:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110302132830.GB2061@linux.develer.com>
References: <1298888105-3778-1-git-send-email-arighi@develer.com>
 <20110228230114.GB20845@redhat.com> <20110302132830.GB2061@linux.develer.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 2 Mar 2011 14:00:10 -0800
Message-ID: <AANLkTin1H2Xip=S1W2_Eh0Y153adsP2s9fSr+WDYqax=@mail.gmail.com>
Subject: Re: [PATCH 0/3] blk-throttle: async write throttling
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <arighi@develer.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 2, 2011 at 5:28 AM, Andrea Righi <arighi@develer.com> wrote:
> On Mon, Feb 28, 2011 at 06:01:14PM -0500, Vivek Goyal wrote:
>> On Mon, Feb 28, 2011 at 11:15:02AM +0100, Andrea Righi wrote:
>> > Overview
>> > =3D=3D=3D=3D=3D=3D=3D=3D
>> > Currently the blkio.throttle controller only support synchronous IO re=
quests.
>> > This means that we always look at the current task to identify the "ow=
ner" of
>> > each IO request.
>> >
>> > However dirty pages in the page cache can be wrote to disk asynchronou=
sly by
>> > the per-bdi flusher kernel threads or by any other thread in the syste=
m,
>> > according to the writeback policy.
>> >
>> > For this reason the real writes to the underlying block devices may
>> > occur in a different IO context respect to the task that originally
>> > generated the dirty pages involved in the IO operation. This makes the
>> > tracking and throttling of writeback IO more complicate respect to the
>> > synchronous IO from the blkio controller's perspective.
>> >
>> > Proposed solution
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > In the previous patch set http://lwn.net/Articles/429292/ I proposed t=
o resolve
>> > the problem of the buffered writes limitation by tracking the ownershi=
p of all
>> > the dirty pages in the system.
>> >
>> > This would allow to always identify the owner of each IO operation at =
the block
>> > layer and apply the appropriate throttling policy implemented by the
>> > blkio.throttle controller.
>> >
>> > This solution makes the blkio.throttle controller to work as expected =
also for
>> > writeback IO, but it does not resolve the problem of faster cgroups ge=
tting
>> > blocked by slower cgroups (that would expose a potential way to create=
 DoS in
>> > the system).
>> >
>> > In fact, at the moment critical IO requests (that have dependency with=
 other IO
>> > requests made by other cgroups) and non-critical requests are mixed to=
gether at
>> > the filesystem layer in a way that throttling a single write request m=
ay stop
>> > also other requests in the system, and at the block layer it's not pos=
sible to
>> > retrieve such informations to make the right decision.
>> >
>> > A simple solution to this problem could be to just limit the rate of a=
sync
>> > writes at the time a task is generating dirty pages in the page cache.=
 The
>> > big advantage of this approach is that it does not need the overhead o=
f
>> > tracking the ownership of the dirty pages, because in this way from th=
e blkio
>> > controller perspective all the IO operations will happen from the proc=
ess
>> > context: writes in memory and synchronous reads from the block device.
>> >
>> > The drawback of this approach is that the blkio.throttle controller be=
comes a
>> > little bit leaky, because with this solution the controller is still a=
ffected
>> > by the IO spikes during the writeback of dirty pages executed by the k=
ernel
>> > threads.
>> >
>> > Probably an even better approach would be to introduce the tracking of=
 the
>> > dirty page ownership to properly account the cost of each IO operation=
 at the
>> > block layer and apply the throttling of async writes in memory only wh=
en IO
>> > limits are exceeded.
>>
>> Andrea, I am curious to know more about it third option. Can you give mo=
re
>> details about accouting in block layer but throttling in memory. So say
>> a process starts IO, then it will still be in throttle limits at block
>> layer (because no writeback has started), then the process will write
>> bunch of pages in cache. By the time throttle limits are crossed at
>> block layer, we already have lots of dirty data in page cache and
>> throttling process now is already late?
>
> Charging the cost of each IO operation at the block layer would allow
> tasks to write in memory at the maximum speed. Instead, with the 3rd
> approach, tasks are forced to write in memory at the rate defined by the
> blkio.throttle.write_*_device (or blkio.throttle.async.write_*_device).
>
> When we'll have the per-cgroup dirty memory accounting and limiting
> feature, with this approach each cgroup could write to its dirty memory
> quota at the maximum rate.
>
> BTW, another thing that we probably need is that any cgroup should be
> forced to write their own inodes when the limit defined by dirty_ratio
> is exceeded. I mean, avoid to select inodes from the list of dirty
> inodes in a FIFO way, but provides a better logic to "assign" the
> ownership of each inode to a cgroup (maybe that one that had generated
> most of the dirty pages in the inodes) and use for example a list of
> dirty inodes per cgroup or something similar.
>
> In this way we should really be able to provide a good quality of
> service for the most part of the cases IMHO.
>
> I also plan to write down another patch set to implement this logic.

I have also been thinking about this problem.  I had assumed that the
per-bdi inode list would be retained, but a memcg_inode filter
function would be used to determine which dirty inodes contribute any
dirty pages to the over-dirty-limit memcg.

To efficiently determine if an inode contributes dirty pages to a
memcg, I was thinking about implementing a shallow memcg identifier
cache within the inode's address space.  Here is a summary of what I
am thinking about:

This approach adds an N deep cache of dirtying cgroups into struct
address_space.  N would likely be 1.  Each address_space would have an
array of N as_memcg identifiers and an as_memcg_overflow bit.  The
memcg identifier may be a memcg pointer or a small integer (maybe
css_id).   Unset cache entries would be NULL if using pointers, 0 if
using css_id (an illegal css_id value).  The memcg identifier would
not be dereferenced - it would only be used as a fuzzy comparison
value.  So a reference to the memcg is not needed.  Modifications to
as_memcg[] and as_memcg_overflow are protected by the mapping
tree_lock.

The kernel integration with this approach involves:

1. When an address_space created in inode_init_always():
1.1 Set as_memcg[*]=3DNULL and as_memcg_overflow=3D0.

2. When a mapping page is dirtied in __set_page_dirty():
2.1 The tree lock is already held
2.2 If any of as_memcg[*] =3D=3D current_memcg, then do nothing.  The
dirtying memcg is already associated with the address space.
2.3 If any of as_memcg[x] is NULL, then set as_memcg[x] =3D
current_memcg.  This associates the dirtying memcg with the address
space.
2.4 Otherwise, set as_memcg_overflow=3D1 indicating that more than N
memcg have dirtied the address space since it was last cleaned.

3. When an inode is completely clean - this is a case within
writeback_single_inode():
3.1 Grab the tree_lock
3.2 Set as_memcg[*]=3DNULL and as_memcg_overflow=3D0.  These are the same
steps as inode creation.
3.3 Release the tree_lock

4. When per-cgroup inode writeback is performed, walk the list of
dirty inodes only matching inodes contributing dirty pages to
cmp_memcg.  For each dirty inode:
4.1 Tree locking is not needed here.  Races are allowed.
4.2 If as_memcg_overflow is set, then schedule inode for writeback.
Assume it contains dirty pages for cmp_memcg.  This is the case where
there are more than N memcg that have dirtied the address space since
it was completely clean.
4.3 If any of as_memcg[*] =3D=3D cmp_memcg, then schedule the inode for wri=
teback.
4.4 Otherwise, do not schedule the inode for writeback because the
current memcg has not contributed dirty pages to the inode.

Weaknesses:

1. If the N deep cache is not sufficiently large then inodes will be
written back more than is ideal.  Example: if more than N cgroups are
dirty an inode, then as_memcg_overflow is set and remains set until
the inode is fully clean.  Until the inode is fully cleaned, any
per-memcg writeback will writeback the inode.  This will unfairly
affect writeback of cgroups that have never touched or dirtied the
overflowing inode.  If this is a significant problem, then increasing
the value of N will solve the problem.  Theoretically each inode, or
filesystem could have a different value of N.  But the preferred
implementation has a compile time constant value of N.

2. If any cgroup continually dirties an inode, then no other cgroups
that have ever dirtied the inode will ever be expired from the N deep
as_memcg[] cache because the "when an inode is completely clean" logic
is never run.  If the past set of dirtying cgroups is greater than N,
then every cgroup writeback will writeback the inode.  If this is a
problem, then a dirty_page counter could be added to each as_memcg[]
record to keep track of the number of dirty pages each memcg
contributes to an inode.  When the per-memcg count reaches zero then
the particular as_memcg entry could be removed.  This would allow for
memcg expiration from as_memcg[] before the inode becomes completely
clean.

3. There is no way to cheaply identify the set of inodes contributing
dirty pages to a memcg that has exceeded its dirty memory limit.  When
a memcg blows its limit, what list of dirty inodes is traversed?  The
bdi that was last being written to which, in the worst case, will have
very little dirty data from the current memcg.  If this is an issue,
we could walk all bdi looking for inodes that contribute dirty pages
to the over-limit memcg.

>> > To summarize, we can identify three possible solutions to properly thr=
ottle the
>> > buffered writes:
>> >
>> > 1) account & throttle everything at block IO layer (bad for "priority
>> > =A0 =A0inversion" problems, needs page tracking for blkio)
>> >
>> > 2) account at block IO layer and throttle in memory (needs page tracki=
ng for
>> > =A0 =A0blkio)
>> >
>> > 3) account & throttle in memory (affected by IO spikes, depending on
>> > =A0 =A0dirty_ratio / dirty_background_ratio settings)
>> >
>> > For now we start with the solution 3) that seems to be the simplest wa=
y to
>> > proceed.
>>
>> Yes, IO spikes is the weakness of this 3rd solution. But it should be
>> simple too. Also as you said problem can be reduced up to some extent
>> by changing reducing dirty_ratio and background dirty ratio But that
>> will have other trade offs, I guess.
>
> Agreed.
>
> -Andrea
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
