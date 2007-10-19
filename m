From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: SLUB: Avoid atomic operation for slab_unlock
Date: Fri, 19 Oct 2007 11:56:42 +1000
References: <Pine.LNX.4.64.0710181514310.3584@schroedinger.engr.sgi.com> <200710190949.01019.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0710181817380.4194@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710181817380.4194@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710191156.43049.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 19 October 2007 11:21, Christoph Lameter wrote:
> On Fri, 19 Oct 2007, Nick Piggin wrote:
> > Ah, thanks, but can we just use my earlier patch that does the
> > proper __bit_spin_unlock which is provided by
> > bit_spin_lock-use-lock-bitops.patch
>
> Ok.
>
> > This primitive should have a better chance at being correct, and
> > also potentially be more optimised for each architecture (it
> > only has to provide release consistency).
>
> Yes that is what I attempted to do with the write barrier. To my knowledge
> there are no reads that could bleed out and I wanted to avoid a full fence
> instruction there.

Oh, OK. Bit risky ;) You might be right, but anyway I think it
should be just as fast with the optimised bit_unlock on most
architectures.

Which reminds me, it would be interesting to test the ia64
implementation I did. For the non-atomic unlock, I'm actually
doing an atomic operation there so that it can use the release
barrier rather than the mf. Maybe it's faster the other way around
though? Will be useful to test with something that isn't a trivial
loop, so the slub case would be a good benchmark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
