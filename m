Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id ED2926B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 05:52:26 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id k9so7226994iok.4
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 02:52:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u11sor1012308itc.60.2017.11.03.02.52.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Nov 2017 02:52:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171103082417.7rwns74txzzoyzyv@dhcp22.suse.cz>
References: <20171102093613.3616-1-mhocko@kernel.org> <20171102093613.3616-2-mhocko@kernel.org>
 <alpine.LSU.2.11.1711030004260.4821@eggly.anvils> <20171103082417.7rwns74txzzoyzyv@dhcp22.suse.cz>
From: David Herrmann <dh.herrmann@gmail.com>
Date: Fri, 3 Nov 2017 10:52:24 +0100
Message-ID: <CANq1E4QZFaj41ZisjotrpcjLHJzQQrGcrGTZ0RJg=odJKnnVJw@mail.gmail.com>
Subject: Re: [PATCH 1/2] shmem: drop lru_add_drain_all from shmem_wait_for_pins
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>

Hi

On Fri, Nov 3, 2017 at 9:24 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 03-11-17 00:46:18, Hugh Dickins wrote:
>> On Thu, 2 Nov 2017, Michal Hocko wrote:
>> > From: Michal Hocko <mhocko@suse.com>
>> >
>> > syzkaller has reported the following lockdep splat
>> > ======================================================
>> > WARNING: possible circular locking dependency detected
>> > 4.13.0-next-20170911+ #19 Not tainted
>> > ------------------------------------------------------
>> > syz-executor5/6914 is trying to acquire lock:
>> >   (cpu_hotplug_lock.rw_sem){++++}, at: [<ffffffff818c1b3e>] get_online_cpus  include/linux/cpu.h:126 [inline]
>> >   (cpu_hotplug_lock.rw_sem){++++}, at: [<ffffffff818c1b3e>] lru_add_drain_all+0xe/0x20 mm/swap.c:729
>> >
>> > but task is already holding lock:
>> >   (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff818fbef7>] inode_lock include/linux/fs.h:712 [inline]
>> >   (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff818fbef7>] shmem_add_seals+0x197/0x1060 mm/shmem.c:2768
>> >
>> > more details [1] and dependencies explained [2]. The problem seems to be
>> > the usage of lru_add_drain_all from shmem_wait_for_pins. While the lock
>> > dependency is subtle as hell and we might want to make lru_add_drain_all
>> > less dependent on the hotplug locks the usage of lru_add_drain_all seems
>> > dubious here. The whole function cares only about radix tree tags, page
>> > count and page mapcount. None of those are touched from the draining
>> > context. So it doesn't make much sense to drain pcp caches. Moreover
>> > this looks like a wrong thing to do because it basically induces
>> > unpredictable latency to the call because draining is not for free
>> > (especially on larger machines with many cpus).
>> >
>> > Let's simply drop the call to lru_add_drain_all to address both issues.
>> >
>> > [1] http://lkml.kernel.org/r/089e0825eec8955c1f055c83d476@google.com
>> > [2] http://lkml.kernel.org/r/http://lkml.kernel.org/r/20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net
>> >
>> > Cc: David Herrmann <dh.herrmann@gmail.com>
>> > Cc: Hugh Dickins <hughd@google.com>
>> > Signed-off-by: Michal Hocko <mhocko@suse.com>
>>
>> NAK.  shmem_wait_for_pins() is waiting for temporary pins on the pages
>> to go away, and using lru_add_drain_all() in the usual way, to lower
>> the refcount of pages temporarily pinned in a pagevec somewhere.  Page
>> count is touched by draining pagevecs: I'm surprised to see you say
>> that it isn't - or have pagevec page references been eliminated by
>> a recent commit that I missed?
>
> I must be missing something here. __pagevec_lru_add_fn merely about
> moving the page into the appropriate LRU list, pagevec_move_tail only
> rotates, lru_deactivate_file_fn moves from active to inactive LRUs,
> lru_lazyfree_fn moves from anon to file LRUs and activate_page_drain
> just moves to the active list. None of those operations touch the page
> count AFAICS. So I would agree that some pages might be pinned outside
> of the LRU (lru_add_pvec) and thus unreclaimable but does this really
> matter. Or what else I am missing?

Yes, we need to make sure those page-pins are dropped.
shmem_wait_for_pins() literally just waits for all those to be
cleared, since there is no way to tell whether a page is still
inflight for some pending async WRITE operation. Hence, if the
pagevecs keep pinning those pages, we must fail the shmem-seal
operation, as we cannot guarantee there are no further WRITEs to this
file. The refcount is our only way to tell.

I think the caller could just call lru_add_drain_all() between
mapping_deny_writable() and shmem_wait_for_pins(), releasing the
inode-lock in between. But that means we drain it even if
shmem_tag_pins() does not find anything (presumably the common case).
It would also have weird interactions with parallel inode-operations,
in case the seal-operation fails and is reverted. Not sure I like
that.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
