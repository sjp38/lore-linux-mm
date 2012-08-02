Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 0BFF96B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 09:33:14 -0400 (EDT)
Date: Thu, 2 Aug 2012 14:33:10 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
Message-ID: <20120802133310.GD29814@suse.de>
References: <20120731124650.GO612@suse.de>
 <50181AA1.0@redhat.com>
 <20120731200650.GB19524@tiehlicka.suse.cz>
 <50189857.4000501@redhat.com>
 <20120801082036.GC4436@tiehlicka.suse.cz>
 <20120801123209.GK4436@tiehlicka.suse.cz>
 <501945F9.2030402@redhat.com>
 <20120802071934.GA7557@dhcp22.suse.cz>
 <20120802073757.GC29814@suse.de>
 <20120802123658.GA5194@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120802123658.GA5194@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 02, 2012 at 02:36:58PM +0200, Michal Hocko wrote:
> On Thu 02-08-12 08:37:57, Mel Gorman wrote:
> > On Thu, Aug 02, 2012 at 09:19:34AM +0200, Michal Hocko wrote:
> [...]
> > > On the other hand, mine is more coupled with the sharing code so it
> > > makes the code easier to follow and also makes the sharing more
> > > effective because racing processes see pmd populated when checking for
> > > shareable mappings.
> > > 
> > 
> > It could do with a small comment above huge_pmd_share() explaining that
> > calling pmd_alloc() under the i_mmap_mutex is necessary to prevent two
> > parallel faults missing a sharing opportunity with each other but it's
> > not mandatory.
> 
> Sure, that's a good idea. What about the following:
> 
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> index 40b2500..51839d1 100644
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -56,7 +56,13 @@ static int vma_shareable(struct vm_area_struct *vma, unsigned long addr)
>  }
>  
>  /*
> - * search for a shareable pmd page for hugetlb.
> + * search for a shareable pmd page for hugetlb. In any case calls
> + * pmd_alloc and returns the corresponding pte. While this not necessary
> + * for the !shared pmd case because we can allocate the pmd later as
> + * well it makes the code much cleaner. pmd allocation is essential for
> + * the shared case though because pud has to be populated inside the
> + * same i_mmap_mutex section otherwise racing tasks could either miss
> + * the sharing (see huge_pte_offset) or selected a bad pmd for sharing.
>   */
>  static pte_t*
>  huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> 

Looks reasonable to me.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
