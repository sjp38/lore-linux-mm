Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id D33936B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 22:31:32 -0500 (EST)
Message-ID: <512C2C90.8090709@ubuntu.com>
Date: Mon, 25 Feb 2013 22:31:28 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: readahead blocking on ext4 ( was: Something amiss with IO throttling
 )
References: <512C0746.6020408@ubuntu.com>
In-Reply-To: <512C0746.6020408@ubuntu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: ext4 development <linux-ext4@vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/25/2013 07:52 PM, Phillip Susi wrote:
> There seems to be something wrong with IO throttling in recent 
> kernels.  I have noticed two problems recently:
> 
> 1)  I noticed that the man page for readahead() states that it
> blocks until the data has been read, which is incorrect.  The whole
> point of the call is that it initiates background read(ahead), in
> the hopes that it will finish before the data is actually read,
> just like posix_fadvise(POSIX_FADV_WILLNEED).  Testing however,
> indicates that indeed, both readahead() and fadvise with
> POSIX_FADV_WILLNEED does appear to be blocking at least for most of
> the time it takes to read a large file.  In my case I'm reading a
> 400mb file after dropping cache and having 2+gb of free ram, and
> the readahead/fadvise blocks for nearly the 5 seconds it takes to
> read that.

Well, I solved this part and no longer think it is related to the
second problem.  It turns out that the file I was using for testing
had been downloaded via bit torrent, and while the data blocks were
100% contiguous, the extent tree was slightly fragmented.  The file
used 3 level 0 extent tree blocks, so it seems that the readahead
blocked until most of the file was read, and the third extent tree
block then could be read, and the remaining blocks mapped by it could
be queued, then readahead would return.

I'm adding linux-ext4 to Cc, and I'm hoping we can come up with some
ideas to improve this.  It seems to me that the extent tree blocks
should be read first, then all of the data blocks queued up so
readahead only has to block once and shortly before returning.  What
do you think?

Also it may be interesting to note that the three extent tree blocks
were allocated seemingly at random:

EXTENTS:
(ETB0):33795, (0-30975):370688-401663, (30976-40191):401664-410879,
(ETB0):483328, (40192-72575):410880-443263,
(72576-81919):443264-452607, (ETB0):483329, (81920-111578):452608-482266

Shouldn't the extent tree blocks be clustered a little better?  And
shouldn't the actual extents be merged a little better?  With 111578
logical blocks and a max of 32767 ( or was it 32768 initialized
blocks, and 32767 uninit? ) per extent, this whole file should be able
to fit within the 4 extents embedded in the inode, with no need for
any extent tree blocks.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQEcBAEBAgAGBQJRLCyQAAoJEJrBOlT6nu75PEkIAK+SWfo6ugAV6cvgqGWiNkuz
eAn6IfaGxdg/6TLH+xsnQbI8KTqe8Zg9VXTZyenfwdC2lsgFz2WOI19yzMbR6eWi
fddzadKuvPbKN8BgpmF3I61wAOG1YdbpEcvJRHhyFU211+I10shOeowGnyIuj7II
uoyGeBaWN1MpIuTzLySFVLAYdbZOofYlTbrxrjiCavAHhjG91WfZExMVR60OkY0z
dxBQ0NF5B+YIx+egOx1fVbstXxfrFTIIqVSLpK6fF44DUN/rHWIRivT3vARJt1Pa
ZxFmqyGMLUgqaq71n9B4L5FmfQ+anYM33plufm4cUjFfoEqBbowZvSnwN2p1mQk=
=H8i2
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
