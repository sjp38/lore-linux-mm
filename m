Subject: Re: 2.4.14 + Bug in swap_out.
References: <Pine.LNX.4.21.0111211558160.1394-100000@localhost.localdomain>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 21 Nov 2001 09:26:21 -0700
In-Reply-To: <Pine.LNX.4.21.0111211558160.1394-100000@localhost.localdomain>
Message-ID: <m1y9l0ytsi.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> writes:

> On Wed, 21 Nov 2001, Rik van Riel wrote:
> > On Wed, 21 Nov 2001, Hugh Dickins wrote:
> > >
> > > fork and exec are well ordered in how they add to the mmlist,
> > > and that ordering (children after parent) suited swapoff nicely,
> > > to minimize duplication of a swapent while it's being unused;
> > > except swap_out randomized the order by cycling init_mm around it.
> > 
> > Urmmm, so the code was obfuscated in order to optimise
> > swapoff() ?
> 
> To speed swapoff, I changed the code back to how fork (see comment
> on "Add it to the mmlist" in fork.c old and new) and exec seemed to
> intend.  I don't see see that I _obfuscated_ the code:
> what's so difficult about swap_mm?

Practical test when I pointed out that something needed to be done
(and I didn't see the code in mmput) both David & Rik didn't even
see the problem much less where it was worked around.  And neither
of the saw the code in mmput.  If people can look at the code
and see what is going on that is hard to follow, by definition.

The primary problem with swap_mm is that swap_mm is used totally
unexpectedly in a different file.  Instead of it's usage being small
local and contained.

> > Exactly how bad was the "mmlist randomising" for swapoff() ?
> 
> It was unnecessary and counter-productive, I changed it.
> Exact number?  No, but small.

There is some sense in allowing swapoff not to check new processes
but...  The only optimization that really makes sense with swapoff is
to turn it inside out and traverse each process only once...  With
possibly a little of the current logic to handle the shared swap case.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
