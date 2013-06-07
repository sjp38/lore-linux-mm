Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 3745B6B0036
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 11:14:44 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <519BE6ED.8030202@sr71.net>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-21-git-send-email-kirill.shutemov@linux.intel.com>
 <519BE6ED.8030202@sr71.net>
Subject: Re: [PATCHv4 20/39] thp, mm: naive support of thp in generic
 read/write routines
Content-Transfer-Encoding: 7bit
Message-Id: <20130607151718.E126AE0090@blue.fi.intel.com>
Date: Fri,  7 Jun 2013 18:17:18 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> > +		if (PageTransHuge(page))
> > +			offset = pos & ~HPAGE_PMD_MASK;
> > +
> >  		pagefault_disable();
> > -		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
> > +		copied = iov_iter_copy_from_user_atomic(
> > +				page + (offset >> PAGE_CACHE_SHIFT),
> > +				i, offset & ~PAGE_CACHE_MASK, bytes);
> >  		pagefault_enable();
> >  		flush_dcache_page(page);
> 
> I think there's enough voodoo in there to warrant a comment or adding
> some temporary variables.  There are three things going on that you wan
> to convey:
> 
> 1. Offset is normally <PAGE_SIZE, but you make it <HPAGE_PMD_SIZE if
>    you are dealing with a huge page
> 2. (offset >> PAGE_CACHE_SHIFT) is always 0 for small pages since
>     offset < PAGE_SIZE
> 3. "offset & ~PAGE_CACHE_MASK" does nothing for small-page offsets, but
>    it turns a large-page offset back in to a small-page-offset.
> 
> I think you can do it with something like this:
> 
>  	int subpage_nr = 0;
> 	off_t smallpage_offset = offset;
> 	if (PageTransHuge(page)) {
> 		// we transform 'offset' to be offset in to the huge
> 		// page instead of inside the PAGE_SIZE page
> 		offset = pos & ~HPAGE_PMD_MASK;
> 		subpage_nr = (offset >> PAGE_CACHE_SHIFT);
> 	}
> 	
> > +		copied = iov_iter_copy_from_user_atomic(
> > +				page + subpage_nr,
> > +				i, smallpage_offset, bytes);
> 
> 
> > @@ -2437,6 +2453,7 @@ again:
> >  			 * because not all segments in the iov can be copied at
> >  			 * once without a pagefault.
> >  			 */
> > +			offset = pos & ~PAGE_CACHE_MASK;
> 
> Urg, and now it's *BACK* in to a small-page offset?
> 
> This means that 'offset' has two _different_ meanings and it morphs
> between them during the function a couple of times.  That seems very
> error-prone to me.

I guess this way is better, right?

@@ -2382,6 +2393,7 @@ static ssize_t generic_perform_write(struct file *file,
                unsigned long bytes;    /* Bytes to write to page */
                size_t copied;          /* Bytes copied from user */
                void *fsdata;
+               int subpage_nr = 0;
 
                offset = (pos & (PAGE_CACHE_SIZE - 1));
                bytes = min_t(unsigned long, PAGE_CACHE_SIZE - offset,
@@ -2411,8 +2423,14 @@ again:
                if (mapping_writably_mapped(mapping))
                        flush_dcache_page(page);
 
+               if (PageTransHuge(page)) {
+                       off_t huge_offset = pos & ~HPAGE_PMD_MASK;
+                       subpage_nr = huge_offset >> PAGE_CACHE_SHIFT;
+               }
+
                pagefault_disable();
-               copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
+               copied = iov_iter_copy_from_user_atomic(page + subpage_nr, i,
+                               offset, bytes);
                pagefault_enable();
                flush_dcache_page(page);
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
