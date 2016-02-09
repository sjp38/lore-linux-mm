Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id A0B076B0009
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 18:15:09 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p63so4449697wmp.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 15:15:09 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u65si1280025wme.76.2016.02.09.15.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 15:15:08 -0800 (PST)
Date: Tue, 9 Feb 2016 18:14:12 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 5/6] mm: workingset: size shadow nodes lru basing on
 file cache size
Message-ID: <20160209231412.GA32427@cmpxchg.org>
References: <cover.1455025246.git.vdavydov@virtuozzo.com>
 <26fb2cef8be75a27eae79e91b0f8351b468ab9d0.1455025246.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <26fb2cef8be75a27eae79e91b0f8351b468ab9d0.1455025246.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 09, 2016 at 04:55:53PM +0300, Vladimir Davydov wrote:
> A page is activated on refault if the refault distance stored in the
> corresponding shadow entry is less than the number of active file pages.
> Since active file pages can't occupy more than half memory, we assume
> that the maximal effective refault distance can't be greater than half
> the number of present pages and size the shadow nodes lru list
> appropriately. Generally speaking, this assumption is correct, but it
> can result in wasting a considerable chunk of memory on stale shadow
> nodes in case the portion of file pages is small, e.g. if a workload
> mostly uses anonymous memory.
> 
> To sort this out, we need to compute the size of shadow nodes lru basing
> not on the maximal possible, but the current size of file cache. We
> could take the size of active file lru for the maximal refault distance,
> but active lru is pretty unstable - it can shrink dramatically at
> runtime possibly disrupting workingset detection logic.
> 
> Instead we assume that the maximal refault distance equals half the
> total number of file cache pages. This will protect us against active
> file lru size fluctuations while still being correct, because size of
> active lru is normally maintained lower than size of inactive lru.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Begrudgingly, because I don't think it matters that much and I like
the dumber version. But it's a reasonable change nonetheless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
