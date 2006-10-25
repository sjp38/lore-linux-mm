Date: Wed, 25 Oct 2006 15:52:23 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 3/3] hugetlb: fix absurd HugePages_Rsvd
Message-ID: <20061025055223.GA2330@localhost.localdomain>
References: <Pine.LNX.4.64.0610250323570.30678@blonde.wat.veritas.com> <Pine.LNX.4.64.0610250335530.30678@blonde.wat.veritas.com> <453EF4C1.5050102@kolumbus.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <453EF4C1.5050102@kolumbus.fi>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mika =?iso-8859-1?Q?Penttil=E4?= <mika.penttila@kolumbus.fi>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Ken Chen <kenneth.w.chen@intel.com>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 25, 2006 at 08:23:13AM +0300, Mika Penttila wrote:
> Hugh Dickins wrote:
> >If you truncated an mmap'ed hugetlbfs file, then faulted on the truncated
> >area, /proc/meminfo's HugePages_Rsvd wrapped hugely "negative".  Reinstate
> >my preliminary i_size check before attempting to allocate the page (though
> >this only fixes the most obvious case: more work will be needed here).
> >
> >Signed-off-by: Hugh Dickins <hugh@veritas.com>
> >___
> >
> >This is not a complete solution (what if hugetlb_no_page is actually
> >racing with truncate_hugepages?), and there are several other accounting
> >anomalies in here (private versus shared pages, hugetlbfs quota handling);
> >but those all need more thought.  It'll probably make sense to use i_mutex
> >instead of hugetlb_instantiation_mutex, so locking out truncation and 
> >mmap.
> >
> > mm/hugetlb.c |    3 +++
> > 1 file changed, 3 insertions(+)
> >
> >--- 2.6.19-rc3/mm/hugetlb.c	2006-10-24 04:34:37.000000000 +0100
> >+++ linux/mm/hugetlb.c	2006-10-24 16:23:17.000000000 +0100
> >@@ -478,6 +478,9 @@ int hugetlb_no_page(struct mm_struct *mm
> > retry:
> > 	page = find_lock_page(mapping, idx);
> > 	if (!page) {
> >+		size = i_size_read(mapping->host) >> HPAGE_SHIFT;
> >+		if (idx >= size)
> >+			goto out;
> > 		if (hugetlb_get_quota(mapping))
> > 			goto out;
> > 		page = alloc_huge_page(vma, address);
> >
> Shouldn't it be something like following ?
> 
> size = (i_size_read(mapping->host) + HPAGE_SIZE - 1) >> HPAGE_SHIFT;
> 
> 
> 
> If so this was wrong in the original code also.

In theory, yes, but AFAIK there is no way to get an i_size on a
hugetlbfs file which is not a multiple of HPAGE_SIZE.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
