Date: Thu, 22 May 2003 12:40:18 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] dirty bit clearing on s390.
Message-ID: <20030522124018.A20638@infradead.org>
References: <20030522112000.GA2597@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030522112000.GA2597@mschwid3.boeblingen.de.ibm.com>; from schwidefsky@de.ibm.com on Thu, May 22, 2003 at 01:20:00PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, akpm@digeo.com, phillips@arcor.de
List-ID: <linux-mm.kvack.org>

On Thu, May 22, 2003 at 01:20:00PM +0200, Martin Schwidefsky wrote:
> +#ifndef arch_set_page_uptodate
> +#define arch_set_page_uptodate(page)
> +#endif
> +
>  #define PageUptodate(page)	test_bit(PG_uptodate, &(page)->flags)
> -#define SetPageUptodate(page)	set_bit(PG_uptodate, &(page)->flags)
> +#define SetPageUptodate(page) \
> +	do {								\
> +		arch_set_page_uptodate(page);				\
> +		set_bit(PG_uptodate, &(page)->flags);			\
> +	} while (0)
>  #define ClearPageUptodate(page)	clear_bit(PG_uptodate, &(page)->flags)

I guess it would be nicer if the arch could just overrid SetPageUptodate
completly e.g.

#ifndef SetPageUptodate
#define SetPageUptodate(page)	set_bit(PG_uptodate, &(page)->flags)
#endif

with a big comment explaining why s390 needs it.  Else it looks fine to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
