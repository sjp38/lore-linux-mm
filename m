Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id A04476B0033
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 18:42:16 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20130717140953.7560e88e607f8f5df1b1fdd8@linux-foundation.org>
References: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1373885274-25249-6-git-send-email-kirill.shutemov@linux.intel.com>
 <20130717140953.7560e88e607f8f5df1b1fdd8@linux-foundation.org>
Subject: Re: [PATCH 5/8] thp, mm: locking tail page is a bug
Content-Transfer-Encoding: 7bit
Message-Id: <20130717224518.6DDAAE0090@blue.fi.intel.com>
Date: Thu, 18 Jul 2013 01:45:18 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Andrew Morton wrote:
> On Mon, 15 Jul 2013 13:47:51 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > Locking head page means locking entire compound page.
> > If we try to lock tail page, something went wrong.
> > 
> > ..
> >
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -639,6 +639,7 @@ void __lock_page(struct page *page)
> >  {
> >  	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
> >  
> > +	VM_BUG_ON(PageTail(page));
> >  	__wait_on_bit_lock(page_waitqueue(page), &wait, sleep_on_page,
> >  							TASK_UNINTERRUPTIBLE);
> >  }
> > @@ -648,6 +649,7 @@ int __lock_page_killable(struct page *page)
> >  {
> >  	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
> >  
> > +	VM_BUG_ON(PageTail(page));
> >  	return __wait_on_bit_lock(page_waitqueue(page), &wait,
> >  					sleep_on_page_killable, TASK_KILLABLE);
> >  }
> 
> lock_page() is a pretty commonly called function, and I assume quite a
> lot of people run with CONFIG_DEBUG_VM=y.
> 
> Is the overhead added by this patch really worthwhile?

I found it useful, especially, when I was starting experiments with THP
for pagecache. But feel free to drop it if think that it adds to much
overhead.

> I'm thinking I might leave it in -mm indefinitely but not send it
> upstream.

Works for me too.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
