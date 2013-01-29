Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id A11B76B005C
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 08:00:53 -0500 (EST)
Date: Tue, 29 Jan 2013 15:01:27 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Message-ID: <5107c827d855d_f167d78c842627@blue.mail>
In-Reply-To: <CAJd=RBAAdYef6+sHnD9kS=7mygSrgAD3cDW1wk8YsT2OK0sfZQ@mail.gmail.com>
References: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com> <1359365068-10147-7-git-send-email-kirill.shutemov@linux.intel.com> <CAJd=RBAAdYef6+sHnD9kS=7mygSrgAD3cDW1wk8YsT2OK0sfZQ@mail.gmail.com>
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
> > @@ -443,6 +443,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
> >                 pgoff_t offset, gfp_t gfp_mask)
> >  {
> >         int error;
> > +       int nr = 1;
> >
> >         VM_BUG_ON(!PageLocked(page));
> >         VM_BUG_ON(PageSwapBacked(page));
> > @@ -450,31 +451,61 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
> >         error = mem_cgroup_cache_charge(page, current->mm,
> >                                         gfp_mask & GFP_RECLAIM_MASK);
> >         if (error)
> > -               goto out;
> > +               return error;
> 
> Due to PageCompound check, thp could not be charged effectively.
> Any change added for charging it?

I've missed this. Will fix.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
