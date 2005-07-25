Message-ID: <42E46FF5.5080805@yahoo.com.au>
Date: Mon, 25 Jul 2005 14:52:05 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: PageReserved removal from swsusp
References: <42E44294.5020408@yahoo.com.au> <1122265909.6144.106.camel@localhost>
In-Reply-To: <1122265909.6144.106.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ncunningham@cyclades.com
Cc: Linux Memory Management <linux-mm@kvack.org>, Pavel Machek <pavel@suse.cz>, Hugh Dickins <hugh@veritas.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Nigel Cunningham wrote:
> Hi.
> 
>>
>>They're my two ideas. Anyone else?
> 
> 
> I have a few differences in Suspend2 that let me only use one real
> pageflag (Nosave).
> 

Thanks for the reply.

> The changes are:
> 
> 1) Use a set of order zero allocations, tied together via a kmalloc'd
> list of pointers as a means of dynamically creating and destroying
> pseudo page-flags (such as are only needed while suspending). The
> bitmaps don't support sparsemem yet, but this support could be added
> pretty easily.
> 
> 2) This bitmap could be used straight off for swsusp's PageNosave flag
> since it is only used in kernel/power/swsusp.c (2.6.13-rc3 checked).
> 
> 3) Set & Clear PageNosaveFree are also used in mm/page_alloc.c, in
> mark_free_pages, which is only called from swsusp.c, so a dynamically
> allocated bitmap could be used there too.
> 

1,2,3 all sound good. I guess if swsusp becomes any more of a page flag
hog then the page flag bitmap sounds like a good idea. Though at present
it will only allow us to save 1 flag (PageNosaveFree).

I guess I'm mostly interested in how to remove PageReserved usage. That is
one that isn't able to be nicely handled with your pseudo flags bitmap.

> 4) That leaves PageReserved. Pavel and I both rely on a page flag being
> set in the arch specific code (based on e820 tables), so as to know what
> pages are untouchable. As I look more closely though, I wonder if we
> could do without that if we instead directly do the 
> 
> (page_is_ram(pfn) && !(bad_ppro && page_kills_ppro(pfn))
> 
> and
> 
> (addr < (void *)&__nosave_begin || addr >= (void *)&__nosave_end)
> 
> tests when preparing the image. Assuming, of course, that page_is_ram,
> bad_ppro and page_kills_ppro can be made usable by us.
> 

Well that doesn't sound too unreasonable. Of course you don't want to
use all that directly, but have it put in a nice arch defined wrapper
for you (eg. page_is_usable_ram).

I'm currently playing around with trying to reuse an existing flag
to get this information (instead of PageReserved). But it doesn't seem
like a big problem if we have to fall back to the above.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
