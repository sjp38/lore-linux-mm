Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA26943
	for <linux-mm@kvack.org>; Wed, 1 Jul 1998 05:23:45 -0400
Date: Wed, 1 Jul 1998 09:50:57 +0100
Message-Id: <199807010850.JAA00764@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Thread implementations... 
In-Reply-To: <199806301930.MAA09098@bitmover.com>
References: <199806301930.MAA09098@bitmover.com>
Sender: owner-linux-mm@kvack.org
To: Larry McVoy <lm@bitmover.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, Christoph Rohland <hans-christoph.rohland@sap-ag.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 30 Jun 1998 12:30:45 -0700, lm@bitmover.com (Larry McVoy)
said:

> 	if ((free_memory < we_will_start_paging_soon) &&
> 	    (offset is clust_size multiple) &&
> 	    (offset > small_file) &&
> 	    (access is sequential)) {
> 	    	free_behind(vp, offset - clust_size, clust_size);
> 	}

Looks entirely reasonable.  I've been thinking of something very
similar but just a little more complex, so that we can also cleanly
handle the case of sequential mmap()ed reads, both of mapped files and
potentially of anonymous datasets.  The difference there is that if we
are dealing with tiled data, then we may need to allow a larger window
between the current pagein cursor and the forget-behind cursor.
Again, if we just unmap the pages and place them on a high-priority
reuse queue, then getting the guess wrong just results in a minor
fault unless we do actually reuse the memory before accessing the data
again.

> 	1) it was nice that I/O took care of itself.  The pageout daemon is
> 	   pretty costly (Stephen, we talked about this at Linux Expo - this
> 	   is why I want a pageout daemon that works on files, not on pages).

Yes, and Ingo and I have been talking about ways of doing it.
	
> 	2) Small files aren't worth the trouble and aren't the cause of the
> 	   trouble.  

Small files benefit from a similar scheme.  For small
sequentially-accessed files, as they age, we want to remove the entire
file from cache at once.  Repopulating a sequential file's fragmented
cache is expensive anyway, so it may in fact be _cheaper_ to do this
than to just throw out one page at a time.  

As long as we have the concept of a virtual extent, where we define
that extent as the natural readahead pattern for the workload, then we
want to uncache the same units we readahead.  That's normally
sequential clusters, but if we have things like Ingo's random swap
stats-based prediction logic, then we can use exactly the same extent
concept there too.
	
--Stephen
