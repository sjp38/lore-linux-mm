Date: Tue, 17 Apr 2007 22:39:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: meminfo returns inaccurate NR_FILE_PAGES
In-Reply-To: <4625AD3C.8010709@google.com>
Message-ID: <Pine.LNX.4.64.0704172236140.4205@schroedinger.engr.sgi.com>
References: <46255446.6060204@google.com> <Pine.LNX.4.64.0704171655390.9381@schroedinger.engr.sgi.com>
 <46259945.8040504@google.com> <Pine.LNX.4.64.0704172157470.3003@schroedinger.engr.sgi.com>
 <4625AD3C.8010709@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Apr 2007, Ethan Solomita wrote:

>    Anonymous pages have a value in mapping, but it's not a struct
> address_space, it's a struct vm_area_struct (+1). The NR_FILE_PAGES count is

Wrong. Anonymous pages can be a part of swap space which is an 
address_space.

from include/linux/mm.h

extern struct address_space swapper_space;
static inline struct address_space *page_mapping(struct page *page)
{
        struct address_space *mapping = page->mapping;

        if (unlikely(PageSwapCache(page)))
                mapping = &swapper_space;
        else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
                mapping = NULL;
        return mapping;
}

> of lines in migrate_page_move_mapping() after modifying *radix_pointer to call
> __dec on the old page and __inc on the new. You can check the zones first if
> you'd like to save effort, although I'm not sure it's a big deal since the
> __dec and __inc functions are only modifying per-cpu accumulation variables.

Ok. That is what the patch does. So please test the patch and get back 
to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
