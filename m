Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4435C6B0255
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 03:15:25 -0500 (EST)
Received: by mail-oi0-f42.google.com with SMTP id k206so6641501oia.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 00:15:25 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id wc7si20313052oeb.88.2016.01.08.00.15.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jan 2016 00:15:24 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/mmap.c: remove redundant check "if (length <
 info->length)"
Date: Fri, 8 Jan 2016 08:11:27 +0000
Message-ID: <20160108081125.GA11868@hori1.linux.bs1.fc.nec.co.jp>
References: <20160107165923.77fea9a3@debian>
In-Reply-To: <20160107165923.77fea9a3@debian>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <622C146B41276042A4698AD875E6B7BA@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jan 07, 2016 at 04:59:23PM +0800, Wang Xiaoqiang wrote:
> Hi, all,
>=20
> since the code:
>=20
> length =3D info->length + info->align_mask
>=20
> and all variables above are "unsigned long" type,
> so there must be "length >=3D info->length".

I think that if info->align_mask is "very large" as an unsigned long value
and the sum of these 2 overflows, length can become smaller than info->leng=
th,
so we seem to need the check.

But why returning -ENOMEM?  Isn't it worth VM_BUG_ON()?

Thanks,
Naoya Horiguchi

>=20
> Signed-off-by: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
> ---
>  mm/mmap.c | 2 --
>  1 file changed, 2 deletions(-)
>=20
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 2ce04a6..99fc461 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1716,8 +1716,6 @@ unsigned long unmapped_area(struct vm_unmapped_area=
_info *info)
> =20
>  	/* Adjust search length to account for worst case alignment overhead */
>  	length =3D info->length + info->align_mask;
> -	if (length < info->length)
> -		return -ENOMEM;
> =20
>  	/* Adjust search limits by the desired length */
>  	if (info->high_limit < length)
> --=20
> 2.1.4
>=20
> thanks,
> Wang Xiaoqiang
>=20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
