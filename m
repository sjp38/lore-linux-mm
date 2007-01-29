Message-ID: <45BD9AE1.6000501@yahoo.com.au>
Date: Mon, 29 Jan 2007 17:57:37 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch] mm: mremap correct rmap accounting
References: <45B61967.5000302@yahoo.com.au>	<Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>	<45BD6A7B.7070501@yahoo.com.au> <20070128224002.3e7da788.akpm@osdl.org>
In-Reply-To: <20070128224002.3e7da788.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 29 Jan 2007 14:31:07 +1100
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>When mremap()ing virtual addresses, some architectures (read: MIPS) switches
>>underlying pages if encountering ZERO_PAGE(old_vaddr) != ZERO_PAGE(new_vaddr).
>>
>>The problem is that the refcount and mapcount remain on the old page, while
>>the actual pte is switched to the new one. This would counter underruns and
>>confuse the rmap code.
> 
> 
> umm, that sounds fairly fatal.  For how long has this bug been present?
> 

It would be. We have a catch to prevent ZERO_PAGE from actually getting freed,
but it would spew warnings and eventually go bug in the page_mapcount underflow
check.

It has been around for quite a few releases, so either we don't have many R4000
or R4400 SC and MC CPUs running a recent kernel, or this type of mremap is
pretty rare, or both. We get far more reports of mapcount underflow on x86 than
MIPS!

If Ralf acks then I think it could go into the next release.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
