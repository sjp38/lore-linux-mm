Date: Fri, 13 Aug 2004 09:24:14 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Pointers to contiguous pages
Message-ID: <90870000.1092414254@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luciano A. Stertz" <luciano@tteng.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> alloc_pages with the desired order of pages. I'll fill these pages with data and need to add them to the page cache. So I need individual pointers to each page contained in the buffer. How do I get them?
>      Is the following code correct?
> 
>      unsigned long pfn;
>      struct page *page = alloc_pages(mask, order);
>      if (!page)
>          return;
> 
>      /* Fill the pages... */
> 
>      pfn = page_to_pfn(page)
>      for (i=0; i<(1<<order); i++, pfn++)
>      {
>          struct page *p = pfn_to_page(pfn);
>          ...
>      }
> 
>      Is this correct? Is there a better way to do this?
> 
>      Thanks in advance,
>          Luciano
> 
> 	P.S.: I tryied kernelnewbies first, but I guess the question is too specific, nobody answered yet...

Looks about right to me, except I'm not sure I'd bother calling pfn_to_page
each time (it's not fast on more complex systems), something like this 
should work (roughly):

      unsigned long pfn;
      struct page *page = alloc_pages(mask, order);
      if (!page)
          return;
 
      /* Fill the pages... */
 
      for (i=0; i<(1<<order); i++)
      {
          struct page *p = page + i;
          ...
      }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
