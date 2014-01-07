Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f79.google.com (mail-pa0-f79.google.com [209.85.220.79])
	by kanga.kvack.org (Postfix) with ESMTP id C642A6B0031
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 09:41:27 -0500 (EST)
Received: by mail-pa0-f79.google.com with SMTP id fa1so16821pad.2
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 06:41:27 -0800 (PST)
Received: from mx0.aculab.com (mx0.aculab.com. [213.249.233.131])
        by mx.google.com with SMTP id mc2si3518158wjb.161.2014.01.07.01.44.27
        for <linux-mm@kvack.org>;
        Tue, 07 Jan 2014 01:44:27 -0800 (PST)
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12611-08 for <linux-mm@kvack.org>; Tue,  7 Jan 2014 09:44:19 +0000 (GMT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Date: Tue, 7 Jan 2014 09:42:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D453A4E@AcuExch.aculab.com>
References: <20140107132100.5b5ad198@kryten>
In-Reply-To: <20140107132100.5b5ad198@kryten>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Anton Blanchard' <anton@samba.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "paulus@samba.org" <paulus@samba.org>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "nacc@linux.vnet.ibm.com" <nacc@linux.vnet.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

> From: Anton Blanchard
> We noticed a huge amount of slab memory consumed on a large ppc64 box:
>=20
> Slab:            2094336 kB
>=20
> Almost 2GB. This box is not balanced and some nodes do not have local
> memory, causing slub to be very inefficient in its slab usage.
>=20
> Each time we call kmem_cache_alloc_node slub checks the per cpu slab,
> sees it isn't node local, deactivates it and tries to allocate a new
> slab. ...
...
>  	if (unlikely(!node_match(page, node))) {
>  		stat(s, ALLOC_NODE_MISMATCH);
> 		deactivate_slab(s, page, c->freelist);
> 		c->page =3D NULL;
> 		c->freelist =3D NULL;
> 		goto new_slab;
>  	}

Why not just delete the entire test?
Presumably some time a little earlier no local memory was available.
Even if there is some available now, it is very likely that some won't
be available again in the near future.

	David.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
