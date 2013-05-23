Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id A7FFF6B0002
	for <linux-mm@kvack.org>; Thu, 23 May 2013 07:46:04 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CAJd=RBCP+YvA46j8K7pXDGBLdLgh2+Db9RDrHU4DP7JHsv_Qcw@mail.gmail.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-40-git-send-email-kirill.shutemov@linux.intel.com>
 <CAJd=RBCP+YvA46j8K7pXDGBLdLgh2+Db9RDrHU4DP7JHsv_Qcw@mail.gmail.com>
Subject: Re: [PATCHv4 39/39] thp: map file-backed huge pages on fault
Content-Transfer-Encoding: 7bit
Message-Id: <20130523114829.B5692E0090@blue.fi.intel.com>
Date: Thu, 23 May 2013 14:48:29 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hillf Danton wrote:
> On Sun, May 12, 2013 at 9:23 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >
> > Look like all pieces are in place, we can map file-backed huge-pages
> > now.
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  include/linux/huge_mm.h |    4 +++-
> >  mm/memory.c             |    5 ++++-
> >  2 files changed, 7 insertions(+), 2 deletions(-)
> >
> > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> > index f4d6626..903f097 100644
> > --- a/include/linux/huge_mm.h
> > +++ b/include/linux/huge_mm.h
> > @@ -78,7 +78,9 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
> >            (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG) &&                   \
> >            ((__vma)->vm_flags & VM_HUGEPAGE))) &&                       \
> >          !((__vma)->vm_flags & VM_NOHUGEPAGE) &&                        \
> > -        !is_vma_temporary_stack(__vma))
> > +        !is_vma_temporary_stack(__vma) &&                              \
> > +        (!(__vma)->vm_ops ||                                           \
> > +                 mapping_can_have_hugepages((__vma)->vm_file->f_mapping)))
> 
> Redefine, why?
> 
> >  #define transparent_hugepage_defrag(__vma)                             \
> >         ((transparent_hugepage_flags &                                  \
> >           (1<<TRANSPARENT_HUGEPAGE_DEFRAG_FLAG)) ||                     \
> > diff --git a/mm/memory.c b/mm/memory.c
> > index ebff552..7fe9752 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3939,10 +3939,13 @@ retry:
> >         if (!pmd)
> >                 return VM_FAULT_OOM;
> >         if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
> > -               int ret = 0;
> > +               int ret;
> >                 if (!vma->vm_ops)
> >                         ret = do_huge_pmd_anonymous_page(mm, vma, address,
> >                                         pmd, flags);
> 
> Ah vma->vm_ops is checked here, so
> 		else if (mapping_can_have_hugepages())

Okay, it's cleaner.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
