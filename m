Subject: Re: Large memory system
References: <19990130083631.B9427@msc.cornell.edu> 	<Pine.LNX.3.95.990130114256.27443A-100000@kanga.kvack.org> <199902081124.LAA02285@dax.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 08 Feb 1999 09:31:11 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Mon, 8 Feb 1999 11:24:58 GMT"
Message-ID: <m17lts52v4.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Daniel Blakeley <daniel@msc.cornell.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> Hi,
ST> On Sat, 30 Jan 1999 12:00:53 -0500 (EST), "Benjamin C.R. LaHaise"
ST> <blah@kvack.org> said:

>> Easily isn't a good way of putting it, unless you're talking about doing
>> something like mmap on /dev/mem, in which case you could make the
>> user/kernel virtual spilt weigh heavy on the user side and do memory
>> allocation yourself.  If you're talking about doing it transparently,
>> you're best bet is to do something like davem's suggested high mem
>> approach, and only use non-kernel mapped memory for user pages... if you
>> want to be able to support the page cache in high memory, things get
>> messy.

ST> No it doesn't!  The only tricky thing is IO, but we need to have bounce
ST> buffers to high memory anyway for swapping.  The page cache uses "struct
ST> page" addresses in preference to actual page data pointers almost
ST> everywhere anyway, and whenever we are doing something like read(2) or
ST> write(2) functions, we just need a single per-CPU virtual pte in the
ST> vmalloc region to temporarily map the page into memory while we copy to
ST> user space (and remember that we do this from the context of the user
ST> process anyway, so we don't have to remap the user page even if it is in
ST> high memory).

Cool.  We now have an idea that sounds possible.

The only remaining question is how much of a performance hit would changing 
the contents of a pte around all of the time be?

Every single page read/write syscall, as well as copying down to I/O bounce buffers
sounds common enough that we probably would see a performance hit.

The other thing that happens is we start breaking assumptions about fixed limits
based on architecture size.  Things like the swap entry may need to be expanded.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
