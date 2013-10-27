Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 04B8B6B00DC
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 07:24:36 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id kq14so1225013pab.7
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 04:24:36 -0700 (PDT)
Received: from psmtp.com ([74.125.245.109])
        by mx.google.com with SMTP id je1si9239073pbb.210.2013.10.27.04.24.35
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 04:24:35 -0700 (PDT)
Received: by mail-qe0-f50.google.com with SMTP id 1so3324267qee.23
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 04:24:34 -0700 (PDT)
Date: Sun, 27 Oct 2013 07:24:29 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] memcg: use __this_cpu_sub to decrement stats
Message-ID: <20131027112429.GC14934@mtj.dyndns.org>
References: <1382859876-28196-1-git-send-email-gthelen@google.com>
 <1382859876-28196-4-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382859876-28196-4-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, handai.szj@taobao.com, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Sun, Oct 27, 2013 at 12:44:36AM -0700, Greg Thelen wrote:
> As of v3.11-9444-g3ea67d0 "memcg: add per cgroup writeback pages
> accounting" memcg counter errors are possible when moving charged
> memory to a different memcg.  Charge movement occurs when processing
> writes to memory.force_empty, moving tasks to a memcg with
> memcg.move_charge_at_immigrate=1, or memcg deletion.  An example
> showing error after memory.force_empty:
>   $ cd /sys/fs/cgroup/memory
>   $ mkdir x
>   $ rm /data/tmp/file
>   $ (echo $BASHPID >> x/tasks && exec mmap_writer /data/tmp/file 1M) &
>   [1] 13600
>   $ grep ^mapped x/memory.stat
>   mapped_file 1048576
>   $ echo 13600 > tasks
>   $ echo 1 > x/memory.force_empty
>   $ grep ^mapped x/memory.stat
>   mapped_file 4503599627370496
> 
> mapped_file should end with 0.
>   4503599627370496 == 0x10,0000,0000,0000 == 0x100,0000,0000 pages
>   1048576          == 0x10,0000           == 0x100 pages
> 
> This issue only affects the source memcg on 64 bit machines; the
> destination memcg counters are correct.  So the rmdir case is not too
> important because such counters are soon disappearing with the entire
> memcg.  But the memcg.force_empty and
> memory.move_charge_at_immigrate=1 cases are larger problems as the
> bogus counters are visible for the (possibly long) remaining life of
> the source memcg.
> 
> The problem is due to memcg use of __this_cpu_from(.., -nr_pages),
> which is subtly wrong because it subtracts the unsigned int nr_pages
> (either -1 or -512 for THP) from a signed long percpu counter.  When
> nr_pages=-1, -nr_pages=0xffffffff.  On 64 bit machines
> stat->count[idx] is signed 64 bit.  So memcg's attempt to simply
> decrement a count (e.g. from 1 to 0) boils down to:
>   long count = 1
>   unsigned int nr_pages = 1
>   count += -nr_pages  /* -nr_pages == 0xffff,ffff */
>   count is now 0x1,0000,0000 instead of 0
> 
> The fix is to subtract the unsigned page count rather than adding its
> negation.  This only works with the "percpu counter: cast
> this_cpu_sub() adjustment" patch which fixes this_cpu_sub().
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
