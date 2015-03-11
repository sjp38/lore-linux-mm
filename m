Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 79E3490002E
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 20:02:18 -0400 (EDT)
Received: by pdbnh10 with SMTP id nh10so6254918pdb.4
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 17:02:18 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id ei10si933965pdb.36.2015.03.10.17.02.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Mar 2015 17:02:17 -0700 (PDT)
From: Krishna Reddy <vdumpa@nvidia.com>
Subject: RE: Greedy kswapd reclaim behavior
Date: Wed, 11 Mar 2015 00:02:15 +0000
Message-ID: <fe129e5a96d84f279693d0d4d764425c@HQMAIL108.nvidia.com>
References: <CAN3bvwucTo41Kk+NdUf8Fa_bkVWyeMcRo2ttAJeDM0G9bHjLiw@mail.gmail.com>
 <loom.20150310T211234-554@post.gmane.org>
In-Reply-To: <loom.20150310T211234-554@post.gmane.org>
MIME-Version: 1.0
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lock Free <atomiclong64@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> Is it expected that kswapd reclaims significantly more pages than the h=
igh
> watermark?

What zones(DMA, DMA32, Normal, etc.) do you have in the system? You can c=
heck
under /proc/zoneinfo.
Each zone has its own Kswapd  thread. Whenever a zone's free memory
is less than low watermark, Kswapd thread of that zone is woke up and it =
tries
to reclaim memory till the zone's high watermark is reached.   During rec=
laim,
pages are swapped out from the zone's lru lists and various caches in ker=
nel.
only swap out from lru lists ensure that pages released belong to the zon=
e,
which kswapd is running for.
Caches shrinking doesn't necessarily release the pages of a particular zo=
ne.
The memory reclaimed from caches can belong to other zones and the kswapd=

doesn't sleep based on total free memory available.

You need to check the free memory available in the zone, which kswapd is =
running for.

-Krishna Reddy
-------------------------------------------------------------------------=
----------
This email message is for the sole use of the intended recipient(s) and m=
ay contain
confidential information.  Any unauthorized review, use, disclosure or di=
stribution
is prohibited.  If you are not the intended recipient, please contact the=
=20sender by
reply email and destroy all copies of the original message.
-------------------------------------------------------------------------=
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
