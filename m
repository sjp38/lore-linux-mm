Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id E3B936B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 07:54:10 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id m15so3739743lah.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2012 04:54:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1349801921-16598-6-git-send-email-mgorman@suse.de>
References: <1349801921-16598-1-git-send-email-mgorman@suse.de>
	<1349801921-16598-6-git-send-email-mgorman@suse.de>
Date: Tue, 4 Dec 2012 14:54:08 +0200
Message-ID: <CA+ydwtqQ7iK_1E+7ctLxYe8JZY+SzMfuRagjyHJ12OYsxbMcaA@mail.gmail.com>
Subject: Re: [PATCH 5/5] mempolicy: fix a memory corruption by refcount
 imbalance in alloc_pages_vma()
From: Tommi Rantala <tt.rantala@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Stable <stable@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

2012/10/9 Mel Gorman <mgorman@suse.de>:
> commit 00442ad04a5eac08a98255697c510e708f6082e2 upstream.
>
> Commit cc9a6c877661 ("cpuset: mm: reduce large amounts of memory barrier
> related damage v3") introduced a potential memory corruption.
> shmem_alloc_page() uses a pseudo vma and it has one significant unique
> combination, vma->vm_ops=NULL and vma->policy->flags & MPOL_F_SHARED.
>
> get_vma_policy() does NOT increase a policy ref when vma->vm_ops=NULL
> and mpol_cond_put() DOES decrease a policy ref when a policy has
> MPOL_F_SHARED.  Therefore, when a cpuset update race occurs,
> alloc_pages_vma() falls in 'goto retry_cpuset' path, decrements the
> reference count and frees the policy prematurely.

Hello,

kmemleak is complaining about memory leaks that point to the mbind()
syscall. I've seen this only in v3.7-rcX, so I bisected this, and
found that this patch is the first mainline commit where I'm able to
reproduce it with Trinity.

$ ./trinity -q -C32 -c mbind -N100000
Trinity v1.1pre  Dave Jones <davej@redhat.com> 2012
[2823] Marking 64-bit syscall 237 (mbind) as enabled
[2823] Marking 32-bit syscall 274 (mbind) as enabled
Enabling syscall mbind
Initial random seed from time of day: 829620642 (0x317301a2)
[2824] Watchdog is alive
[2823] Started watchdog process, PID is 2824
[2825] Main thread is alive.
375 sockets created based on info from socket cachefile.
Generating file descriptors
Added 24 filenames from /dev
Added 23893 filenames from /proc
Added 8415 filenames from /sys
[2825] Random reseed: 4210789068 (0xfafb8acc)
[watchdog] 1060 iterations. [F:996 S:63]
[watchdog] 6588 iterations. [F:6119 S:468]
[watchdog] 12405 iterations. [F:11509 S:894]
[watchdog] 18163 iterations. [F:16850 S:1311]
[watchdog] 24001 iterations. [F:22260 S:1741]
[watchdog] 30122 iterations. [F:27935 S:2184]
[watchdog] 36074 iterations. [F:33465 S:2605]
[watchdog] 42042 iterations. [F:38971 S:3069]
[watchdog] 47949 iterations. [F:44419 S:3527]
[watchdog] 53873 iterations. [F:49908 S:3961]
[watchdog] 59719 iterations. [F:55345 S:4369]
[watchdog] 65583 iterations. [F:60787 S:4790]
[watchdog] 71690 iterations. [F:66451 S:5233]
[watchdog] 77755 iterations. [F:72070 S:5681]
[watchdog] 83850 iterations. [F:77714 S:6134]
[watchdog] 89877 iterations. [F:83296 S:6582]
[watchdog] 95890 iterations. [F:88851 S:7042]
[2825] Bailing main loop. Exit reason: Reached maximum syscall count
[2824] Watchdog exiting

Ran 100017 syscalls. Successes: 7355  Failures: 92665

# echo scan > /sys/kernel/debug/kmemleak
# cat /sys/kernel/debug/kmemleak
unreferenced object 0xffff88002c8b1060 (size 24):
  comm "trinity-child13", pid 2141, jiffies 4294861068 (age 1585.092s)
  hex dump (first 24 bytes):
    02 00 00 00 01 00 03 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00                          ........
  backtrace:
    [<ffffffff81a53481>] kmemleak_alloc+0x21/0x50
    [<ffffffff81196116>] kmem_cache_alloc+0x96/0x220
    [<ffffffff8118fd02>] __mpol_dup+0x22/0x190
    [<ffffffff8118feb8>] sp_alloc+0x48/0xa0
    [<ffffffff81190960>] mpol_set_shared_policy+0x40/0xd0
    [<ffffffff8115f1f8>] shmem_set_policy+0x28/0x30
    [<ffffffff811902c1>] mbind_range+0x1a1/0x210
    [<ffffffff811904fc>] do_mbind+0x1cc/0x2d0
    [<ffffffff811906a2>] sys_mbind+0xa2/0xb0
    [<ffffffff81a924a9>] system_call_fastpath+0x16/0x1b
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff88003d83f168 (size 24):
  comm "trinity-child10", pid 2686, jiffies 4295117470 (age 1328.725s)
  hex dump (first 24 bytes):
    01 00 00 00 01 00 03 00 00 00 00 00 00 00 00 00  ................
    01 00 00 00 00 00 00 00                          ........
  backtrace:
    [<ffffffff81a53481>] kmemleak_alloc+0x21/0x50
    [<ffffffff81196116>] kmem_cache_alloc+0x96/0x220
    [<ffffffff8118fd02>] __mpol_dup+0x22/0x190
    [<ffffffff8118feb8>] sp_alloc+0x48/0xa0
    [<ffffffff81190960>] mpol_set_shared_policy+0x40/0xd0
    [<ffffffff8115f1f8>] shmem_set_policy+0x28/0x30
    [<ffffffff811902c1>] mbind_range+0x1a1/0x210
    [<ffffffff811904fc>] do_mbind+0x1cc/0x2d0
    [<ffffffff811906a2>] sys_mbind+0xa2/0xb0
    [<ffffffff81a924a9>] system_call_fastpath+0x16/0x1b
    [<ffffffffffffffff>] 0xffffffffffffffff
#

Since the patch is touching the reference counting, I suppose the
finding could be legit.

Tommi

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Christoph Lameter <cl@linux.com>
> Cc: Josh Boyer <jwboyer@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/mempolicy.c |   12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 1763418..3d64b36 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1552,8 +1552,18 @@ struct mempolicy *get_vma_policy(struct task_struct *task,
>                                                                         addr);
>                         if (vpol)
>                                 pol = vpol;
> -               } else if (vma->vm_policy)
> +               } else if (vma->vm_policy) {
>                         pol = vma->vm_policy;
> +
> +                       /*
> +                        * shmem_alloc_page() passes MPOL_F_SHARED policy with
> +                        * a pseudo vma whose vma->vm_ops=NULL. Take a reference
> +                        * count on these policies which will be dropped by
> +                        * mpol_cond_put() later
> +                        */
> +                       if (mpol_needs_cond_ref(pol))
> +                               mpol_get(pol);
> +               }
>         }
>         if (!pol)
>                 pol = &default_policy;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
