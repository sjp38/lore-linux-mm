Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id A47B96B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 11:44:12 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l66so62272886wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 08:44:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e130si12011517wmd.64.2016.01.29.08.44.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 08:44:11 -0800 (PST)
Date: Fri, 29 Jan 2016 11:43:53 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/5] mm: memcontrol: generalize locking for the
 page->mem_cgroup binding
Message-ID: <20160129164353.GA8845@cmpxchg.org>
References: <1453842006-29265-1-git-send-email-hannes@cmpxchg.org>
 <1453842006-29265-2-git-send-email-hannes@cmpxchg.org>
 <20160127143045.GA9623@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160127143045.GA9623@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Jan 27, 2016 at 05:30:45PM +0300, Vladimir Davydov wrote:
> On Tue, Jan 26, 2016 at 04:00:02PM -0500, Johannes Weiner wrote:
> 
> > @@ -683,17 +683,17 @@ int __set_page_dirty_buffers(struct page *page)
> >  		} while (bh != head);
> >  	}
> >  	/*
> > -	 * Use mem_group_begin_page_stat() to keep PageDirty synchronized with
> > -	 * per-memcg dirty page counters.
> > +	 * Lock out page->mem_cgroup migration to keep PageDirty
> > +	 * synchronized with per-memcg dirty page counters.
> >  	 */
> > -	memcg = mem_cgroup_begin_page_stat(page);
> > +	memcg = lock_page_memcg(page);
> >  	newly_dirty = !TestSetPageDirty(page);
> >  	spin_unlock(&mapping->private_lock);
> >  
> >  	if (newly_dirty)
> >  		__set_page_dirty(page, mapping, memcg, 1);
> 
> Do we really want to pass memcg to __set_page_dirty and then to
> account_page_dirtied, increasing stack/regs usage even in case memory
> cgroup is disabled? May be, it'd be better to make
> mem_cgroup_update_page_stat take a page instead of a memcg?

I'll look into that. It will need changing migration to leave the
page->mem_cgroup binding of live pages alone, but that's something
worth doing anyway. It's beyond the scope of these patches, though.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
