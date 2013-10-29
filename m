Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f79.google.com (mail-oa0-f79.google.com [209.85.219.79])
	by kanga.kvack.org (Postfix) with ESMTP id D01376B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 12:44:31 -0400 (EDT)
Received: by mail-oa0-f79.google.com with SMTP id k14so55594oag.10
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 09:44:31 -0700 (PDT)
Received: from psmtp.com ([74.125.245.195])
        by mx.google.com with SMTP id cx4si15094416pbc.89.2013.10.29.07.31.50
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 07:31:51 -0700 (PDT)
Date: Tue, 29 Oct 2013 10:28:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 3/3] memcg: use __this_cpu_sub() to dec stats to avoid
 incorrect subtrahend casting
Message-ID: <20131029142850.GC1548@cmpxchg.org>
References: <1382895017-19067-1-git-send-email-gthelen@google.com>
 <1382895017-19067-4-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382895017-19067-4-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, handai.szj@taobao.com, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Sun, Oct 27, 2013 at 10:30:17AM -0700, Greg Thelen wrote:
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
> negation.  This only works once "percpu: fix this_cpu_sub() subtrahend
> casting for unsigneds" is applied to fix this_cpu_sub().
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Acked-by: Tejun Heo <tj@kernel.org>

Huh, it looked so innocent...  At first I thought 2/3 would fix this
case as well but the cast happens only after the negation, so the sign
extension does not happen.  Alright, then.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
