Date: Thu, 16 Aug 2001 20:37:50 -0700 (PDT)
From: Ted Unangst <tedu@stanford.edu>
Subject: Re: help for swap encryption
In-Reply-To: <Pine.LNX.4.33L.0108162307290.5646-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.GSO.4.31.0108161922240.13329-100000@elaine12.Stanford.EDU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Aug 2001, Rik van Riel wrote:

> > 1.  the data is at page->virtual, right?  that's what i want.
>
> Doing this will make your scheme unable to work on
> machines with more than 890MB of RAM.

aiee!  well, i obviously don't want to encrypt the page struct.  what i'm
having trouble finding is how to access the in RAM data.  i followed the
(rw, page, dev, etc.) arguments around for a while, but i wasn't able to
see what actually got sent to disk.  how do i find out what data is
referenced by the page?

> > 2.  if a page gets written to disk, nobody will be trying to read the
> > former RAM location, correct?  i was going to encrypt the ram in place.
> > nobody is going to go back and try reading that RAM again, are they?
>
> Wrong. You'll have to remove the page from the swap
> cache first, possibly moving it to an encrypted
> swap cache ;)

yes.  i didn't account for that.


pages are 4k, right?  i'll assume so.  now, starting at the beginning,
with a simplified VM:

4k of RAM, starting at address 0x16abcdef, needs to be swapped.  so i need
to make that 4k of RAM encrypted.  or i need to encrypt it to another
address, 0x11223344, and make sure that _that_ is the data to go to disk.
it sounds like only the second choice will work without messing up the
swap cache.

problem: the page disappears into the filesystem code before being
written.  so unless i change nearly every api along the way, it looks like
every file written to disk is going to get encrypted with a random key.
that's bad.
same thing with reading it back and decrypting it.

to break the whole thing down into simple steps:
1.  page is selected for swap out.
2.  that data is encrypted.  <-- new!
3.  encrypted data goes to disk, to the same spot it would have normally.
4.  page is selected for swap in.
5.  data is read from disk.
6.  data is decrypted.  <-- new!
7.  data is copied to wherever it was supposed to go.

i'm having trouble i think because 1 & 3 and 5 & 7 as they are now, are
close to atomic operations.  as in, it's difficult to show up in between.
and the vm read/write operations are tangled up in the fs code.

well, hopefully, it won't be too much trouble to help me.  i know you're
busy.  :)  someone else?

thanks
ted




--
"If you take out the killings, Washington actually has a very very
low crime rate."
      - M. Barry, Mayor of Washington, DC


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
