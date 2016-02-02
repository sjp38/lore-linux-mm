Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id AB5BB6B0005
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 17:03:27 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l66so137601104wml.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 14:03:27 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id uj7si5139080wjc.0.2016.02.02.14.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 14:03:26 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id l66so43671079wml.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 14:03:26 -0800 (PST)
Date: Wed, 3 Feb 2016 00:03:23 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 2/2] mm: downgrade VM_BUG in isolate_lru_page() to
 warning
Message-ID: <20160202220323.GA7561@node.shutemov.name>
References: <1454430061-116955-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1454430061-116955-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20160202125844.43f23e2f8637b5a304b887dc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160202125844.43f23e2f8637b5a304b887dc@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dmitry Vyukov <dvyukov@google.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 02, 2016 at 12:58:44PM -0800, Andrew Morton wrote:
> On Tue,  2 Feb 2016 19:21:01 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > Calling isolate_lru_page() is wrong and shouldn't happen, but it not
> > nessesary fatal: the page just will not be isolated if it's not on LRU.
> > 
> > Let's downgrade the VM_BUG_ON_PAGE() to WARN_RATELIMIT().
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  mm/vmscan.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index eb3dd37ccd7c..71b1c29948db 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1443,7 +1443,7 @@ int isolate_lru_page(struct page *page)
> >  	int ret = -EBUSY;
> >  
> >  	VM_BUG_ON_PAGE(!page_count(page), page);
> > -	VM_BUG_ON_PAGE(PageTail(page), page);
> > +	WARN_RATELIMIT(PageTail(page), "trying to isolate tail page");
> >  
> >  	if (PageLRU(page)) {
> >  		struct zone *zone = page_zone(page);
> 
> Confused.  I thought mm-fix-bogus-vm_bug_on_page-in-isolate_lru_page.patch:
> 
> --- a/mm/vmscan.c~mm-fix-bogus-vm_bug_on_page-in-isolate_lru_page
> +++ a/mm/vmscan.c
> @@ -1443,7 +1443,7 @@ int isolate_lru_page(struct page *page)
>  	int ret = -EBUSY;
>  
>  	VM_BUG_ON_PAGE(!page_count(page), page);
> -	VM_BUG_ON_PAGE(PageTail(page), page);
> +	VM_BUG_ON_PAGE(PageLRU(page) && PageTail(page), page);
>  
>  	if (PageLRU(page)) {
>  		struct zone *zone = page_zone(page);
> 
> was better.  We *know* that we sometimes encounter LRU pages here and
> we know that we handle them correctly.  So why scare users by blurting
> out a warning about something for which we won't be taking any action?

We will.

If we try to isolate tail page something went wrong. It just shouldn't
happen. Compound pages should be isolated by head page as only whole
compound page is on LRU, not subpages.

If we see tail page here it's most probably from broken driver which
forgot to set VM_IO. With setting VM_IO on such VMA we would avoid useless
scan through pte in them and save some time.

Or maybe something else is broken. Like we forgot to split THP before
migration.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
