Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id BD9786B00B8
	for <linux-mm@kvack.org>; Wed, 22 May 2013 09:48:47 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <519BCACD.4020106@sr71.net>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-10-git-send-email-kirill.shutemov@linux.intel.com>
 <519BCACD.4020106@sr71.net>
Subject: Re: [PATCHv4 09/39] thp, mm: introduce mapping_can_have_hugepages()
 predicate
Content-Transfer-Encoding: 7bit
Message-Id: <20130522135112.32C3EE0090@blue.fi.intel.com>
Date: Wed, 22 May 2013 16:51:12 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > Returns true if mapping can have huge pages. Just check for __GFP_COMP
> > in gfp mask of the mapping for now.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  include/linux/pagemap.h |   12 ++++++++++++
> >  1 file changed, 12 insertions(+)
> > 
> > diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> > index e3dea75..28597ec 100644
> > --- a/include/linux/pagemap.h
> > +++ b/include/linux/pagemap.h
> > @@ -84,6 +84,18 @@ static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
> >  				(__force unsigned long)mask;
> >  }
> >  
> > +static inline bool mapping_can_have_hugepages(struct address_space *m)
> > +{
> > +	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE)) {
> > +		gfp_t gfp_mask = mapping_gfp_mask(m);
> > +		/* __GFP_COMP is key part of GFP_TRANSHUGE */
> > +		return !!(gfp_mask & __GFP_COMP) &&
> > +			transparent_hugepage_pagecache();
> > +	}
> > +
> > +	return false;
> > +}
> 
> transparent_hugepage_pagecache() already has the same IS_ENABLED()
> check,  Is it really necessary to do it again here?
> 
> IOW, can you do this?
> 
> > +static inline bool mapping_can_have_hugepages(struct address_space
> > +{
> > +		gfp_t gfp_mask = mapping_gfp_mask(m);
> 		if (!transparent_hugepage_pagecache())
> 			return false;
> > +		/* __GFP_COMP is key part of GFP_TRANSHUGE */
> > +		return !!(gfp_mask & __GFP_COMP);
> > +}

Yeah, it's better.

> I know we talked about this in the past, but I've forgotten already.
> Why is this checking for __GFP_COMP instead of GFP_TRANSHUGE?

It's up to filesystem what gfp mask to use. For example ramfs's pages are
not movable currently. So, we check only part which matters.

> Please flesh out the comment.

I'll make the comment in code a bit more descriptive.

> Also, what happens if "transparent_hugepage_flags &
> (1<<TRANSPARENT_HUGEPAGE_PAGECACHE)" becomes false at runtime and you
> have some already-instantiated huge page cache mappings around?  Will
> things like mapping_align_mask() break?

We will not touch existing huge pages in existing VMAs. The userspace can
use them until they will be unmapped or split. It's consistent with anon
THP pages.

If anybody mmap() the file after disabling the feature, we will not
setup huge pages anymore: transparent_hugepage_enabled() check in
handle_mm_fault will fail and the page fill be split.

mapping_align_mask() is part of mmap() call path, so there's only chance
that we will get VMA aligned more strictly then needed. Nothing to worry
about.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
