Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 67CC46B0031
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 07:34:04 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CACz4_2fJPngXwijEQcmVYB67u_4QDDJkpiyCv4K0iCFdmPsDuA@mail.gmail.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-4-git-send-email-kirill.shutemov@linux.intel.com>
 <CACz4_2fJPngXwijEQcmVYB67u_4QDDJkpiyCv4K0iCFdmPsDuA@mail.gmail.com>
Subject: Re: [PATCH 03/23] thp: compile-time and sysfs knob for thp pagecache
Content-Transfer-Encoding: 7bit
Message-Id: <20130906113358.6D8EEE0090@blue.fi.intel.com>
Date: Fri,  6 Sep 2013 14:33:58 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Ning Qu wrote:
> One minor question inline.
> 
> Best wishes,
> -- 
> Ning Qu (ae?2a(R)?) | Software Engineer | quning@google.com | +1-408-418-6066
> 
> 
> On Sat, Aug 3, 2013 at 7:17 PM, Kirill A. Shutemov <
> kirill.shutemov@linux.intel.com> wrote:
> 
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >
> > For now, TRANSPARENT_HUGEPAGE_PAGECACHE is only implemented for x86_64.
> >
> > Radix tree perload overhead can be significant on BASE_SMALL systems, so
> > let's add dependency on !BASE_SMALL.
> >
> > /sys/kernel/mm/transparent_hugepage/page_cache is runtime knob for the
> > feature. It's enabled by default if TRANSPARENT_HUGEPAGE_PAGECACHE is
> > enabled.
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  Documentation/vm/transhuge.txt |  9 +++++++++
> >  include/linux/huge_mm.h        |  9 +++++++++
> >  mm/Kconfig                     | 12 ++++++++++++
> >  mm/huge_memory.c               | 23 +++++++++++++++++++++++
> >  4 files changed, 53 insertions(+)
> >
> > diff --git a/Documentation/vm/transhuge.txt
> > b/Documentation/vm/transhuge.txt
> > index 4a63953..4cc15c4 100644
> > --- a/Documentation/vm/transhuge.txt
> > +++ b/Documentation/vm/transhuge.txt
> > @@ -103,6 +103,15 @@ echo always
> > >/sys/kernel/mm/transparent_hugepage/enabled
> >  echo madvise >/sys/kernel/mm/transparent_hugepage/enabled
> >  echo never >/sys/kernel/mm/transparent_hugepage/enabled
> >
> > +If TRANSPARENT_HUGEPAGE_PAGECACHE is enabled kernel will use huge pages in
> > +page cache if possible. It can be disable and re-enabled via sysfs:
> > +
> > +echo 0 >/sys/kernel/mm/transparent_hugepage/page_cache
> > +echo 1 >/sys/kernel/mm/transparent_hugepage/page_cache
> > +
> > +If it's disabled kernel will not add new huge pages to page cache and
> > +split them on mapping, but already mapped pages will stay intakt.
> > +
> >  It's also possible to limit defrag efforts in the VM to generate
> >  hugepages in case they're not immediately free to madvise regions or
> >  to never try to defrag memory and simply fallback to regular pages
> > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> > index 3935428..1534e1e 100644
> > --- a/include/linux/huge_mm.h
> > +++ b/include/linux/huge_mm.h
> > @@ -40,6 +40,7 @@ enum transparent_hugepage_flag {
> >         TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
> >         TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
> >         TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG,
> > +       TRANSPARENT_HUGEPAGE_PAGECACHE,
> >         TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG,
> >  #ifdef CONFIG_DEBUG_VM
> >         TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,
> > @@ -229,4 +230,12 @@ static inline int do_huge_pmd_numa_page(struct
> > mm_struct *mm, struct vm_area_str
> >
> >  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> >
> > +static inline bool transparent_hugepage_pagecache(void)
> > +{
> > +       if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE))
> > +               return false;
> > +       if (!(transparent_hugepage_flags & (1<<TRANSPARENT_HUGEPAGE_FLAG)))
> >
> 
> Here, I suppose we should test the  TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG as
> well? E.g.
>         if (!(transparent_hugepage_flags &
>               ((1<<TRANSPARENT_HUGEPAGE_FLAG) |
>                (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))))
> 
> +               return false;

You're right. Fixed.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
