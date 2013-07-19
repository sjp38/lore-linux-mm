Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id D9A6C6B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 00:36:50 -0400 (EDT)
Date: Fri, 19 Jul 2013 00:36:13 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1374208573-y6d9p8yt-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAJd=RBBv6rhKqb-30SDaZF3DFf2Nc=Odfo8=uRXQ8m40v_1rKg@mail.gmail.com>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374183272-10153-5-git-send-email-n-horiguchi@ah.jp.nec.com>
 <CAJd=RBBv6rhKqb-30SDaZF3DFf2Nc=Odfo8=uRXQ8m40v_1rKg@mail.gmail.com>
Subject: Re: [PATCH 4/8] migrate: add hugepage migration code to move_pages()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jul 19, 2013 at 11:36:19AM +0800, Hillf Danton wrote:
> On Fri, Jul 19, 2013 at 5:34 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > This patch extends move_pages() to handle vma with VM_HUGETLB set.
> > We will be able to migrate hugepage with move_pages(2) after
> > applying the enablement patch which comes later in this series.
> >
> > We avoid getting refcount on tail pages of hugepage, because unlike thp,
> > hugepage is not split and we need not care about races with splitting.
> >
> > And migration of larger (1GB for x86_64) hugepage are not enabled.
> >
> > ChangeLog v3:
> >  - revert introducing migrate_movable_pages
> >  - follow_page_mask(FOLL_GET) returns NULL for tail pages
> >  - use isolate_huge_page
> >
> > ChangeLog v2:
> >  - updated description and renamed patch title
> >
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  mm/memory.c  | 12 ++++++++++--
> >  mm/migrate.c | 13 +++++++++++--
> >  2 files changed, 21 insertions(+), 4 deletions(-)
> >
> > diff --git v3.11-rc1.orig/mm/memory.c v3.11-rc1/mm/memory.c
> > index 1ce2e2a..8c9a2cb 100644
> > --- v3.11-rc1.orig/mm/memory.c
> > +++ v3.11-rc1/mm/memory.c
> > @@ -1496,7 +1496,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
> >         if (pud_none(*pud))
> >                 goto no_page_table;
> >         if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
> > -               BUG_ON(flags & FOLL_GET);
> > +               if (flags & FOLL_GET)
> > +                       goto out;
> >                 page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
> >                 goto out;
> >         }
> > @@ -1507,8 +1508,15 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
> >         if (pmd_none(*pmd))
> >                 goto no_page_table;
> >         if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
> > -               BUG_ON(flags & FOLL_GET);
> >                 page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
> > +               if (flags & FOLL_GET) {
> > +                       if (PageHead(page))
> > +                               get_page_foll(page);
> > +                       else {
> > +                               page = NULL;
> > +                               goto out;
> > +                       }
> > +               }
> 
> Can get_page do the work for us, like the following?
> 
> 		if (flags & FOLL_GET)
> 			get_page(page);

Ohh, OK. We should use get_page instead of get_page_foll, because
get_page_foll is for thp.
However, I think that if(PageHead) blocks are necessary because
otherwise we get refcounts on tail pages and release them immediately
in the caller's side, which is fragile (this was discussed previously.)
  http://thread.gmane.org/gmane.linux.kernel.mm/96665/focus=96818
Anyway I'll add comment on this hunk in the next post.

Thanks,
Naoya

> >                 goto out;
> >         }
> >         if ((flags & FOLL_NUMA) && pmd_numa(*pmd))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
