Subject: Re: [RFC] shared page table for hugetlbpage memory causing leak.
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <20080117101946.GJ11384@balbir.in.ibm.com>
References: <478E3DFA.9050900@redhat.com>
	 <1200509668.3296.204.camel@localhost.localdomain>
	 <20080117101946.GJ11384@balbir.in.ibm.com>
Content-Type: text/plain
Date: Thu, 17 Jan 2008 06:53:38 -0500
Message-Id: <1200570818.18160.2.camel@dhcp83-56.boston.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-01-17 at 15:49 +0530, Balbir Singh wrote:
> * Adam Litke <agl@us.ibm.com> [2008-01-16 12:54:28]:
> 
> > Since we know we are dealing with a hugetlb VMA, how about the
> > following, simpler, _untested_ patch:
> > 
> > Signed-off-by: Adam Litke <agl@us.ibm.com>
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 6f97821..75b0e4f 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -644,6 +644,11 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
> >  		dst_pte = huge_pte_alloc(dst, addr);
> >  		if (!dst_pte)
> >  			goto nomem;
> > +
> > +		/* If page table is shared do not copy or take references */
> > +		if (src_pte == dst_pte)
> > +			continue;
> > +
> 
> Shouldn't you be checking the PTE contents rather than the pointers?
No, this is chacking for shared page tables not shared pages.
> Shouldn't the check be
> 
>                 if (unlikely(pte_same(*src_pte, *dst_pte))
>                         continue;
> 
> 
> >  		spin_lock(&dst->page_table_lock);
> >  		spin_lock(&src->page_table_lock);
> >  		if (!pte_none(*src_pte)) {
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
