Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 32BA36B005A
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 11:54:36 -0400 (EDT)
Date: Mon, 6 Aug 2012 17:54:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2] hugetlb: correct page offset index for sharing pmd
Message-ID: <20120806155433.GB4850@dhcp22.suse.cz>
References: <CAJd=RBC9HhKh5Q0-yXi3W0x3guXJPFz4BNsniyOFmp0TjBdFqg@mail.gmail.com>
 <20120806132410.GA6150@dhcp22.suse.cz>
 <CAJd=RBCuvpG49JcTUY+qw-tTdH_vFLgOfJDE3sW97+M04TR+hg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBCuvpG49JcTUY+qw-tTdH_vFLgOfJDE3sW97+M04TR+hg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 06-08-12 21:37:45, Hillf Danton wrote:
> On Mon, Aug 6, 2012 at 9:24 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Sat 04-08-12 14:08:31, Hillf Danton wrote:
> >> The computation of page offset index is incorrect to be used in scanning
> >> prio tree, as huge page offset is required, and is fixed with well
> >> defined routine.
> >>
> >> Changes from v1
> >>       o s/linear_page_index/linear_hugepage_index/ for clearer code
> >>       o hp_idx variable added for less change
> >>
> >>
> >> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> >> ---
> >>
> >> --- a/arch/x86/mm/hugetlbpage.c       Fri Aug  3 20:34:58 2012
> >> +++ b/arch/x86/mm/hugetlbpage.c       Fri Aug  3 20:40:16 2012
> >> @@ -62,6 +62,7 @@ static void huge_pmd_share(struct mm_str
> >>  {
> >>       struct vm_area_struct *vma = find_vma(mm, addr);
> >>       struct address_space *mapping = vma->vm_file->f_mapping;
> >> +     pgoff_t hp_idx;
> >>       pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
> >>                       vma->vm_pgoff;
> >
> > So we have two indexes now. That is just plain ugly!
> >
> 
> Two indexes result in less code change here and no change
> in page_table_shareable. Plus linear_hugepage_index tells
> clearly readers that hp_idx and idx are different.

Why do you think they are different? It's the very same thing AFAICS.
It's just that page_table_shareable fix the index silently by saddr &
PUD_MASK.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
