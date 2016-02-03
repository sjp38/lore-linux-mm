Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 21F996B0005
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 04:20:29 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id o185so10835722pfb.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 01:20:29 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id f83si8090235pfd.208.2016.02.03.01.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 01:20:28 -0800 (PST)
Date: Wed, 3 Feb 2016 12:20:09 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 1/3] mm: migrate: do not touch page->mem_cgroup of live
 pages
Message-ID: <20160203092009.GE21016@esperanza>
References: <1454109573-29235-1-git-send-email-hannes@cmpxchg.org>
 <1454109573-29235-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1454109573-29235-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Jan 29, 2016 at 06:19:31PM -0500, Johannes Weiner wrote:
> Changing a page's memcg association complicates dealing with the page,
> so we want to limit this as much as possible. Page migration e.g. does
> not have to do that. Just like page cache replacement, it can forcibly
> charge a replacement page, and then uncharge the old page when it gets
> freed. Temporarily overcharging the cgroup by a single page is not an
> issue in practice, and charging is so cheap nowadays that this is much
> preferrable to the headache of messing with live pages.
> 
> The only place that still changes the page->mem_cgroup binding of live
> pages is when pages move along with a task to another cgroup. But that
> path isolates the page from the LRU, takes the page lock, and the move
> lock (lock_page_memcg()). That means page->mem_cgroup is always stable
> in callers that have the page isolated from the LRU or locked. Lighter
> unlocked paths, like writeback accounting, can use lock_page_memcg().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
