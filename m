Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 0CFC36B0005
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 17:38:18 -0500 (EST)
Message-ID: <512A965A.6060201@ubuntu.com>
Date: Sun, 24 Feb 2013 17:38:18 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: fadvise: fix POSIX_FADV_DONTNEED
References: <1361660281-22165-1-git-send-email-psusi@ubuntu.com> <1361660281-22165-2-git-send-email-psusi@ubuntu.com> <5129710F.6060804@linux.vnet.ibm.com> <51298B0C.2020400@ubuntu.com> <512A5AC4.30808@linux.vnet.ibm.com> <512A7AC4.5000006@ubuntu.com> <512A8550.2040200@linux.vnet.ibm.com>
In-Reply-To: <512A8550.2040200@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/24/2013 04:25 PM, Dave Hansen wrote:
> Essentially, they don't want any I/O initiated except that which
> is initiated by the app.  If you let the system get in to reclaim,
> it'll start doing dirty writeout for pages other than those the app
> is interested in.

Are you talking about IO initiated by the app, or other tasks in the
system?  If the former then it won't be affected by this change.  For
the latter, you don't really have control over that now since the
pages very well may cause other writeouts before you get around to
calling fadvise.  The extent to which the fadvise call mitigates
pushing writes from other applications out of the cache is only
slightly affected by this patch.  Specifically it may cause other
pages that already got pushed to the inactive list to be flushed, but
they were already very close to that before.

If you use POSIX_FADV_NOREUSE instead, then you will end up at least
as well off as before, possibly better since it takes effect at write
time instead of some later call to fadvise, after having synced the pages.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQEcBAEBAgAGBQJRKpZZAAoJEJrBOlT6nu75VpMH/1Lu37g/y6uRs4cfnAlKritI
P5Jk2cDO9Bc/DrdyHlbDxI45FnuOr/4KCQfRvWpbSArqdpIWZdvUI1uUJ8D71+MH
xKuJrdF4Z1tXXpcNAvGTN6bhTuD+mdDJOkQG+YvcIEKUPvlZHVpswsmddVkLmnRm
CZPwzEuZ52dU9YyLEAQu+XyirBwrLnTaGfwVtY6qkB8Ts5SxOMMrkq+X+sRxe/6e
fnuA+1hMpbXLHEJh+Q4xGWK9BnMahA96/0VJgRGzRmTHnenrjO3z+n7GKr63W+1U
2t3EYtgB9pHBUmrdv/AtFFe8ciTtgZuj9sMoFYJdOn+6BHy76jmiivQYJhXPqSQ=
=hrZY
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
