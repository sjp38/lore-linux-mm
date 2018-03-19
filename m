Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 189E16B0008
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 18:08:28 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x7so10372986pfd.19
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 15:08:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m89si160261pfg.202.2018.03.19.15.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 15:08:26 -0700 (PDT)
Date: Mon, 19 Mar 2018 15:08:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: Warn on lock_page() from reclaim context.
Message-Id: <20180319150824.24032e2854908b0cc5240d9f@linux-foundation.org>
In-Reply-To: <201803181022.IAI30275.JOFOQMtFSHLFOV@I-love.SAKURA.ne.jp>
References: <1521295866-9670-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180317155437.pcbeigeivn4a23gt@node.shutemov.name>
	<201803181022.IAI30275.JOFOQMtFSHLFOV@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: kirill@shutemov.name, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mhocko@suse.com

On Sun, 18 Mar 2018 10:22:49 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> >From f43b8ca61b76f9a19c13f6bf42b27fad9554afc0 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sun, 18 Mar 2018 10:18:01 +0900
> Subject: [PATCH v2] mm: Warn on lock_page() from reclaim context.
> 
> Kirill A. Shutemov noticed that calling lock_page[_killable]() from
> reclaim context might cause deadlock. In order to help finding such
> lock_page[_killable]() users (including out of tree users), this patch
> emits warning messages when CONFIG_PROVE_LOCKING is enabled.
>
> ...
> 
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -466,6 +466,7 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
>  extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
>  				unsigned int flags);
>  extern void unlock_page(struct page *page);
> +extern void __warn_lock_page_from_reclaim_context(void);
>  
>  static inline int trylock_page(struct page *page)
>  {
> @@ -479,6 +480,9 @@ static inline int trylock_page(struct page *page)
>  static inline void lock_page(struct page *page)
>  {
>  	might_sleep();
> +	if (IS_ENABLED(CONFIG_PROVE_LOCKING) &&
> +	    unlikely(current->flags & PF_MEMALLOC))
> +		__warn_lock_page_from_reclaim_context();
>  	if (!trylock_page(page))
>  		__lock_page(page);
>  }

I think it would be neater to do something like

#ifdef CONFIG_PROVE_LOCKING
static inline void lock_page_check_context(struct page *page)
{
	if (unlikely(current->flags & PF_MEMALLOC))
		__lock_page_check_context(page);
}
#else
static inline void lock_page_check_context(struct page *page)
{
}
#endif

and

void __lock_page_check_context(struct page *page)
{
	WARN_ONCE(...);
	dump_page(page);
}

And I wonder if overloading CONFIG_PROVE_LOCKING is appropriate here. 
CONFIG_PROVE_LOCKING is a high-level thing under which a whole bunch of
different debugging options may exist.  I guess we should add a new
config item under PROVE_LOCKING, or perhaps use CONFIG_DEBUG_VM.

Also, is PF_MEMALLOC the best way of determining that we're running
reclaim?  What about using current->reclaim_state?
