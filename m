Date: Mon, 8 Feb 1999 11:24:58 GMT
Message-Id: <199902081124.LAA02285@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Large memory system
In-Reply-To: <Pine.LNX.3.95.990130114256.27443A-100000@kanga.kvack.org>
References: <19990130083631.B9427@msc.cornell.edu>
	<Pine.LNX.3.95.990130114256.27443A-100000@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Daniel Blakeley <daniel@msc.cornell.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 30 Jan 1999 12:00:53 -0500 (EST), "Benjamin C.R. LaHaise"
<blah@kvack.org> said:

> Easily isn't a good way of putting it, unless you're talking about doing
> something like mmap on /dev/mem, in which case you could make the
> user/kernel virtual spilt weigh heavy on the user side and do memory
> allocation yourself.  If you're talking about doing it transparently,
> you're best bet is to do something like davem's suggested high mem
> approach, and only use non-kernel mapped memory for user pages... if you
> want to be able to support the page cache in high memory, things get
> messy.

No it doesn't!  The only tricky thing is IO, but we need to have bounce
buffers to high memory anyway for swapping.  The page cache uses "struct
page" addresses in preference to actual page data pointers almost
everywhere anyway, and whenever we are doing something like read(2) or
write(2) functions, we just need a single per-CPU virtual pte in the
vmalloc region to temporarily map the page into memory while we copy to
user space (and remember that we do this from the context of the user
process anyway, so we don't have to remap the user page even if it is in
high memory).

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
