Received: from bitmover.com (root@bitmover.com [207.181.251.162])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA23419
	for <linux-mm@kvack.org>; Tue, 30 Jun 1998 15:39:49 -0400
Message-Id: <199806301930.MAA09098@bitmover.com>
From: lm@bitmover.com (Larry McVoy)
Subject: Re: Thread implementations... 
Date: Tue, 30 Jun 1998 12:30:45 -0700
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, Christoph Rohland <hans-christoph.rohland@sap-ag.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

: Not for very large files: the forget-behind is absolutely critical in
: that case.

SunOS' local file system, UFS, implements the following alg for forget
behind on all types of accesses (SunOS has a unified page cache, all
accesses are mmap based, read/write are implemented by the kernel doing
an mmap and then a bcopy):

	if ((free_memory < we_will_start_paging_soon) &&
	    (offset is clust_size multiple) &&
	    (offset > small_file) &&
	    (access is sequential)) {
	    	free_behind(vp, offset - clust_size, clust_size);
	}

in the ufs_getpage() code.

I'll admit this was a hack, but it had some nice attributes that you might
want to consider:

	1) it was nice that I/O took care of itself.  The pageout daemon is
	   pretty costly (Stephen, we talked about this at Linux Expo - this
	   is why I want a pageout daemon that works on files, not on pages).
	
	2) Small files aren't worth the trouble and aren't the cause of the
	   trouble.  
	
	3) Random access frequently wants caching and randoms are expensive
	   to bring in.
	
	4) I/O is freed in large chunks, not a page at a time.  It's about
	   as costly to bring in one page as bring in 64-256K these days.
