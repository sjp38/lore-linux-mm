Message-ID: <45C841A5.20702@yahoo.com.au>
Date: Tue, 06 Feb 2007 19:51:49 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/3] mm: fix PageUptodate memorder
References: <20070206054925.21042.50546.sendpatchset@linux.site>	<20070206054935.21042.13541.sendpatchset@linux.site> <20070206002512.4e0bbbad.akpm@linux-foundation.org>
In-Reply-To: <20070206002512.4e0bbbad.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue,  6 Feb 2007 09:02:11 +0100 (CET) Nick Piggin <npiggin@suse.de> wrote:
> 
> 
>>+static inline void __SetPageUptodate(struct page *page)
>>+{
>>+#ifdef CONFIG_S390
>> 	if (!test_and_set_bit(PG_uptodate, &page->flags))
>> 		page_test_and_clear_dirty(page);
>>-}
>> #else
>>-#define SetPageUptodate(page)	set_bit(PG_uptodate, &(page)->flags)
>>+	/*
>>+	 * Memory barrier must be issued before setting the PG_uptodate bit,
>>+	 * so all previous writes that served to bring the page uptodate are
>>+	 * visible before PageUptodate becomes true.
>>+	 *
>>+	 * S390 is guaranteed to have a barrier in the test_and_set operation
>>+	 * (see Documentation/atomic_ops.txt).
>>+	 *
>>+	 * XXX: does this memory barrier need to be anything special to
>>+	 * handle things like DMA writes into the page?
>>+	 */
>>+	smp_wmb();
>>+	set_bit(PG_uptodate, &(page)->flags);
>> #endif
>>+}
>>+
>>+static inline void SetPageUptodate(struct page *page)
>>+{
>>+	WARN_ON(!PageLocked(page));
>>+	__SetPageUptodate(page);
>>+}
>>+
>>+static inline void SetNewPageUptodate(struct page *page)
>>+{
>>+	__SetPageUptodate(page);
>>+}
> 
> 
> I was panicing for a minute when I saw that __SetPageUptodate() in there.
> 
> Conventionally the __SetPageFoo namespace is for nonatomic updates to
> page->flags.  Can we call this something different?

Duh, of course, sorry.

> What a fugly patchset :(

Fugly problem. One could fix it by always locking the page, but I was
worried about Hugh flaming me if I tried that ;)

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
