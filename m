Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id EADBB6B026C
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 12:34:49 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id z26-v6so9324330qto.17
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 09:34:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d10-v6sor19128321qkj.5.2018.06.07.09.34.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 09:34:49 -0700 (PDT)
MIME-Version: 1.0
References: <1528378654-1484-1-git-send-email-geert@linux-m68k.org>
In-Reply-To: <1528378654-1484-1-git-send-email-geert@linux-m68k.org>
From: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@gmail.com>
Date: Thu, 7 Jun 2018 18:34:29 +0200
Message-ID: <CAJ+HfNiciU0+4zd3ppapH12Gg_SFf9oUWTy+yafJSxCX8Mv-Dg@mail.gmail.com>
Subject: Re: [PATCH] xsk: Fix umem fill/completion queue mmap on 32-bit
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: geert@linux-m68k.org
Cc: David Miller <davem@davemloft.net>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, "Karlsson, Magnus" <magnus.karlsson@intel.com>, ast@kernel.org, Arnd Bergmann <arnd@arndb.de>, akpm@linux-foundation.org, Netdev <netdev@vger.kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Den tors 7 juni 2018 kl 15:37 skrev Geert Uytterhoeven <geert@linux-m68k.or=
g>:
>
> With gcc-4.1.2 on 32-bit:
>
>     net/xdp/xsk.c:663: warning: integer constant is too large for =E2=80=
=98long=E2=80=99 type
>     net/xdp/xsk.c:665: warning: integer constant is too large for =E2=80=
=98long=E2=80=99 type
>
> Add the missing "ULL" suffixes to the large XDP_UMEM_PGOFF_*_RING values
> to fix this.
>
>     net/xdp/xsk.c:663: warning: comparison is always false due to limited=
 range of data type
>     net/xdp/xsk.c:665: warning: comparison is always false due to limited=
 range of data type
>
> "unsigned long" is 32-bit on 32-bit systems, hence the offset is
> truncated, and can never be equal to any of the XDP_UMEM_PGOFF_*_RING
> values.  Use loff_t (and the required cast) to fix this.
>
> Fixes: 423f38329d267969 ("xsk: add umem fill queue support and mmap")
> Fixes: fe2308328cd2f26e ("xsk: add umem completion queue support and mmap=
")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
> Compile-tested only.
> ---
>  include/uapi/linux/if_xdp.h | 4 ++--
>  net/xdp/xsk.c               | 2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/include/uapi/linux/if_xdp.h b/include/uapi/linux/if_xdp.h
> index 1fa0e977ea8d0224..caed8b1614ffc0aa 100644
> --- a/include/uapi/linux/if_xdp.h
> +++ b/include/uapi/linux/if_xdp.h
> @@ -63,8 +63,8 @@ struct xdp_statistics {
>  /* Pgoff for mmaping the rings */
>  #define XDP_PGOFF_RX_RING                        0
>  #define XDP_PGOFF_TX_RING               0x80000000
> -#define XDP_UMEM_PGOFF_FILL_RING       0x100000000
> -#define XDP_UMEM_PGOFF_COMPLETION_RING 0x180000000
> +#define XDP_UMEM_PGOFF_FILL_RING       0x100000000ULL
> +#define XDP_UMEM_PGOFF_COMPLETION_RING 0x180000000ULL
>
>  /* Rx/Tx descriptor */
>  struct xdp_desc {
> diff --git a/net/xdp/xsk.c b/net/xdp/xsk.c
> index c6ed2454f7ce55e8..36919a254ba370c3 100644
> --- a/net/xdp/xsk.c
> +++ b/net/xdp/xsk.c
> @@ -643,7 +643,7 @@ static int xsk_getsockopt(struct socket *sock, int le=
vel, int optname,
>  static int xsk_mmap(struct file *file, struct socket *sock,
>                     struct vm_area_struct *vma)
>  {
> -       unsigned long offset =3D vma->vm_pgoff << PAGE_SHIFT;
> +       loff_t offset =3D (loff_t)vma->vm_pgoff << PAGE_SHIFT;
>         unsigned long size =3D vma->vm_end - vma->vm_start;
>         struct xdp_sock *xs =3D xdp_sk(sock->sk);
>         struct xsk_queue *q =3D NULL;
> --
> 2.7.4
>

Thanks Geert!

Acked-by: Bj=C3=B6rn T=C3=B6pel <bjorn.topel@intel.com>
