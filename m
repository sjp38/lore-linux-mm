Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2107B6B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 19:36:28 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id g203so71961073iof.2
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 16:36:28 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id s95si6501786ioe.115.2016.02.24.16.36.26
        for <linux-mm@kvack.org>;
        Wed, 24 Feb 2016 16:36:27 -0800 (PST)
Date: Thu, 25 Feb 2016 09:37:44 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2] mm: scale kswapd watermarks in proportion to memory
Message-ID: <20160225003744.GC9723@js1304-P5Q-DELUXE>
References: <1456184002-15729-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456184002-15729-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hello, Johannes.

Just nitpick below.

On Mon, Feb 22, 2016 at 03:33:22PM -0800, Johannes Weiner wrote:
> In machines with 140G of memory and enterprise flash storage, we have
> seen read and write bursts routinely exceed the kswapd watermarks and
> cause thundering herds in direct reclaim. Unfortunately, the only way
> to tune kswapd aggressiveness is through adjusting min_free_kbytes -
> the system's emergency reserves - which is entirely unrelated to the
> system's latency requirements. In order to get kswapd to maintain a
> 250M buffer of free memory, the emergency reserves need to be set to
> 1G. That is a lot of memory wasted for no good reason.
> 
> On the other hand, it's reasonable to assume that allocation bursts
> and overall allocation concurrency scale with memory capacity, so it
> makes sense to make kswapd aggressiveness a function of that as well.
> 
> Change the kswapd watermark scale factor from the currently fixed 25%
> of the tunable emergency reserve to a tunable 0.001% of memory.

s/0.001%/0.1%

> Beyond 1G of memory, this will produce bigger watermark steps than the
> current formula in default settings. Ensure that the new formula never
> chooses steps smaller than that, i.e. 25% of the emergency reserve.
> 
> On a 140G machine, this raises the default watermark steps - the
> distance between min and low, and low and high - from 16M to 143M.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Mel Gorman <mgorman@suse.de>
> ---
>  Documentation/sysctl/vm.txt | 18 ++++++++++++++++++
>  include/linux/mm.h          |  1 +
>  include/linux/mmzone.h      |  2 ++
>  kernel/sysctl.c             | 10 ++++++++++
>  mm/page_alloc.c             | 29 +++++++++++++++++++++++++++--
>  5 files changed, 58 insertions(+), 2 deletions(-)
> 
> v2: Ensure 25% of emergency reserves as a minimum on small machines -Rik
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 89a887c..b02d940 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -803,6 +803,24 @@ performance impact. Reclaim code needs to take various locks to find freeable
>  directory and inode objects. With vfs_cache_pressure=1000, it will look for
>  ten times more freeable objects than there are.
>  
> +=============================================================
> +
> +watermark_scale_factor:
> +
> +This factor controls the aggressiveness of kswapd. It defines the
> +amount of memory left in a node/system before kswapd is woken up and
> +how much memory needs to be free before kswapd goes back to sleep.
> +
> +The unit is in fractions of 10,000. The default value of 10 means the
> +distances between watermarks are 0.001% of the available memory in the
> +node/system. The maximum value is 1000, or 10% of memory.

Ditto for 0.001%.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
