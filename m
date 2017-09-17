Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 71DC86B0038
	for <linux-mm@kvack.org>; Sun, 17 Sep 2017 11:43:23 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m30so13655160pgn.2
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 08:43:23 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0065.outbound.protection.outlook.com. [104.47.1.65])
        by mx.google.com with ESMTPS id k2si3432548pgc.704.2017.09.17.08.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 17 Sep 2017 08:43:21 -0700 (PDT)
Subject: Re: Page allocator bottleneck
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
 <87vaklyqwq.fsf@linux.intel.com>
From: Tariq Toukan <tariqt@mellanox.com>
Message-ID: <acc7ed46-b5d4-dac5-1c9f-a5a9c454c4a7@mellanox.com>
Date: Sun, 17 Sep 2017 18:43:09 +0300
MIME-Version: 1.0
In-Reply-To: <87vaklyqwq.fsf@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>, Tariq Toukan <tariqt@mellanox.com>
Cc: David Miller <davem@davemloft.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Linux Kernel Network Developers <netdev@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>



On 14/09/2017 11:19 PM, Andi Kleen wrote:
> Tariq Toukan <tariqt@mellanox.com> writes:
>>
>> Congestion in this case is very clear.
>> When monitored in perf top:
>> 85.58% [kernel] [k] queued_spin_lock_slowpath
> 
> Please look at the callers. Spinlock profiles without callers
> are usually useless because it's just blaming the messenger.
> 
> Most likely the PCP lists are too small for your extreme allocation
> rate, so it goes back too often to the shared pool.
> 
> You can play with the vm.percpu_pagelist_fraction setting.

Thanks Andi.
That was my initial guess, but I wasn't familiar with these tunes in VM 
to verify that.
Indeed, bottleneck is released when increasing the PCP size, and BW 
becomes significantly better.

> 
> -Andi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
