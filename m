From: Neil Brown <neilb@suse.de>
Date: Fri, 2 Feb 2007 17:29:06 +1100
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17858.55858.642522.861130@notabene.brown>
Subject: Re: [rfc][patch] mm: half-fix page tail zeroing on write problem
In-Reply-To: message from Nick Piggin on Friday February 2
References: <20070202055142.GA5004@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Friday February 2, npiggin@suse.de wrote:
> Hi,
> 
> For no important reason, I've again looked at those zeroing patches that
> Neil did a while back. I've always thought that a simple
> `write(fd, NULL, size)` would cause the same sorts of problems.

Yeh, but who in their right mind would do that???
Oh, you did :-)

> 
> Turns out it does. If you first write all 1s into a page, then do the
> `write(fd, NULL, size)` at the same position, you end up with all 0s in
> the page (test-case available on request).  Incredible; surely this
> violates the spec?

Does it?
I guess filling with zeros isn't what one would expect, but you could
make a case for it being right.
  write(fd, 0, size)
writes 'size' 0s.  Cool.   Ok, bad-cool.

> 
> The buffered-write fixes I've got actually fix this properly, but  they
> don't look like getting merged any time soon. We could do this simple
> patch which just reduces the chance of corruption from a certainty down
> to a small race.
> 
> Any thoughts?

I cannot see why you make a change to fault_in_pages_writeable.  Is it
just for symmetry?
For the rest, it certainly makes sense to return an early -EFAULT if
you cannot fault in the page.

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
