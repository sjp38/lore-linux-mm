Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E12FD6B007D
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 06:23:30 -0500 (EST)
Received: by padfb1 with SMTP id fb1so512015pad.8
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 03:23:30 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y5si4948750pdq.28.2015.02.18.03.23.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 03:23:29 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
	<20150217131618.GA14778@phnom.home.cmpxchg.org>
	<20150217165024.GI32017@dhcp22.suse.cz>
	<20150217232552.GK4251@dastard>
	<20150218084842.GB4478@dhcp22.suse.cz>
In-Reply-To: <20150218084842.GB4478@dhcp22.suse.cz>
Message-Id: <201502182023.EEJ12920.QFFMOVtOSJLHFO@I-love.SAKURA.ne.jp>
Date: Wed, 18 Feb 2015 20:23:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: david@fromorbit.com, hannes@cmpxchg.org, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, fernando_b1@lab.ntt.co.jp

[ cc fsdevel list - watch out for side effect of 9879de7373fc (mm: page_alloc:
embed OOM killing naturally into allocation slowpath) which was merged between
3.19-rc6 and 3.19-rc7 , started from
http://marc.info/?l=linux-mm&m=142348457310066&w=2 ]

Replying in this post picked up from several posts in this thread.

Michal Hocko wrote:
> Besides that __GFP_WAIT callers should be prepared for the allocation
> failure and should better cope with it. So no, I really hate something
> like the above.

Those who do not want to retry with invoking the OOM killer are using
__GFP_WAIT + __GFP_NORETRY allocations.

Those who want to retry with invoking the OOM killer are using
__GFP_WAIT allocations.

Those who must retry forever with invoking the OOM killer, no matter how
many processes the OOM killer kills, are using __GFP_WAIT + __GFP_NOFAIL
allocations.

However, since use of __GFP_NOFAIL is prohibited, I think many of
__GFP_WAIT users are expecting that the allocation fails only when
"the OOM killer set TIF_MEMDIE flag to the caller but the caller
failed to allocate from memory reserves". Also, the implementation
before 9879de7373fc (mm: page_alloc: embed OOM killing naturally
into allocation slowpath) effectively supported __GFP_WAIT users
with such expectation.

Michal Hocko wrote:
> Because they cannot perform any IO/FS transactions and that would lead
> to a premature OOM conditions way too easily. OOM killer is a _last
> resort_ reclaim opportunity not something that would happen just because
> you happen to be not able to flush dirty pages. 

But you should not have applied such change without making necessary
changes to GFP_NOFS / GFP_NOIO users with such expectation and testing
at linux-next.git . Applying such change after 3.19-rc6 is a sucker punch.

Michal Hocko wrote:
> Well, you are beating your machine to death so you can hardly get any
> time guarantee. It would be nice to have a better feedback mechanism to
> know when to back off and fail the allocation attempt which might be
> blocking OOM victim to pass away. This is extremely tricky because we
> shouldn't be too eager to fail just because of a sudden memory pressure.

Michal Hocko wrote:
> >   I wish only somebody like kswapd repeats the loop on behalf of all
> >   threads waiting at memory allocation slowpath...
> 
> This is the case when the kswapd is _able_ to cope with the memory
> pressure.

It looks wasteful for me that so many threads (greater than number of
available CPUs) are sleeping at cond_resched() in shrink_slab() when
checking SysRq-t. Imagine 1000 threads sleeping at cond_resched() in
shrink_slab() on a machine with only 1 CPU. Each thread gets a chance
to try calling reclaim function only when all other threads gave that
thread a chance at cond_resched(). Such situation is almost mutually
preventing from making progress. I wish the following mechanism.

  Prepare a kernel thread (for avoiding being OOM-killed) and let
  __GFP_WAIT and __GFP_WAIT + __GFP_NOFAIL users to wake up the kernel
  thread when they failed to allocate from free list. The kernel thread
  calls shrink_slab() etc. (and also out_of_memory() as needed) and
  wakes them sleeping at wait_for_event() up.

Failing to allocate from free list is a rare case. Therefore, context
switches for asking somebody else for reclaiming memory would be an
acceptable overhead. If such mechanism are implemented, 1000 threads
except the somebody can save CPU time by sleeping. Avoiding "almost
mutually preventing from making progress" situation will drastically
shorten the time guarantee even if I beat my machine to death.
Such mechanism might be similar to Dave Chinner's

  Make the OOM killer only be invoked by kswapd or some other
  independent kernel thread so that it is independent of the
  allocation context that needs to invoke it, and have the
  invoker wait to be told what to do.

suggestion.

Dave Chinner wrote:
> Filesystems do demand paging of metadata within transactions, which
> means we are guaranteed to be holding locks when doing memory
> allocation. Indeed, this is what the GFP_NOFS allocation context is
> supposed to convey - we currently *hold locks* and so reclaim needs
> to be careful about recursion. I'll also argue that it means the OOM
> killer cannot kill the process attempting memory allocation for the
> same reason.

I agree with Dave Chinner about this.

I tested on ext4 filesystem, one is stock Linux 3.19 and the other is
Linux 3.19 with

   -               /* The OOM killer does not compensate for light reclaim */
   -               if (!(gfp_mask & __GFP_FS))
   -                       goto out;

applied. Running a Java-like stressing program (which is multi threaded
and likely be chosen by the OOM killer due to huge memory usage) shown
below with ext4 filesystem set to remount read-only upon filesystem error.

   # mount -o remount,errors=remount-ro /

---------- Testing program start ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>

static int file_writer(void *unused)
{
        char buffer[128] = { };
        int fd;
        snprintf(buffer, sizeof(buffer) - 1, "/tmp/file.%u", getpid());
        fd = open(buffer, O_WRONLY | O_CREAT, 0600);
        unlink(buffer);
        while (write(fd, buffer, 1) == 1 && fsync(fd) == 0);
        return 0;
}

static void memory_consumer(void)
{
        const int fd = open("/dev/zero", O_RDONLY);
        unsigned long size;
        char *buf = NULL;
        for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
                char *cp = realloc(buf, size);
                if (!cp) {
                        size >>= 1;
                        break;
                }
                buf = cp;
        }
        read(fd, buf, size); /* Will cause OOM due to overcommit */
}

