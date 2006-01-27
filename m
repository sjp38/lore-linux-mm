Message-ID: <43D968E4.5020300@us.ibm.com>
Date: Thu, 26 Jan 2006 16:27:16 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 0/9] Critical Mempools
References: <1138217992.2092.0.camel@localhost.localdomain> <Pine.LNX.4.62.0601260954540.15128@schroedinger.engr.sgi.com> <43D954D8.2050305@us.ibm.com> <Pine.LNX.4.62.0601261516160.18716@schroedinger.engr.sgi.com> <43D95BFE.4010705@us.ibm.com> <20060127000304.GG10409@kvack.org>
In-Reply-To: <20060127000304.GG10409@kvack.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Christoph Lameter <clameter@engr.sgi.com>, linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:
> On Thu, Jan 26, 2006 at 03:32:14PM -0800, Matthew Dobson wrote:
> 
>>>I thought the earlier __GFP_CRITICAL was a good idea.
>>
>>Well, I certainly could have used that feedback a month ago! ;)  The
>>general response to that patchset was overwhelmingly negative.  Yours is
>>the first vote in favor of that approach, that I'm aware of.
> 
> 
> Personally, I'm more in favour of a proper reservation system.  mempools 
> are pretty inefficient.  Reservations have useful properties, too -- one 
> could reserve memory for a critical process to use, but allow the system 
> to use that memory for easy to reclaim caches or to help with memory 
> defragmentation (more free pages really helps the buddy allocator).

That's an interesting idea...  Keep track of the number of pages "reserved"
but allow them to be used something like read-only pagecache...  Something
along those lines would most certainly be easier on the page allocator,
since it wouldn't have chunks of pages "missing" for long periods of time.


>>>Gfp flag? Better memory reclaim functionality?
>>
>>Well, I've got patches that implement the GFP flag approach, but as I
>>mentioned above, that was poorly received.  Better memory reclaim is a
>>broad and general approach that I agree is useful, but will not necessarily
>>solve the same set of problems (though it would likely lessen the severity
>>somewhat).
> 
> 
> Which areas are the priorities for getting this functionality into?  
> Networking over particular sockets?  A GFP_ flag would plug into the current 
> network stack trivially, as sockets already have a field to store the memory 
> allocation flags.

The impetus for this work was getting this functionality into the
networking stack, to keep the network alive under periods of extreme VM
pressure.  Keeping track of 'criticalness' on a per-socket basis is good,
but the problem is the receive side.  Networking packets are received and
put into skbuffs before there is any concept of what socket they belong to.
 So to really handle incoming traffic under extreme memory pressure would
require something beyond just a per-socket flag.

I have to say I'm somewhat amused by how much support the old approach is
getting now that I've spent a few weeks going back to the drawing board and
coming up with what I thought was a more general solution! :\

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
