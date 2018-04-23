Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id ABAC16B0003
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 09:10:12 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i127so6483344pgc.22
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 06:10:12 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z125si11341335pfz.335.2018.04.23.06.10.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 06:10:11 -0700 (PDT)
Date: Mon, 23 Apr 2018 21:10:33 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: Page allocator bottleneck
Message-ID: <20180423131033.GA13792@intel.com>
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
 <20170915102320.zqceocmvvkyybekj@techsingularity.net>
 <d8cfaf8b-7601-2712-f9f2-8327c720db5a@mellanox.com>
 <1c218381-067e-7757-ccc2-4e5befd2bfc3@mellanox.com>
 <20180421081505.GA24916@intel.com>
 <127df719-b978-60b7-5d77-3c8efbf2ecff@mellanox.com>
 <0dea4da6-8756-22d4-c586-267217a5fa63@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0dea4da6-8756-22d4-c586-267217a5fa63@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tariq Toukan <tariqt@mellanox.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, David Miller <davem@davemloft.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Mon, Apr 23, 2018 at 11:54:57AM +0300, Tariq Toukan wrote:
> Hi,
> 
> I ran my tests with your patches.
> Initial BW numbers are significantly higher than I documented back then in
> this mail-thread.
> For example, in driver #2 (see original mail thread), with 6 rings, I now
> get 92Gbps (slightly less than linerate) in comparison to 64Gbps back then.
> 
> However, there were many kernel changes since then, I need to isolate your
> changes. I am not sure I can finish this today, but I will surely get to it
> next week after I'm back from vacation.
> 
> Still, when I increase the scale (more rings, i.e. more cpus), I see that
> queued_spin_lock_slowpath gets to 60%+ cpu. Still high, but lower than it
> used to be.

I wonder if it is on allocation path or free path?

Also, increasing PCP size through vm.percpu_pagelist_fraction would
still help with my patches since it can avoid touching even more cache
lines on allocation path with a higher PCP->batch(which has an upper
limit of 96 though at the moment).

> 
> This should be root solved by the (orthogonal) changes planned in network
> subsystem, which will change the SKB allocation/free scheme so that SKBs are
> released on the originating cpu.
