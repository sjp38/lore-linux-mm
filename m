Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 318C56B0036
	for <linux-mm@kvack.org>; Tue, 28 May 2013 08:51:00 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <519BD65C.1050709@sr71.net>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-16-git-send-email-kirill.shutemov@linux.intel.com>
 <519BD65C.1050709@sr71.net>
Subject: Re: [PATCHv4 15/39] thp, mm: trigger bug in replace_page_cache_page()
 on THP
Content-Transfer-Encoding: 7bit
Message-Id: <20130528125328.5385CE0090@blue.fi.intel.com>
Date: Tue, 28 May 2013 15:53:28 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > replace_page_cache_page() is only used by FUSE. It's unlikely that we
> > will support THP in FUSE page cache any soon.
> > 
> > Let's pospone implemetation of THP handling in replace_page_cache_page()
> > until any will use it.
> ...
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 657ce82..3a03426 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -428,6 +428,8 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
> >  {
> >  	int error;
> >  
> > +	VM_BUG_ON(PageTransHuge(old));
> > +	VM_BUG_ON(PageTransHuge(new));
> >  	VM_BUG_ON(!PageLocked(old));
> >  	VM_BUG_ON(!PageLocked(new));
> >  	VM_BUG_ON(new->mapping);
> 
> The code calling replace_page_cache_page() has a bunch of fallback and
> error returning code.  It seems a little bit silly to bring the whole
> machine down when you could just WARN_ONCE() and return an error code
> like fuse already does:

What about:

	if (WARN_ONCE(PageTransHuge(old) || PageTransHuge(new),
		     "%s: unexpected huge page\n", __func__))
		return -EINVAL;

?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
