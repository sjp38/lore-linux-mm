Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3064B6B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 11:33:38 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so108693356pad.2
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 08:33:38 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id cw8si18844524pad.134.2016.07.29.08.33.37
        for <linux-mm@kvack.org>;
        Fri, 29 Jul 2016 08:33:37 -0700 (PDT)
Subject: Re: [PATCH 0/3] new feature: monitoring page cache events
References: <cover.1469489884.git.gamvrosi@gmail.com>
 <579A72F5.10808@intel.com> <20160729034745.GA10234@leftwich>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <579B774E.10309@intel.com>
Date: Fri, 29 Jul 2016 08:33:34 -0700
MIME-Version: 1.0
In-Reply-To: <20160729034745.GA10234@leftwich>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Amvrosiadis <gamvrosi@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 07/28/2016 08:47 PM, George Amvrosiadis wrote:
> On Thu, Jul 28, 2016 at 02:02:45PM -0700, Dave Hansen wrote:
>> On 07/25/2016 08:47 PM, George Amvrosiadis wrote:
>>>  21 files changed, 2424 insertions(+), 1 deletion(-)
>>
>> I like the idea, but yikes, that's a lot of code.
>>
>> Have you considered using or augmenting the kernel's existing tracing
>> mechanisms?  Have you considered using something like netlink for
>> transporting the data out of the kernel?
> 
> We contemplated a couple other solutions. One was extending existing debugging
> mechanisms. E.g., there are already tracepoints at __add_to_page_cache_locked()
> and __delete_from_page_cache(). A consistent reaction I got for doing that,
> however, was that of exposing an unruly interface to user applications, which
> is certainly not an elegant solution.

What's to stop you from using tracing to gather and transport data out
of the kernel and then aggregate and present it to apps in an "elegant"
way of your choosing?

>> The PageDirty() hooks look simple but turn out to be horribly deep.
>> Where we used to have a plain old bit set, we now have new locks,
>> potentially long periods of irq disabling, and loops over all the tasks
>> doing duet, even path lookup!
> 
> It's true that the hooks are deep, but they are fully exercised only once per
> inode, per task. The reasoning behind the 'struct bmap_rbnode'->seen bitmap is
> to remember whether an inode was seen before by a given task. During that first
> access is when we do the path lookup to decide whether this inode is relevant
> to the task and mark 'struct bmap_rbnode'->relv accordingly. If it is not, we
> ignore future events from it. Tasks can also use the 'structu bmap_rbnode'->done
> bitmap to indicate that they are done with a specific inode, which also stops
> those events from passing that task loop.

OK, but it still disables interrupts and takes a spinlock for each
bitmap it checks.  That spinlock becomes essentially a global lock in a
hot path, which can't be good.

>> Given a big system, I would imagine these locks slowing down
>> SetPageDirty() and things like write() pretty severely.  Have you done
>> an assessment of the performance impact of this change?   I can't
>> imagine this being used in any kind of performance or
>> scalability-sensitive environment.
> 
> I have used filebench to saturate an HDD and an SSD, registered a task to be
> notified about every file in the filesystem, and measured no difference in I/O
> throughput. To measure the CPU utilization of Duet, I tried an extreme case
> where I booted using only one core and again saturated an HDD using filebench.
> There was a 1-1.5% increase in CPU utilization. There is a description of this
> result in the paper. I have also tuned filebench to hit the cache often in my
> experiments (more than 60-70% of accesses going to less than 10% of the data),
> but the results were similar. For the Hadoop and Spark experiments we used a
> 24-node cluster and these overhead numbers didn't seem to affect performance.

I'd say testing with _more_ cores is important, not less.  How about
trying to watch a single file, then have one process per core writing to
a 1MB file in a loop.  What does that do?  Or, heck, just compile a
kernel on a modern 2-socket system.

In any case, I still can't see the current duet _model_ ever working
out, much less the implementation posted here.

>> The current tracing code has a model where the trace producers put data
>> in *one* place, then all the mulitple consumers pull it out of that
>> place.  Duet seems to have the model that the producer puts the data in
>> multiple places and consumers consume it from their own private copies.
>>  That seems a bit backwards and puts cost directly in to hot code paths.
>>  Even a single task watching a single file on the system makes everyone
>> go in and pay some of this cost for every SetPageDirty().
> 
> Duet operates in a similar way. There is one large global hash table to avoid
> collisions, so that on average a single lookup is sufficient to place a page in
> it. Due to its global nature, if a page is of interest to multiple tasks, only
> one entry is used to hold the events for that page across all tasks. And to
> avoid walking that hash table for relevant events on a read(), each task
> maintains a separate bitmap of the hash table's buckets that tells it which
> buckets to look into. (In the past I've also tried a work queue approach on the
> hot code path, but the overhead was almost double as a result of allocating the
> work queue items.)

I don't think Duet operates in a similar way.  Asserting that it does
makes me wary that you've understood and actually considered how tracing
works.

Duet takes global locks in hot paths.  The tracing code doesn't do that.
 It uses percpu buffers that don't require shared locks when adding
records.  It makes the reader of the data do all the hard work.

>> Tasks seem to have a fixed 'struct path' ->regpath at duet_task_init()
>> time.  The code goes page->mapping->inode->i_dentry and then tries to
>> compare that with the originally recorded path.  Does this even work in
>> the face of things like bind mounts, mounts that change after
>> duet_task_init(), or mounting a fs with a different superblock
>> underneath a watched path?  It seems awfully fragile.
> 
> This is an excellent point. Currently any events that occur on inodes of a
> different superblock would get filtered at duet_hook() for those tasks that
> haven't registered with that superblock. One solution is to do a duet_init()
> once per file system, and have the user application use select() on all those
> fds. This could potentially be done under the covers by the userlevel library.
> 
> I'm not sure how to handle mounts that change, however. At the very least I
> would like to be able to somehow inform Duet at unmount to close any
> outstanding fds. Any ideas/thoughts on this would be really appreciated,
> obviously.

It's complicated.  You can't simply toss things at unmount because it
might have been a bind mount and still be mounted somewhere else.

I don't think it's really even worth having an in-depth discussion of
how to modify duet.  I can't imagine that this would get merged as-is,
or even anything resembling the current design.  If you want to see
duet-like functionality in the kernel, I think it needs to be integrated
better and enhance or take advantage of existing mechanisms.

You've identified a real problem and a real solution, and it is in an
area where Linux is weak (monitoring the page cache).  If you are really
interested in seeing a solution that folks can use, I think you need to
find some way to leverage existing kernel functionality (ftrace,
fanotify, netlink, etc...), or come up with a much more compelling story
about why you can't use them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
