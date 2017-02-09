Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACE56B038B
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 10:26:54 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id q124so4372892wmg.2
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 07:26:54 -0800 (PST)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id o67si6445384wme.163.2017.02.09.07.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 07:26:53 -0800 (PST)
Message-ID: <1486653999.2900.63.camel@decadent.org.uk>
Subject: Re: [PATCH 4.4 05/48] mm: fix devm_memremap_pages crash, use
 mem_hotplug_{begin, done}
From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 09 Feb 2017 15:26:39 +0000
In-Reply-To: <20170118104625.789178853@linuxfoundation.org>
References: <20170118104625.550018627@linuxfoundation.org>
	 <20170118104625.789178853@linuxfoundation.org>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IUE/iiWc6aE7gDvmMIDT"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--=-IUE/iiWc6aE7gDvmMIDT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-01-18 at 11:46 +0100, Greg Kroah-Hartman wrote:
> 4.4-stable review patch.=C2=A0=C2=A0If anyone has any objections, please =
let me know.
>=20
> ------------------
>=20
> From: Dan Williams <dan.j.williams@intel.com>
>=20
> commit f931ab479dd24cf7a2c6e2df19778406892591fb upstream.
>=20
> Both arch_add_memory() and arch_remove_memory() expect a single threaded
> context.
[...]
> The result is that two threads calling devm_memremap_pages()
> simultaneously can end up colliding on pgd initialization.=C2=A0=C2=A0Thi=
s leads
> to crash signatures like the following where the loser of the race
> initializes the wrong pgd entry:
[...]
> Hold the standard memory hotplug mutex over calls to
> arch_{add,remove}_memory().
[...]

This is not a sufficient fix, because memory_hotplug.c still assumes
there's only one 'writer':

void put_online_mems(void)
{
	...
        if (!--mem_hotplug.refcount && unlikely(mem_hotplug.active_writer))
                wake_up_process(mem_hotplug.active_writer);
        ...
}

void mem_hotplug_begin(void)
{
        mem_hotplug.active_writer =3D current;

        memhp_lock_acquire();
        for (;;) {
                mutex_lock(&mem_hotplug.lock);
                if (likely(!mem_hotplug.refcount))
                        break;
                __set_current_state(TASK_UNINTERRUPTIBLE);
                mutex_unlock(&mem_hotplug.lock);
                schedule();
        }
}

With multiple writers, one or more of them may hang or
{get,put}_online_mems() may=C2=A0mess up the hotplug reference count.

Is there a good reason that memory_hotplug.c isn't using an rwsem?

Ben.

--=20
Ben Hutchings
All the simple programs have been written, and all the good names
taken.


--=-IUE/iiWc6aE7gDvmMIDT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAlicii8ACgkQ57/I7JWG
EQlmOhAA0YlOHwRr13tcbxEhWm/pKgnNDE2ethYz2yPoinft4VRKnxjEO0pqAIre
ONgjKPEm3N9RlBSQfCLy87zVYh3jJ3lzDQGRrcoI+07pPMXlTg4eiCXZcoh2p3gk
hbxdgnzys2dLhVmKs22/vw3Zkc2auQ+fU65iclSktL3N/H4b85THcAFw46r4VLIP
UYP6SAx9VernfY3ZeFGcoPJJzcoRXxAKd5T4it/VwnOMysLV1mT0fjy4YkgO+EEB
rRGQJMJNMu0kC7mRNg3mIP6hYAC060Roc0o7Y/AfJ/VtUOlSIzL1ipqLBeSBpyDE
Bdb0N0NtaYouuvWp6Sz+NTs44Ax+8r5FZomGFEZjRKYBbQQ7qUdEKgOGXyjniATO
pMLeW8lvE/TZeZxcBslJrFWhBAlQ6KjGRruR+JeORrbrBKCkEJe5INvy5PfRD7WE
5Q1I8+ctGxD2COpxFM2beVpx88Cyuxi/V38juD1UtvsdXjnZIisY8M7VmR56j4Uy
v78mjNOF+yv2yPuBZfFa0G0AZNlEgdsG1GOq2MMqPr85Rb5LNxeVJbWhAM5uKVRx
EKUddB+06OJOtb7/t5JTw6UI9OIdCP62YvjWVc5KphIwV1OqyKKSfMg5APbr/ioK
FH2sjr4SJCi2YPKlqT6ntVJEDK8y2N1QUtpMkVJqAfT7KqUhZKw=
=DyUp
-----END PGP SIGNATURE-----

--=-IUE/iiWc6aE7gDvmMIDT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
