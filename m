Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A4F2D6B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 02:28:32 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o247SSj6030997
	for <linux-mm@kvack.org>; Thu, 4 Mar 2010 07:28:29 GMT
Received: from gyg4 (gyg4.prod.google.com [10.243.50.132])
	by wpaz1.hot.corp.google.com with ESMTP id o247SQKe013559
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 23:28:27 -0800
Received: by gyg4 with SMTP id 4so1180499gyg.26
        for <linux-mm@kvack.org>; Wed, 03 Mar 2010 23:28:26 -0800 (PST)
Date: Thu, 4 Mar 2010 07:28:11 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] swapfile : fix the wrong return value
In-Reply-To: <4B8F5A82.2030805@gmail.com>
Message-ID: <alpine.LSU.2.00.1003040706400.3894@sister.anvils>
References: <1267501102-24190-1-git-send-email-shijie8@gmail.com> <alpine.LSU.2.00.1003040029210.28735@sister.anvils> <4B8F5A82.2030805@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Mar 2010, Huang Shijie wrote:
> > 
> > swap_duplicate()'s loop appears to miss out on returning the error code
> > from __swap_duplicate(), except when that's -ENOMEM.  In fact this is
> > intentional: prior to -ENOMEM for swap_count_continuation, swap_duplicate()
> > was void (and the case only occurs when copy_one_pte() hits a corrupt pte).
> >    
> only?
> 
> There are several paths calling the try_to_unmap(), Could you sure that
> the swap entries are valid in all the paths ?

Yes.  Well, we are debating the likelihoods of corruption in different memory
areas here.  I answer "Yes" because the swap entry involved in try_to_unmap_one()
comes from page->private when PageSwapCache is set (and the page is locked):
it requires either an mm bug, or corruption of struct page, for that swap entry
to be invalid for duplication.  Memory corruption of entries in a user page
table seems to have been a more common case, whether because of single-bit memory
errors, or use-after-free bugs: that's the case which copy_one_pte() might meet.
 
> 
> For the sake of the stability of the system, I perfer to export all the error
> value, and check it carefully.

But we were happy with void swap_duplicate() for many years.
If I wanted to make a further change, it would rather be to remove those
error returns from __swap_duplicate() which are not actually made use of.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
