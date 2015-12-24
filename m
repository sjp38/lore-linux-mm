Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 54DBE82F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 17:56:27 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p187so193842160wmp.0
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 14:56:27 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id l6si74562943wje.171.2015.12.24.14.56.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Dec 2015 14:56:25 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id p187so190812058wmp.1
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 14:56:25 -0800 (PST)
Date: Fri, 25 Dec 2015 00:56:23 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/4] thp: fix regression in handling mlocked pages in
 __split_huge_pmd()
Message-ID: <20151224225623.GA22707@node.shutemov.name>
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1450957883-96356-3-git-send-email-kirill.shutemov@linux.intel.com>
 <CAPcyv4iRPEw7tPT7bCBX+0eYbrTU679moLZ+zff1RXUvoDmCoA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iRPEw7tPT7bCBX+0eYbrTU679moLZ+zff1RXUvoDmCoA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Linux MM <linux-mm@kvack.org>

On Thu, Dec 24, 2015 at 10:51:43AM -0800, Dan Williams wrote:
> On Thu, Dec 24, 2015 at 3:51 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > This patch fixes regression caused by patch
> >  "mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd"
> >
> > The patch makes pmd_trans_huge() check and "page = pmd_page(*pmd)" after
> > __split_huge_pmd_locked(). It can never succeed, since the pmd already
> > points to a page table. As result the page is never get munlocked.
> >
> > It causes crashes like this:
> >  http://lkml.kernel.org/r/5661FBB6.6050307@oracle.com
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Reported-by: Sasha Levin <sasha.levin@oracle.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  mm/huge_memory.c | 8 +++-----
> >  1 file changed, 3 insertions(+), 5 deletions(-)
> >
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 99f2a0ecb621..1a988d9b86ef 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -3024,14 +3024,12 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> >         ptl = pmd_lock(mm, pmd);
> >         if (unlikely(!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)))
> >                 goto out;
> > -       __split_huge_pmd_locked(vma, pmd, haddr, false);
> > -
> > -       if (pmd_trans_huge(*pmd))
> > -               page = pmd_page(*pmd);
> > -       if (page && PageMlocked(page))
> > +       page = pmd_page(*pmd);
> > +       if (PageMlocked(page))
> >                 get_page(page);
> >         else
> >                 page = NULL;
> > +       __split_huge_pmd_locked(vma, pmd, haddr, false);
> 
> Since dax pmd mappings may not have a backing struct page I think this
> additionally needs the following:
> 
> 8<-----
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 4eae97325e95..c4eccfa836f4 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -3025,11 +3025,13 @@ void __split_huge_pmd(struct vm_area_struct
> *vma, pmd_t *pmd,
>        ptl = pmd_lock(mm, pmd);
>        if (unlikely(!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)))
>                goto out;
> -       page = pmd_page(*pmd);
> -       if (PageMlocked(page))
> -               get_page(page);
> -       else
> -               page = NULL;
> +       else if (pmd_trans_huge(*pmd)) {
> +               page = pmd_page(*pmd);
> +               if (PageMlocked(page))
> +                       get_page(page);
> +               else
> +                       page = NULL;
> +       }
>        __split_huge_pmd_locked(vma, pmd, haddr, false);
> out:
>        spin_unlock(ptl);
> 

Right, I've missed that. Here's updated patch.
