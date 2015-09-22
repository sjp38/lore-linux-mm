Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 32B4D6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 18:24:26 -0400 (EDT)
Received: by qgx61 with SMTP id 61so6274571qgx.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 15:24:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 40si1079453qgj.100.2015.09.22.15.24.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 15:24:25 -0700 (PDT)
Date: Tue, 22 Sep 2015 15:24:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: make mem_cgroup_read_stat() unsigned
Message-Id: <20150922152423.5751d932aebfe12cdd40a618@linux-foundation.org>
In-Reply-To: <1442960192-83405-1-git-send-email-gthelen@google.com>
References: <1442960192-83405-1-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 22 Sep 2015 15:16:32 -0700 Greg Thelen <gthelen@google.com> wrote:

> mem_cgroup_read_stat() returns a page count by summing per cpu page
> counters.  The summing is racy wrt. updates, so a transient negative sum
> is possible.  Callers don't want negative values:
> - mem_cgroup_wb_stats() doesn't want negative nr_dirty or nr_writeback.
> - oom reports and memory.stat shouldn't show confusing negative usage.
> - tree_usage() already avoids negatives.
> 
> Avoid returning negative page counts from mem_cgroup_read_stat() and
> convert it to unsigned.

Someone please remind me why this code doesn't use the existing
percpu_counter library which solved this problem years ago.

>  	for_each_possible_cpu(cpu)

and which doesn't iterate across offlined CPUs.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
