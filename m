Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id F40DD6B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 11:09:18 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id u74so60694256lff.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 08:09:18 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u68si15262567wmd.41.2016.06.13.08.09.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 08:09:17 -0700 (PDT)
Date: Mon, 13 Jun 2016 11:06:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v1 3/3] mm: per-process reclaim
Message-ID: <20160613150653.GA30642@cmpxchg.org>
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
 <1465804259-29345-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465804259-29345-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Sangwoo Park <sangwoo2.park@lge.com>

Hi Minchan,

On Mon, Jun 13, 2016 at 04:50:58PM +0900, Minchan Kim wrote:
> These day, there are many platforms available in the embedded market
> and sometime, they has more hints about workingset than kernel so
> they want to involve memory management more heavily like android's
> lowmemory killer and ashmem or user-daemon with lowmemory notifier.
> 
> This patch adds add new method for userspace to manage memory
> efficiently via knob "/proc/<pid>/reclaim" so platform can reclaim
> any process anytime.

Cgroups are our canonical way to control system resources on a per
process or group-of-processes level. I don't like the idea of adding
ad-hoc interfaces for single-use cases like this.

For this particular case, you can already stick each app into its own
cgroup and use memory.force_empty to target-reclaim them.

Or better yet, set the soft limits / memory.low to guide physical
memory pressure, once it actually occurs, toward the least-important
apps? We usually prefer doing work on-demand rather than proactively.

The one-cgroup-per-app model would give Android much more control and
would also remove a *lot* of overhead during task switches, see this:
https://lkml.org/lkml/2014/12/19/358

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
