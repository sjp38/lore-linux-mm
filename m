Message-ID: <419EA1D7.2060708@yahoo.com.au>
Date: Sat, 20 Nov 2004 12:45:59 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: page fault scalability patch V11 [0/7]: overview
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>  <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>  <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com>  <419D581F.2080302@yahoo.com.au>  <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com>  <419D5E09.20805@yahoo.com.au>  <Pine.LNX.4.58.0411181921001.1674@schroedinger.engr.sgi.com> <1100848068.25520.49.camel@gaston> <Pine.LNX.4.58.0411190704330.5145@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411191155180.2222@ppc970.osdl.org> <419E98E7.1080402@yahoo.com.au> <Pine.LNX.4.58.0411191726001.1719@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411191726001.1719@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sat, 20 Nov 2004, Nick Piggin wrote:
> 
> 
>>I think this sounds like it might be a good idea. I prefer it to having
>>the unbounded error of sloppy rss (as improbable as it may be in practice).
> 
> 
> It may also be faster since the processors can have exclusive cache lines.
> 

Yep.

> This means we need to move rss into the task struct. But how does one get
> from mm struct to task struct? current is likely available most of
> the time. Is that always the case?
> 

It is available everywhere that mm_struct is, I guess. So yes, I
think `current` should be OK.

> 
>>The per thread rss may wrap (maybe not 64-bit counters), but even so,
>>the summation over all threads should still end up being correct I
>>think.
> 
> 
> Note though that the mmap_sem is no protection. It is a read lock and may
> be held by multiple processes while incrementing and decrementing rss.
> This is likely reducing the number of collisions significantly but it wont
> be a  guarantee like locking or atomic ops.
> 

Yeah the read lock won't do anything to serialise it. I think what Linus
is saying is that we _don't care_ most of the time (because the error will
be bounded). But if it happened that we really do care anywhere, then the
write lock should be sufficient.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
