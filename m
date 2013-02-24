Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 5D3016B0005
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 22:37:50 -0500 (EST)
Message-ID: <51298B0C.2020400@ubuntu.com>
Date: Sat, 23 Feb 2013 22:37:48 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: fadvise: fix POSIX_FADV_DONTNEED
References: <1361660281-22165-1-git-send-email-psusi@ubuntu.com> <1361660281-22165-2-git-send-email-psusi@ubuntu.com> <5129710F.6060804@linux.vnet.ibm.com>
In-Reply-To: <5129710F.6060804@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/23/2013 08:46 PM, Dave Hansen wrote:
> Folks actually use this in practice to flush the page cache out:
> 
> http://git.sr71.net/?p=eyefi-config.git;a=blob;f=eyefi-linux.c;h=b77a891995109f6caa288925a13985cc495d7b2d;hb=HEAD#l62
>
>  I have really good reasons for really wanting to be _rid_ of the
> page cache no matter how much memory pressure there is.
> 
> I've seen people at IBM using this to ensure that they stay out of 
> memory reclaim completely.  I don't completely agree with the
> approach, but this would completely ruin their performance since
> the VM-initiated writeout is so relatively slow for them.
> 
> I think this patch is a really bad idea.  If you want the behavior 
> you're proposing, I'd suggest using another flag.

This is the correct behavior prescribed by posix.  If you have been
using it for that purpose in the past, then you were using the wrong
syscall.  If you want to begin writeout now, then you should be using
sync_file_range().  As it was, it only initiated writeout if the
backing device was not already congested, which is going to no longer
be the case rather soon if you ( or other tasks ) are writing
significant amounts of data.

If you really want to stay out of memory reclaim entirely, then you
should be using O_DIRECT.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQEcBAEBAgAGBQJRKYsKAAoJEJrBOlT6nu75nLAH/AyZetl9eFqSsXEXoSVsmimW
ih9Nwlhqy1g4zSuThHWIS41t2XQ6vrwh7NDkGdFSwJ0GWVoWIFu5E31LofbCQEYk
ApsTrUflUk/Cn/82oCCBzxv9G4RrmG+ywcz9SCG62uOHs3+e2525+aPzt0mPMsBR
672J5wPXV59NmEp2jNl2VFObnBQBWKxQR9xFfZ/jzvtjW+KtVvg+G4eG+3gFGfqi
gExlAnh6V05AS9ut7GUNDhWkJky/2qQl7sE53NbYC738f6I70vF38IMF68Taojcw
kWWW3gc8tZvhlYVnZqWqbK9Yz7+fBxca73ELtCI5i89gcV6VBekdFTqjq4HnWyg=
=7et5
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
