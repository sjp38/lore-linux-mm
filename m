Date: Sun, 28 Jul 2002 19:32:30 -0400
Subject: Re: [RFC] start_aggressive_readahead
Content-Type: text/plain; charset=US-ASCII; format=flowed
Mime-Version: 1.0 (Apple Message framework v482)
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
In-Reply-To: <3D41A54D.408FA357@zip.com.au>
Message-Id: <48F039DC-A282-11D6-A4C0-000393829FA4@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Christoph Hellwig <hch@lst.de>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Friday, July 26, 2002, at 03:38 PM, Andrew Morton wrote:

> readahead was rewritten for 2.5.

It is just darned difficult to keep up with all of the changes!

> I think it covers most of the things you discuss there.
>
> - It adaptively grows the window size in response to "hits"

Seems somewhat reasonable, although easy to be fooled.  If I reference 
some of the most recently read-ahead blocks, I'll grow the read-ahead 
window, keeping other unreference, read-ahead blocks for longer, even 
though there's no evidence that keeping them longer will result in more 
hits.  In other words, it's not hits that should necessarily make you grow 
the cache -- it's the evidence that there will be an *increase* in hits if 
you do.

> - It shrinks the window size in response to "misses"  - if
>   userspace requests a page which is *not* inside the previously-requested
>   window, the future window size is shrunk by 25%

This one seems wierd.  If I reference a page that could have been in a 
larger read-ahead window, shouldn't I make the window *larger* so that 
next time, it *will* be in the window?

> - It detects eviction:  if userspace requests a page which *should*
>   have been inside the readahead window, but it's actually not there,
>   then we know it was evicted prior to being used.  We shrink the
>   window by 3 pages.  (This almost never happens, in my testing).

Again, this seems backwards in the manner mentioned above.  It could have 
been resident, but it was evicted, so if you want it to be a hit, make the 
window *bigger*, no?  What should drive the reduction in the read-ahead 
window is the observation that recent increases have not yielding higher 
hit rates -- more has not been better.

> - It behaves differently for page faults:  for read(2), readahead is
>   strictly ahead of the requested page.  For mmap pagefaults,
>   the readaround window is positioned 25% behind the requested page and
>   75% ahead of it.

That seems sensible enough...

The entire adaptive mechanism you've described seems only to consider one 
of the two competing pools, though, namely the read-ahead pool of pages.  
What about its competition -- The references to pages that are near 
eviction at the end of the inactive list?  Adapting to one without 
consideration of the other is working half-blind.  Why would you ever want 
to shrink the read-ahead window if very, very few pages at the end of the 
inactive list are being hit?  Similarly, you would want to be very 
cautious about increasing the size of the read-ahead window of many pages 
at the end of the inactive list are being re-used.

> To some extent, this device-level caching makes the whole readahead thing 
> of historical interest only, I suspect.

To some extent, yes, but the scales are substantially difference.  If your 
disk has just a few MB of cache, but your RAM is hundreds of MB (or larger)
, the VM system can choose to cache read-ahead pages for much, much longer 
if it detects that its of greater benefit than caching very old, used 
pages.

> - We no longer put readahead pages on the active list.  They are placed
>   on the head of the inactive list.  If nobody subsequently uses the
>   page, it proceeds to the tail of the inactive list and is evicted.

This seems a wise move, as placing them in the active list is only going 
to be beneficial in some very unusual cases.  Still, the question does 
remain as to *how long* a read-ahead page should be left unused before it 
is prepared for eviction.

I'll admit that it's not necessarily clear how to do the cost/benefit 
adaptivity that I'm describing.  I'm working on that right now, which I 
why I'm suddenly so curious about the details of this VM and how to play 
with it.  All in all, it sounds like you've made good changes, but perhaps 
you can address the weaknesses that I've pointed out (or tell me why I'm 
wrong about them).

Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9RH8R8eFdWQtoOmgRAtQPAJwJr6z3zkY5fJShQ3fSq44j2PwsLgCffw2B
xyUMF/CKvmvn3+4BDvbcekQ=
=BuBd
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
