Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 323C46B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 16:52:57 -0500 (EST)
Message-ID: <5127E8B7.9080202@ubuntu.com>
Date: Fri, 22 Feb 2013 16:52:55 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: POSIX_FADV_DONTNEED implemented wrong
References: <5127CD9B.7050406@ubuntu.com> <20130222202921.GB4824@cmpxchg.org>
In-Reply-To: <20130222202921.GB4824@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 2/22/2013 3:29 PM, Johannes Weiner wrote:
>> 1)  It is completely useless for writing files.  This hint
>> should allow a program generating lots of writes to files that
>> will not likely be read again to reduce the cache pressure that
>> causes.
> 
> Wouldn't direct IO make more sense in that case?

It could, but doing direct aio is a lot more complicated than just using
posix_fadvise. Also it has problem #3: even if it is unlikely, it
*may* be used again, so it makes sense to cache it if we have plenty
of ram.

> Minchan worked on deactivating pages on truncation.  Maybe all it 
> takes is to implement deactivate_mapping_range() or something to 
> combine a page cache walk with deactivate_page().

Looks like a good idea!

> While you are at it, madvise(MADV_DONTNEED) does not do anything
> to the page cache, but it probably should.  :-)

It seems to be implemented by discarding the pages, even if dirty.
This also seems to be wrong.  According to posix, this is a hint that
it will not access the pages again any time *soon*, not that the data
will never be needed again and so it can be discarded.

It looks like MADV_SEQUENTIAL is missing the second part of its
implementation: making sure the pages will be discarded soon after
they are accessed.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJRJ+i3AAoJEJrBOlT6nu759/IIAMbFAjJGmI7hkpt1GMtUfty8
n72BoygV3bDULpZ8BybJonRfiVw/ze9sVf6KhojB2dm9bvdZHl11DDGvf9Ro8OSr
dcjWUQxbHzuzGtUtnUEZPOAj6Ux6cetBtmjUxjnLyJrijK+W+cEHzWnzUZXWddlo
XcPe3IHNmj7YlTH+tcPevLCeTlzfFkjq/t4JXuZWmFW97MmMe5wTCScS0eiBYpHM
SVVL+VJ8TPG9Hnk/9oP0RqAyg+SjshGfaqhM8mTFvS4FtMbp/gXFz8GnewxG322h
ZdgwZqafiWsNeC8KitcTwKlxMU5fWFDLfHXKoFWgX2P7hVh8zJ9T6Ugi4KeaAN4=
=RFzN
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
