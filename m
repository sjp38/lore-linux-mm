Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 870F06B0027
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 11:30:05 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <514CA325.3010104@sr71.net>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-19-git-send-email-kirill.shutemov@linux.intel.com>
 <514CA325.3010104@sr71.net>
Subject: Re: [PATCHv2, RFC 18/30] thp, mm: truncate support for transparent
 huge page cache
Content-Transfer-Encoding: 7bit
Message-Id: <20130328153152.54DDAE0085@blue.fi.intel.com>
Date: Thu, 28 Mar 2013 17:31:52 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave wrote:
> On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> > @@ -280,6 +291,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
> >  			if (index > end)
> >  				break;
> >  
> > +			VM_BUG_ON(PageTransHuge(page));
> >  			lock_page(page);
> >  			WARN_ON(page->index != index);
> >  			wait_on_page_writeback(page);
> 
> This looks to be during the second truncate pass where things are
> allowed to block.  What's the logic behind it not being possible to
> encounter TransHugePage()s here?

Good question.

The only way how the page can be created from under us is collapsing, but
it's not implemented for file pages and I'm not sure yet how to implement
it...

Probably, I'll replace the BUG with

if (PageTransHuge(page))
	split_huge_page(page);

It should be good enough.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
