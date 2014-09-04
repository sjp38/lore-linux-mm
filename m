Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4ED6B0037
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 16:50:39 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id p10so14280600pdj.25
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 13:50:39 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id g3si67879pdi.100.2014.09.04.13.50.37
        for <linux-mm@kvack.org>;
        Thu, 04 Sep 2014 13:50:37 -0700 (PDT)
Message-ID: <5408D09A.5030000@sr71.net>
Date: Thu, 04 Sep 2014 13:50:34 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
References: <54061505.8020500@sr71.net> <20140902221814.GA18069@cmpxchg.org> <5406466D.1020000@sr71.net> <20140903001009.GA25970@cmpxchg.org> <5406612E.8040802@sr71.net> <20140904150846.GA10794@cmpxchg.org>
In-Reply-To: <20140904150846.GA10794@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Linus Torvalds <torvalds@linuxfoundation.org>, Andrew Morton <akpm@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 09/04/2014 08:08 AM, Johannes Weiner wrote:
> Dave Hansen reports a massive scalability regression in an uncontained
> page fault benchmark with more than 30 concurrent threads, which he
> bisected down to 05b843012335 ("mm: memcontrol: use root_mem_cgroup
> res_counter") and pin-pointed on res_counter spinlock contention.
> 
> That change relied on the per-cpu charge caches to mostly swallow the
> res_counter costs, but it's apparent that the caches don't scale yet.
> 
> Revert memcg back to bypassing res_counters on the root level in order
> to restore performance for uncontained workloads.

A quick sniff test shows performance coming back to what it was around
3.16 with this patch.  I'll run a more thorough set of tests and verify
that it's working well.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
