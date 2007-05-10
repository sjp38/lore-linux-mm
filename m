Date: Wed, 9 May 2007 23:19:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: vm changes from linux-2.6.14 to linux-2.6.15
Message-Id: <20070509231937.ea254c26.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.61.0705012354290.12808@mtfhpc.demon.co.uk>
References: <20070430145414.88fda272.akpm@linux-foundation.org>
	<20070430.150407.07642146.davem@davemloft.net>
	<1177977619.24962.6.camel@localhost.localdomain>
	<20070430.173806.112621225.davem@davemloft.net>
	<Pine.LNX.4.61.0705010223040.3556@mtfhpc.demon.co.uk>
	<1177985136.24962.8.camel@localhost.localdomain>
	<Pine.LNX.4.61.0705011453380.4771@mtfhpc.demon.co.uk>
	<1178055110.13263.2.camel@localhost.localdomain>
	<Pine.LNX.4.61.0705012354290.12808@mtfhpc.demon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007 00:08:31 +0100 (BST) Mark Fortescue <mark@mtfhpc.demon.co.uk> wrote:

> On Wed, 2 May 2007, Benjamin Herrenschmidt wrote:
> 
> >
> >> I have attached a patch (so pine does not mangle it) for linux-2.6.20.9.
> >> Is this what you had in mind?
> >>
> >> For linux-2.6.21, more work will be needed as it has more code calling
> >> ptep_set_access_flags.
> >
> > I'm not 100% sure we need the 'update' argument... we can remove the
> > whole old_entry, pte_same, etc... and just have pte_set_access_flags()
> > read the old PTE and decide wether something needs to be changed or not.
> >
> > Ben.
> >
> >
> 
> The attached patch works on sun4c (with my simple ADA compile test) but 
> the change in functionality may break things other platforms.
> 
> The advantage of the previous patch is that the functionality is only 
> changed for sparc sun4c so less testing would be required.
> 
> Regards
>  	Mark Fortescue.
> 
> [Update-MMUCache-2.patch  TEXT/PLAIN (10.7KB)]
> diff -ruNpd linux-2.6.20.9/include/asm-generic/pgtable.h linux-test/include/asm-generic/pgtable.h
> --- linux-2.6.20.9/include/asm-generic/pgtable.h	2007-05-01 12:57:56.000000000 +0100
> +++ linux-test/include/asm-generic/pgtable.h	2007-05-01 23:13:23.000000000 +0100
> @@ -30,10 +30,17 @@ do {				  					\
>   * to optimize this.
>   */
>  #define ptep_set_access_flags(__vma, __address, __ptep, __entry, __dirty) \
> -do {				  					  \
> -	set_pte_at((__vma)->vm_mm, (__address), __ptep, __entry);	  \
> -	flush_tlb_page(__vma, __address);				  \
> -} while (0)
> +({									  \
> +	int __update = !pte_same(*(__ptep), __entry);			  \
> +									  \
> +	if (__update) {				  			  \
> +		set_pte_at((__vma)->vm_mm, (__address), __ptep, __entry); \
> +		flush_tlb_page(__vma, __address);			  \
> +	} else if (__dirty) {						  \
> +		flush_tlb_page(__vma, __address);			  \
> +	}								  \
> +	__update;							  \
> +})

We never seemed to reach completion here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
