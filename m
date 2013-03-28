Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id E5B4F6B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 08:24:09 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <514C773A.6070000@sr71.net>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-15-git-send-email-kirill.shutemov@linux.intel.com>
 <514C773A.6070000@sr71.net>
Subject: Re: [PATCHv2, RFC 14/30] thp, mm: naive support of thp in generic
 read/write routines
Content-Transfer-Encoding: 7bit
Message-Id: <20130328122557.2D6A7E0085@blue.fi.intel.com>
Date: Thu, 28 Mar 2013 14:25:57 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > For now we still write/read at most PAGE_CACHE_SIZE bytes a time.
> > 
> > This implementation doesn't cover address spaces with backing store.
> ...
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -1165,12 +1165,23 @@ find_page:
> >  			if (unlikely(page == NULL))
> >  				goto no_cached_page;
> >  		}
> > +		if (PageTransTail(page)) {
> > +			page_cache_release(page);
> > +			page = find_get_page(mapping,
> > +					index & ~HPAGE_CACHE_INDEX_MASK);
> > +			if (!PageTransHuge(page)) {
> > +				page_cache_release(page);
> > +				goto find_page;
> > +			}
> > +		}
> 
> So, we're going to do a read of a file, and we pulled a tail page out of
> the page cache.  Why can't we just deal with the tail page directly?

Good point. I'll redo it once again.

First I thought to make it possible to read/write more PAGE_SIZE at once.
If not take this option in account for now, it's possible to make code much
cleaner.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
