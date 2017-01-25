Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B0D086B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 09:41:49 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p192so38994324wme.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 06:41:49 -0800 (PST)
Received: from mxout1.idt.com (mxout1.idt.com. [157.165.5.25])
        by mx.google.com with ESMTPS id x107si27090749wrb.294.2017.01.25.06.41.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 06:41:48 -0800 (PST)
From: "Bounine, Alexandre" <Alexandre.Bounine@idt.com>
Subject: RE: [PATCH RESEND] rapidio: use get_user_pages_unlocked()
Date: Wed, 25 Jan 2017 14:35:29 +0000
Message-ID: <8D983423E7EDF846BB3056827B8CC5D15D01C95F@corpmail1.na.ads.idt.com>
References: <20170103205024.6704-1-lstoakes@gmail.com>
In-Reply-To: <20170103205024.6704-1-lstoakes@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Porter <mporter@kernel.crashing.org>

Acked-by: Alexandre Bounine <alexandre.bounine@idt.com>

> -----Original Message-----
> From: Lorenzo Stoakes [mailto:lstoakes@gmail.com]
> Sent: Tuesday, January 03, 2017 3:50 PM
> To: Matt Porter; Bounine, Alexandre
> Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; Andrew Morton;
> Lorenzo Stoakes
> Subject: [PATCH RESEND] rapidio: use get_user_pages_unlocked()
>=20
> Moving from get_user_pages() to get_user_pages_unlocked() simplifies
> the code
> and takes advantage of VM_FAULT_RETRY functionality when faulting in
> pages.
>=20
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
> ---
>  drivers/rapidio/devices/rio_mport_cdev.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/rapidio/devices/rio_mport_cdev.c
> b/drivers/rapidio/devices/rio_mport_cdev.c
> index 9013a585507e..50b617af81bd 100644
> --- a/drivers/rapidio/devices/rio_mport_cdev.c
> +++ b/drivers/rapidio/devices/rio_mport_cdev.c
> @@ -889,17 +889,16 @@ rio_dma_transfer(struct file *filp, u32
> transfer_mode,
>  			goto err_req;
>  		}
>=20
> -		down_read(&current->mm->mmap_sem);
> -		pinned =3D get_user_pages(
> +		pinned =3D get_user_pages_unlocked(
>  				(unsigned long)xfer->loc_addr & PAGE_MASK,
>  				nr_pages,
> -				dir =3D=3D DMA_FROM_DEVICE ? FOLL_WRITE : 0,
> -				page_list, NULL);
> -		up_read(&current->mm->mmap_sem);
> +				page_list,
> +				dir =3D=3D DMA_FROM_DEVICE ? FOLL_WRITE : 0);
>=20
>  		if (pinned !=3D nr_pages) {
>  			if (pinned < 0) {
> -				rmcd_error("get_user_pages err=3D%ld", pinned);
> +				rmcd_error("get_user_pages_unlocked err=3D%ld",
> +					   pinned);
>  				nr_pages =3D 0;
>  			} else
>  				rmcd_error("pinned %ld out of %ld pages",
> --
> 2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
