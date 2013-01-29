Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 54DCE6B003D
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 07:48:58 -0500 (EST)
Date: Tue, 29 Jan 2013 14:48:37 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Message-ID: <5107c525eb8d1_f167d78c8425f9@blue.mail>
In-Reply-To: <CAJd=RBCCmDrS=866SMEezcsCCX3vrfnusUFoyaRQb+c=JCkFEg@mail.gmail.com>
References: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com> <1359365068-10147-7-git-send-email-kirill.shutemov@linux.intel.com> <CAJd=RBCCmDrS=866SMEezcsCCX3vrfnusUFoyaRQb+c=JCkFEg@mail.gmail.com>
Subject: Re: [PATCH, RFC 06/16] thp, mm: rewrite add_to_page_cache_locked() to
 support huge pages
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

Hillf Danton wrote:
> On Mon, Jan 28, 2013 at 5:24 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > +       page_cache_get(page);
> > +       spin_lock_irq(&mapping->tree_lock);
> > +       page->mapping = mapping;
> > +       if (PageTransHuge(page)) {
> > +               int i;
> > +               for (i = 0; i < HPAGE_CACHE_NR; i++) {
> > +                       page_cache_get(page + i);
> > +                       page[i].index = offset + i;
> > +                       error = radix_tree_insert(&mapping->page_tree,
> > +                                       offset + i, page + i);
> > +                       if (error) {
> > +                               page_cache_release(page + i);
> > +                               break;
> > +                       }
> 
> Is page count balanced with the following?

It's broken. Last minue changes are evil :(

Thanks for catching it. I'll fix it in next revision.

> @@ -168,6 +180,9 @@ void delete_from_page_cache(struct page *page)
> 
>         if (freepage)
>                 freepage(page);
> +       if (PageTransHuge(page))
> +               for (i = 1; i < HPAGE_CACHE_NR; i++)
> +                       page_cache_release(page);
>         page_cache_release(page);

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
