Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 30CB56B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 10:01:23 -0400 (EDT)
Date: Tue, 23 Jul 2013 16:01:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: hugepage related lockdep trace.
Message-ID: <20130723140120.GG8677@dhcp22.suse.cz>
References: <20130717153223.GD27731@redhat.com>
 <20130718000901.GA31972@blaptop>
 <87hafrdatb.fsf@linux.vnet.ibm.com>
 <20130719001303.GB23354@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130719001303.GB23354@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri 19-07-13 09:13:03, Minchan Kim wrote:
> On Thu, Jul 18, 2013 at 11:12:24PM +0530, Aneesh Kumar K.V wrote:
[...]
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 83aff0a..2cb1be3 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -3266,8 +3266,8 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> >  		put_page(virt_to_page(spte));
> >  	spin_unlock(&mm->page_table_lock);
> >  out:
> > -	pte = (pte_t *)pmd_alloc(mm, pud, addr);
> >  	mutex_unlock(&mapping->i_mmap_mutex);
> > +	pte = (pte_t *)pmd_alloc(mm, pud, addr);
> >  	return pte;
> 
> I am blind on hugetlb but not sure it doesn't break eb48c071.
> Michal?

Well, it is some time since I debugged the race and all the details
vanished in the meantime. But this part of the changelog suggests that
this indeed breaks the fix:
"
    This patch addresses the issue by moving pmd_alloc into huge_pmd_share
    which guarantees that the shared pud is populated in the same critical
    section as pmd.  This also means that huge_pte_offset test in
    huge_pmd_share is serialized correctly now which in turn means that the
    success of the sharing will be higher as the racing tasks see the pud
    and pmd populated together.
"

Besides that I fail to see how moving pmd_alloc down changes anything.
Even if pmd_alloc triggered reclaim then we cannot trip over the same
i_mmap_mutex as hugetlb pages are not reclaimable because they are not
on the LRU.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
