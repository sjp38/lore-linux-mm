Date: Sat, 18 Aug 2001 19:53:12 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: help for swap encryption
Message-ID: <20010818195312.I9870@nightmaster.csn.tu-chemnitz.de>
References: <Pine.LNX.4.33L.0108162307290.5646-100000@imladris.rielhome.conectiva> <Pine.GSO.4.31.0108161922240.13329-100000@elaine12.Stanford.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.31.0108161922240.13329-100000@elaine12.Stanford.EDU>; from tedu@stanford.edu on Thu, Aug 16, 2001 at 08:37:50PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ted Unangst <tedu@stanford.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 16, 2001 at 08:37:50PM -0700, Ted Unangst wrote:
> > > 2.  if a page gets written to disk, nobody will be trying to read the
> > > former RAM location, correct?  i was going to encrypt the ram in place.
> > > nobody is going to go back and try reading that RAM again, are they?
> >
> > Wrong. You'll have to remove the page from the swap
> > cache first, possibly moving it to an encrypted
> > swap cache ;)
> 
> yes.  i didn't account for that.
> 
> 
> pages are 4k, right?  i'll assume so.  now, starting at the beginning,
> with a simplified VM:
> to break the whole thing down into simple steps:
> 1.  page is selected for swap out.
> 2.  that data is encrypted.  <-- new!
> 3.  encrypted data goes to disk, to the same spot it would have normally.
> 4.  page is selected for swap in.
> 5.  data is read from disk.
> 6.  data is decrypted.  <-- new!
> 7.  data is copied to wherever it was supposed to go.
> 
> i'm having trouble i think because 1 & 3 and 5 & 7 as they are now, are
> close to atomic operations.  as in, it's difficult to show up in between.
> and the vm read/write operations are tangled up in the fs code.
 
No. address_space_operations is the interface.

> well, hopefully, it won't be too much trouble to help me.  i know you're
> busy.  :)  someone else?

I have spend some time thinking about this. We have the
address_space_operations for this. You can encrypt/decrypt while
your page is locked for IO and set a flag on your page. So you
decrypt or zero on readpage and encrypt on writepage.

Later you just read/write with the "inherited" function from the
swap_aops (in mm/swap_stat.c). How does that sound?

Another problem is, that you need to encrypt/decrypt IN PLACE,
which is not possible with the current cryptoapi, or have to
copy data around in PAGEs (which costs performance).

At third you may have the page present twice: One instance on disk
and one in memory. For both you have only ONE page_struct
available for flags.

If you encrypt in place, then you cannot allow two instances. You
have to require a readpage after every writepage of the same
page. But this shouldn't happen that often...

Hope that helps.

Regards

Ingo Oeser
-- 
In der Wunschphantasie vieler Mann-Typen [ist die Frau] unsigned und
operatorvertraeglich. --- Dietz Proepper in dasr
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
