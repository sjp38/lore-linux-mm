From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Re: differences between MADV_FREE and MADV_DONTNEED
Date: Tue, 17 Jan 2006 02:06:09 +0100
References: <20051029025119.GA14998@ccure.user-mode-linux.org> <43757263.2030401@us.ibm.com> <20060116130649.GE15897@opteron.random>
In-Reply-To: <20060116130649.GE15897@opteron.random>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200601170206.10212.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, hugh@veritas.com, dvhltc@us.ibm.com, linux-mm@kvack.org, jdike@addtoit.com
List-ID: <linux-mm.kvack.org>

On Monday 16 January 2006 14:06, Andrea Arcangeli wrote:
> Now that MADV_REMOVE is in, should we discuss MADV_FREE?

> MADV_FREE in Solaris is destructive and only works on anonymous memory,

I.e. it's a restriction of MADV_REMOVE. Is there anything conceivable relying 
on errors or no behaviour on file-backed memory? If relying on errors we 
could need an API, but if relying only on the NO-OP thing the correctness 
semantics are already implemented. I.e. data are retained on both Solaris 
MADV_FREE and Linux MADV_REMOVE for file-backed case, they get a different 
semantics for caching.

> while MADV_DONTNEED seems to never be destructive (which I assume it
> means it's a noop on anonymous memory).

It could be a "swap it out", as mentioned in Linux comments on our madvise 
semantics about "other Unices".

> Our MADV_DONTNEED is destructive on anonymous memory, while it's
> non-destructive on file mappings.

Indeed, not even that. See our madvise_dontneed() comment - dirty data are 
discarded in both cases, and the comment suggests msync(MS_INVALIDATE). It 
also speaks of "other implementation", which could also refer to Solaris.

> Perhaps we could move the destructive anonymous part of MADV_DONTNEED to
> MADV_FREE?

Why changing existing apps behaviour? That's nonsense, unless you have a 
standard. Indeed, however, posix_madvise exists, and it's DONTNEED semantics 
are the Solaris ones. Don't know past behaviour about "breaking existing to 
comply to standards" (new syscall slot?).

> Or we could as well go relaxed and define MADV_FREE and MADV_DONTNEED
> the same way (that still leaves the question if we risk to break apps
> ported from solaris where MADV_DONTNEED is apparently always not
> destructive).

Provide our fine-grained semantics with new, not misunderstandable identifiers 
(MADV_FREE_DISCARD, MADV_FREE_CACHE, for instance).

For current names, libc could provide a "let user choose the meaning of 
things", like it does for signals with _BSD_SOURCE, _POSIX_SOURCE and so on.

> I only read the docs, I don't know in practice what MADV_DONTNEED does
> on solaris (does it return -EINVAL if run on anonymous memory or not?).

> http://docs.sun.com/app/docs/doc/816-5168/6mbb3hrgk?a=view

> BTW, I don't know how other specifications define MADV_FREE, but besides
> MADV_REMOVE I've also got the request to provide MADV_FREE in linux,
> this is why I'm asking. (right now I'm telling them to use #ifdef
> __linux__ #define MADV_FREE MADV_DONTNEED but that's quite an hack since
> it could break if we make MADV_DONTNEED non-destructive in the future)

Making their apps work by causing the same breakage to Linux apps is a better 
idea?

> Thanks.

-- 
Inform me of my mistakes, so I can keep imitating Homer Simpson's "Doh!".
Paolo Giarrusso, aka Blaisorblade (Skype ID "PaoloGiarrusso", ICQ 215621894)
http://www.user-mode-linux.org/~blaisorblade

	

	
		
___________________________________ 
Yahoo! Mail: gratis 1GB per i messaggi e allegati da 10MB 
http://mail.yahoo.it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
