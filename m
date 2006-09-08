Date: Fri, 8 Sep 2006 09:46:16 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/2] own header file for struct page.
Message-Id: <20060908094616.48849a7a.akpm@osdl.org>
In-Reply-To: <20060908111716.GA6913@osiris.boeblingen.de.ibm.com>
References: <20060908111716.GA6913@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 8 Sep 2006 13:17:16 +0200
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> This moves the definition of struct page from mm.h to its own header file
> page.h.
> This is a prereq to fix SetPageUptodate which is broken on s390:
> 
> #define SetPageUptodate(_page)
>        do {
>                struct page *__page = (_page);
>                if (!test_and_set_bit(PG_uptodate, &__page->flags))
>                        page_test_and_clear_dirty(_page);
>        } while (0)
> 
> _page gets used twice in this macro which can cause subtle bugs. Using
> __page for the page_test_and_clear_dirty call doesn't work since it
> causes yet another problem with the page_test_and_clear_dirty macro as
> well.
> In order to get of all these problems caused by macros it seems to
> be a good idea to get rid of them and convert them to static inline
> functions. Because of header file include order it's necessary to have a
> seperate header file for the struct page definition.
> 

hmm.

> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6/include/linux/page.h	2006-09-08 13:10:23.000000000 +0200

We have asm/page.h, and one would expect that a <linux/page.h> would be
related to <asm/page.h> in the usual fashion.  But it isn't.

Can we think of a different filename? page-struct.h, maybe? pageframe.h?

> +#ifndef CONFIG_DISCONTIGMEM
> +/* The array of struct pages - for discontigmem use pgdat->lmem_map */
> +extern struct page *mem_map;
> +#endif

Am surprised to see this declaration in this file.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
