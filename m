Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id C65D86B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 10:46:08 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id f8so1282324wiw.5
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 07:46:08 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id k10si4205782wiy.40.2014.07.18.07.46.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 07:46:07 -0700 (PDT)
Date: Fri, 18 Jul 2014 10:45:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140718144554.GG29639@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715082545.GA9366@dhcp22.suse.cz>
 <20140715121935.GB9366@dhcp22.suse.cz>
 <20140718071246.GA21565@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140718071246.GA21565@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Miklos Szeredi <miklos@szeredi.hu>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Michal,

[cc'ing Miklos for fuse's use of replace_page_cache()]

On Fri, Jul 18, 2014 at 09:12:46AM +0200, Michal Hocko wrote:
> On Tue 15-07-14 14:19:35, Michal Hocko wrote:
> > [...]
> > > +/**
> > > + * mem_cgroup_migrate - migrate a charge to another page
> > > + * @oldpage: currently charged page
> > > + * @newpage: page to transfer the charge to
> > > + * @lrucare: page might be on LRU already
> > 
> > which one? I guess the newpage?
> > 
> > > + *
> > > + * Migrate the charge from @oldpage to @newpage.
> > > + *
> > > + * Both pages must be locked, @newpage->mapping must be set up.
> > > + */
> > > +void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
> > > +			bool lrucare)
> > > +{
> > > +	unsigned int nr_pages = 1;
> > > +	struct page_cgroup *pc;
> > > +
> > > +	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
> > > +	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
> > > +	VM_BUG_ON_PAGE(PageLRU(oldpage), oldpage);
> > > +	VM_BUG_ON_PAGE(PageLRU(newpage), newpage);
> > 
> > 	VM_BUG_ON_PAGE(PageLRU(newpage) && !lruvec, newpage);
> 
> I guess everything except these two notes got addressed.

Sorry, they fell through the cracks.

Yes, @newpage can already be on the LRU, and it's what @lrucare is
for.  However, you got me thinking about the source page, and so I
went back to replace_page_cache(); and fuse code, which is the only
user of it.

I assumed the source page would always be new, according to this part
in fuse_try_move_page():

	/*
	 * This is a new and locked page, it shouldn't be mapped or
	 * have any special flags on it
	 */
	if (WARN_ON(page_mapped(oldpage)))
		goto out_fallback_unlock;
	if (WARN_ON(page_has_private(oldpage)))
		goto out_fallback_unlock;
	if (WARN_ON(PageDirty(oldpage) || PageWriteback(oldpage)))
		goto out_fallback_unlock;
	if (WARN_ON(PageMlocked(oldpage)))
		goto out_fallback_unlock;

However, it's in the page cache and I can't really convince myself
that it's not also on the LRU.  Miklos, I have trouble pinpointing
where oldpage is instantiated exactly and what state it might be in -
can it already be on the LRU?

If it can, we need to make sure we don't change pc->mem_cgroup while
mem_cgroup_migrate() is looking at it:

---
