Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f46.google.com (mail-lf0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 28E0A828F3
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 06:23:58 -0500 (EST)
Received: by mail-lf0-f46.google.com with SMTP id l143so93230327lfe.2
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 03:23:58 -0800 (PST)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com. [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id th8si15852616lbb.174.2016.02.08.03.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 03:23:56 -0800 (PST)
Received: by mail-lb0-x233.google.com with SMTP id bc4so80879466lbc.2
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 03:23:56 -0800 (PST)
From: Dmitry Monakhov <dmonakhov@openvz.org>
Subject: DAX: __dax_fault race question
Date: Mon, 08 Feb 2016 14:23:49 +0300
Message-ID: <87bn7rwim2.fsf@openvz.org>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: willy@linux.intel.com, ross.zwisler@linux.intel.com

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Hi,

I try to understand locking rules for dax and realized that there is
some suspicious case in dax_fault

On __dax_fault we try to replace normal page with dax-entry
Basically dax_fault steps looks like follows

1) page =3D find_get_page(..)
2) lock_page_or_retry(page)
3) get_block
4) delete_from_page_cache(page)
5) unlock_page(page)
6) dax_insert_mapping(inode, &bh, vma, vmf)
...

But what protects us from other taks does new page_fault after (4) but
before (6).
AFAIU this case is not prohibited
Let's see what happens for two read/write tasks does fault inside file-hole
task_1(writer)                  task_2(reader)
__dax_fault(write)
  ->lock_page_or_retry
  ->delete_from_page_cache()    __dax_fault(read)
                                ->dax_load_hole
                                  ->find_or_create_page()
                                    ->new page in mapping->radix_tree=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20
  ->dax_insert_mapping
     ->dax_radix_entry->collision: return -EIO

Before dax/fsync patch-set this race result in silent dax/page duality(which
likely result data incoherence or data corruption), Luckily now this
race result in collision on insertion to radix_tree and return -EIO.
From=20first glance testcase looks very simple, but I can not reproduce
this in my environment.=20

Imho it is reasonable pass locked page to dax_insert_mapping and let
dax_radix_entry use atomic page/dax-entry replacement similar to
replace_page_cache_page. Am I right?


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCgAGBQJWuHrGAAoJELhyPTmIL6kBij8IAKsU5Qd5BLD4DHX8Sos8teix
EGeJv2fp+gaFjbQJmtmG25B7gF1KByFaynL17Rt8H+P6WNcNXx//DPqMyU3/kw1M
pWL5iaXnTyz1UR22UZ34HyKhasIjR9MUNrnI0ZZ0e9YfG3iNRU3mQzgIJV3bHOUd
KLTe9wfd8tC0GgzI+T5mrEPoL4pEgWOm+Cgl5drDdiWO8XVcgKZysw9MqSPTVAQr
Uk25F2ksghl0zSHJHZQ1Ps9n/gpkjcj0G0UaPWRtZchxEPKHYx2cfgAagH95OfhG
j5b/cHqD4hBK2B5d03joB4GoUoK/zu4ByhhxQW9Ank0/wZPrnFep3p0s+Aj9MK0=
=PMeb
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