int main(int argc, char *argv[])
{
        int i;
        for (i = 0; i < 100; i++) {
                char *cp = malloc(4 * 1024);
                if (!cp || clone(file_writer, cp + 4 * 1024,
                                 CLONE_SIGHAND | CLONE_VM, NULL) == -1)
                        break;
        }
        memory_consumer();
        while (1)
                pause();
        return 0;
}
---------- Testing program end ----------

The former showed that the ext4 filesystem is remounted read-only due to
filesystem errors with 50%+ reproducibility.

----------
[   72.440013] do_get_write_access: OOM for frozen_buffer
[   72.440014] EXT4-fs: ext4_reserve_inode_write:4729: aborting transaction: Out of memory in __ext4_journal_get_write_access
[   72.440015] EXT4-fs error (device sda1) in ext4_reserve_inode_write:4735: Out of memory
(...snipped....)
[   72.495559] do_get_write_access: OOM for frozen_buffer
[   72.495560] EXT4-fs: ext4_reserve_inode_write:4729: aborting transaction: Out of memory in __ext4_journal_get_write_access
[   72.496839] do_get_write_access: OOM for frozen_buffer
[   72.496841] EXT4-fs: ext4_reserve_inode_write:4729: aborting transaction: Out of memory in __ext4_journal_get_write_access
[   72.505766] Aborting journal on device sda1-8.
[   72.505851] EXT4-fs (sda1): Remounting filesystem read-only
[   72.505853] EXT4-fs warning (device sda1): ext4_evict_inode:260: couldn't mark inode dirty (err -12)
[   72.507995] EXT4-fs warning (device sda1): ext4_evict_inode:260: couldn't mark inode dirty (err -12)
[   72.508773] EXT4-fs (sda1): Remounting filesystem read-only
[   72.508775] EXT4-fs warning (device sda1): ext4_evict_inode:260: couldn't mark inode dirty (err -12)
[   72.547799] do_get_write_access: OOM for frozen_buffer
[   72.706692] EXT4-fs warning (device sda1): ext4_evict_inode:260: couldn't mark inode dirty (err -12)
[   73.035416] EXT4-fs warning (device sda1): ext4_evict_inode:260: couldn't mark inode dirty (err -12)
[   73.291732] EXT4-fs warning (device sda1): ext4_evict_inode:260: couldn't mark inode dirty (err -12)
[   73.422171] EXT4-fs warning (device sda1): ext4_evict_inode:260: couldn't mark inode dirty (err -12)
[   73.511862] EXT4-fs warning (device sda1): ext4_evict_inode:260: couldn't mark inode dirty (err -12)
[   73.589174] EXT4-fs warning (device sda1): ext4_evict_inode:260: couldn't mark inode dirty (err -12)
[   73.665302] EXT4-fs warning (device sda1): ext4_evict_inode:260: couldn't mark inode dirty (err -12)
----------

On the other hand, the latter showed that the ext4 filesystem was never
remounted read-only because filesystem errors did not occur, though several
TIF_MEMDIE stalls which the timeout patch would handle were observed as with
the former.

As this is ext4 filesystem, this would use GFP_NOFS. But does using GFP_NOFS +
__GFP_NOFAIL at ext4 filesystem solve the problem? I don't think so.
The underlying block layer which ext4 filesystem calls would use GFP_NOIO.
And memory allocation failures at block layer will result in I/O error which
is observed by users as filesystem error. Does passing __GFP_NOFAIL down to
block layer solve the problem? I don't think so. There is no means to teach
block layer that filesystem layer is doing critical operations where failure
results in serious problems. Then, does using GFP_NOIO + __GFP_NOFAIL at
block layer solves the problem? I don't think so. It is nothing but bypassing

   /* The OOM killer does not compensate for light reclaim */
   if (!(gfp_mask & __GFP_FS))
           goto out;

check by passing __GFP_NOFAIL flag.

Michal Hocko wrote:
> Failing __GFP_WAIT allocation is perfectly fine IMO. Why do you think
> this is a problem?

Killing a user space process or taking filesystem error actions (e.g.
remount-ro or kernel panic), which choice is less painful for users?
I believe that !(gfp_mask & __GFP_FS) check is a bug and should be removed.

Rather, shouldn't allocations without __GFP_FS get more chance to succeed
than allocations with __GFP_FS? If I were the author, I might have added
below check instead.

   /* This is not a critical allocation. Don't invoke the OOM killer. */
   if (gfp_mask & __GFP_FS)
           goto out;

Falling into retry loop with same watermark might prevent rescuer threads from
doing memory allocation which is needed for making free memory. Maybe we should
use lower watermark for GFP_NOIO and below, middle watermark for GFP_NOFS, high
watermark for GFP_KERNEL and above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
