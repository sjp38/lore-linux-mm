Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id C29B46B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 01:15:48 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id j7so16437020qaq.38
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 22:15:48 -0700 (PDT)
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2001:468:c80:2105:0:2fc:76e3:30de])
        by mx.google.com with ESMTPS id m8si17715514qas.49.2014.09.09.22.15.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Sep 2014 22:15:48 -0700 (PDT)
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
In-Reply-To: Your message of "Tue, 09 Sep 2014 16:21:14 -0700."
             <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
From: Valdis.Kletnieks@vt.edu
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
            <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1410326115_3387P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 10 Sep 2014 01:15:15 -0400
Message-ID: <113623.1410326115@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Kosina <jkosina@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Carpenter <dan.carpenter@oracle.com>, Theodore Ts'o <tytso@mit.edu>

--==_Exmh_1410326115_3387P
Content-Type: text/plain; charset=us-ascii

On Tue, 09 Sep 2014 16:21:14 -0700, Andrew Morton said:
> On Tue, 9 Sep 2014 23:25:28 +0200 (CEST) Jiri Kosina <jkosina@suse.cz> wrote:
> kfree() is quite a hot path to which this will add overhead.  And we
> have (as far as we know) no code which will actually use this at
> present.

We already do a check for ZERO_SIZE_PTR, and given that dereferencing *that* is
instant death for the kernel, and we see it very rarely, I'm going to guess
that IS_ERR(ptr) *has* to be true more often than ZERO_SIZE_PTR, and thus even
more advantageous to short-circuit.

I guess it depends on a few things:

1) How many instances of 'if (!IS_ERR(foo)) kfree(foo);' are in the tree, and
what percent of kfree() calls executed have the guard on them

2) How many of the hot calls can/will get the guard removed.

3) How many cycles, if any, this adds to the path (a non-trivial question on
superscalar architectures), compared with doing a test before calling kfree()

I unfortunately have no earthly clue what the values of any of those
three quantities are....

--==_Exmh_1410326115_3387P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVA/eYwdmEQWDXROgAQI27BAAmq1hlX5b1qxcWw29qC2wbcb91IwJny0A
ZkrGnbufyOazPnEWQED1ZG0k/9borujJ7UYanehZNCOf7IpNXEtE8cn9TYpQVThC
bwO6rIKrWBy+Iq6kxTKVDZlMGPNBEJMhbvvJIZFJ7+eOd50E/oEgskTWzFxx+cKY
K7neMsDP5oaE1BvLGl6JMrzgBLhTXTbvDeHM2GIeRmkUMNyvJCK/evx1O7HSdzmw
6KR/hT0KKd4ydZ068LbFPv+0vy0PI7vfTyZ61Jt1lewPBidzobVmVuXy1tWwuP7T
IgDNuR+97QlDcm79H1aQ6crAiU6wmsZ16CAYZn/prA/35pQ3wX1Z7/+kY6QTBIAc
fkl1f7DK+VQ88KkHqHNFfMAJV0/+WO17pR33Wkll/dlTzD1+3rXJmpqyjrim9wvI
afGRhzEMI6HcDBppzw8IjG2oN1xjmy+6lIujY1WZFRRb1UKeQsF5SaQ6YJuZ4oDv
l3yTWnikP3kQuT3P+PLWl8kcQhS5sYvtws+aXbLU79pt9DOgxrsWGRynkTbVSvV6
RWB/SpAkSqSRr5nWDSccr+yDBeViQs/VwlClh6neL2AzBhyZKjuVXlMEenItYDbn
OAHRX8BO4wQIZQTHgyfIUMC7pRiP1QBvbIuh99eKiMLdBZDZMUWgsD2g/tplKAK4
8Ppt1IKac34=
=ACPN
-----END PGP SIGNATURE-----

--==_Exmh_1410326115_3387P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
