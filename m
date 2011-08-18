Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 27AE0900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 02:08:10 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v9 03/13] memcg: add dirty page accounting infrastructure
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
	<1313597705-6093-4-git-send-email-gthelen@google.com>
	<20110818093959.cdf501ae.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 17 Aug 2011 23:07:29 -0700
In-Reply-To: <20110818093959.cdf501ae.kamezawa.hiroyu@jp.fujitsu.com>
	(KAMEZAWA Hiroyuki's message of "Thu, 18 Aug 2011 09:39:59 +0900")
Message-ID: <xr93bovnuuam.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> On Wed, 17 Aug 2011 09:14:55 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> Add memcg routines to count dirty, writeback, and unstable_NFS pages.
>> These routines are not yet used by the kernel to count such pages.  A
>> later change adds kernel calls to these new routines.
>> 
>> As inode pages are marked dirty, if the dirtied page's cgroup differs
>> from the inode's cgroup, then mark the inode shared across several
>> cgroup.
>> 
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> Signed-off-by: Andrea Righi <andrea@betterlinux.com>
>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> A nitpick..
>
>
>
>> +static inline
>> +void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
>> +				       struct mem_cgroup *to,
>> +				       enum mem_cgroup_stat_index idx)
>> +{
>> +	preempt_disable();
>> +	__this_cpu_dec(from->stat->count[idx]);
>> +	__this_cpu_inc(to->stat->count[idx]);
>> +	preempt_enable();
>> +}
>> +
>
> this_cpu_dec()
> this_cpu_inc()
>
> without preempt_disable/enable will work. CPU change between dec/inc will
> not be problem.
>
> Thanks,
> -Kame

I agree, but this fix is general cleanup, which seems independent of
memcg dirty accounting.  This preemption disable/enable pattern exists
before this patch series in both mem_cgroup_charge_statistics() and
mem_cgroup_move_account().  For consistency we should change both.  To
keep the dirty page accounting series simple, I would like to make these
changes outside of this series.  On x86 usage of this_cpu_dec/inc looks
equivalent to __this_cpu_inc(), so I assume the only trade off is that
preemptible non-x86 using generic this_this_cpu() will internally
disable/enable preemption in this_cpu_*() operations.

I'll submit a cleanup patch outside of the dirty limit patches for this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
