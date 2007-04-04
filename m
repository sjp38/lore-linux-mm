Date: Wed, 4 Apr 2007 15:40:02 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [rfc] no ZERO_PAGE?
Message-ID: <20070404134002.GE19587@v2.random>
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de> <Pine.LNX.4.64.0704041023040.17341@blonde.wat.veritas.com> <20070404102407.GA529@wotan.suse.de> <Pine.LNX.4.64.0704041338450.7416@blonde.wat.veritas.com> <20070404130559.GD19587@v2.random> <Pine.LNX.4.64.0704041426080.10683@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704041426080.10683@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 04, 2007 at 02:32:03PM +0100, Hugh Dickins wrote:
> That's a little unfortunate, since we'd then have to lose the win from
> this change, that we issue a writable zeroed page (when VM_WRITE) in
> do_anonymous_page, even when it's a read fault, saving subsequent fault.

Hmm no, that win would remain (and that win would only apply to the
class of apps that we intend to hurt by removing the zero-page
anyway). I think it's enough to increase a per-cpu counter in
do_anonymous_page if it's a read fault, and nothing else. We don't
need to keep track of the exact number of ZERO_PAGEs in the
VM. Ideally nothing should increase my counter, hence your "exact"
counter would always be zero too when everything is ok.

The only real win we'll lose with the counter is the removal of the
slow-path branch in do_anonymous_page, but I guess I'm more
comfortable to be able to detect if something very inefficient ever
run on my system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
