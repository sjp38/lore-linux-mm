Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AF2636B009F
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 20:21:45 -0500 (EST)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id oBH1Le3X003383
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 17:21:41 -0800
Received: from iyi12 (iyi12.prod.google.com [10.241.51.12])
	by kpbe15.cbf.corp.google.com with ESMTP id oBH1LKs6004147
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 17:21:39 -0800
Received: by iyi12 with SMTP id 12so127126iyi.25
        for <linux-mm@kvack.org>; Thu, 16 Dec 2010 17:21:39 -0800 (PST)
Date: Thu, 16 Dec 2010 17:21:30 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
In-Reply-To: <20101216220457.GA3450@barrios-desktop>
Message-ID: <alpine.LSU.2.00.1012161708260.3351@tigran.mtv.corp.google.com>
References: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu> <AANLkTikXQmsgZ8Ea-GoQ4k2St6yCJj8Z3XthuBQ9u+EV@mail.gmail.com> <E1PTCV4-0007sR-SO@pomaz-ex.szeredi.hu> <20101216220457.GA3450@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Dec 2010, Minchan Kim wrote:
> On Thu, Dec 16, 2010 at 12:59:58PM +0100, Miklos Szeredi wrote:
> > On Thu, 16 Dec 2010, Minchan Kim wrote:
> > > 
> > > Why do you release reference of old?
> > 
> > That's the page cache reference we release.  Just like we acquire the
> > page cache reference for "new" above.
> 
> I mean current page cache handling semantic and page reference counting semantic
> is separeated. For example, remove_from_page_cache doesn't drop the reference of page.
> That's because we need more works after drop the page from page cache.
> Look at shmem_writepage, truncate_complete_page.

I disagree with you there: I like the way Miklos made it symmetric,
I like the way delete_from_swap_cache drops the swap cache reference,
I dislike the way remove_from_page_cache does not - I did once try to
change that, but did a bad job, messed up reiserfs or reiser4 I forget
which, retreated in shame.

In both the examples you give, shmem_writepage and truncate_complete_page,
the caller has to be holding their own reference, in part because they
locked the page, and will need to unlock it before releasing their ref.
I think that would be true of any replace_page_cache_page caller.

> 
> You makes the general API and caller might need works before the old page 
> is free. So how about this?
> 
> err = replace_page_cache_page(oldpage, newpage, GFP_KERNEL);
> if (err) {
>         ...
> }
> 
> page_cache_release(oldpage); /* drop ref of page cache */
> 
> 
> > 
> > I suspect it's historic that page_cache_release() doesn't drop the
> > page cache ref.
> 
> Sorry I can't understand your words.

Me neither: I believe Miklos meant __remove_from_page_cache() rather
than page_cache_release() in that instance.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
