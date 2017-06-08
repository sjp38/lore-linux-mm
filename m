Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAFF06B0315
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 16:30:51 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w91so5981070wrb.13
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 13:30:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k24si6926689wmh.19.2017.06.08.13.30.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 13:30:50 -0700 (PDT)
Date: Thu, 8 Jun 2017 22:30:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Sleeping BUG in khugepaged for i586
Message-ID: <20170608203046.GB5535@dhcp22.suse.cz>
References: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net>
 <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org>
 <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz>
 <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net>
 <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
 <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
 <20170608144831.GA19903@dhcp22.suse.cz>
 <20170608170557.GA8118@bombadil.infradead.org>
 <20170608201822.GA5535@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170608201822.GA5535@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Larry Finger <Larry.Finger@lwfinger.net>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu 08-06-17 22:18:22, Michal Hocko wrote:
> On Thu 08-06-17 10:05:57, Matthew Wilcox wrote:
> > On Thu, Jun 08, 2017 at 04:48:31PM +0200, Michal Hocko wrote:
> > > On Wed 07-06-17 13:56:01, David Rientjes wrote:
> > > > I agree it's probably going to bisect to 338a16ba15495 since it's the 
> > > > cond_resched() at the line number reported, but I think there must be 
> > > > something else going on.  I think the list of locks held by khugepaged is 
> > > > correct because it matches with the implementation.  The preempt_count(), 
> > > > as suggested by Andrew, does not.  If this is reproducible, I'd like to 
> > > > know what preempt_count() is.
> > > 
> > > collapse_huge_page
> > >   pte_offset_map
> > >     kmap_atomic
> > >       kmap_atomic_prot
> > >         preempt_disable
> > >   __collapse_huge_page_copy
> > >   pte_unmap
> > >     kunmap_atomic
> > >       __kunmap_atomic
> > >         preempt_enable
> > > 
> > > I suspect, so cond_resched seems indeed inappropriate on 32b systems.
> > 
> > Then why doesn't it trigger on 64-bit systems too?
> > 
> > #ifndef ARCH_HAS_KMAP
> > ...
> > static inline void *kmap_atomic(struct page *page)
> > {
> >         preempt_disable();
> >         pagefault_disable();
> >         return page_address(page);
> > }
> > #define kmap_atomic_prot(page, prot)    kmap_atomic(page)
> > 
> > 
> > ... oh, wait, I see.  Because pte_offset_map() doesn't call kmap_atomic()
> > on 64-bit.  Indeed, it doesn't necessarily call kmap_atomic() on 32-bit
> > either; only with CONFIG_HIGHPTE enabled.  How much of a performance
> > penalty would it be to call kmap_atomic() unconditionally on 64 bit to
> > make sure that this kind of problem doesn't show on 32-bit systems only?
> 
> I am not sure I understand why would we map those pages in 64b systems?
> We can access them directly.

But I guess you are primary after syncing the preemptive mode for 64 and
32b systems, right? I agree that having a different model is more than
unfortunate because 32b gets much less testing coverage and so a risk of
introducing a new bug is just a matter of time. Maybe we should make
pte_offset_map disable preemption and currently noop pte_unmap to
preempt_enable. The overhead should be pretty marginal on x86_64 but not
all arches have per-cpu preempt count. So I am not sure we really want
to add this to just for the debugging purposes...

I would just pull the cond_resched out of __collapse_huge_page_copy
right after pte_unmap. But I am not really sure why this cond_resched is
really needed because the changelog of the patch which adds is is quite
terse on details.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
