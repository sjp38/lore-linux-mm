Message-ID: <45B69EFD.7060703@yahoo.com.au>
Date: Wed, 24 Jan 2007 10:49:17 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch] mm: mremap correct rmap accounting
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 24 Jan 2007, Nick Piggin wrote:
> 
>>When mremap()ing virtual addresses, some architectures (read: MIPS) switches
>>underlying pages if encountering ZERO_PAGE(old_vaddr) != ZERO_PAGE(new_vaddr).
>>
>>The problem is that the refcount and mapcount remain on the old page, while
>>the actual pte is switched to the new one. This would counter underruns and
>>confuse the rmap code.
> 
> 
> Good point.  Nasty.
> 
> 
>>Fix it by actually moving accounting info to the new page. Would it be neater
>>to do this in move_pte? maybe rmap.c? (nick mumbles something about not
>>accounting ZERO_PAGE()s)
> 
> 
> Tiresome, I can quite see why it brings you to mumbling.
> 
> Though it looks right, I do hate the patch cluttering up move_ptes()
> like that: will the compiler be able to work out that that "unlikely"
> means impossible (and optimize away the code) on all arches but MIPS?
> Even if it can, I'd rather not see it there.

Yeah it doesn't look quite right.

> Could you make the MIPS move_pte() a proper function, say in
> arch/mips/mm/init.c next to setup_zero_pages(), and do that tiresome
> stuff there - should then be able to assume ZERO_PAGEs and skip the
> BUG_ON embellishments.

The only thing I was thinking of was if another arch comes along and
does the same thing. Also tried to keep such rmap specifics in mm/.

But if you're happy to do it that way, then I'm happy with it!

> Utter nit-of-nits: my sense of symmetry prefers that you put_page()
> after page_remove_rmap() instead of before.

I prefer that way too, now you mention it ;)

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
