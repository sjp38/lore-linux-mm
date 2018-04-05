Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 154596B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 21:53:15 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o52so16976418qto.3
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 18:53:15 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g8si8138656qka.88.2018.04.04.18.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 18:53:14 -0700 (PDT)
Date: Thu, 5 Apr 2018 04:53:12 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] gup: return -EFAULT on access_ok failure
Message-ID: <20180405045231-mutt-send-email-mst@kernel.org>
References: <1522431382-4232-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522431382-4232-1-git-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org, syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>

On Fri, Mar 30, 2018 at 08:37:45PM +0300, Michael S. Tsirkin wrote:
> get_user_pages_fast is supposed to be a faster drop-in equivalent of
> get_user_pages. As such, callers expect it to return a negative return
> code when passed an invalid address, and never expect it to
> return 0 when passed a positive number of pages, since
> its documentation says:
> 
>  * Returns number of pages pinned. This may be fewer than the number
>  * requested. If nr_pages is 0 or negative, returns 0. If no pages
>  * were pinned, returns -errno.
> 
> Unfortunately this is not what the implementation does: it returns 0 if
> passed a kernel address, confusing callers: for example, the following
> is pretty common but does not appear to do the right thing with a kernel
> address:
> 
>         ret = get_user_pages_fast(addr, 1, writeable, &page);
>         if (ret < 0)
>                 return ret;
> 
> Change get_user_pages_fast to return -EFAULT when supplied a
> kernel address to make it match expectations.
> 
> __get_user_pages_fast does not seem to be used like this, but let's
> change __get_user_pages_fast as well for consistency and to match
> documentation.
> 
> Lightly tested.
> 
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Thorsten Leemhuis <regressions@leemhuis.info>
> Cc: stable@vger.kernel.org
> Fixes: 5b65c4677a57 ("mm, x86/mm: Fix performance regression in get_user_pages_fast()")
> Reported-by: syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Any feedback on this? As this fixes a bug in vhost, I'll merge
through the vhost tree unless someone objects.

> ---
>  mm/gup.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 6afae32..5642521 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1749,6 +1749,9 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  	unsigned long flags;
>  	int nr = 0;
>  
> +	if (nr_pages <= 0)
> +		return 0;
> +
>  	start &= PAGE_MASK;
>  	addr = start;
>  	len = (unsigned long) nr_pages << PAGE_SHIFT;
> @@ -1756,7 +1759,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  
>  	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
>  					(void __user *)start, len)))
> -		return 0;
> +		return -EFAULT;
>  
>  	/*
>  	 * Disable interrupts.  We use the nested form as we can already have
> @@ -1806,9 +1809,12 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  	len = (unsigned long) nr_pages << PAGE_SHIFT;
>  	end = start + len;
>  
> +	if (nr_pages <= 0)
> +		return 0;
> +
>  	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
>  					(void __user *)start, len)))
> -		return 0;
> +		return -EFAULT;
>  
>  	if (gup_fast_permitted(start, nr_pages, write)) {
>  		local_irq_disable();
> -- 
> MST
