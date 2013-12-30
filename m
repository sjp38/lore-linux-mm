Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id AC8B46B0031
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 06:43:21 -0500 (EST)
Received: by mail-ee0-f44.google.com with SMTP id b57so5035766eek.31
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 03:43:20 -0800 (PST)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id p46si52004353eem.0.2013.12.30.03.43.20
        for <linux-mm@kvack.org>;
        Mon, 30 Dec 2013 03:43:20 -0800 (PST)
Date: Mon, 30 Dec 2013 13:43:17 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 1/2] mm: additional page lock debugging
Message-ID: <20131230114317.GA8117@node.dhcp.inet.fi>
References: <1388281504-11453-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1388281504-11453-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Dec 28, 2013 at 08:45:03PM -0500, Sasha Levin wrote:
> We've recently stumbled on several issues with the page lock which
> triggered BUG_ON()s.
> 
> While working on them, it was clear that due to the complexity of
> locking its pretty hard to figure out if something is supposed
> to be locked or not, and if we encountered a race it was quite a
> pain narrowing it down.
> 
> This is an attempt at solving this situation. This patch adds simple
> asserts to catch cases where someone is trying to lock the page lock
> while it's already locked, and cases to catch someone unlocking the
> lock without it being held.
> 
> My initial patch attempted to use lockdep to get further coverege,
> but that attempt uncovered the amount of issues triggered and made
> it impossible to debug the lockdep integration without clearing out
> a large portion of existing bugs.
> 
> This patch adds a new option since it will horribly break any system
> booting with it due to the amount of issues that it uncovers. This is
> more of a "call for help" to other mm/ hackers to help clean it up.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  include/linux/pagemap.h | 11 +++++++++++
>  lib/Kconfig.debug       |  9 +++++++++
>  mm/filemap.c            |  4 +++-
>  3 files changed, 23 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 1710d1b..da24939 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -321,6 +321,14 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
>  	return pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>  }
>  
> +#ifdef CONFIG_DEBUG_VM_PAGE_LOCKS
> +#define VM_ASSERT_LOCKED(page) VM_BUG_ON_PAGE(!PageLocked(page), (page))
> +#define VM_ASSERT_UNLOCKED(page) VM_BUG_ON_PAGE(PageLocked(page), (page))
> +#else
> +#define VM_ASSERT_LOCKED(page) do { } while (0)
> +#define VM_ASSERT_UNLOCKED(page) do { } while (0)
> +#endif
> +
>  extern void __lock_page(struct page *page);
>  extern int __lock_page_killable(struct page *page);
>  extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
> @@ -329,16 +337,19 @@ extern void unlock_page(struct page *page);
>  
>  static inline void __set_page_locked(struct page *page)
>  {
> +	VM_ASSERT_UNLOCKED(page);
>  	__set_bit(PG_locked, &page->flags);
>  }
>  
>  static inline void __clear_page_locked(struct page *page)
>  {
> +	VM_ASSERT_LOCKED(page);
>  	__clear_bit(PG_locked, &page->flags);
>  }
>  
>  static inline int trylock_page(struct page *page)
>  {
> +	VM_ASSERT_UNLOCKED(page);

This is not correct. It's perfectly fine if the page is locked here: it's
why trylock needed.

IIUC, what we want to catch is the case when the page has already locked
by the task.

I don't think it's reasonable to re-implement this functionality. We
really need to hook up lockdep.

>  	return (likely(!test_and_set_bit_lock(PG_locked, &page->flags)));
>  }
>  
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index 48d32cd..ae4b60d 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -510,6 +510,15 @@ config DEBUG_VM_RB
>  
>  	  If unsure, say N.
>  
> +config DEBUG_VM_PAGE_LOCKS
> +	bool "Debug VM page locking"
> +	depends on DEBUG_VM
> +	help
> +	  Debug page locking by catching double locks and double frees. These
> +	  checks may impact performance.
> +
> +	  If unsure, say N.
> +
>  config DEBUG_VIRTUAL
>  	bool "Debug VM translations"
>  	depends on DEBUG_KERNEL && X86
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 7a7f3e0..665addc 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -607,7 +607,7 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
>   */
>  void unlock_page(struct page *page)
>  {
> -	VM_BUG_ON_PAGE(!PageLocked(page), page);
> +	VM_ASSERT_LOCKED(page);
>  	clear_bit_unlock(PG_locked, &page->flags);
>  	smp_mb__after_clear_bit();
>  	wake_up_page(page, PG_locked);
> @@ -639,6 +639,7 @@ void __lock_page(struct page *page)
>  {
>  	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
>  
> +	VM_ASSERT_UNLOCKED(page);

It's no correct as well: __lock_page() usually called when the page is
locked and we have to sleep. See lock_page().

>  	__wait_on_bit_lock(page_waitqueue(page), &wait, sleep_on_page,
>  							TASK_UNINTERRUPTIBLE);
>  }
> @@ -648,6 +649,7 @@ int __lock_page_killable(struct page *page)
>  {
>  	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
>  
> +	VM_ASSERT_UNLOCKED(page);

The same here.

>  	return __wait_on_bit_lock(page_waitqueue(page), &wait,
>  					sleep_on_page_killable, TASK_KILLABLE);
>  }

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
