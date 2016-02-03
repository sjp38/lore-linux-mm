Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id C20E9828F6
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 16:19:41 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id o11so26161590qge.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 13:19:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 70si7232679qha.1.2016.02.03.13.19.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 13:19:41 -0800 (PST)
Date: Wed, 3 Feb 2016 13:19:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/workingset: do not forget to unlock page
Message-Id: <20160203131939.1a35d9bc03f13b2b143d27c0@linux-foundation.org>
In-Reply-To: <20160203162400.GB10440@cmpxchg.org>
References: <1454493513-19316-1-git-send-email-sergey.senozhatsky@gmail.com>
	<20160203104136.GA517@swordfish>
	<20160203162400.GB10440@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Wed, 3 Feb 2016 11:24:00 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, Feb 03, 2016 at 07:41:36PM +0900, Sergey Senozhatsky wrote:
> > From 1d6315221f2f81c53c99f9980158f8ae49dbd582 Mon Sep 17 00:00:00 2001
> > From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Date: Wed, 3 Feb 2016 18:49:16 +0900
> > Subject: [PATCH] mm/workingset: do not forget to unlock_page in workingset_activation
> > 
> > Do not return from workingset_activation() with locked rcu and page.
> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> 
> Thanks Sergey. Even though I wrote this function, my brain must have
> gone "it can't be locking anything when it returns NULL, right?" It's
> a dumb interface. Luckily, that's fixed with follow-up patches in -mm.
> 
> As for this one:
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Fixes: mm: workingset: per-cgroup cache thrash detection
> 
> Andrew, can you please fold this?

Yup.  I turned it into a fix against
mm-workingset-per-cgroup-cache-thrash-detection.patch, which is where
the bug was added.  And I did the goto thing instead, so the final
result will be

void workingset_activation(struct page *page)
{
	struct lruvec *lruvec;

	lock_page_memcg(page);
	/*
	 * Filter non-memcg pages here, e.g. unmap can call
	 * mark_page_accessed() on VDSO pages.
	 *
	 * XXX: See workingset_refault() - this should return
	 * root_mem_cgroup even for !CONFIG_MEMCG.
	 */
	if (!mem_cgroup_disabled() && !page_memcg(page))
		goto out;
	lruvec = mem_cgroup_zone_lruvec(page_zone(page), page_memcg(page));
	atomic_long_inc(&lruvec->inactive_age);
out:
	unlock_page_memcg(page);
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
