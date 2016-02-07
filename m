Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 30754830AE
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 13:41:14 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id uo6so62920733pac.1
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 10:41:14 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ln6si40509130pab.182.2016.02.07.10.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 10:41:13 -0800 (PST)
Date: Sun, 7 Feb 2016 21:41:00 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 2/2] mm: memcontrol: drop unnecessary lru locking from
 mem_cgroup_migrate()
Message-ID: <20160207184059.GB19151@esperanza>
References: <1454616467-8994-1-git-send-email-hannes@cmpxchg.org>
 <1454616467-8994-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1454616467-8994-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mateusz Guzik <mguzik@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Feb 04, 2016 at 03:07:47PM -0500, Johannes Weiner wrote:
> Migration accounting in the memory controller used to have to handle
> both oldpage and newpage being on the LRU already; fuse's page cache
> replacement used to pass a recycled newpage that had been uncharged
> but not freed and removed from the LRU, and the memcg migration code
> used to uncharge oldpage to "pass on" the existing charge to newpage.
> 
> Nowadays, pages are no longer uncharged when truncated from the page
> cache, but rather only at free time, so if a LRU page is recycled in
> page cache replacement it'll also still be charged. And we bail out of
> the charge transfer altogether in that case. Tell commit_charge() that
> we know newpage is not on the LRU, to avoid taking the zone->lru_lock
> unnecessarily from the migration path.
> 
> But also, oldpage is no longer uncharged inside migration. We only use
> oldpage for its page->mem_cgroup and page size, so we don't care about
> its LRU state anymore either. Remove any mention from the kernel doc.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Suggested-by: Hugh Dickins <hughd@google.com>

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Nit:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae8b81c55685..120118f3ce0a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5483,6 +5483,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
 	unsigned int nr_pages;
 	bool compound;
 
+	VM_BUG_ON_PAGE(PageLRU(newpage), newpage);
 	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
 	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
 	VM_BUG_ON_PAGE(PageAnon(oldpage) != PageAnon(newpage), newpage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
