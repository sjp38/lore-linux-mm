Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 7B9216B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 15:57:47 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id t12so650652pdi.30
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 12:57:46 -0700 (PDT)
Date: Tue, 23 Apr 2013 12:57:45 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: page eviction from the buddy cache
In-Reply-To: <20130423122708.GA31170@thunk.org>
Message-ID: <alpine.LNX.2.00.1304231230340.12850@eggly.anvils>
References: <51504A40.6020604@ya.ru> <20130327150743.GC14900@thunk.org> <alpine.LNX.2.00.1303271135420.29687@eggly.anvils> <3C8EEEF8-C1EB-4E3D-8DE6-198AB1BEA8C0@gmail.com> <515CD665.9000300@gmail.com> <239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com>
 <51730619.3030204@fastmail.fm> <20130420235718.GA28789@thunk.org> <5176785D.5030707@fastmail.fm> <20130423122708.GA31170@thunk.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Bernd Schubert <bernd.schubert@fastmail.fm>, Alexey Lyahkov <alexey.lyashkov@gmail.com>, Will Huck <will.huckk@gmail.com>, Andrew Perepechko <anserper@ya.ru>, linux-ext4@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de

On Tue, 23 Apr 2013, Theodore Ts'o wrote:
> On Tue, Apr 23, 2013 at 02:02:37PM +0200, Bernd Schubert wrote:
> > 
> > I just thought we can (mis)use that flag and and add another
> > information to the page that it holds meta data. The mm system then
> > could use that flag and evict those pages with a lower priority
> > compared to other pages.
> 
> Well, the flag I added was to the buffer_head, not to the page, and my
> understanding is that the mm folks are very hesitant to add new page
> flags, since they are bumping up against the 32 bit limit (on the i386
> platform), and they are trying to keep the struct page structure trim
> and svelte.  :-)

Yes indeed.  But luckily this issue seems not to need another page flag.

If metadata is useful, it gets used: so mark_page_accessed when it's used
should generally do the job; perhaps it's already called on that path,
perhaps calls need to be added.

Rarely used but nonetheless useful metadata might get pushed out by data.
But I don't think we want another page flag, and yet more complicated
reclaim policy in mm for that case.  If the filesystem knows of such
cases, I hope it can find a way to use mark_page_accessed more often
on such pages than they are actually accessed, to help retain them.

What this thread did bring up was the failure of mark_page_accessed
to be fully effective until the page is flushed from pagevec to lru.
That remains a good point: something that several would like to fix.

For now I stand by what I said before (if you find it effective
in practice - I haven't heard back): at the moment you need to

	mark_page_accessed(page);	/* to SetPageReferenced */
	lru_add_drain();		/* to SetPageLRU */
	mark_page_accessed(page);	/* to SetPageActive */

when such a metadata page is first brought in.

We all hate that lru_add_drain in the middle, which will exacerbate
lru_lock contention.  We would love to eliminate the need for most
lru_add_drains: I have some ideas which I'm pursuing in odd moments,
but I promise nothing.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
