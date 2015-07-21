Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 93DE06B028B
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 04:36:35 -0400 (EDT)
Received: by ietj16 with SMTP id j16so136712178iet.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 01:36:35 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id ji2si19402525icb.106.2015.07.21.01.36.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jul 2015 01:36:35 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] pagemap: update documentation
Date: Tue, 21 Jul 2015 08:35:05 +0000
Message-ID: <20150721083504.GA8170@hori1.linux.bs1.fc.nec.co.jp>
References: <20150714152516.29844.69929.stgit@buzz>
 <20150716184742.8858.14639.stgit@buzz>
In-Reply-To: <20150716184742.8858.14639.stgit@buzz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <CB1B053981AEE04FA0D10C7DEDB4F794@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jul 16, 2015 at 09:47:42PM +0300, Konstantin Khlebnikov wrote:
> Notes about recent changes.
>=20
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  Documentation/vm/pagemap.txt |   14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
>=20
> diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
> index 3cfbbb333ea1..aab39aa7dd8f 100644
> --- a/Documentation/vm/pagemap.txt
> +++ b/Documentation/vm/pagemap.txt
> @@ -16,12 +16,17 @@ There are three components to pagemap:
>      * Bits 0-4   swap type if swapped
>      * Bits 5-54  swap offset if swapped
>      * Bit  55    pte is soft-dirty (see Documentation/vm/soft-dirty.txt)
> -    * Bit  56    page exlusively mapped
> +    * Bit  56    page exclusively mapped (since 4.2)
>      * Bits 57-60 zero
> -    * Bit  61    page is file-page or shared-anon
> +    * Bit  61    page is file-page or shared-anon (since 3.5)
>      * Bit  62    page swapped
>      * Bit  63    page present
> =20
> +   Since Linux 4.0 only users with the CAP_SYS_ADMIN capability can get =
PFNs:
> +   for unprivileged users from 4.0 till 4.2 open fails with -EPERM, star=
ting

I'm expecting that this patch will be merged before 4.2 is released, so if =
that's
right, stating "till 4.2" might be incorrect.

> +   from from 4.2 PFN field is zeroed if user has no CAP_SYS_ADMIN capabi=
lity.

"from" duplicates ...

Thanks,
Naoya Horiguchi

> +   Reason: information about PFNs helps in exploiting Rowhammer vulnerab=
ility.
> +
>     If the page is not present but in swap, then the PFN contains an
>     encoding of the swap file number and the page's offset into the
>     swap. Unmapped pages return a null PFN. This allows determining
> @@ -160,3 +165,8 @@ Other notes:
>  Reading from any of the files will return -EINVAL if you are not startin=
g
>  the read on an 8-byte boundary (e.g., if you sought an odd number of byt=
es
>  into the file), or if the size of the read is not a multiple of 8 bytes.
> +
> +Before Linux 3.11 pagemap bits 55-60 were used for "page-shift" (which i=
s
> +always 12 at most architectures). Since Linux 3.11 their meaning changes
> +after first clear of soft-dirty bits. Since Linux 4.2 they are used for
> +flags unconditionally.
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
