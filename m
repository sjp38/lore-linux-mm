Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 3BD126B0027
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 11:03:44 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CAJd=RBBL7VV50zHP2obJ7_CzOekgH9i-E3Fz3PO5YXk5f=B2Kw@mail.gmail.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-9-git-send-email-kirill.shutemov@linux.intel.com>
 <CAJd=RBAH1+YaDvL9=ayx2j6b4jx0CzBZGrAL9LVwPMx4Y=s3Rg@mail.gmail.com>
 <20130315132333.B8205E0085@blue.fi.intel.com>
 <CAJd=RBAh7-qBYhCxtj56V5sez1HSek9TNVeu9V=+mW0qNpxEWA@mail.gmail.com>
 <20130315135026.32B58E0085@blue.fi.intel.com>
 <CAJd=RBBL7VV50zHP2obJ7_CzOekgH9i-E3Fz3PO5YXk5f=B2Kw@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 08/30] thp, mm: rewrite add_to_page_cache_locked()
 to support huge pages
Content-Transfer-Encoding: 7bit
Message-Id: <20130315150522.8BF97E0085@blue.fi.intel.com>
Date: Fri, 15 Mar 2013 17:05:22 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hillf Danton wrote:
> On Fri, Mar 15, 2013 at 9:50 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > Hillf Danton wrote:
> >> On Fri, Mar 15, 2013 at 9:23 PM, Kirill A. Shutemov
> >> <kirill.shutemov@linux.intel.com> wrote:
> >> > Hillf Danton wrote:
> >> >> On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
> >> >> <kirill.shutemov@linux.intel.com> wrote:
> >> >> > +       page_cache_get(page);
> >> >> > +       spin_lock_irq(&mapping->tree_lock);
> >> >> > +       page->mapping = mapping;
> >> >> > +       page->index = offset;
> >> >> > +       error = radix_tree_insert(&mapping->page_tree, offset, page);
> >> >> > +       if (unlikely(error))
> >> >> > +               goto err;
> >> >> > +       if (PageTransHuge(page)) {
> >> >> > +               int i;
> >> >> > +               for (i = 1; i < HPAGE_CACHE_NR; i++) {
> >> >>                       struct page *tail = page + i; to easy reader
> >> >>
> >> >> > +                       page_cache_get(page + i);
> >> >> s/page_cache_get/get_page_foll/ ?
> >> >
> >> > Why?
> >> >
> >> see follow_trans_huge_pmd() please.
> >
> > Sorry, I fail to see how follow_trans_huge_pmd() is relevant here.
> > Could you elaborate?
> >
> Lets see the code
> 
> 	page += (addr & ~HPAGE_PMD_MASK) >> PAGE_SHIFT;
> //page is tail now
> 	VM_BUG_ON(!PageCompound(page));
> 	if (flags & FOLL_GET)
> 		get_page_foll(page);
> //raise page count with the foll function
> 
> thus I raised question.

get_page_foll() is designed to be part of follow_page*() call chain.
get_page() can handle compound pages properly.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
