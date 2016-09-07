Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 643B46B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 20:51:58 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id 71so1045327uag.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 17:51:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j132si2247691ywc.460.2016.09.06.17.51.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 17:51:57 -0700 (PDT)
Message-ID: <1473209511.32433.179.camel@redhat.com>
Subject: Re: [PATCH] mm:Avoid soft lockup due to possible attempt of double
 locking object's lock in __delete_object
From: Rik van Riel <riel@redhat.com>
Date: Tue, 06 Sep 2016 20:51:51 -0400
In-Reply-To: <6b5d162b-c09d-85c0-752f-a18f35bbbb5c@gmail.com>
References: <1472582112-9059-1-git-send-email-xerofoify@gmail.com>
 <20160831075421.GA15732@e104818-lin.cambridge.arm.com>
 <33981.1472677706@turing-police.cc.vt.edu>
	 <6b5d162b-c09d-85c0-752f-a18f35bbbb5c@gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-dy0kqJGGf8c7l+WZEmDr"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nick <xerofoify@gmail.com>, Valdis.Kletnieks@vt.edu, Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


--=-dy0kqJGGf8c7l+WZEmDr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-08-31 at 17:28 -0400, nick wrote:
>=C2=A0
> Rather then argue since that will go nowhere. I am posing actual
> patches that have been tested on
> hardware.=20

But not by you, apparently.

The patch below was first posted by somebody else
in 2013:=C2=A0https://lkml.org/lkml/2013/7/11/93

When re-posting somebody else's patch, you need to
preserve their From: and Signed-off-by: headers.

See=C2=A0Documentation/SubmittingPatches for the details
on that.

Pretending that other people's code is your own
is not only very impolite, it also means that
the origin of the code, and permission to distribute
it under the GPL, are in question.

Will you promise to not claim other people's code as
your own?

Otherwise there is another very good reason to refuse
ever accepting code posted by you into the kernel.
We cannot merge code when there is no clear permission
from the actual author to distribute it under the GPL.

> From 719ad39496679523c70c7dda006e6da31d9004b3 Mon Sep 17 00:00:00
> 2001
> From: Nicholas Krause <xerofoify@gmail.com>
> Date: Wed, 24 Aug 2016 02:09:39 -0400
> Subject: [PATCH] pciehp: Avoid not bringing up device if already
> existing on
> =C2=A0bus
>=20
> This fixes pcihp_resume to now avoid incorrectly bailing out if the
> device is already live in the pci bus but currently suspended.
> Further
> more this issue is caused by incorrectly checking the status of the
> device adapter directly, instead since this adapter can be shared
> we must instead also check if the pci_bus has no more links to this
> adapter by checking if the pci_bus used by this adapter's device list
> is also empty before enabling it. Finally do the opposite of checking
> that the list is not empty before disabling in order to avoid the
> same issue on disabling the slot instead.
>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
> =C2=A0drivers/pci/hotplug/pciehp_core.c | 10 ++++++----
> =C2=A01 file changed, 6 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/pci/hotplug/pciehp_core.c
> b/drivers/pci/hotplug/pciehp_core.c
> index ac531e6..1ce725e 100644
> --- a/drivers/pci/hotplug/pciehp_core.c
> +++ b/drivers/pci/hotplug/pciehp_core.c
> @@ -291,7 +291,7 @@ static int pciehp_resume(struct pcie_device *dev)
> =C2=A0	struct controller *ctrl;
> =C2=A0	struct slot *slot;
> =C2=A0	u8 status;
> -
> +	struct pci_bus *pbus =3D dev->port->subordinate;
> =C2=A0	ctrl =3D get_service_data(dev);
> =C2=A0
> =C2=A0	/* reinitialize the chipset's event detection logic */
> @@ -302,10 +302,12 @@ static int pciehp_resume(struct pcie_device
> *dev)
> =C2=A0	/* Check if slot is occupied */
> =C2=A0	pciehp_get_adapter_status(slot, &status);
> =C2=A0	mutex_lock(&slot->hotplug_lock);
> -	if (status)
> -		pciehp_enable_slot(slot);
> -	else
> +	if (status) {
> +		if (list_empty(&pbus->devices))
> +			pciehp_enable_slot(slot);
> +	} else if (!list_empty(&pbus->devices))
> =C2=A0		pciehp_disable_slot(slot);
> +
> =C2=A0	mutex_unlock(&slot->hotplug_lock);
> =C2=A0	return 0;
> =C2=A0}
>=C2=A0
--=20

All Rights Reversed.
--=-dy0kqJGGf8c7l+WZEmDr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXz2SnAAoJEM553pKExN6DdFQIAIopu9I8sifIS7o2uklLo2Tr
nh5sRuqAorWOUTj+v5XQy8Odxsf51xQHx8jGLXoOesxJKzIBCTrayoI7PZ9rwbw7
XNagkfUrR9fHkjbubobjQWF7EkACxuqTzuhRCVTaez0lgQUsU6geGtBwLLTvuxHe
+yS+Cx6XKxeE0fsioO4ao4c3YVFECSWtMv8CV2onYXZ+v59lmS6RCFClAf1uvp8D
VG63mIPr4C+Oi8hjlAAS/uRXpR1IMiRsR9groOt6+FK7EbbfsgQe6EcwHbQ/nBTR
UV7dsqGJO6AYGp3/+Q4/19A4iIPJmOKF+i66jfeyXOAFBln2dqwL4qGNF9rRySo=
=oIAI
-----END PGP SIGNATURE-----

--=-dy0kqJGGf8c7l+WZEmDr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
