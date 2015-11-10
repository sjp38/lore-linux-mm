Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3075C6B0255
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 20:40:27 -0500 (EST)
Received: by ioc74 with SMTP id 74so139467467ioc.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 17:40:27 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id f11si1659973ioj.131.2015.11.09.17.40.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Nov 2015 17:40:26 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/mmap.c: Remove redundant local variables for
 may_expand_vm()
Date: Tue, 10 Nov 2015 01:39:46 +0000
Message-ID: <20151110013945.GA24497@hori1.linux.bs1.fc.nec.co.jp>
References: <COL130-W65418E50E899195C9B2134B9150@phx.gbl>
In-Reply-To: <COL130-W65418E50E899195C9B2134B9150@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <D35883853C89C3488137AC763A7FDEC9@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "oleg@redhat.com" <oleg@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "dave@stgolabs.net" <dave@stgolabs.net>, "aarcange@redhat.com" <aarcange@redhat.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

On Tue, Nov 10, 2015 at 05:41:08AM +0800, Chen Gang wrote:
> From 7050c267d8dda220226067039d815593d2f9a874 Mon Sep 17 00:00:00 2001
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> Date: Tue, 10 Nov 2015 05:32:38 +0800
> Subject: [PATCH] mm/mmap.c: Remove redundant local variables for may_expa=
nd_vm()
>=20
> After merge the related code into one line, the code is still simple and
> meaningful enough.
>=20
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

I agree that this function can be cleaned up.

> ---
>  mm/mmap.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
>=20
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 2ce04a6..a515260 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2988,12 +2988,7 @@ out:
>   */
>  int may_expand_vm(struct mm_struct *mm, unsigned long npages)

marking inline?=20

>  {
> -	unsigned long cur =3D mm->total_vm;	/* pages */
> -	unsigned long lim;
> -
> -	lim =3D rlimit(RLIMIT_AS) >> PAGE_SHIFT;
> -
> -	if (cur + npages > lim)
> +	if (mm->total_vm + npages > (rlimit(RLIMIT_AS) >> PAGE_SHIFT))
>  		return 0;
>  	return 1;

How about doing simply

	return mm->total_vm + npages <=3D (rlimit(RLIMIT_AS) >> PAGE_SHIFT);

? These changes save some bytes :)

   text    data     bss     dec     hex filename=20
  20566    2250      40   22856    5948 mm/mmap.o (before)

   text    data     bss     dec     hex filename=20
  20542    2250      40   22832    5930 mm/mmap.o (after)

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
