Date: Wed, 16 Jun 2004 08:12:14 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] s390: lost dirty bits.
Message-ID: <20040616071214.GA7810@infradead.org>
References: <20040615174436.GA10098@mschwid3.boeblingen.de.ibm.com> <20040615210919.1c82a5c8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040615210919.1c82a5c8.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2004 at 09:09:19PM -0700, Andrew Morton wrote:
>  #define ClearPageReferenced(page)	clear_bit(PG_referenced, &(page)->flags)
>  #define TestClearPageReferenced(page) test_and_clear_bit(PG_referenced, &(page)->flags)
>  
> -#ifndef arch_set_page_uptodate
> -#define arch_set_page_uptodate(page) do { } while (0)
> +#ifdef arch_set_page_uptodate
> +#define SetPageUptodate(page) arch_set_page_uptodate(page)
> +#else
> +#define SetPageUptodate(page) set_bit(PG_uptodate, &(page)->flags)
>  #endif

Eek.  It looks like SetPageUptodate, it smells like SetPageUptodate, why
do you give it another name?  Just put a

#ifndef SetPageUptodate	/* S390 wants to override this */
#define SetPageUptodate		set_bit(PG_uptodate, &(page)->flags)
#endif

in mm.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
