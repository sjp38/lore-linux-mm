Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3A5E78D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 11:11:08 -0500 (EST)
Date: Fri, 21 Jan 2011 10:11:03 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] When migrate_pages returns 0, all pages must have
 been released
In-Reply-To: <20110120212841.GB9506@random.random>
Message-ID: <alpine.DEB.2.00.1101211005150.14313@router.home>
References: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com> <alpine.DEB.2.00.1101201130100.10695@router.home> <20110120182444.GA9506@random.random> <alpine.DEB.2.00.1101201233001.20633@router.home>
 <20110120212841.GB9506@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Jan 2011, Andrea Arcangeli wrote:

> Which following putback_lru_page()?  You mean
> putback_lru_page(newpage)? That is for the newly allocated page
> (allocated at the very top, so always needed), it's not relevant to
> the page_count(page) = 1. The page_count 1 is hold by the caller, so
> it's leaking memory right now (for everything but compaction).

Ahh yes we removed the putback_lru_pages call from migrate_pages()
and broke the existing release logic. The caller has to call
putback_release_pages() as per commit
cf608ac19c95804dc2df43b1f4f9e068aa9034ab

If that is still the case then we still have the double free.

Could we please document the calling conventions exactly in the source?
Right now it says that the caller should call putback_lru_pages().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
