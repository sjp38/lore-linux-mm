Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87D7E6B0005
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 20:29:49 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id g133so116710614ywb.0
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 17:29:49 -0700 (PDT)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2607:b400:92:8400:0:33:fb76:806e])
        by mx.google.com with ESMTPS id 107si30626819qgj.45.2016.04.13.17.29.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 17:29:48 -0700 (PDT)
Subject: linux-next crash during very early boot
From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1460593786_2402P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Apr 2016 20:29:46 -0400
Message-ID: <3689.1460593786@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

--==_Exmh_1460593786_2402P
Content-Type: text/plain; charset=us-ascii

I'm seeing my laptop crash/wedge up/something during very early
boot - before it can write anything to the console.  Nothing in pstore,
need to hold down the power button for 6 seconds and reboot.

git bisect points at:

commit 7a6bacb133752beacb76775797fd550417e9d3a2
Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Date:   Thu Apr 7 13:59:39 2016 +1000

    mm/slab: factor out kmem_cache_node initialization code

    It can be reused on other place, so factor out it.  Following patch will
    use it.


Not sure what the problem is - the logic *looks* ok at first read.  The
patch *does* remove a spin_lock_irq() - but I find it difficult to
believe that with it gone, my laptop is able to hit the race condition
the spinlock protects against *every single boot*.

The only other thing I see is that n->free_limit used to be assigned
every time, and now it's only assigned at initial creation.


--==_Exmh_1460593786_2402P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVw7kegdmEQWDXROgAQJdeg/+MKwO0tOq62jVxhJpilvfatLYTD+SDIhx
XZ+xBdrGLwE+zeAesp5nMMMni8sXelSRL0v+q4Evi53OUL/OEU5oyobzLCjIPOEF
VkP8g7TklsgPMQ7aDhkyqO+whPzdOcsN3pwtcYGkTO4D+ucm0j2By6QqrsI8lgyx
wtWv4E1GvqK+cWv+8Dh9husDd4e9DIhFFVGyAxsXt6vv09Trdmmq+U3Fn2dwQZ+C
ujeWdMrn6lzx5MoUrKmuN/bQDWDVA8LcFE/onQLU9dr/k97v/VJzL49TtGK3PSjZ
SVB8axmWPWl9o/756DsSn3fc8Vix3AV9jAoukMgzWF1Ndy4UcsDt2YYd3YXCABJE
E0yjzEZnxxiLON8/I3o9+I+S1Jm//6UBeuFWGKfXTqs9gvDKYpxb7TOUZ3ezsSVi
gZvJehFf6hqySAyMcwTh3CD6UF3m3WRki4vCwwnV2uXUkTZpP7BuSmbUDiixNpwJ
rsFxLeBXDjlUY1MKmo1Fx0A0AQoKn5W/GYoMsCH3IuPcPGowAqC4h0cih+HA8Tbx
0TLjCMQHl05XIu/9KXy+LIf6sNNl/sfnprGYfLrB9SCOadALWgYHXGZng0ecrcBf
vWJ1gY34lE/TE0xCeYPj9Sx9mPNO2CeugnzKa4wYNxWcpupAAaevXjEqVlpVMqDo
dPW+t/cS6sU=
=K6j/
-----END PGP SIGNATURE-----

--==_Exmh_1460593786_2402P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
