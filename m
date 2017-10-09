Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9E36B025F
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 13:52:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l188so48691133pfc.7
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 10:52:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s1sor1294286plk.38.2017.10.09.10.52.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Oct 2017 10:52:47 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
In-Reply-To: <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
References: <20171005222144.123797-1-shakeelb@google.com> <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz> <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com> <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
Date: Mon, 09 Oct 2017 10:52:44 -0700
Message-ID: <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 06-10-17 12:33:03, Shakeel Butt wrote:
>> >>       names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
>> >> -                     SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
>> >> +                     SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT, NULL);
>> >
>> > I might be wrong but isn't name cache only holding temporary objects
>> > used for path resolution which are not stored anywhere?
>> >
>> 
>> Even though they're temporary, many containers can together use a
>> significant amount of transient uncharged memory. We've seen machines
>> with 100s of MiBs in names_cache.
>
> Yes that might be possible but are we prepared for random ENOMEM from
> vfs calls which need to allocate a temporary name?
>
>> 
>> >>       filp_cachep = kmem_cache_create("filp", sizeof(struct file), 0,
>> >> -                     SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
>> >> +                     SLAB_HWCACHE_ALIGN | SLAB_PANIC | SLAB_ACCOUNT, NULL);
>> >>       percpu_counter_init(&nr_files, 0, GFP_KERNEL);
>> >>  }
>> >
>> > Don't we have a limit for the maximum number of open files?
>> >
>> 
>> Yes, there is a system limit of maximum number of open files. However
>> this limit is shared between different users on the system and one
>> user can hog this resource. To cater that, we set the maximum limit
>> very high and let the memory limit of each user limit the number of
>> files they can open.
>
> Similarly here. Are all syscalls allocating a fd prepared to return
> ENOMEM?
>
> -- 
> Michal Hocko
> SUSE Labs

Even before this patch I find memcg oom handling inconsistent.  Page
cache pages trigger oom killer and may allow caller to succeed once the
kernel retries.  But kmem allocations don't call oom killer.  They
surface errors to user space.  This makes memcg hard to use for memory
overcommit because it's desirable for a high priority task to
transparently kill a lower priority task using the memcg oom killer.

A few ideas on how to make it more flexible:

a) Go back to memcg oom killing within memcg charging.  This runs risk
   of oom killing while caller holds locks which oom victim selection or
   oom victim termination may need.  Google's been running this way for
   a while.

b) Have every syscall return do something similar to page fault handler:
   kmem allocations in oom memcg mark the current task as needing an oom
   check return NULL.  If marked oom, syscall exit would use
   mem_cgroup_oom_synchronize() before retrying the syscall.  Seems
   risky.  I doubt every syscall is compatible with such a restart.

c) Overcharge kmem to oom memcg and queue an async memcg limit checker,
   which will oom kill if needed.

Comments?

Demo program which eventually gets ENOSPC from mkdir.

$ cat /tmp/t
while umount /tmp/mnt; do true; done
mkdir -p /tmp/mnt
mount -t tmpfs nodev /tmp/mnt
cd /dev/cgroup/memory
rmdir t
mkdir t
echo 32M > t/memory.limit_in_bytes
(echo $BASHPID > t/cgroup.procs && cd /tmp/mnt && exec /tmp/mkdirs)

$ cat /tmp/mkdirs.c
#include <err.h>
#include <stdio.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>

int main()
{
        int i;
        char name[32];

        if (mlockall(MCL_CURRENT|MCL_FUTURE))
                err(1, "mlockall");
        for (i = 0; i < (1<<20); i++) {
                sprintf(name, "%d", i);
                if (mkdir(name, 0700))
                        err(1, "mkdir");
        }
        printf("done\n");
        return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
