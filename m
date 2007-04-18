Message-ID: <4625B711.8060400@google.com>
Date: Tue, 17 Apr 2007 23:13:37 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: meminfo returns inaccurate NR_FILE_PAGES
References: <46255446.6060204@google.com> <Pine.LNX.4.64.0704171655390.9381@schroedinger.engr.sgi.com> <46259945.8040504@google.com> <Pine.LNX.4.64.0704172157470.3003@schroedinger.engr.sgi.com> <4625AD3C.8010709@google.com> <Pine.LNX.4.64.0704172236140.4205@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704172236140.4205@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 17 Apr 2007, Ethan Solomita wrote:
>
>   
>>    Anonymous pages have a value in mapping, but it's not a struct
>> address_space, it's a struct vm_area_struct (+1). The NR_FILE_PAGES count is
>>     
>
> Wrong. Anonymous pages can be a part of swap space which is an 
> address_space.
>
> from include/linux/mm.h
>
> extern struct address_space swapper_space;
> static inline struct address_space *page_mapping(struct page *page)
> {
>         struct address_space *mapping = page->mapping;
>
>         if (unlikely(PageSwapCache(page)))
>                 mapping = &swapper_space;
>         else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
>                 mapping = NULL;
>         return mapping;
> }
>   

    While you're busy correcting me, look in swap_state.c at 
__add_to_swap_cache(). Note how, when it inserts a page into 
swapper_space.page_tree, it then does an 
__inc_zone_page_state(NR_FILE_PAGES). Going back to my initial email 
reporting the bug you'll see that I make it clear: whenever a page is 
inserted into a mapping's page_tree we increment NR_FILE_PAGES.

    My comment above was meant to refer to anonymous mappings ala 
PAGE_MAPPING_ANON.

>> of lines in migrate_page_move_mapping() after modifying *radix_pointer to call
>> __dec on the old page and __inc on the new. You can check the zones first if
>> you'd like to save effort, although I'm not sure it's a big deal since the
>> __dec and __inc functions are only modifying per-cpu accumulation variables.
>>     
>
> Ok. That is what the patch does. So please test the patch and get back 
> to me.
>   

    I'll test it when it works, i.e. when you remove the check for 
PAGE_ANON.  There is a one-to-one correspondence -- except in migrate.c 
-- of adding/removing a page from *ANY* page_tree and inc/dec'ing 
NR_FILE_PAGES. There's no reason for migrate to make an exception and 
check for PAGE_ANON.
    -- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
