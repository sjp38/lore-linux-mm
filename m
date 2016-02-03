Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id BAF93828F6
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 17:03:48 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p63so185901944wmp.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:03:48 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p137si119009wmb.0.2016.02.03.14.03.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 14:03:47 -0800 (PST)
Date: Wed, 3 Feb 2016 17:02:53 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/workingset: do not forget to unlock page
Message-ID: <20160203220253.GA6859@cmpxchg.org>
References: <1454493513-19316-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20160203104136.GA517@swordfish>
 <20160203162400.GB10440@cmpxchg.org>
 <20160203131939.1a35d9bc03f13b2b143d27c0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160203131939.1a35d9bc03f13b2b143d27c0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Wed, Feb 03, 2016 at 01:19:39PM -0800, Andrew Morton wrote:
> Yup.  I turned it into a fix against
> mm-workingset-per-cgroup-cache-thrash-detection.patch, which is where
> the bug was added.  And I did the goto thing instead, so the final
> result will be
> 
> void workingset_activation(struct page *page)
> {
> 	struct lruvec *lruvec;
> 
> 	lock_page_memcg(page);
> 	/*
> 	 * Filter non-memcg pages here, e.g. unmap can call
> 	 * mark_page_accessed() on VDSO pages.
> 	 *
> 	 * XXX: See workingset_refault() - this should return
> 	 * root_mem_cgroup even for !CONFIG_MEMCG.
> 	 */
> 	if (!mem_cgroup_disabled() && !page_memcg(page))
> 		goto out;
> 	lruvec = mem_cgroup_zone_lruvec(page_zone(page), page_memcg(page));
> 	atomic_long_inc(&lruvec->inactive_age);
> out:
> 	unlock_page_memcg(page);
> }

LGTM, thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
