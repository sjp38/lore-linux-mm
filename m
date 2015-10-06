Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id DBBEF82F6F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 05:53:31 -0400 (EDT)
Received: by lbcao8 with SMTP id ao8so73009796lbc.3
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 02:53:31 -0700 (PDT)
Received: from bes.se.axis.com (bes.se.axis.com. [195.60.68.10])
        by mx.google.com with ESMTP id xu2si20284243lbb.104.2015.10.06.02.53.30
        for <linux-mm@kvack.org>;
        Tue, 06 Oct 2015 02:53:30 -0700 (PDT)
From: Mikael Starvik <mikael.starvik@axis.com>
Date: Tue, 6 Oct 2015 11:53:27 +0200
Subject: Re: [PATCH 1/7] cris: Convert cryptocop to use get_user_pages_fast()
Message-ID: <4A71022F-5EB7-40D5-9646-A200C5C140A0@axis.com>
References: <1444123470-4932-1-git-send-email-jack@suse.com>
 <1444123470-4932-2-git-send-email-jack@suse.com>
In-Reply-To: <1444123470-4932-2-git-send-email-jack@suse.com>
Content-Language: sv-SE
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, linux-cris-kernel <linux-cris-kernel@axis.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jespern@axis.com>

Thank you! I will do the same change in our out-of-tree modules! Jesper wil=
l do the ack.



> 6 okt 2015 kl. 11:43 skrev Jan Kara <jack@suse.com>:
>=20
> From: Jan Kara <jack@suse.cz>
>=20
> CC: linux-cris-kernel@axis.com
> CC: Mikael Starvik <starvik@axis.com>
> CC: Jesper Nilsson <jesper.nilsson@axis.com>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
> arch/cris/arch-v32/drivers/cryptocop.c | 35 ++++++++++-------------------=
-----
> 1 file changed, 10 insertions(+), 25 deletions(-)
>=20
> diff --git a/arch/cris/arch-v32/drivers/cryptocop.c b/arch/cris/arch-v32/=
drivers/cryptocop.c
> index 877da1908234..df7ceeff1086 100644
> --- a/arch/cris/arch-v32/drivers/cryptocop.c
> +++ b/arch/cris/arch-v32/drivers/cryptocop.c
> @@ -2716,43 +2716,28 @@ static int cryptocop_ioctl_process(struct inode *=
inode, struct file *filp, unsig
>        }
>    }
>=20
> -    /* Acquire the mm page semaphore. */
> -    down_read(&current->mm->mmap_sem);
> -
> -    err =3D get_user_pages(current,
> -                 current->mm,
> -                 (unsigned long int)(oper.indata + prev_ix),
> -                 noinpages,
> -                 0,  /* read access only for in data */
> -                 0, /* no force */
> -                 inpages,
> -                 NULL);
> +    err =3D get_user_pages_fast((unsigned long)(oper.indata + prev_ix),
> +                  noinpages,
> +                  0,  /* read access only for in data */
> +                  inpages);
>=20
>    if (err < 0) {
> -        up_read(&current->mm->mmap_sem);
>        nooutpages =3D noinpages =3D 0;
> -        DEBUG_API(printk("cryptocop_ioctl_process: get_user_pages indata=
\n"));
> +        DEBUG_API(printk("cryptocop_ioctl_process: get_user_pages_fast i=
ndata\n"));
>        goto error_cleanup;
>    }
>    noinpages =3D err;
>    if (oper.do_cipher){
> -        err =3D get_user_pages(current,
> -                     current->mm,
> -                     (unsigned long int)oper.cipher_outdata,
> -                     nooutpages,
> -                     1, /* write access for out data */
> -                     0, /* no force */
> -                     outpages,
> -                     NULL);
> -        up_read(&current->mm->mmap_sem);
> +        err =3D get_user_pages_fast((unsigned long)oper.cipher_outdata,
> +                      nooutpages,
> +                      1, /* write access for out data */
> +                      outpages);
>        if (err < 0) {
>            nooutpages =3D 0;
> -            DEBUG_API(printk("cryptocop_ioctl_process: get_user_pages ou=
tdata\n"));
> +            DEBUG_API(printk("cryptocop_ioctl_process: get_user_pages_fa=
st outdata\n"));
>            goto error_cleanup;
>        }
>        nooutpages =3D err;
> -    } else {
> -        up_read(&current->mm->mmap_sem);
>    }
>=20
>    /* Add 6 to nooutpages to make room for possibly inserted buffers for =
storing digest and
> --=20
> 2.1.4
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
