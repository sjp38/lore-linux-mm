Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 99B346B005D
	for <linux-mm@kvack.org>; Wed, 20 May 2009 16:42:04 -0400 (EDT)
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090520183045.GB10547@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com>
Content-Type: text/plain
Date: Wed, 20 May 2009 22:42:38 +0200
Message-Id: <1242852158.6582.231.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-05-20 at 11:30 -0700, Larry H. wrote:
> This patch adds support for the SENSITIVE flag to the low level page
> allocator. An additional GFP flag is added for use with higher level
> allocators (GFP_SENSITIVE, which implies GFP_ZERO).
> 
> The code is largely based off the memory sanitization feature in the
> PaX project (licensed under the GPL v2 terms), and allows fine grained
> marking of pages for sanitization on allocation and release time, as an
> opt-in feature (instead of its opt-all counterpart in PaX).
> 
> This avoids leaking sensitive information when memory is released to
> the system after use, for example in cryptographic subsystems.
> 
> The next patches in this set deploy this flag for different
> subsystems that could potentially leak cryptographic secrets or other
> confidential information by means of an information leak or other kinds
> of security bugs (ex. use of uninitialized variables or use-after-free),
> besides extending the remanence of this data on memory (allowing
> Iceman/coldboot attacks possible).
> 
> The "Shredding Your Garbage: Reducing Data Lifetime Through Secure
> Deallocation" paper by Jim Chow et. al from the Stanford University
> Department of Computer Science, explains the security implications of
> insecure deallocation, and provides extensive information with figures
> and applications thoroughly analyzed for this behavior [1]. More recently
> this issue came to widespread attention when the "Lest We Remember:
> Cold Boot Attacks on Encryption Keys" (by Halderman et. al) paper was
> published [2].

Seems like a particularly wasteful use of a pageflag. Why not simply
erase the buffer before freeing in those few places where we know its
important (ie. exactly those places you now put the pageflag in)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
