From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] My research agenda for 2.7
Date: Fri, 27 Jun 2003 16:41:06 +0200
References: <200306250111.01498.phillips@arcor.de> <200306270222.27727.phillips@arcor.de> <Pine.LNX.4.53.0306271345330.14677@skynet>
In-Reply-To: <Pine.LNX.4.53.0306271345330.14677@skynet>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200306271641.06771.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 27 June 2003 15:00, Mel Gorman wrote:
> On Fri, 27 Jun 2003, Daniel Phillips wrote:
> I was thinking of using slabs because that way there wouldn't be need to
> scan all of mem_map, just a small number of slabs. I have no basis for
> this other than hand waving gestures though.

That's the right idea, it's just not necessary to use slab cache to achieve 
it.  Actually, to handle huge (hardware) pages efficiently, my first instinct 
is to partition them into their own largish chunks as well, and allocate new 
chunks as necessary.  To get rid of a chunk (because freespace of that type 
of chunk has fallen below some threshold) it has to be entirely empty, which 
can be accomplished using the same move logic as for defragmentation.

You're right to be worried about intrusion of unmovable pages into regions 
that are supposed to be defraggable.  It's very easy for some random kernel 
code to take a use count on a page and hang onto it forever, making the page 
unmovable.  My hope is that:

  - This doesn't happen much
  - Code that does that can be cleaned up
  - Even when it happens it won't hurt much
  - If all of the above fails, fix the api for the offending code or create
    a new one
  - If that fails too, give up.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
