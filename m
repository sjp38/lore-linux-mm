Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 100A06B025E
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:42:07 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f144so6362741pfa.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 22:42:07 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id o184si9544910pfb.214.2017.01.17.22.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 22:42:06 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id 19so448399pfo.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 22:42:06 -0800 (PST)
Date: Wed, 18 Jan 2017 14:42:30 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v4 15/15] lockdep: Crossrelease feature documentation
Message-ID: <20170118064230.GF15084@tardis.cn.ibm.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-16-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="qM81t570OJUP5TU/"
Content-Disposition: inline
In-Reply-To: <1481260331-360-16-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com


--qM81t570OJUP5TU/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Dec 09, 2016 at 02:12:11PM +0900, Byungchul Park wrote:
[...]
> +Example 1:
> +
> +   CONTEXT X		   CONTEXT Y
> +   ---------		   ---------
> +   mutext_lock A
> +			   lock_page B
> +   lock_page B
> +			   mutext_lock A /* DEADLOCK */

s/mutext_lock/mutex_lock

> +   unlock_page B
> +			   mutext_unlock A
> +   mutex_unlock A
> +			   unlock_page B
> +
> +   where A is a lock class and B is a page lock.
> +
> +No, we cannot.
> +
> +Example 2:
> +
> +   CONTEXT X	   CONTEXT Y	   CONTEXT Z
> +   ---------	   ---------	   ----------
> +		   mutex_lock A
> +   lock_page B
> +		   lock_page B
> +				   mutext_lock A /* DEADLOCK */
> +				   mutext_unlock A

Ditto.

> +				   unlock_page B held by X
> +		   unlock_page B
> +		   mutex_unlock A
> +
> +   where A is a lock class and B is a page lock.
> +
> +No, we cannot.
> +
> +Example 3:
> +
> +   CONTEXT X		   CONTEXT Y
> +   ---------		   ---------
> +			   mutex_lock A
> +   mutex_lock A
> +   mutex_unlock A
> +			   wait_for_complete B /* DEADLOCK */

I think this part better be:

   CONTEXT X		   CONTEXT Y
   ---------		   ---------
   			   mutex_lock A
   mutex_lock A
   			   wait_for_complete B /* DEADLOCK */
   mutex_unlock A

, right? Because Y triggers DEADLOCK before X could run mutex_unlock().

Regards,
Boqun

--qM81t570OJUP5TU/
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlh/DlIACgkQSXnow7UH
+rgQQwf9E19qbmMxZXyNiuBhO/JQ4KtJrJLK/UTgqJHEOX5XoiJsoETe5tisBFPR
YMyMkcycnEDtfPjluXA1wsl5ye9egPSkMlPXocddw99Pg4k4BfAUrA6OD82ckRHj
oBulA9dfeeZ17eXwZvF69BLqa6k+T9OS5VC+X/J5DznP415EhSH0nZVDgXUtpS1t
YpQaoK6Z0CzqFQrkyVgJHpI5efhRBraaBMEGOg+rqVVAo3SbmKcq2wwvyuxj3yeX
0Ldj7hXx9L+/KgZjRXRoMj3goMFF251NIAbiqzOPpSljTwL6YgYoPmR4dUCr8lNo
OgPKIyfOhTDMEFyeYpF4MilrD9WJvg==
=1Eus
-----END PGP SIGNATURE-----

--qM81t570OJUP5TU/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
