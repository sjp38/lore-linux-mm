Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id B2F086B006C
	for <linux-mm@kvack.org>; Thu,  9 Oct 2014 06:50:39 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id cc10so12724083wib.13
        for <linux-mm@kvack.org>; Thu, 09 Oct 2014 03:50:39 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id gd4si17077838wib.6.2014.10.09.03.50.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Oct 2014 03:50:38 -0700 (PDT)
Date: Thu, 9 Oct 2014 12:50:37 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/4] mm: gup: add get_user_pages_locked and
 get_user_pages_unlocked
Message-ID: <20141009105037.GM4750@worktop.programming.kicks-ass.net>
References: <1412153797-6667-1-git-send-email-aarcange@redhat.com>
 <1412153797-6667-3-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1412153797-6667-3-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>

On Wed, Oct 01, 2014 at 10:56:35AM +0200, Andrea Arcangeli wrote:

> +static inline long __get_user_pages_locked(struct task_struct *tsk,
> +					   struct mm_struct *mm,
> +					   unsigned long start,
> +					   unsigned long nr_pages,
> +					   int write, int force,
> +					   struct page **pages,
> +					   struct vm_area_struct **vmas,
> +					   int *locked,
> +					   bool notify_drop)
> +{

> +	if (notify_drop && lock_dropped && *locked) {
> +		/*
> +		 * We must let the caller know we temporarily dropped the lock
> +		 * and so the critical section protected by it was lost.
> +		 */
> +		up_read(&mm->mmap_sem);
> +		*locked = 0;
> +	}
> +	return pages_done;
> +}

> +long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
> +			   unsigned long start, unsigned long nr_pages,
> +			   int write, int force, struct page **pages,
> +			   int *locked)
> +{
> +	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
> +				       pages, NULL, locked, true);
> +}

> +long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> +			     unsigned long start, unsigned long nr_pages,
> +			     int write, int force, struct page **pages)
> +{
> +	long ret;
> +	int locked = 1;
> +	down_read(&mm->mmap_sem);
> +	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
> +				      pages, NULL, &locked, false);
> +	if (locked)
> +		up_read(&mm->mmap_sem);
> +	return ret;
> +}

>  long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		unsigned long start, unsigned long nr_pages, int write,
>  		int force, struct page **pages, struct vm_area_struct **vmas)
>  {
> +	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
> +				       pages, vmas, NULL, false);
>  }

I'm wondering about that notify_drop parameter, what's the added
benefit? If you look at these 3 callers we can do away with it, since in
the second called where we have locked but !notify_drop we seem to do
the exact same thing afterwards anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
