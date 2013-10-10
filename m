Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3A33B6B0037
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 16:48:17 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so3303646pab.6
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 13:48:16 -0700 (PDT)
Received: by mail-vc0-f172.google.com with SMTP id hu8so2152563vcb.3
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 13:48:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131010002412.GC856@cmpxchg.org>
References: <CAJ75kXYqNfWejMhykEqmby4Yvs1w+Tv+QxKHZF67j77HJnco5A@mail.gmail.com>
 <20131010002412.GC856@cmpxchg.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 10 Oct 2013 22:47:54 +0200
Message-ID: <CAJ75kXa89w28hRS4LWbXUmzJe12N39Wowym_PTmRN7y5vu-1DA@mail.gmail.com>
Subject: Re: strange oom behaviour on 3.10
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org

Hi Johannes,

On Thu, Oct 10, 2013 at 2:24 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Can you try this patch on top of what you have right now?
>
> ---
>  mm/memcontrol.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ba3051a..d60f560 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2706,6 +2706,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>         if (unlikely(task_in_memcg_oom(current)))
>                 goto bypass;
>
> +       if (gfp_mask & __GFP_NOFAIL)
> +               oom = false;
> +
>         /*
>          * We always charge the cgroup the mm_struct belongs to.
>          * The mm_struct's mem_cgroup changes on task migration if the
> @@ -2803,10 +2806,10 @@ done:
>         *ptr = memcg;
>         return 0;
>  nomem:
> -       *ptr = NULL;
> -       if (gfp_mask & __GFP_NOFAIL)
> -               return 0;
> -       return -ENOMEM;
> +       if (!(gfp_mask & __GFP_NOFAIL)) {
> +               *ptr = NULL;
> +               return -ENOMEM;
> +       }
>  bypass:
>         *ptr = root_mem_cgroup;
>         return -EINTR;

Unfortunately, I'm getting the same result with your additional patch:

mysqld invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=-1000
mysqld cpuset=VM_A mems_allowed=0-1
CPU: 15 PID: 4414 Comm: mysqld Not tainted 3.10 #1
Hardware name: Dell Inc. PowerEdge C8220/0TDN55, BIOS 1.1.19 02/25/2013
ffffffff81515f50 0000000000000000 ffffffff815135a5 0101881000000000
ffff88201ddd3800 ffffc9001d2ac040 0000000000000000 0000000000000000
ffffffff81d236f8 ffff88201ddd3800 ffffffff810b7698 0000000000000001
Call Trace:
[<ffffffff81515f50>] ? dump_stack+0xd/0x17
[<ffffffff815135a5>] ? dump_header+0x78/0x21a
[<ffffffff810b7698>] ? find_lock_task_mm+0x28/0x80
[<ffffffff81103bbb>] ? mem_cgroup_same_or_subtree+0x2b/0x50
[<ffffffff810b7b50>] ? oom_kill_process+0x270/0x400
[<ffffffff8104a6fc>] ? has_ns_capability_noaudit+0x4c/0x70
[<ffffffff81105d2e>] ? mem_cgroup_oom_synchronize+0x53e/0x560
[<ffffffff81105150>] ? mem_cgroup_charge_common+0xa0/0xa0
[<ffffffff810b837b>] ? pagefault_out_of_memory+0xb/0x80
[<ffffffff81028e27>] ? __do_page_fault+0x497/0x580
[<ffffffff81158d3e>] ? read_events+0x27e/0x2e0
[<ffffffff81062f20>] ? abort_exclusive_wait+0xb0/0xb0
[<ffffffff81065830>] ? update_rmtp+0x190/0x190
[<ffffffff8151aaa8>] ? page_fault+0x38/0x40
Task in / killed as a result of limit of /lxc/VM_A
memory: usage 53192kB, limit 262144kB, failcnt 99902
memory+swap: usage 53192kB, limit 524288kB, failcnt 0
kmem: usage 0kB, limit 9007199254740991kB, failcnt 0
Memory cgroup stats for /lxc/VM_A: cache:18092KB rss:34988KB
rss_huge:14336KB mapped_file:100KB swap:0KB inactive_anon:4344KB
active_anon:48720KB inactive_file:4KB active_file:0KB unevictable:0KB
[ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[ 4359]     0  4359     4446      233      14        0             0 start
[ 4410]  5101  4410    63969     6404      56        0         -1000 mysqld
[ 4515]  5000  4515    89140     1490     123        0             0 php5-fpm
[ 4520]  5001  4520    24212      959      51        0             0 apache2
[24794]     0 24794     1023       80       8        0             0 sleep
[24795]  5001 24795   176565     2785     121        0             0 apache2
[31892]  5000 31892    89135     1474     118        0             0 php5-fpm
Memory cgroup out of memory: Kill process 31826 (php5-fpm) score 895
or sacrifice child

Do you have some more ideas?

Regards,
-- 
William

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
