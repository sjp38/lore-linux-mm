Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 42E456B0072
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 15:24:41 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id e49so1716335eek.34
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 12:24:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v48si946497een.116.2014.02.27.12.24.38
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 12:24:39 -0800 (PST)
Message-ID: <530F9EB2.3070800@redhat.com>
Date: Thu, 27 Feb 2014 15:23:14 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/2] mm: page_alloc: reset aging cycle with GFP_THISNODE
References: <1393360022-22566-1-git-send-email-hannes@cmpxchg.org> <20140226095422.GY6732@suse.de> <20140226171206.GU6963@cmpxchg.org> <20140226201333.GV6963@cmpxchg.org>
In-Reply-To: <20140226201333.GV6963@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/26/2014 03:13 PM, Johannes Weiner wrote:

> Would this be an acceptable replacement for 1/2?

Looks reasonable to me. This should avoid the issues that
were observed with NUMA migrations.

> ---
>
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch 1/2] mm: page_alloc: exempt GFP_THISNODE allocations from zone
>   fairness
>
> Jan Stancek reports manual page migration encountering allocation
> failures after some pages when there is still plenty of memory free,
> and bisected the problem down to 81c0a2bb515f ("mm: page_alloc: fair
> zone allocator policy").
>
> The problem is that GFP_THISNODE obeys the zone fairness allocation
> batches on one hand, but doesn't reset them and wake kswapd on the
> other hand.  After a few of those allocations, the batches are
> exhausted and the allocations fail.
>
> Fixing this means either having GFP_THISNODE wake up kswapd, or
> GFP_THISNODE not participating in zone fairness at all.  The latter
> seems safer as an acute bugfix, we can clean up later.
>
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: <stable@kernel.org> # 3.12+

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
