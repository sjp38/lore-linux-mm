Date: Mon, 13 Jul 1998 14:42:07 +0100
Message-Id: <199807131342.OAA06485@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.95.980711214119.28032A-100000@as200.spellcast.com>
References: <199807112123.WAA03437@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.95.980711214119.28032A-100000@as200.spellcast.com>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 11 Jul 1998 21:47:44 -0400 (EDT), "Benjamin C.R. LaHaise"
<blah@kvack.org> said:

> On Sat, 11 Jul 1998, Stephen C. Tweedie wrote:
>> Personally, I think just a two-level LRU ought to be adequat.   Yes, I
>> know this implies getting rid of some of the page ageing from 2.1 again,
>> but frankly, that code seems to be more painful than it's worth.  The
>> "solution" of calling shrink_mmap multiple times just makes the
>> algorithm hideously expensive to execute.

> Hmmm, is that a hint that I should sit down and work on the code tomorrow
> whilst recovering? =)

I'm working on it right now.  Currently, the VM is so bad that it is
seriously getting in the way of my job.  Just trying to fix some odd
swapper bugs is impossible to test because I can't set up a ramdisk for
swap and do in-memory tests that way: things thrash incredibly.  The
algorithms for aggressive cache pruning rely on fractions of
nr_physpages, and that simply doesn't work if you have large numbers of
pages dedicated to non-swappable things such as ramdisk, bigphysarea DMA
buffers or network buffers.

Rik, unfortunately I think we're just going to have to back out your
cache page ageing.  I've just done that on my local test box and the
results are *incredible*: it is going much more than an order of
magnitude faster on many things.  Fragmentation also seems drastically
improved: I've been doing builds of defrag in a 6MB box which were
impossible beforehand due to NFS stalls.

I'm going to do a bit more experimenting to see if we can keep some of
the good ageing behaviour by doing proper LRU in the cache, but
otherwise I think the cache ageing has either got to go or to be
drastically altered.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
