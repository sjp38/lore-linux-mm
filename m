Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k88IYVja068942
	for <linux-mm@kvack.org>; Fri, 8 Sep 2006 18:34:31 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k88IacU21785926
	for <linux-mm@kvack.org>; Fri, 8 Sep 2006 19:36:39 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k88IYViZ007681
	for <linux-mm@kvack.org>; Fri, 8 Sep 2006 19:34:31 +0100
Date: Fri, 8 Sep 2006 20:33:40 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [patch 1/2] own header file for struct page.
Message-ID: <20060908183340.GA8421@osiris.ibm.com>
References: <20060908111716.GA6913@osiris.boeblingen.de.ibm.com> <20060908094616.48849a7a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060908094616.48849a7a.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

> > This moves the definition of struct page from mm.h to its own header file
> > page.h.
> > This is a prereq to fix SetPageUptodate which is broken on s390:
> > 
> > #define SetPageUptodate(_page)
> >        do {
> >                struct page *__page = (_page);
> >                if (!test_and_set_bit(PG_uptodate, &__page->flags))
> >                        page_test_and_clear_dirty(_page);
> >        } while (0)
> > 
> > _page gets used twice in this macro which can cause subtle bugs. Using
> > __page for the page_test_and_clear_dirty call doesn't work since it
> > causes yet another problem with the page_test_and_clear_dirty macro as
> > well.
> > In order to get of all these problems caused by macros it seems to
> > be a good idea to get rid of them and convert them to static inline
> > functions. Because of header file include order it's necessary to have a
> > seperate header file for the struct page definition.
> > 
> 
> hmm.
> 
> > --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> > +++ linux-2.6/include/linux/page.h	2006-09-08 13:10:23.000000000 +0200
> 
> We have asm/page.h, and one would expect that a <linux/page.h> would be
> related to <asm/page.h> in the usual fashion.  But it isn't.
> 
> Can we think of a different filename? page-struct.h, maybe? pageframe.h?

Yes, of course.

> > +#ifndef CONFIG_DISCONTIGMEM
> > +/* The array of struct pages - for discontigmem use pgdat->lmem_map */
> > +extern struct page *mem_map;
> > +#endif
> 
> Am surprised to see this declaration in this file.

Hmm... first I thought I could add the same declaration to asm-s390/pgtable.h.
But then deciced against it, since I would just duplicate code.
Any better idea where to put it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
