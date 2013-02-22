Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 04D336B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 14:57:16 -0500 (EST)
Message-ID: <5127CD9B.7050406@ubuntu.com>
Date: Fri, 22 Feb 2013 14:57:15 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: POSIX_FADV_DONTNEED implemented wrong
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

I believe the current implementation for this is wrong.  For clean
pages, it immediately discards them from the cache, and for dirty
ones, it immediately tries to initiate writeout if the bdi is not
congested.  I believe this is wrong for three reasons:

1)  It is completely useless for writing files.  This hint should
allow a program generating lots of writes to files that will not
likely be read again to reduce the cache pressure that causes.

2)  When there is little to no cache pressure, this hint should not
cause the disk to spin up.

3)  This is supposed to be a hint that caching this data is unlikely
to do any good, so the cache should favor other data instead.  Just
because one process does not think it will be used again does not mean
it won't be, so when there is little to no cache pressure, we
shouldn't go discarding potentially useful data.

I'd like to change this to simply force the pages to the inactive
list, so they will be reclaimed sooner than other pages, but not
immediately discarded, or written out.

Also the related POSIX_FADV_NOREUSE is currently unimplemented, and
this should also cause the cache pages to skip the active list and go
straight to the inactive list.

Any thoughts or hints on how to go about doing this?

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJRJ82ZAAoJEJrBOlT6nu75i3YIAMjrwhzL28m/WbsD4m2BQaX9
swz0OlO9AimoQLE0vvbYSRYFmlGAayQafIOJU1GiLSijPGmHqisOePZpWnCKbesP
PeoHFxC+jDNHGrmIDHGOgq7ELAX6DNh5yU1sBhvo7iSnDCfjdfvJP7wWNyzCD/bD
FT7bEgQ1vjd6bB3812Qj3PBs/UHvHUj8zAJDAiArqMJSW6LgxINzjyXs030NRqxS
A1RUVUJ/4ydJz7SS4uitFWmObrpImIt6oxpQnIb1SOzL67KNx/YwMgWq/hknAS3H
ravePc2VwH2aS/gcyo2VW3OLHlIXOxgbjhZWbKidkNv6KsccEqqY8yFeO+fCvjA=
=dsVO
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
