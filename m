Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 89DC86B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 19:39:33 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id q63so1984705pfb.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 16:39:33 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id o77si641604pfi.119.2016.02.23.16.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 16:39:32 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id ho8so1936446pac.2
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 16:39:32 -0800 (PST)
Date: Tue, 23 Feb 2016 16:39:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: scale kswapd watermarks in proportion to memory
In-Reply-To: <1456184002-15729-1-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1602231639190.25511@chino.kir.corp.google.com>
References: <1456184002-15729-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, 22 Feb 2016, Johannes Weiner wrote:

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
> 
> Beyond 1G of memory, this will produce bigger watermark steps than the
> current formula in default settings. Ensure that the new formula never
> chooses steps smaller than that, i.e. 25% of the emergency reserve.
> 
> On a 140G machine, this raises the default watermark steps - the
> distance between min and low, and low and high - from 16M to 143M.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
