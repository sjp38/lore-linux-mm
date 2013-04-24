Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id E69FB6B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 10:26:56 -0400 (EDT)
Date: Wed, 24 Apr 2013 10:26:50 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: page eviction from the buddy cache
Message-ID: <20130424142650.GA29097@thunk.org>
References: <alpine.LNX.2.00.1303271135420.29687@eggly.anvils>
 <3C8EEEF8-C1EB-4E3D-8DE6-198AB1BEA8C0@gmail.com>
 <515CD665.9000300@gmail.com>
 <239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com>
 <51730619.3030204@fastmail.fm>
 <20130420235718.GA28789@thunk.org>
 <5176785D.5030707@fastmail.fm>
 <20130423122708.GA31170@thunk.org>
 <alpine.LNX.2.00.1304231230340.12850@eggly.anvils>
 <20130423150008.046ee9351da4681128db0bf3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130423150008.046ee9351da4681128db0bf3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Bernd Schubert <bernd.schubert@fastmail.fm>, Alexey Lyahkov <alexey.lyashkov@gmail.com>, Will Huck <will.huckk@gmail.com>, Andrew Perepechko <anserper@ya.ru>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de

On Tue, Apr 23, 2013 at 03:00:08PM -0700, Andrew Morton wrote:
> That should fix things for now.  Although it might be better to just do
> 
>  	mark_page_accessed(page);	/* to SetPageReferenced */
>  	lru_add_drain();		/* to SetPageLRU */
> 
> Because a) this was too early to decide that the page is
> super-important and b) the second touch of this page should have a
> mark_page_accessed() in it already.

The question is do we really want to put lru_add_drain() into the ext4
file system code?  That seems to pushing some fairly mm-specific
knowledge into file system code.  I'll do this if I have to do, but
wouldn't be better if this was pushed into mark_page_accessed(), or
some other new API was exported by the mm subsystem?

> At present the code decides up-front which LRU the lru_add_pvecs page
> will eventually be spilled onto.  That's a bit strange and I wonder why
> we did it that way.  Why not just have a single (per-cpu) magazine of
> pages which are to go onto the LRUs, and decide *which* LRU that will
> be at the last possible moment?

And this is why it seems strange that fs code should need or should
want to put something as mm-implementation dependent into their code
paths.  At minimum, if we do this, we'll want to put some explanatory
comments so that later, people won't be asking, what the !@#@?!? are
the ext4 people calling lru_add_drain() here?

							- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
