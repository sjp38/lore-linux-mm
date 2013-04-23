Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id C2D0E6B0032
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 18:00:11 -0400 (EDT)
Date: Tue, 23 Apr 2013 15:00:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: page eviction from the buddy cache
Message-Id: <20130423150008.046ee9351da4681128db0bf3@linux-foundation.org>
In-Reply-To: <alpine.LNX.2.00.1304231230340.12850@eggly.anvils>
References: <51504A40.6020604@ya.ru>
	<20130327150743.GC14900@thunk.org>
	<alpine.LNX.2.00.1303271135420.29687@eggly.anvils>
	<3C8EEEF8-C1EB-4E3D-8DE6-198AB1BEA8C0@gmail.com>
	<515CD665.9000300@gmail.com>
	<239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com>
	<51730619.3030204@fastmail.fm>
	<20130420235718.GA28789@thunk.org>
	<5176785D.5030707@fastmail.fm>
	<20130423122708.GA31170@thunk.org>
	<alpine.LNX.2.00.1304231230340.12850@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Bernd Schubert <bernd.schubert@fastmail.fm>, Alexey Lyahkov <alexey.lyashkov@gmail.com>, Will Huck <will.huckk@gmail.com>, Andrew Perepechko <anserper@ya.ru>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de

On Tue, 23 Apr 2013 12:57:45 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> For now I stand by what I said before (if you find it effective
> in practice - I haven't heard back): at the moment you need to
> 
> 	mark_page_accessed(page);	/* to SetPageReferenced */
> 	lru_add_drain();		/* to SetPageLRU */
> 	mark_page_accessed(page);	/* to SetPageActive */
> 
> when such a metadata page is first brought in.

That should fix things for now.  Although it might be better to just do

 	mark_page_accessed(page);	/* to SetPageReferenced */
 	lru_add_drain();		/* to SetPageLRU */


Because a) this was too early to decide that the page is
super-important and b) the second touch of this page should have a
mark_page_accessed() in it already.

I do agree that we should be able to set both PageReferenced and
PageActive on a lru_add_pvecs page and have those hints honoured when
lru_add_pvecs is spilled onto the LRU.

At present the code decides up-front which LRU the lru_add_pvecs page
will eventually be spilled onto.  That's a bit strange and I wonder why
we did it that way.  Why not just have a single (per-cpu) magazine of
pages which are to go onto the LRUs, and decide *which* LRU that will
be at the last possible moment?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
