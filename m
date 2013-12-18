Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 750726B0037
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 17:30:37 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so272836pbc.19
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:30:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id pi8si1084024pac.1.2013.12.18.14.30.35
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 14:30:35 -0800 (PST)
Date: Wed, 18 Dec 2013 14:30:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: remove BUG_ON() from mlock_vma_page()
Message-Id: <20131218143033.481361914129a68b74ec7e9d@linux-foundation.org>
In-Reply-To: <1387327369-18806-1-git-send-email-bob.liu@oracle.com>
References: <1387327369-18806-1-git-send-email-bob.liu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, walken@google.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, sasha.levin@oracle.com, vbabka@suse.cz, stable@kernel.org, gregkh@linuxfoundation.org, Bob Liu <bob.liu@oracle.com>

On Wed, 18 Dec 2013 08:42:49 +0800 Bob Liu <lliubbo@gmail.com> wrote:

> This BUG_ON() was triggered when called from try_to_unmap_cluster() which
> didn't lock the page.
> And it's safe to mlock_vma_page() without PageLocked, so this patch fix this
> issue by removing that BUG_ON() simply.
> 
> [  253.869145] kernel BUG at mm/mlock.c:82!
>
> ...
>
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -79,8 +79,6 @@ void clear_page_mlock(struct page *page)
>   */
>  void mlock_vma_page(struct page *page)
>  {
> -	BUG_ON(!PageLocked(page));
> -
>  	if (!TestSetPageMlocked(page)) {
>  		mod_zone_page_state(page_zone(page), NR_MLOCK,
>  				    hpage_nr_pages(page));

The b291f000393f5a0b67901 changelog is pretty remarkable.  It's not
entirely clear who ended up originating this patch - either Rik or
Lee.

Why do we assert PAGE_Locked() in munlock_vma_page()?

I agree with Vlastimil that we should remove now-unneeded lock_page()s
from callers.

The patch is of course worrisome.  It's going to take quite some effort
to review its safety and I'm disinclined to merge this into 3.13.  Has
this bug really been there since 2008?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
