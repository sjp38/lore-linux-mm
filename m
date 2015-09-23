Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7016B0255
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:02:07 -0400 (EDT)
Received: by qgev79 with SMTP id v79so10949554qge.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:02:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 188si4990296qhe.57.2015.09.22.21.02.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 21:02:06 -0700 (PDT)
Date: Tue, 22 Sep 2015 21:03:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: make mem_cgroup_read_stat() unsigned
Message-Id: <20150922210346.749204fb.akpm@linux-foundation.org>
In-Reply-To: <xr93bncum0ey.fsf@gthelen.mtv.corp.google.com>
References: <xr93bncum0ey.fsf@gthelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 22 Sep 2015 17:42:13 -0700 Greg Thelen <gthelen@google.com> wrote:

> Andrew Morton wrote:
> 
> > On Tue, 22 Sep 2015 15:16:32 -0700 Greg Thelen <gthelen@google.com> wrote:
> >
> >> mem_cgroup_read_stat() returns a page count by summing per cpu page
> >> counters.  The summing is racy wrt. updates, so a transient negative sum
> >> is possible.  Callers don't want negative values:
> >> - mem_cgroup_wb_stats() doesn't want negative nr_dirty or nr_writeback.
> >> - oom reports and memory.stat shouldn't show confusing negative usage.
> >> - tree_usage() already avoids negatives.
> >>
> >> Avoid returning negative page counts from mem_cgroup_read_stat() and
> >> convert it to unsigned.
> >
> > Someone please remind me why this code doesn't use the existing
> > percpu_counter library which solved this problem years ago.
> >
> >>   for_each_possible_cpu(cpu)
> >
> > and which doesn't iterate across offlined CPUs.
> 
> I found [1] and [2] discussing memory layout differences between:
> a) existing memcg hand rolled per cpu arrays of counters
> vs
> b) array of generic percpu_counter
> The current approach was claimed to have lower memory overhead and
> better cache behavior.
> 
> I assume it's pretty straightforward to create generic
> percpu_counter_array routines which memcg could use.  Possibly something
> like this could be made general enough could be created to satisfy
> vmstat, but less clear.
> 
> [1] http://www.spinics.net/lists/cgroups/msg06216.html
> [2] https://lkml.org/lkml/2014/9/11/1057

That all sounds rather bogus to me.  __percpu_counter_add() doesn't
modify struct percpu_counter at all except for when the cpu-local
counter overflows the configured batch size.  And for the memcg
application I suspect we can set the batch size to INT_MAX...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
