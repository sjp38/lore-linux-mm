Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1C8628D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 11:29:47 -0500 (EST)
Date: Tue, 22 Feb 2011 17:29:40 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/8] Fix interleaving for transparent hugepages
Message-ID: <20110222162940.GE13092@random.random>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org>
 <1298315270-10434-2-git-send-email-andi@firstfloor.org>
 <alpine.DEB.2.00.1102220933500.16060@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1102220933500.16060@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lwoodman@redhat.com, Andi Kleen <ak@linux.intel.com>

On Tue, Feb 22, 2011 at 09:34:33AM -0600, Christoph Lameter wrote:
> 
> On Mon, 21 Feb 2011, Andi Kleen wrote:
> 
> > @@ -1830,7 +1830,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
> >  	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
> >  		unsigned nid;
> >
> > -		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
> > +		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT << order);
> 
> Should be PAGE_SHIFT + order.

This one is very good after changing + order. I updated
alloc_page_interleave to get an order parameter but I didn't adjust
the nid accordingly to order. This was my incomplete modification for
hpage interleaving:

@@ -1830,7 +1832,7 @@ alloc_page_vma(gfp_t gfp, struct vm_area_struct
*vma, unsigned long addr)
 
                nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
                mpol_cond_put(pol);
-               page = alloc_page_interleave(gfp, 0, nid);
+               page = alloc_page_interleave(gfp, order, nid);
                put_mems_allowed();
                return page;
        }


Andi, can you resubmit this one fixd with + to Andrew, this one can go
in 2.6.38. For the rest frankly I've an hard time to see how it cannot
hurt performance (instead of improving them) especially for KSM. It's
impossible to improve KSM for NUMA with that change to
ksm_does_need_to_copy at the very least. But the same reasoning
applies to the rest. But I'll think more about the others, I just
would prefer to include the above fix quick, the rest don't seem that
urgent even if it's really improving performance (instead of hurting
it as I think).

Acked-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
