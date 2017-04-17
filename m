Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB0F6B0390
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 01:28:02 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id x86so105591742ioe.5
        for <linux-mm@kvack.org>; Sun, 16 Apr 2017 22:28:02 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id 201si6786251itw.49.2017.04.16.22.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Apr 2017 22:28:01 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH V2] mm/madvise: Move up the behavior parameter validation
Date: Mon, 17 Apr 2017 05:27:30 +0000
Message-ID: <20170417052729.GA23423@hori1.linux.bs1.fc.nec.co.jp>
References: <20170413092008.5437-1-khandual@linux.vnet.ibm.com>
 <20170414135141.15340-1-khandual@linux.vnet.ibm.com>
In-Reply-To: <20170414135141.15340-1-khandual@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B26C17411D662A469A7D404E2FD4A6E2@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Fri, Apr 14, 2017 at 07:21:41PM +0530, Anshuman Khandual wrote:
> The madvise_behavior_valid() function should be called before
> acting upon the behavior parameter. Hence move up the function.
> This also includes MADV_SOFT_OFFLINE and MADV_HWPOISON options
> as valid behavior parameter for the system call madvise().
>=20
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
> Changes in V2:
>=20
> Added CONFIG_MEMORY_FAILURE check before using MADV_SOFT_OFFLINE
> and MADV_HWPOISONE constants.
>=20
>  mm/madvise.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/madvise.c b/mm/madvise.c
> index efd4721..ccff186 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -694,6 +694,10 @@ static int madvise_inject_error(int behavior,
>  #endif
>  	case MADV_DONTDUMP:
>  	case MADV_DODUMP:
> +#ifdef CONFIG_MEMORY_FAILURE
> +	case MADV_SOFT_OFFLINE:
> +	case MADV_HWPOISON:
> +#endif
>  		return true;
> =20
>  	default:
> @@ -767,12 +771,13 @@ static int madvise_inject_error(int behavior,
>  	size_t len;
>  	struct blk_plug plug;
> =20
> +	if (!madvise_behavior_valid(behavior))
> +		return error;
> +
>  #ifdef CONFIG_MEMORY_FAILURE
>  	if (behavior =3D=3D MADV_HWPOISON || behavior =3D=3D MADV_SOFT_OFFLINE)
>  		return madvise_inject_error(behavior, start, start + len_in);
>  #endif
> -	if (!madvise_behavior_valid(behavior))
> -		return error;

Hi Anshuman,

I'm wondering why current code calls madvise_inject_error() at the beginnin=
g
of SYSCALL_DEFINE3(madvise), without any boundary checks of address or leng=
th.
I agree to checking madvise_behavior_valid for MADV_{HWPOISON,SOFT_OFFLINE}=
,
but checking boundary of other arguments is also helpful, so how about movi=
ng
down the existing #ifdef block like below?

diff --git a/mm/madvise.c b/mm/madvise.c
index a09d2d3dfae9..7b36912e1f4a 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -754,10 +754,6 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t,=
 len_in, int, behavior)
 	size_t len;
 	struct blk_plug plug;
=20
-#ifdef CONFIG_MEMORY_FAILURE
-	if (behavior =3D=3D MADV_HWPOISON || behavior =3D=3D MADV_SOFT_OFFLINE)
-		return madvise_inject_error(behavior, start, start+len_in);
-#endif
 	if (!madvise_behavior_valid(behavior))
 		return error;
=20
@@ -777,6 +773,11 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t,=
 len_in, int, behavior)
 	if (end =3D=3D start)
 		return error;
=20
+#ifdef CONFIG_MEMORY_FAILURE
+	if (behavior =3D=3D MADV_HWPOISON || behavior =3D=3D MADV_SOFT_OFFLINE)
+		return madvise_inject_error(behavior, start, start+len_in);
+#endif
+
 	write =3D madvise_need_mmap_write(behavior);
 	if (write) {
 		if (down_write_killable(&current->mm->mmap_sem))


Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
