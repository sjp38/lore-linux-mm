Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 52D376B00EE
	for <linux-mm@kvack.org>; Sun,  7 Aug 2011 10:00:25 -0400 (EDT)
Received: by pzk6 with SMTP id 6so1178843pzk.36
        for <linux-mm@kvack.org>; Sun, 07 Aug 2011 07:00:22 -0700 (PDT)
Date: Sun, 7 Aug 2011 23:00:08 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC PATCH 2/3] mm: page count lock
Message-ID: <20110807140008.GA1823@barrios-desktop>
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <1312492042-13184-3-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312492042-13184-3-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Thu, Aug 04, 2011 at 02:07:21PM -0700, Michel Lespinasse wrote:
> This change introduces a new lock in order to simplify the way
> __split_huge_page_refcount and put_compound_page interact.
> 
> The synchronization problem in this code is that when operating on
> tail pages, put_page() needs to adjust page counts for both the tail
> and head pages. On the other hand, when splitting compound pages
> __split_huge_page_refcount() needs to adjust the head page count so that
> it does not reflect tail page references anymore. When the two race
> together, they must agree as to the order things happen so that the head
> page reference count does not end up with an improper value.
> 
> I propose doing this using a new lock on the tail page. Compared to
> the previous version using the compound lock on the head page,
> the compound page case of put_page() ends up being much simpler.
> 
> The new lock is implemented using the lowest bit of page->_count.
> Page count accessor functions are modified to handle this transparently.
> New accessors are added in mm/internal.h to lock/unlock the
> page count lock while simultaneously accessing the page count value.
> The number of atomic operations required is thus minimized.
> 
> Note that the current implementation takes advantage of the implicit
> memory barrier provided by x86 on atomic RMW instructions to provide
> the expected lock/unlock semantics. Clearly this is not portable
> accross architectures, and will have to be accomodated for using
> an explicit memory barrier on architectures that require it.
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

I didn't take a long time to find out any faults but I see the approach and
it seems no problem except barrier stuff.
I agree this patch makes simple thing complicated by THP in put_page.
It would be very good about readability. :)

But the concern is that put_page on tail page is rare operation but get_page is very
often one. And you are going to enhance readability as scarificing the performance.
A shift operation cost would be negligible but at least we need the number.

If it doesn't hurt performance, I absolutely support your patch!.
Because your patch would reduce many atomic opeartion on head page of put_page
as well as readbility.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
