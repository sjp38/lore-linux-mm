Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4E26C6B00E9
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 21:34:40 -0500 (EST)
Received: by pxi12 with SMTP id 12so5102007pxi.14
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 18:34:38 -0800 (PST)
Date: Tue, 11 Jan 2011 11:34:31 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: mmotm hangs on compaction lock_page
Message-ID: <20110111023431.GA2113@barrios-desktop>
References: <alpine.LSU.2.00.1101061632020.9601@sister.anvils>
 <20110107145259.GK29257@csn.ul.ie>
 <20110107175705.GL29257@csn.ul.ie>
 <20110110172609.GA11932@csn.ul.ie>
 <alpine.LSU.2.00.1101101458540.21100@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1101101458540.21100@tigran.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 10, 2011 at 03:56:37PM -0800, Hugh Dickins wrote:
> On Mon, 10 Jan 2011, Mel Gorman wrote:
> > This patch fixes makes the problem
> > unreprodible for me at least. I still don't have the exact reason why pages are
> > not getting unlocked by IO completion but suspect it's because the same process
> > completes the IO that started it. If it's deadlocked, it never finishes the IO.
> 
> It again seems fairly obvious to me, now that you've spelt it out for me
> this far.  If we go the mpage_readpages route, that builds up an mpage bio,
> calling add_to_page_cache (which sets the locked bit) on a series of pages,
> before submitting the bio whose mpage_end_io will unlock them all after.
> An allocation when adding second or third... page is in danger of
> deadlocking on the first page down in compaction's migration.

Indeed. 
If we are lucky, all I/O requests are merged into just one bio and it will submit 
by mpage_bio_submit after finishing looping add_to_page_cache_lru.
It is likely to make deadlock if direct compaction happens in the middle of looping.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
