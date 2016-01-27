Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 035D06B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 09:31:01 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id n128so5635476pfn.3
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 06:31:00 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ut6si9849070pab.68.2016.01.27.06.30.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 06:30:59 -0800 (PST)
Date: Wed, 27 Jan 2016 17:30:45 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 1/5] mm: memcontrol: generalize locking for the
 page->mem_cgroup binding
Message-ID: <20160127143045.GA9623@esperanza>
References: <1453842006-29265-1-git-send-email-hannes@cmpxchg.org>
 <1453842006-29265-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1453842006-29265-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Jan 26, 2016 at 04:00:02PM -0500, Johannes Weiner wrote:

> @@ -683,17 +683,17 @@ int __set_page_dirty_buffers(struct page *page)
>  		} while (bh != head);
>  	}
>  	/*
> -	 * Use mem_group_begin_page_stat() to keep PageDirty synchronized with
> -	 * per-memcg dirty page counters.
> +	 * Lock out page->mem_cgroup migration to keep PageDirty
> +	 * synchronized with per-memcg dirty page counters.
>  	 */
> -	memcg = mem_cgroup_begin_page_stat(page);
> +	memcg = lock_page_memcg(page);
>  	newly_dirty = !TestSetPageDirty(page);
>  	spin_unlock(&mapping->private_lock);
>  
>  	if (newly_dirty)
>  		__set_page_dirty(page, mapping, memcg, 1);

Do we really want to pass memcg to __set_page_dirty and then to
account_page_dirtied, increasing stack/regs usage even in case memory
cgroup is disabled? May be, it'd be better to make
mem_cgroup_update_page_stat take a page instead of a memcg?

Thanks,
Vladimir

>  
> -	mem_cgroup_end_page_stat(memcg);
> +	unlock_page_memcg(memcg);
>  
>  	if (newly_dirty)
>  		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
