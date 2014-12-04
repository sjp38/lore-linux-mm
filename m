Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id D91736B0032
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 20:51:51 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so16916168pac.36
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 17:51:51 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id iu1si40664749pbb.216.2014.12.03.17.51.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 03 Dec 2014 17:51:50 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: shmem: avoid overflowing in shmem_fallocate
Date: Thu, 4 Dec 2014 01:51:25 +0000
Message-ID: <20141204015120.GA2522@hori1.linux.bs1.fc.nec.co.jp>
References: <1417652657-1801-1-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1417652657-1801-1-git-send-email-sasha.levin@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <45D0DB6519F4164CA50E8EAA753C59A7@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Dec 03, 2014 at 07:24:07PM -0500, Sasha Levin wrote:
> "offset + len" has the potential of overflowing. Validate this user input
> first to avoid undefined behaviour.
>=20
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  mm/shmem.c |    3 +++
>  1 file changed, 3 insertions(+)
>=20
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 185836b..5a0e344 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2098,6 +2098,9 @@ static long shmem_fallocate(struct file *file, int =
mode, loff_t offset,
>  	}
> =20
>  	/* We need to check rlimit even when FALLOC_FL_KEEP_SIZE */
> +	error =3D -EOVERFLOW;
> +	if ((u64)len + offset < (u64)len)
> +		goto out;

Hi Sasha,

It seems to me that we already do some overflow check in common path,
do_fallocate():

        /* Check for wrap through zero too */
        if (((offset + len) > inode->i_sb->s_maxbytes) || ((offset + len) <=
 0))
                return -EFBIG;

Do we really need another check?

And this patch changes the return value of fallocate(2), so you need
update man document.

BTW, when I'm reading your patch, I noticed that returning -EOVERFLOW
(rather than -EFBIG) looks better when ((offset + len) < 0) in
do_fallocate() is true.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
