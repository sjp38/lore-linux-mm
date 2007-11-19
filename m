Date: Mon, 19 Nov 2007 13:08:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Cast page_to_pfn to unsigned long in CONFIG_SPARSEMEM
Message-Id: <20071119130801.bd7b7021.akpm@linux-foundation.org>
In-Reply-To: <20071119202023.GA5086@Krystal>
References: <20071113194025.150641834@polymtl.ca>
	<1195160783.7078.203.camel@localhost>
	<20071115215142.GA7825@Krystal>
	<1195164977.27759.10.camel@localhost>
	<20071116144742.GA17255@Krystal>
	<1195495626.27759.119.camel@localhost>
	<20071119185258.GA998@Krystal>
	<1195501381.27759.127.camel@localhost>
	<20071119195257.GA3440@Krystal>
	<1195502983.27759.134.camel@localhost>
	<20071119202023.GA5086@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 19 Nov 2007 15:20:23 -0500
Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:

> * Dave Hansen (haveblue@us.ibm.com) wrote:
> > The only thing I might suggest doing differently is actually using the
> > page_to_pfn() definition itself:
> > 
> > memory_model.h:#define page_to_pfn __page_to_pfn
> > 
> > The full inline function version should do this already, and we
> > shouldn't have any real direct __page_to_pfn() users anyway.    
> > 
> 
> Like this then..
> 
> Cast page_to_pfn to unsigned long in CONFIG_SPARSEMEM
> 
> Make sure the type returned by page_to_pfn is always unsigned long. If we
> don't cast it explicitly, it can be int on i386, but long on x86_64.

formally ptrdiff_t, I believe.

> This is
> especially inelegant for printks.
> 
> Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
> CC: Dave Hansen <haveblue@us.ibm.com>
> CC: linux-mm@kvack.org
> CC: linux-kernel@vger.kernel.org
> ---
>  include/asm-generic/memory_model.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6-lttng/include/asm-generic/memory_model.h
> ===================================================================
> --- linux-2.6-lttng.orig/include/asm-generic/memory_model.h	2007-11-19 15:06:40.000000000 -0500
> +++ linux-2.6-lttng/include/asm-generic/memory_model.h	2007-11-19 15:18:57.000000000 -0500
> @@ -76,7 +76,7 @@ struct page;
>  extern struct page *pfn_to_page(unsigned long pfn);
>  extern unsigned long page_to_pfn(struct page *page);
>  #else
> -#define page_to_pfn __page_to_pfn
> +#define page_to_pfn ((unsigned long)__page_to_pfn)
>  #define pfn_to_page __pfn_to_page
>  #endif /* CONFIG_OUT_OF_LINE_PFN_TO_PAGE */

I'd have thought that __pfn_to_page() was the place to fix this: the
lower-level point.  Because someone might later start using __pfn_to_page()
for something.

Heaven knows why though - why does __pfn_to_page() even exist?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
