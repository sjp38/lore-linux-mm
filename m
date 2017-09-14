Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E05F6B0069
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 16:19:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y77so618532pfd.2
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 13:19:20 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v81si11208116pgb.504.2017.09.14.13.19.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 13:19:18 -0700 (PDT)
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: Page allocator bottleneck
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
Date: Thu, 14 Sep 2017 13:19:17 -0700
In-Reply-To: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com> (Tariq
	Toukan's message of "Thu, 14 Sep 2017 19:49:31 +0300")
Message-ID: <87vaklyqwq.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tariq Toukan <tariqt@mellanox.com>
Cc: David Miller <davem@davemloft.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Linux Kernel Network Developers <netdev@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>

Tariq Toukan <tariqt@mellanox.com> writes:
>
> Congestion in this case is very clear.
> When monitored in perf top:
> 85.58% [kernel] [k] queued_spin_lock_slowpath

Please look at the callers. Spinlock profiles without callers
are usually useless because it's just blaming the messenger.

Most likely the PCP lists are too small for your extreme allocation
rate, so it goes back too often to the shared pool.

You can play with the vm.percpu_pagelist_fraction setting.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
