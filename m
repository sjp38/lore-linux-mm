Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9A166B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 23:47:50 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id s189so89974346vkh.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 20:47:50 -0700 (PDT)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id z1si10747225qtd.154.2016.07.28.20.47.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 20:47:49 -0700 (PDT)
Received: by mail-qt0-x241.google.com with SMTP id q11so4127682qtb.2
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 20:47:49 -0700 (PDT)
Date: Thu, 28 Jul 2016 23:47:45 -0400
From: George Amvrosiadis <gamvrosi@gmail.com>
Subject: Re: [PATCH 0/3] new feature: monitoring page cache events
Message-ID: <20160729034745.GA10234@leftwich>
References: <cover.1469489884.git.gamvrosi@gmail.com>
 <579A72F5.10808@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <579A72F5.10808@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 28, 2016 at 02:02:45PM -0700, Dave Hansen wrote:
> On 07/25/2016 08:47 PM, George Amvrosiadis wrote:
> >  21 files changed, 2424 insertions(+), 1 deletion(-)
> 
> I like the idea, but yikes, that's a lot of code.
> 
> Have you considered using or augmenting the kernel's existing tracing
> mechanisms?  Have you considered using something like netlink for
> transporting the data out of the kernel?
>

We contemplated a couple other solutions. One was extending existing debugging
mechanisms. E.g., there are already tracepoints at __add_to_page_cache_locked()
and __delete_from_page_cache(). A consistent reaction I got for doing that,
however, was that of exposing an unruly interface to user applications, which
is certainly not an elegant solution. After that experience, and reading up on
issues of the auditing subsystem (https://lwn.net/Articles/600568/) I decided
to avoid going further down that path.

> The PageDirty() hooks look simple but turn out to be horribly deep.
> Where we used to have a plain old bit set, we now have new locks,
> potentially long periods of irq disabling, and loops over all the tasks
> doing duet, even path lookup!
> 

It's true that the hooks are deep, but they are fully exercised only once per
inode, per task. The reasoning behind the 'struct bmap_rbnode'->seen bitmap is
to remember whether an inode was seen before by a given task. During that first
access is when we do the path lookup to decide whether this inode is relevant
to the task and mark 'struct bmap_rbnode'->relv accordingly. If it is not, we
ignore future events from it. Tasks can also use the 'structu bmap_rbnode'->done
bitmap to indicate that they are done with a specific inode, which also stops
those events from passing that task loop.

> Given a big system, I would imagine these locks slowing down
> SetPageDirty() and things like write() pretty severely.  Have you done
> an assessment of the performance impact of this change?   I can't
> imagine this being used in any kind of performance or
> scalability-sensitive environment.
> 

I have used filebench to saturate an HDD and an SSD, registered a task to be
notified about every file in the filesystem, and measured no difference in I/O
throughput. To measure the CPU utilization of Duet, I tried an extreme case
where I booted using only one core and again saturated an HDD using filebench.
There was a 1-1.5% increase in CPU utilization. There is a description of this
result in the paper. I have also tuned filebench to hit the cache often in my
experiments (more than 60-70% of accesses going to less than 10% of the data),
but the results were similar. For the Hadoop and Spark experiments we used a
24-node cluster and these overhead numbers didn't seem to affect performance.

> The current tracing code has a model where the trace producers put data
> in *one* place, then all the mulitple consumers pull it out of that
> place.  Duet seems to have the model that the producer puts the data in
> multiple places and consumers consume it from their own private copies.
>  That seems a bit backwards and puts cost directly in to hot code paths.
>  Even a single task watching a single file on the system makes everyone
> go in and pay some of this cost for every SetPageDirty().
> 

Duet operates in a similar way. There is one large global hash table to avoid
collisions, so that on average a single lookup is sufficient to place a page in
it. Due to its global nature, if a page is of interest to multiple tasks, only
one entry is used to hold the events for that page across all tasks. And to
avoid walking that hash table for relevant events on a read(), each task
maintains a separate bitmap of the hash table's buckets that tells it which
buckets to look into. (In the past I've also tried a work queue approach on the
hot code path, but the overhead was almost double as a result of allocating the
work queue items.)

Having said all the above, Dave, I've seen your work at the 2013 Linux Plumbers
Conference on scalability issues, so if you think I'm missing something in my
replies, please call me out on that. I'm definitely open to improving this code.

> Let's say we had a big system with virtually everything sitting in the
> page cache.  Does duet have a way to find things currently _in_ the
> cache, or only when things move in/out of it?
> 

At task registration time we grab the superblock for the filesystem of the
registered path, and then scan_page_cache() traverses the list of inodes
currently in memory. We enqueue ADDED and DIRTY events for relevant inodes
as needed.

> Tasks seem to have a fixed 'struct path' ->regpath at duet_task_init()
> time.  The code goes page->mapping->inode->i_dentry and then tries to
> compare that with the originally recorded path.  Does this even work in
> the face of things like bind mounts, mounts that change after
> duet_task_init(), or mounting a fs with a different superblock
> underneath a watched path?  It seems awfully fragile.

This is an excellent point. Currently any events that occur on inodes of a
different superblock would get filtered at duet_hook() for those tasks that
haven't registered with that superblock. One solution is to do a duet_init()
once per file system, and have the user application use select() on all those
fds. This could potentially be done under the covers by the userlevel library.

I'm not sure how to handle mounts that change, however. At the very least I
would like to be able to somehow inform Duet at unmount to close any
outstanding fds. Any ideas/thoughts on this would be really appreciated,
obviously.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
