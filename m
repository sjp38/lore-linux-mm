Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f179.google.com (mail-gg0-f179.google.com [209.85.161.179])
	by kanga.kvack.org (Postfix) with ESMTP id 57BAC6B0031
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 11:33:55 -0500 (EST)
Received: by mail-gg0-f179.google.com with SMTP id l4so2310364ggi.38
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 08:33:55 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f29si47356479yhd.195.2013.12.30.08.33.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 30 Dec 2013 08:33:54 -0800 (PST)
Message-ID: <52C1A06B.4070605@oracle.com>
Date: Mon, 30 Dec 2013 11:33:47 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/2] mm: additional page lock debugging
References: <1388281504-11453-1-git-send-email-sasha.levin@oracle.com> <20131230114317.GA8117@node.dhcp.inet.fi>
In-Reply-To: <20131230114317.GA8117@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/30/2013 06:43 AM, Kirill A. Shutemov wrote:
> On Sat, Dec 28, 2013 at 08:45:03PM -0500, Sasha Levin wrote:
>> We've recently stumbled on several issues with the page lock which
>> triggered BUG_ON()s.
>>
>> While working on them, it was clear that due to the complexity of
>> locking its pretty hard to figure out if something is supposed
>> to be locked or not, and if we encountered a race it was quite a
>> pain narrowing it down.
>>
>> This is an attempt at solving this situation. This patch adds simple
>> asserts to catch cases where someone is trying to lock the page lock
>> while it's already locked, and cases to catch someone unlocking the
>> lock without it being held.
>>
>> My initial patch attempted to use lockdep to get further coverege,
>> but that attempt uncovered the amount of issues triggered and made
>> it impossible to debug the lockdep integration without clearing out
>> a large portion of existing bugs.
>>
>> This patch adds a new option since it will horribly break any system
>> booting with it due to the amount of issues that it uncovers. This is
>> more of a "call for help" to other mm/ hackers to help clean it up.
>>
>> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>> ---
>>   include/linux/pagemap.h | 11 +++++++++++
>>   lib/Kconfig.debug       |  9 +++++++++
>>   mm/filemap.c            |  4 +++-
>>   3 files changed, 23 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
>> index 1710d1b..da24939 100644
>> --- a/include/linux/pagemap.h
>> +++ b/include/linux/pagemap.h
>> @@ -321,6 +321,14 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
>>   	return pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>>   }
>>
>> +#ifdef CONFIG_DEBUG_VM_PAGE_LOCKS
>> +#define VM_ASSERT_LOCKED(page) VM_BUG_ON_PAGE(!PageLocked(page), (page))
>> +#define VM_ASSERT_UNLOCKED(page) VM_BUG_ON_PAGE(PageLocked(page), (page))
>> +#else
>> +#define VM_ASSERT_LOCKED(page) do { } while (0)
>> +#define VM_ASSERT_UNLOCKED(page) do { } while (0)
>> +#endif
>> +
>>   extern void __lock_page(struct page *page);
>>   extern int __lock_page_killable(struct page *page);
>>   extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
>> @@ -329,16 +337,19 @@ extern void unlock_page(struct page *page);
>>
>>   static inline void __set_page_locked(struct page *page)
>>   {
>> +	VM_ASSERT_UNLOCKED(page);
>>   	__set_bit(PG_locked, &page->flags);
>>   }
>>
>>   static inline void __clear_page_locked(struct page *page)
>>   {
>> +	VM_ASSERT_LOCKED(page);
>>   	__clear_bit(PG_locked, &page->flags);
>>   }
>>
>>   static inline int trylock_page(struct page *page)
>>   {
>> +	VM_ASSERT_UNLOCKED(page);
>
> This is not correct. It's perfectly fine if the page is locked here: it's
> why trylock needed.
>
> IIUC, what we want to catch is the case when the page has already locked
> by the task.

Frankly, we shouldn't have trylock_page() at all.

Look at page_referenced() for example. Instead of assuming that it has to be
called with page lock held, it's trying to acquire the lock and to free it only
if it's the one that allocated it.

Why isn't there a VM_BUG_ON() there to test whether the page is locked, and let
the callers handle that?

>
> I don't think it's reasonable to re-implement this functionality. We
> really need to hook up lockdep.

The issue with adding lockdep straight away is that we need to deal with
long held page locks somehow nicely. Unlike regular locks, these may be
held for a rather long while, triggering really long locking chains which
lockdep doesn't really like.

Many places lock a long list of pages in bulk - we could allow that with
nesting, but then you lose your ability to detect trivial deadlocks.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
