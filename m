Message-ID: <42E44294.5020408@yahoo.com.au>
Date: Mon, 25 Jul 2005 11:38:28 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: PageReserved removal from swsusp
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, Nigel Cunningham <ncunningham@cyclades.com>, Pavel Machek <pavel@suse.cz>, Hugh Dickins <hugh@veritas.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Hi,

kernel/power/swsusp.c is the last remaining real user of PageReserved
with my current PageReserved removal patchset. This is actually not a
problem for my purposes, and swsusp is quite able to continue using
PageReserved... however that may be a bit ugly, and means swsusp will
be the sole user of 3(!) page-flags.

The PageReserved test in save_highmem_zone() is the hard one. rvmalloc
is no problem, but it seems to be important to prevent saving regions
that aren't RAM.

I seem to be able to work around this on i386 by testing page_is_ram()
instead of PageReserved, however that looks nonportable, and at least
on i386 we rather want something like page_is_usable_ram() which is
(page_is_ram && !(bad_ppro && page_kills_ppro))

Otherwise we could perhaps have a PageUsableRAM() which returns
page->flags != 0xffffffff or some other unlikely combination of flags.

They're my two ideas. Anyone else?

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
