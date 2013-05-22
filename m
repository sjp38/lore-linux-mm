Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id AE43A6B00DB
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:23:51 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CAJd=RBAwi6mUv0GqTobfPS7X4kpaRVD_NFg6WvCodkSmy+7uKA@mail.gmail.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-34-git-send-email-kirill.shutemov@linux.intel.com>
 <CAJd=RBAwi6mUv0GqTobfPS7X4kpaRVD_NFg6WvCodkSmy+7uKA@mail.gmail.com>
Subject: Re: [PATCHv4 33/39] thp, mm: implement do_huge_linear_fault()
Content-Transfer-Encoding: 7bit
Message-Id: <20130522152615.A4E22E0090@blue.fi.intel.com>
Date: Wed, 22 May 2013 18:26:15 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hillf Danton wrote:
> On Sun, May 12, 2013 at 9:23 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >         page = vmf.page;
> > +
> > +       /*
> > +        * If we asked for huge page we expect to get it or VM_FAULT_FALLBACK.
> > +        * If we don't ask for huge page it must be splitted in ->fault().
> > +        */
> > +       BUG_ON(PageTransHuge(page) != thp);
> > +
> Based on the log message in 34/39(
> If the area of page cache required to create huge is empty, we create a
> new huge page and return it.), the above trap looks bogus.

The statement in 34/39 is true for (flags & FAULT_FLAG_TRANSHUGE).
For !(flags & FAULT_FLAG_TRANSHUGE) huge page must be split in ->fault.

The BUG_ON() above is shortcut for two checks:

if (thp)
	BUG_ON(!PageTransHuge(page));
if (!thp)
	BUG_ON(PageTransHuge(page));

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
