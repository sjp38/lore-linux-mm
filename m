Date: Mon, 29 Jul 2002 11:24:07 -0400
Subject: Re: [RFC] start_aggressive_readahead
Content-Type: text/plain; charset=US-ASCII; format=flowed
Mime-Version: 1.0 (Apple Message framework v482)
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
In-Reply-To: <Pine.LNX.4.44L.0207282355130.3086-100000@imladris.surriel.com>
Message-Id: <397881C8-A307-11D6-A4C0-000393829FA4@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@zip.com.au>, Christoph Hellwig <hch@lst.de>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Sunday, July 28, 2002, at 11:05 PM, Rik van Riel wrote:

> My experience with 300 ftp clients pulling a collective 40 Mbit/s
> suggests otherwise.
>
> About 70% of the clients were on modem speed and the other 30% of
> the clients were on widely variable higher speeds.
>
> Since a disk seek + read is about 10ms, the absolute maximum
> number of seeks that can be done is 100 a second and the minimum
> amount of time between disk seeks for one stream should be about
> 3 seconds.

This is a very interesting example of some real (and important) reference 
behavior that must be understood to be handled well.  In the context of 
this thread of discussion, this case is substantially different from your 
original comment on read-ahead for ``linear file I/O''.

Just as a refresher for myself and anyone else that needs it:  I claimed 
that linear file I/O was a case in which read-ahead blocks should not be 
cached for long before they would either be used or evicted from lack of 
use.  (That is, they should be placed nearer to the end of the LRU 
ordering.)  The claim was based on the observation that sequential file 
traversal is a very good case for read-ahead, where the read-ahead blocks 
are very likely to be used very soon.

What's important about this example is that, due to the whole system 
workload and the disparate connection speeds of the ftp clients, it is 
*NOT* a typical case of linear file I/O.  In fact, what's odd about it is 
that block `i' of a file will be read, and for slower connections, block `
i+1' will *not* be used for some time, since reading block `i' will take a 
while.  In other words, the interleaved reference behavior from all of 
these ftp downloads makes the prediction that block `i+1' will be used 
soon a weaker prediction.  It is very likely to be used, yes, but not so 
soon in many cases due to the other files being read and referenced.

Because the soonness of use is weak, we do indeed want to cache the 
read-ahead pages for longer.  (That is, I agree that for this example, 
read-ahead pages should go into the active list.)  Caching read-ahead 
pages for longer, though, displaces more used pages, forcing them to be 
evicted sooner then they would have been without the aggressive read-ahead 
caching.  Critically, for *this* workload, that's probably just fine.  
Assuming that different files are being downloaded by different ftp 
clients, after reading and referencing a block, it's probably worth little 
to cache it in case of re-use for very long.  In other words, among the 
referenced pages, those near the end of the LRU ordering are referenced 
rarely.  The competition between read-ahead pages and less recently used 
referenced pages is lopsided in favor of the read-ahead pages.  But that 
is only a consequence of reference pattern for *this specific workload* -- 
it may not be true for other workloads.

Incidentally, this is all just mental masturbation until someone actually 
records and measures the reference behavior from this kind of workload.  
It all sounds about right, but that's neither good science nor good 
engineering.

In short, I agree that for this case, inserting read-ahead pages into the 
inactive list may not be aggressive enough.  I disagree that the reason is 
``linear file I/O'', as the reference pattern here is more complex than 
that.  This is also a wonderful case for getting read-ahead caching 
adaptivity right:  A system that can weigh read-ahead caching allocations 
against less recently used referenced-page allocations will detect and 
adjust to this case quickly, while avoiding such aggressive read-ahead 
caching for other workloads.

Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9RV4a8eFdWQtoOmgRAk6tAKCYX8tHrauHGMaek1oyCJMvEQf5yACgrEgX
pHx2gTsY4HTy9OUmOZjT7I8=
=JTJP
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
