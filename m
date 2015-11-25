Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3936B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 10:45:17 -0500 (EST)
Received: by wmuu63 with SMTP id u63so143237381wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 07:45:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ej8si35441303wjd.85.2015.11.25.07.45.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 07:45:16 -0800 (PST)
Subject: Re: [PATCH] vmscan: do not throttle kthreads due to too_many_isolated
References: <1448465801-3280-1-git-send-email-vdavydov@virtuozzo.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5655D789.80201@suse.cz>
Date: Wed, 25 Nov 2015 16:45:13 +0100
MIME-Version: 1.0
In-Reply-To: <1448465801-3280-1-git-send-email-vdavydov@virtuozzo.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/25/2015 04:36 PM, Vladimir Davydov wrote:
> Block device drivers often hand off io request processing to kernel
> threads (example: device mapper). If such a thread calls kmalloc, it can
> dive into direct reclaim path and end up waiting for too_many_isolated
> to return false, blocking writeback. This can lead to a dead lock if the

Shouldn't such allocation lack __GFP_IO to prevent this and other kinds of
deadlocks? And/or have mempools? PF_KTHREAD looks like a big hammer to me that
will solve only one potential problem...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
