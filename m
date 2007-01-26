Date: Fri, 26 Jan 2007 12:34:32 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] typeof __page_to_pfn with SPARSEMEM=y
Message-Id: <20070126123432.93a175f2.akpm@osdl.org>
In-Reply-To: <20070126120113.c17c1174.randy.dunlap@oracle.com>
References: <20070126120113.c17c1174.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007 12:01:13 -0800
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> With CONFIG_SPARSEMEM=y:
> 
> mm/rmap.c:579: warning: format '%lx' expects type 'long unsigned int', but argument 2 has type 'int'
> 
> Make __page_to_pfn() return unsigned long.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  include/asm-generic/memory_model.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-2620-rc6.orig/include/asm-generic/memory_model.h
> +++ linux-2620-rc6/include/asm-generic/memory_model.h
> @@ -54,7 +54,7 @@
>  #define __page_to_pfn(pg)					\
>  ({	struct page *__pg = (pg);				\
>  	int __sec = page_to_section(__pg);			\
> -	__pg - __section_mem_map_addr(__nr_to_section(__sec));	\
> +	(unsigned long)(__pg - __section_mem_map_addr(__nr_to_section(__sec)));	\
>  })

whaa?  The difference between two pointers has type `int' on a 64-bit
compiler.  How stupid.

<reads the book>

A.4 Important Data Types
========================

The result of subtracting two pointers in C is always an integer, but
the precise data type varies from C compiler to C compiler.  Likewise,
the data type of the result of `sizeof' also varies between compilers.
ISO defines standard aliases for these two types, so you can refer to
them in a portable fashion.  They are defined in the header file
`stddef.h'.  

 -- Data Type: ptrdiff_t
     This is the signed integer type of the result of subtracting two
     pointers.  For example, with the declaration `char *p1, *p2;', the
     expression `p2 - p1' is of type `ptrdiff_t'.  This will probably
     be one of the standard signed integer types (`short int', `int' or
     `long int'), but might be a nonstandard type that exists only for
     this purpose.

So it seems that's `int' on (at least) x86_64.

How the hell can that be reliable?  I'm missing something here...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
