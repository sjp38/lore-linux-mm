Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 2AA276B0002
	for <linux-mm@kvack.org>; Thu, 23 May 2013 08:07:00 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CAJd=RBA64hW7x6u0Mou4_z_Ox3J+sC3ZL+a4h8XcTHbXZicALg@mail.gmail.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-38-git-send-email-kirill.shutemov@linux.intel.com>
 <CAJd=RBA64hW7x6u0Mou4_z_Ox3J+sC3ZL+a4h8XcTHbXZicALg@mail.gmail.com>
Subject: Re: [PATCHv4 37/39] thp: handle write-protect exception to
 file-backed huge pages
Content-Transfer-Encoding: 7bit
Message-Id: <20130523120856.DD752E0090@blue.fi.intel.com>
Date: Thu, 23 May 2013 15:08:56 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hillf Danton wrote:
> On Sun, May 12, 2013 at 9:23 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > @@ -1120,7 +1119,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >
> >         page = pmd_page(orig_pmd);
> >         VM_BUG_ON(!PageCompound(page) || !PageHead(page));
> > -       if (page_mapcount(page) == 1) {
> > +       if (PageAnon(page) && page_mapcount(page) == 1) {
> 
> Could we avoid copying huge page if
> no-one else is using it, no matter anon?

No. The page is still in page cache and can be later accessed later.
We could isolate the page from page cache, but I'm not sure whether it's
good idea.

do_wp_page() does exectly the same for small pages, so let's keep it
consistent.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
