Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3513B6B0292
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 20:22:12 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 76so43163537pgh.11
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 17:22:12 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id c86si425971pfe.323.2017.06.27.17.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 17:22:11 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id e199so6675825pfh.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 17:22:11 -0700 (PDT)
Date: Wed, 28 Jun 2017 08:22:07 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH 3/4] mm/hotplug: make __add_pages() iterate on
 memory_block and split __add_section()
Message-ID: <20170628002207.GD66023@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-4-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="bjuZg6miEcdLYP6q"
Content-Disposition: inline
In-Reply-To: <20170625025227.45665-4-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, linux-mm@kvack.org


--bjuZg6miEcdLYP6q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index a79a83ec965f..14a08b980b59 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -302,8 +302,7 @@ void __init register_page_bootmem_info_node(struct pgl=
ist_data *pgdat)
> }
> #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
>=20
>-static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>-		bool want_memblock)
>+static int __meminit __add_section(int nid, unsigned long phys_start_pfn)
> {
> 	int ret;
> 	int i;
>@@ -332,6 +331,18 @@ static int __meminit __add_section(int nid, unsigned =
long phys_start_pfn,
> 		SetPageReserved(page);
> 	}
>=20
>+	return 0;
>+}
>+
>+static int __meminit __add_memory_block(int nid, unsigned long phys_start=
_pfn,
>+		bool want_memblock)
>+{
>+	int ret;
>+
>+	ret =3D __add_section(nid, phys_start_pfn);
>+	if (ret)
>+		return ret;
>+

One error here.

I forget to iterate on each section in the memory_block.
Fixed in my repo.


--=20
Wei Yang
Help you, Help me

--bjuZg6miEcdLYP6q
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZUvavAAoJEKcLNpZP5cTdY+QP/3XfQBbGTNnVB0qXL2AahMe2
evC72dQcGzF6J+JM6N5/dDUmBb6VixEarIHEEBFCmBNDp1hkFpaXK5lNug5NR/is
5eEc/BNfLVKLHkMR2Em63JZBYUaq7SqpT254IB7ZNdT9h1kv0zXHf1gmvuSJZ5V5
9b3xgBPAGg5c1djtFLMnYpik38NiqMxOiE7aCYxqKcNwGExZZVj4uDj2FznihVIb
Is/zQNmgiSZyqhyRZr2CPcF0dTUtRz7CDUjTuwqYVHjVjLg9rqJNaTT0cMM3mx7u
yZ8XfiIGdCHDA0r5GIc7xL+SydMS6qGlz32JMiwGQN+KjqtsXHqvynQ6ORXPeae4
tAt60xrqs1DIJkNLCmhYqrYu5TImTOBDIgku0kXT8SIGRXDInUNlIQt8Ya42s+oJ
HfSjljchwPqzi3DoXt0pBRjuDbpBJT+cJ2cGXvfmZrAiy7Uqgynb8tLs9jEm3YUI
B9/s9MpCiCpn3GvBg5OFxP3mdS+uDffb2eLcn+sCzlImPvzf8OtmxphfC+MtUmnQ
YufSuZuXU7dgeEkznSQdyJfDvuR8i7B4dZXpWuxI1+egOniR5SJUc4/LxKwvaJB5
Rea7r6wR2lBhh5p51KFxzu9qCnxoq2I9cpMjAqIbECTi4005Gs3Rd2egdArRZVdK
fi+tpP4cJuoIg2mnRdXU
=pr0t
-----END PGP SIGNATURE-----

--bjuZg6miEcdLYP6q--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
