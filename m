Message-ID: <45BD6160.10608@yahoo.com.au>
Date: Mon, 29 Jan 2007 13:52:16 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
References: <1169993494.10987.23.camel@lappy> <20070128142925.df2f4dce.akpm@osdl.org>
In-Reply-To: <20070128142925.df2f4dce.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Sun, 28 Jan 2007 15:11:34 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

>>+static inline int set_page_address(struct page *page, void *address)
>>+{
>>+	if (address)
>>+		return cmpxchg(&page->virtual, NULL, address) == NULL;
>>+	else {
>>+		/*
>>+		 * cmpxchg is a bit abused because it is not guaranteed
>>+		 * safe wrt direct assignment on all platforms.
>>+		 */
>>+		void *virt = page->virtual;
>>+		return cmpxchg(&page->vitrual, virt, NULL) == virt;
>>+	}
>>+}
> 
> 
> Have you verified that all architectures which can implement
> WANT_PAGE_VIRTUAL also implement cmpxchg?

Simple: we should not implement cmpxchg in generic code. We should
be able to use atomic_long_cmpxchg for this -- it will work perfectly
regardless of what anybody else tells you.

cmpxchg is only required for when that memory location may get modified
by some other means than under your control (eg. userspace, in the case
of drm, or hardware MMU in the case of Christoph's old page fault
scalability patches).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
