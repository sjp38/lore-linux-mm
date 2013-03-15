Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 89D9A6B0027
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 09:22:12 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CAJd=RBAH1+YaDvL9=ayx2j6b4jx0CzBZGrAL9LVwPMx4Y=s3Rg@mail.gmail.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-9-git-send-email-kirill.shutemov@linux.intel.com>
 <CAJd=RBAH1+YaDvL9=ayx2j6b4jx0CzBZGrAL9LVwPMx4Y=s3Rg@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 08/30] thp, mm: rewrite add_to_page_cache_locked()
 to support huge pages
Content-Transfer-Encoding: 7bit
Message-Id: <20130315132333.B8205E0085@blue.fi.intel.com>
Date: Fri, 15 Mar 2013 15:23:33 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hillf Danton wrote:
> On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > +       page_cache_get(page);
> > +       spin_lock_irq(&mapping->tree_lock);
> > +       page->mapping = mapping;
> > +       page->index = offset;
> > +       error = radix_tree_insert(&mapping->page_tree, offset, page);
> > +       if (unlikely(error))
> > +               goto err;
> > +       if (PageTransHuge(page)) {
> > +               int i;
> > +               for (i = 1; i < HPAGE_CACHE_NR; i++) {
> 			struct page *tail = page + i; to easy reader
> 
> > +                       page_cache_get(page + i);
> s/page_cache_get/get_page_foll/ ?

Why?

> > +                       page[i].index = offset + i;
> > +                       error = radix_tree_insert(&mapping->page_tree,
> > +                                       offset + i, page + i);
> > +                       if (error) {
> > +                               page_cache_release(page + i);
> > +                               break;
> > +                       }
> >                 }
> > -               radix_tree_preload_end();
> > -       } else
> > -               mem_cgroup_uncharge_cache_page(page);
> > -out:
> > +               if (error) {
> > +                       error = ENOSPC; /* no space for a huge page */
> s/E/-E/

Good catch! Thanks.

> > +                       for (i--; i > 0; i--) {
> > +                               radix_tree_delete(&mapping->page_tree,
> > +                                               offset + i);
> > +                               page_cache_release(page + i);
> > +                       }
> > +                       radix_tree_delete(&mapping->page_tree, offset);
> > +                       goto err;
> > +               }
> > +       }

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
