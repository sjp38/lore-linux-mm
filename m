Date: Tue, 30 Jul 2002 09:21:57 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: [RFC] start_aggressive_readahead
Message-ID: <644994853.1028020916@[10.10.2.3]>
In-Reply-To: <F245ABF4-A3D6-11D6-9922-000393829FA4@cs.amherst.edu>
References: <F245ABF4-A3D6-11D6-9922-000393829FA4@cs.amherst.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>, Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
>> Ah, but if we're not getting hits in the readahead window
>> then we're getting misses.  And misses shrink the window.
> 
> Yes, and that's the wrong thing to do.  If you are getting hits, 
> you should try *skrinking* the window to see if there is a 
> reduction in hits.  If there is no reduction, you can capture 
> just as many hits with a smaller window -- the extra space was
> superfluous.  If you're getting misses, you should try to *grow* 
> the window (to commit an awful case of verbing) in an attempt to 
> turn such misses into hits.  If growing the window doesn't decrease 
> the misses, then you may need too large of an increase to cache 
> those pages successfully.  If growing the window does decrease 
> the misses, then keep growing until you don't see a decrease.

Would it not be easier to actually calculate (statistically) the 
read-ahead window, rather than actually tweaking it empirically?
If we're getting misses, there could be at least two causes - 

1. We're doing random, not sequential IO. Shrinking the window
would be most sensible.

2. We're reading ahead really fast, or skip-reading ahead. 
Growing the window would probably be most sensible.

Thus I'd contend that either growing or shrinking in straight 
response to just a hit/miss rate is not correct. We need to actually 
look at the access pattern of the application, surely? Perhaps I'm 
being naive, but I would have thought it would be possible
to calculate what the hit/miss rate with a given readahead window
would be without actually going to the pain of shrinking it up
and down.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
