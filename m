From: Jack Steiner <steiner@sgi.com>
Message-Id: <200105291748.MAA57815@fsgi056.americas.sgi.com>
Subject: Re: Possible bug in tlb shootdown patch (IA64)
Date: Tue, 29 May 2001 12:48:44 -0500 (CDT)
In-Reply-To: <Pine.LNX.4.33.0105251506570.20484-100000@toomuch.toronto.redhat.com> from "Ben LaHaise" at May 25, 2001 03:11:17 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, alan@redhat.com
List-ID: <linux-mm.kvack.org>

> 
> On Fri, 25 May 2001, Jack Steiner wrote:
> 
> > I posted this to linux-mm@kvack.org but failed to
> > send you a copy.
> >
> > ----
> >
> > We hit a problem that looks like it is related to the tlb
> > shootdown patch.
> 
> Thanks for the analysis.  I think the following patch should help...
> 
> 		-ben
> 
> 
> diff -urN v2.4.4-ac17/mm/memory.c wrk/mm/memory.c
> --- v2.4.4-ac17/mm/memory.c	Thu May 24 19:45:18 2001
> +++ wrk/mm/memory.c	Fri May 25 15:10:16 2001
> @@ -285,9 +285,9 @@
>  		return 0;
>  	}
>  	ptep = pte_offset(pmd, address);
> -	address &= ~PMD_MASK;
> -	if (address + size > PMD_SIZE)
> -		size = PMD_SIZE - address;
> +	offset = address & ~PMD_MASK;
> +	if (offset + size > PMD_SIZE)
> +		size = PMD_SIZE - offset;
>  	size &= PAGE_MASK;
>  	for (offset=0; offset < size; ptep++, offset += PAGE_SIZE) {
>  		pte_t pte = *ptep;
> 

I didnt try the code, but I think there is still a problem.

It looks like the patch addresses only part of the problem. There
is also code in zap_pmd_range that will mask off the upper bits of the
address being flushed. The call to tlb_remove_page() in zap_pte_range()
must pass the entire user virtual address that is being removed.



-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
