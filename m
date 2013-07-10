Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id CB14D6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 02:03:33 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id eg20so5373430lab.5
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 23:03:32 -0700 (PDT)
Message-ID: <51DCF92F.6090409@openvz.org>
Date: Wed, 10 Jul 2013 10:03:27 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
References: <20130708095928.14058.26736.stgit@zurg> <CAFj3OHVtVGDnWHqNBRZH+LNtzDrbk8PO0fKLwFscZAWCJRW9oA@mail.gmail.com>
In-Reply-To: <CAFj3OHVtVGDnWHqNBRZH+LNtzDrbk8PO0fKLwFscZAWCJRW9oA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Vivek Goyal <vgoyal@redhat.com>, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>, "devel@openvz.org" <devel@openvz.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

Sha Zhengju wrote:
> Hi,
>
> On Mon, Jul 8, 2013 at 5:59 PM, Konstantin Khlebnikov
> <khlebnikov@openvz.org>  wrote:
>> >  This is proof of concept, just basic functionality for IO controller.
>> >  This cgroup will control filesystem usage on vfs layer, it's main goal is
>> >  bandwidth control. It's supposed to be much more lightweight than memcg/blkio.
>> >
>> >  This patch shows easy way for accounting pages in dirty/writeback state in
>> >  per-inode manner. This is easier that doing this in memcg in per-page manner.
>> >  Main idea is in keeping on each inode pointer (->i_fsio) to cgroup which owns
>> >  dirty data in that inode. It's settled by fsio_account_page_dirtied() when
>> >  first dirty tag appears in the inode. Relying to mapping tags gives us locking
>> >  for free, this patch doesn't add any new locks to hot paths.
> While referring to dirty/writeback numbers, what I care about is 'how
> many dirties in how many memory' and later may use the proportion to
> decide throttling or something else. So if you are talking about nr of
> dirty pages without memcg's amount of memory, I don't see the meaning
> of a single number.

I'm planning to add some thresholds or limits to fsio cgroup -- how many dirty pages
this cgroup may have. memcg is completely different thing: memcg controls data storage
while fsio controls data flows. Memcg already handles too much, I just don't want add
yet another unrelated stuff into it. Otherwise we will end with one single controller
which would handle all possible resources, because they all related in some cases.

>
> What's more, counting dirty/writeback stats in per-node manner can
> bring inaccuracy in some situations: considering two tasks from
> different fsio cgroups are dirtying one file concurrently but may only
> be counting in one fsio stats, or a task is moved to another fsio
> cgroup after dirtrying one file. As talking about task moving, it is
> the root cause of adding memcg locks in page stat routines, since
> there's a race window between 'modify cgroup owner' and 'update stats
> using cgroup pointer'. But if you are going to handle task move or
> take care of ->i_fsio for better accuracy in future, I'm afraid you
> will also need some synchronization mechanism in hot paths. Maybe also
> a new lock or mapping->tree_lock(which is already hot enough) IMHO.

Yes, per-inode accounting is less accurate. But this approach works really
well in the real life. I don't want add new locks and loose performance just
to fix accuracy for some artificial cases.

to Tejun:
BTW I don't like that volatility of task's cgroup ponters. I'd like to forbid
moving tasks between cgroups except for 'current', existing behavior can be
kept with help of task_work: instead external change of task->cgroups we can
schedule task_work into it in and change that pointer in the 'current' context.
That will save us a lot of rcu_lock/unlock and atomic operations in grabbing
temporary pointers to current cgroup because current->cgroups will be stable.
I don't think that external cross-cgroup task migration is really performance
critical. Currently I don't know what to do with kernel threads and workqueues,
but any way this problem doesn't look unsolvable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
