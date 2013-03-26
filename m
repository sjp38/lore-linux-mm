Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 3E12A6B00BB
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 01:13:24 -0400 (EDT)
Date: Tue, 26 Mar 2013 01:13:10 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1364274790-z44rtlpy-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130325130416.GV2154@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-6-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325130416.GV2154@dhcp22.suse.cz>
Subject: Re: [PATCH 05/10] migrate: add hugepage migration code to
 migrate_pages()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Mon, Mar 25, 2013 at 02:04:16PM +0100, Michal Hocko wrote:
> On Fri 22-03-13 16:23:50, Naoya Horiguchi wrote:
> [...]
> > @@ -523,6 +544,11 @@ static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
> >  	pmd = pmd_offset(pud, addr);
> >  	do {
> >  		next = pmd_addr_end(addr, end);
> > +		if (pmd_huge(*pmd) && is_vm_hugetlb_page(vma)) {
> > +			check_hugetlb_pmd_range(vma, pmd, nodes,
> > +						flags, private);
> 
> I am afraid this has the same issue with other huge page sizes I have
> mentioned earlier.

So we need arch-dependent helper functions. I'll try that, but it
might be better to start with enabling only x86_64 if it takes time
to implement this.

> > +			continue;
> > +		}
> >  		split_huge_page_pmd(vma, addr, pmd);
> >  		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
> >  			continue;
> [...]
> > @@ -1012,14 +1040,8 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
> >  	check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
> >  			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
> >  
> > -	if (!list_empty(&pagelist)) {
> > -		err = migrate_pages(&pagelist, new_node_page, dest,
> > +	return migrate_movable_pages(&pagelist, new_node_page, dest,
> >  					MIGRATE_SYNC, MR_SYSCALL);
> > -		if (err)
> > -			putback_lru_pages(&pagelist);
> > -	}
> > -
> > -	return err;
> 
> This is really confusing. Why migrate_pages doesn't do putback cleanup
> on its own but migrate_movable_pages does?

I consider migrate_movable_pages() as a wrapper of migrate_pages(),
not the variant of migrate_pages().
We can find the same pattern in the callers like

  if (!list_empty(&pagelist)) {
        err = migrate_pages(...);
        if (err)
                putback_lru_pages(&pagelist);
  }

, so it can be simplified by migrate_movable_pages().

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
