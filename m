Date: Sun, 28 Jul 2002 22:12:08 -0400
Subject: Re: [RFC] start_aggressive_readahead
Content-Type: text/plain; charset=US-ASCII; format=flowed
Mime-Version: 1.0 (Apple Message framework v482)
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
In-Reply-To: <Pine.LNX.4.44L.0207282117040.3086-100000@imladris.surriel.com>
Message-Id: <95C024B4-A298-11D6-A4C0-000393829FA4@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@zip.com.au>, Christoph Hellwig <hch@lst.de>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Sunday, July 28, 2002, at 08:19 PM, Rik van Riel wrote:

> I'm not sure about that. If we do linear IO we most likely
> want to evict the pages we've already used as opposed to the
> pages we're about to use.

The situation is more subtle than that.  I agree that in a linear I/O case,
  the read-ahead pages are extremely likely to be used very soon.  However,
  that does *not* imply that they should be promoted to the active list -- 
in fact, quite the opposite when considering the read-ahead situation.

Consider exactly the case you have raised -- strict, linear referencing of 
blocks, such as a sequential file read.  When block `i' is referenced, it 
is an excellent prediction that block `i+1' will be referenced soon.  If 
block `i+1' is not referenced soon, then the prediction was incorrect, 
*and there's little reason to keep the block around any longer*.  In other 
words, the better the prediction, the closer to the end of the LRU 
ordering the blocks can be placed.  The ones that *are* used soon will be 
referenced and promoted to the front of the LRU ordering before they are 
evicted, exactly because the soonness of use is so strong.  The read-ahead 
blocks that are not used soon are evicted before long.  In other words, 
the shorter a time you think you need to keep a block, the closer to the 
end of the list it should go.  If your guess is wrong, you've displaced 
fewer other blocks.  If your prediction is a good one, such as with linear 
file reading, you will not need to cache a block as a read-ahead block for 
long before it is actually used.

It is when you predict that a read-ahead will not pay off for some time -- 
that the read-ahead blocks will not be used so soon -- that such blocks 
need to be placed closer to the front of the LRU ordering (that is, in the 
active list).  That way, they will be cached much longer so that they will 
still be resident when they finally are used.  Of course, such caching 
displaces more of the other pages, possibly causing faults on those.  It 
is when your read-ahead prediction indicates a weak soonness of use that 
you must compare the benefits of caching those pages against the cost of 
displacing other pages.  Only if few pages near the end of the LRU 
ordering -- non-read-ahead pages -- are being referenced might it be worth 
caching read-ahead pages for so long.

So, in the case of linear I/O, placing the read-ahead pages at the front 
of the inactive list is likely to provide more than enough time for those 
pages to be used and promoted to the active list.  By placing them in the 
inactive list, you reduce the damage done when read-ahead pages are *not* 
used soon.

Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9RKR78eFdWQtoOmgRAr1EAJ9RSY10utFCEvIftv9qEMNZzzczswCfTlZv
63z5vAMl38r+jtGQRImUkoY=
=X6S4
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
