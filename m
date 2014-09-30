Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4668F6B0038
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 17:52:56 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id i13so300146qae.41
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 14:52:56 -0700 (PDT)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2001:468:c80:2105:0:24d:7091:8b9c])
        by mx.google.com with ESMTPS id kb2si17061062qcb.48.2014.09.30.14.52.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Sep 2014 14:52:52 -0700 (PDT)
Subject: Re: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
In-Reply-To: Your message of "Tue, 30 Sep 2014 15:25:17 -0600."
             <A8F88370-512D-45D0-8414-C478D64E46E5@dilger.ca>
From: Valdis.Kletnieks@vt.edu
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com> <15705.1412070301@turing-police.cc.vt.edu> <20140930144854.GA5098@wil.cx> <123795.1412088827@turing-police.cc.vt.edu> <20140930160841.GB5098@wil.cx> <15704.1412109476@turing-police.cc.vt.edu>
            <A8F88370-512D-45D0-8414-C478D64E46E5@dilger.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1412113956_2351P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Sep 2014 17:52:36 -0400
Message-ID: <62749.1412113956@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--==_Exmh_1412113956_2351P
Content-Type: text/plain; charset=us-ascii

On Tue, 30 Sep 2014 15:25:17 -0600, Andreas Dilger said:

> I think you would be much better off having more aggressive "use once"
> semantics in the page cache, so that page cache pages for streaming
> writes are evicted more aggressively from cache rather than going down
> the "automatic O_DIRECT" hole.

Well, I'm open to convincing.. an inode bit that says "I/O for this file is
always first out of the page cache" would probably fix  most of the thrashing
page cache problem (and avoid the "unexpected O_DIRECT kills the program"
issue), at the cost of a little more CPU when we turn around and evict it
from the page cache.

As long as we're at it, if we go that route we probably *also* want a
way for a program to specify it at open() time (for instance, for the
use of backup programs) - that should minimize the infamous "everything
runs like a pig after the backup finishes running because  the *useful*
pages are all cache-cold".

(And yes, you really *do* want the ability in both places - one for a
program to be able to say "do this for any file I touch", and another for
the file to say "do this for any program that touches me").

Matthew - would that sort of approach make more sense to you?  I admit
I originally posted only because I'd just finished fighting with a
similar issue, and code floated by that got filesystem pages into
core without trashing the page cache.  I'm not at all tied to the specific
solution.. :)



--==_Exmh_1412113956_2351P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVCsmJAdmEQWDXROgAQLF4w//bC27sR3tYMAXUDIz7gtBvyZfAgV6MZE8
ISyDvTbznH26Whpz2lnZovOYcOQ492pq7/aWVwmpvoRdERD+pXygtKx2UcCH3Pra
c9H/VVUHmEH0gRM99olZtyvIIdGG4nGW4fs9orw6DfnEnrurhybWlQGNgeCe8HgV
ul+FQ+zOW+fP7rrQBCGn/y1mA5yYWbWy8ox+/kYnX6X0noMDpSYndV05nLp95MC2
ThalxXom8Nxzi5J/aDKFpT7ihHEiCr6xiGV+EsyNGhIjtjR/Y/VhzsJ32f8aBBdh
PqopyQvhNlfqY3jOKSIjaWbhatubQzyL5xcLQXRptok6xW90XXT9tDRr4mDshzhO
UCOg7DQ8ylI6AVE6fVHD6cqSXu+VONSJRu1fBRTnSKbebKEz1pApXONkrFNRphsl
yvm0dsT7cEF8qV6XRtl498nnNjeZv010x6L0aiP6gH7Uhb0DqlTfE0t+e5zaBe1T
cubwHzDmxj4DLb0Iq6/KftAHq6J1zQ0EflHJH1al7VrUSoA0Ad8q1mBD0dN1KiQg
DP6GU3n4PUhXBAO3K0z0DJdxvh8P54O3XOK808onOIvWEDLxiqrxjmTPSsehAtM6
O1P4ip2Ko93dEr7iFEtAM4RKD7ZBQlz7DQj5r9Dl2XvfdwRYvKtEwf/VLWb2vCv0
+90jeX7+1eM=
=sOpo
-----END PGP SIGNATURE-----

--==_Exmh_1412113956_2351P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
