Date: Mon, 20 Jul 1998 17:04:19 +0100
Message-Id: <199807201604.RAA01395@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980719000622.27620E-100000@mirkwood.dummy.home>
References: <199807131342.OAA06485@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980719000622.27620E-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 19 Jul 1998 00:10:09 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On Mon, 13 Jul 1998, Stephen C. Tweedie wrote:
>> I'm working on it right now.  Currently, the VM is so bad that it is
>> seriously getting in the way of my job.  Just trying to fix some odd
>> swapper bugs is impossible to test because I can't set up a ramdisk for
>> swap and do in-memory tests that way: things thrash incredibly.  The
>> algorithms for aggressive cache pruning rely on fractions of
>> nr_physpages, and that simply doesn't work if you have large numbers of
>> pages dedicated to non-swappable things such as ramdisk, bigphysarea DMA
>> buffers or network buffers.

> This means we'll have to substract those pages before
> determining the used percentage.

Sure, but that's just admitting that the system is so inherently
incapable of balancing itself that we have to place fixed limits on
the cache size, and I'm not sure that's a good thing.

>> Rik, unfortunately I think we're just going to have to back out your
>> cache page ageing.  I've just done that on my local test box and the
>> results are *incredible*:

> OK, I don't see much problems with that, except that the
> aging helps a _lot_ with readahead. For the rest, it's
> not much more than a kludge anyway ;(

This is something we need to sort out.  From my benchmarks so far, the
one thing that's certain is that you were benchmarking something
different from me when you found the ageing speedups.  That's not
good, because it implies that neither mechanism is doing the Right
Thing.  What sort of circumstances were you seeing big performance
improvements in for your original page ageing code?  That might help
us to identify what the core improvement in the ageing is, so that we
don't lose too much if we start changing the scheme again.

> We really ought to do better than that anyway. I'll give
> you guys the URL of the Digital Unix manuals on this...
> (they have some _very_ nice mechanisms for this)

OK, thanks!

> A 2-level LRU on the page cache would be _very_ nice,
> but probably just as desastrous wrt. fragmentation as
> aging...

Actually, fragmentation is not the big issue wrt ageing.  The page
ageing code is simply keeping the cache too large; the time it takes
to age the cache means that far too much is getting swapped out, and
on low memory machine the cache grows too large altogether.

This means that there may be several ways forward.  A multi-level LRU
would not necessarily be any worse for fragmentation.  Keeping a (low)
ceiling on the page age in the cache might also be a way forward,
allowing us to give a priority boost to readahead pages, but letting
us then cap the age once the pages are read to prevent them from
staying too long in the cache.  

I'm also experimenting right now with a number of new zoneing and
ageing mechanisms which may address the fragmentation issue.  As far
as page ageing is concerned, it's really just the overall cache size,
and the self-tuning of the cache size, which are my main concerns at
the moment.

--Stephen

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
