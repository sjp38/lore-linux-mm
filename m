Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 51C986B0085
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 10:45:29 -0500 (EST)
Date: Mon, 8 Nov 2010 23:45:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: memcg writeout throttling, was: [patch 4/4] memcg: use native
 word page statistics counters
Message-ID: <20101108154524.GA9530@localhost>
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
 <20101106010357.GD23393@cmpxchg.org>
 <AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
 <20101107215030.007259800@cmpxchg.org>
 <20101107220353.964566018@cmpxchg.org>
 <AANLkTinh+LEQYGe9dDOKBwNnVVXMiFYpDqkqvvpNe9H8@mail.gmail.com>
 <20101108093715.GJ23393@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101108093715.GJ23393@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 08, 2010 at 05:37:16PM +0800, Johannes Weiner wrote:
> On Mon, Nov 08, 2010 at 09:07:35AM +0900, Minchan Kim wrote:
> > BTW, let me ask a question.
> > dirty_writeback_pages seems to be depends on mem_cgroup_page_stat's
> > result(ie, negative) for separate global and memcg.
> > But mem_cgroup_page_stat could return negative value by per-cpu as
> > well as root cgroup.
> > If I understand right, Isn't it a problem?
> 
> Yes, the numbers are not reliable and may be off by some.  It appears
> to me that the only sensible interpretation of a negative sum is to
> assume zero, though.  So to be honest, I don't understand the fallback
> to global state when the local state fluctuates around low values.

Agreed. It does not make sense to compare values from different domains.

The bdi stats use percpu_counter_sum_positive() which never return
negative values. It may be suitable for memcg page counts, too.

> This function is also only used in throttle_vm_writeout(), where the
> outcome is compared to the global dirty threshold.  So using the
> number of writeback pages _from the current cgroup_ and falling back
> to global writeback pages when this number is low makes no sense to me
> at all.
> 
> I looks like it should rather compare the cgroup state with the cgroup
> limit, and the global state with the global limit.

Right.

> Can somebody explain the reasoning behind this?  And in case it makes
> sense after all, put a comment into this function?

It seems a better match to test sc->mem_cgroup rather than
mem_cgroup_from_task(current). The latter could make mismatches. When
someone is changing the memcg limits and hence triggers memcg
reclaims, the current task is actually the (unrelated) shell. It's
also possible for the memcg task to trigger _global_ direct reclaim.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
