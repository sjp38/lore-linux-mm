From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17024.46571.303130.323765@gargle.gargle.HOWL>
Date: Tue, 10 May 2005 09:23:55 -0400
Subject: Re: Fw: [Bug 4520] New: /proc/*/maps fragments too quickly compared to
In-Reply-To: <20050509213027.GA3963@devserv.devel.redhat.com>
References: <17023.26119.111329.865429@gargle.gargle.HOWL>
	<20050509142651.1d3ae91e.akpm@osdl.org>
	<20050509213027.GA3963@devserv.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: Andrew Morton <akpm@osdl.org>, Wolfgang Wander <wwc@rentec.com>, mingo@elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Arjan van de Ven writes:
 > On Mon, May 09, 2005 at 02:26:51PM -0700, Andrew Morton wrote:
 > 
 > > Possibly for the 2.6.12 release the safest approach would be to just
 > > disable the free area cache while we think about it.
 > 
 > the free area cache either is historically tricky to be fair; it has the
 > thankless job of either keeping at the "ealiest" small hole (and thus being
 > useless if most allocs are bigger than that hole) or leaving an occasionally
 > small hole alone and thus fragmenting memory more, like you've shown.
 > I like neither to be honest; the price however is a higher lookup cost (well
 > mitigated if vma merging is really effective) 

My approach tries to find a compromise. It changes the behaviour so
that is keeps the size of the largest hole it found below the cache
so that it knows for what request size to disregard the cache and
start from scratch.  By doing so it also avoids setting the cache
to the latest munmap-ed region (and adjusts the largest_hole below
the cache pointer instead).  Setting the cache pointer to the latest
munmap was also a major contributor to the fragmentation:

Imagine 5 consecutive maps of 1K, then free map 2,4,3 in that order.
The next mmap will get its space from the original area 3 leaving gaps
on either side.

But I'm of course also very happy if the original 2.4 behaviour
without caching is restored...

                    Wolfgang
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
