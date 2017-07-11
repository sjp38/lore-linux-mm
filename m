Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7FD6B0536
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 13:22:22 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g46so1652825wrd.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 10:22:22 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p52si1835627eda.61.2017.07.11.10.22.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 11 Jul 2017 10:22:20 -0700 (PDT)
Date: Tue, 11 Jul 2017 13:22:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] tracing/ring_buffer: Try harder to allocate
Message-ID: <20170711172204.GA961@cmpxchg.org>
References: <20170711060500.17016-1-joelaf@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170711060500.17016-1-joelaf@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com, linux-mm@kvack.org, Alexander Duyck <alexander.h.duyck@intel.com>, Mel Gorman <mgorman@suse.de>, Hao Lee <haolee.swjtu@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Tim Murray <timmurray@google.com>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org

On Mon, Jul 10, 2017 at 11:05:00PM -0700, Joel Fernandes wrote:
> ftrace can fail to allocate per-CPU ring buffer on systems with a large
> number of CPUs coupled while large amounts of cache happening in the
> page cache. Currently the ring buffer allocation doesn't retry in the VM
> implementation even if direct-reclaim made some progress but still
> wasn't able to find a free page. On retrying I see that the allocations
> almost always succeed. The retry doesn't happen because __GFP_NORETRY is
> used in the tracer to prevent the case where we might OOM, however if we
> drop __GFP_NORETRY, we risk destabilizing the system if OOM killer is
> triggered. To prevent this situation, use the __GFP_RETRY_MAYFAIL flag
> introduced recently [1].
> 
> Tested the following still succeeds without destabilizing a system with
> 1GB memory.
> echo 300000 > /sys/kernel/debug/tracing/buffer_size_kb
> 
> [1] https://marc.info/?l=linux-mm&m=149820805124906&w=2
> 
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hao Lee <haolee.swjtu@gmail.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Tim Murray <timmurray@google.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: stable@vger.kernel.org
> Signed-off-by: Joel Fernandes <joelaf@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
