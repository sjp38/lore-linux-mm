Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 168656B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 09:15:21 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k27-v6so26050440wre.23
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 06:15:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r65sor3621190wmf.11.2018.04.26.06.15.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 06:15:19 -0700 (PDT)
Date: Thu, 26 Apr 2018 14:15:17 +0100
From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [RFC v2 2/2] pmem: device flush over VIRTIO
Message-ID: <20180426131517.GB30991@stefanha-x1.localdomain>
References: <20180425112415.12327-1-pagupta@redhat.com>
 <20180425112415.12327-3-pagupta@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NDin8bjvE/0mNLFQ"
Content-Disposition: inline
In-Reply-To: <20180425112415.12327-3-pagupta@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, jack@suse.cz, stefanha@redhat.com, dan.j.williams@intel.com, riel@surriel.com, haozhong.zhang@intel.com, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross.zwisler@intel.com, david@redhat.com, xiaoguangrong.eric@gmail.com, hch@infradead.org, marcel@redhat.com, mst@redhat.com, niteshnarayanlal@hotmail.com, imammedo@redhat.com, lcapitulino@redhat.com


--NDin8bjvE/0mNLFQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 25, 2018 at 04:54:14PM +0530, Pankaj Gupta wrote:
> This patch adds functionality to perform=20
> flush from guest to hosy over VIRTIO=20
> when 'ND_REGION_VIRTIO'flag is set on=20
> nd_negion. Flag is set by 'virtio-pmem'
> driver.
>=20
> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> ---
>  drivers/nvdimm/region_devs.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>=20
> diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
> index a612be6..6c6454e 100644
> --- a/drivers/nvdimm/region_devs.c
> +++ b/drivers/nvdimm/region_devs.c
> @@ -20,6 +20,7 @@
>  #include <linux/nd.h>
>  #include "nd-core.h"
>  #include "nd.h"
> +#include <linux/virtio_pmem.h>
> =20
>  /*
>   * For readq() and writeq() on 32-bit builds, the hi-lo, lo-hi order is
> @@ -1074,6 +1075,12 @@ void nvdimm_flush(struct nd_region *nd_region)
>  	struct nd_region_data *ndrd =3D dev_get_drvdata(&nd_region->dev);
>  	int i, idx;
> =20
> +       /* call PV device flush */
> +	if (test_bit(ND_REGION_VIRTIO, &nd_region->flags)) {
> +		virtio_pmem_flush(&nd_region->dev);
> +		return;
> +	}

How does libnvdimm know when flush has completed?

Callers expect the flush to be finished when nvdimm_flush() returns but
the virtio driver has only queued the request, it hasn't waited for
completion!

--NDin8bjvE/0mNLFQ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJa4dDlAAoJEJykq7OBq3PI980IAJY41FLfXhqcQzxR13OvtKqj
cM7mQMJIee6fETlh9HYqEh7dOvOHhpqojY9PEKA+Bu1f/KC3Y03liilCCKdLiHc+
WpCVSyT3nOTjPlY4tS+e4WEEzaCwqNYu8rbz7sfJxd1c+4Hl9VuLfBQLieSnTsmE
GUawKQak2e+c7EdOdKxmxtaeZfX1qJcm6ZMhbqSrvIrzR+E+fz4WKmntxrdgeDwY
4IzZHK5h2u4z0jSeLf0tfdWf/77y1IWPqKGvuK6MTZHFxvMn6AiI4VZ116LfXgNC
l7SS25ehqJ5WGgBrUYsL40QAimQDSCQL2ouNwyx/Q1+Ub/xi6TWKN17u3UV5Bpc=
=i3H2
-----END PGP SIGNATURE-----

--NDin8bjvE/0mNLFQ--
