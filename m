Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7A55F6B0255
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 11:30:15 -0500 (EST)
Received: by wmec201 with SMTP id c201so112898917wme.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 08:30:15 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kv9si20299249wjb.199.2015.11.23.08.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 08:30:14 -0800 (PST)
Date: Mon, 23 Nov 2015 11:30:03 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] vmscan: do not force-scan file lru if its absolute
 size is small
Message-ID: <20151123163003.GC13000@cmpxchg.org>
References: <20151120134311.8ff0947215fc522f72f791fe@linux-foundation.org>
 <1448275173-10538-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448275173-10538-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 23, 2015 at 01:39:33PM +0300, Vladimir Davydov wrote:
> We assume there is enough inactive page cache if the size of inactive
> file lru is greater than the size of active file lru, in which case we
> force-scan file lru ignoring anonymous pages. While this logic works
> fine when there are plenty of page cache pages, it fails if the size of
> file lru is small (several MB): in this case (lru_size >> prio) will be
> 0 for normal scan priorities, as a result, if inactive file lru happens
> to be larger than active file lru, anonymous pages of a cgroup will
> never get evicted unless the system experiences severe memory pressure,
> even if there are gigabytes of unused anonymous memory there, which is
> unfair in respect to other cgroups, whose workloads might be page cache
> oriented.
> 
> This patch attempts to fix this by elaborating the "enough inactive page
> cache" check: it makes it not only check that inactive lru size > active
> lru size, but also that we will scan something from the cgroup at the
> current scan priority. If these conditions do not hold, we proceed to
> SCAN_FRACT as usual.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
