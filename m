Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 8D60F6B0093
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 06:09:18 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <514B320C.4030507@sr71.net>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-6-git-send-email-kirill.shutemov@linux.intel.com>
 <514B320C.4030507@sr71.net>
Subject: Re: [PATCHv2, RFC 05/30] thp, mm: avoid PageUnevictable on
 active/inactive lru lists
Content-Transfer-Encoding: 7bit
Message-Id: <20130322101102.10C40E0085@blue.fi.intel.com>
Date: Fri, 22 Mar 2013 12:11:02 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> > active/inactive lru lists can contain unevicable pages (i.e. ramfs pages
> > that have been placed on the LRU lists when first allocated), but these
> > pages must not have PageUnevictable set - otherwise shrink_active_list
> > goes crazy:
> ...
> > For lru_add_page_tail(), it means we should not set PageUnevictable()
> > for tail pages unless we're sure that it will go to LRU_UNEVICTABLE.
> > The tail page will go LRU_UNEVICTABLE if head page is not on LRU or if
> > it's marked PageUnevictable() too.
> 
> This is only an issue once you're using lru_add_page_tail() for
> non-anonymous pages, right?

I'm not sure about that. Documentation/vm/unevictable-lru.txt:

Some examples of these unevictable pages on the LRU lists are:

 (1) ramfs pages that have been placed on the LRU lists when first allocated.

 (2) SHM_LOCK'd shared memory pages.  shmctl(SHM_LOCK) does not attempt to
     allocate or fault in the pages in the shared memory region.  This happens
     when an application accesses the page the first time after SHM_LOCK'ing
     the segment.

 (3) mlocked pages that could not be isolated from the LRU and moved to the
     unevictable list in mlock_vma_page().

 (4) Pages mapped into multiple VM_LOCKED VMAs, but try_to_munlock() couldn't
     acquire the VMA's mmap semaphore to test the flags and set PageMlocked.
     munlock_vma_page() was forced to let the page back on to the normal LRU
     list for vmscan to handle.

> > diff --git a/mm/swap.c b/mm/swap.c
> > index 92a9be5..31584d0 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -762,7 +762,8 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
> >  			lru = LRU_INACTIVE_ANON;
> >  		}
> >  	} else {
> > -		SetPageUnevictable(page_tail);
> > +		if (!PageLRU(page) || PageUnevictable(page))
> > +			SetPageUnevictable(page_tail);
> >  		lru = LRU_UNEVICTABLE;
> >  	}
> 
> You were saying above that ramfs pages can get on the normal
> active/inactive lists.  But, this will end up getting them on the
> unevictable list, right?  So, we have normal ramfs pages on the
> active/inactive lists, but ramfs pages after a huge-page-split on the
> unevictable list.  That seems a bit inconsistent.

Yeah, it's confusing.

I was able to trigger another bug on this code:
if page_evictable(page_tail) is false and PageLRU(page) is true, page_tail
will go to the same lru as page, but nobody cares to sync page_tail
active/inactive state with page. So we can end up with inactive page on
active lru...

I've updated the patch for the next interation. You can check it in git.
It should be cleaner. Description need to be updated.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
