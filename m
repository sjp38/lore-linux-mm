Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAD636B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 19:36:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c6so209391794pfj.5
        for <linux-mm@kvack.org>; Wed, 24 May 2017 16:36:45 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id h19si9040799pgk.221.2017.05.24.16.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 16:36:44 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: hwpoison: Use compound_head() flags for huge pages
Date: Wed, 24 May 2017 23:30:41 +0000
Message-ID: <20170524233039.GA27332@hori1.linux.bs1.fc.nec.co.jp>
References: <20170524130204.21845-1-james.morse@arm.com>
In-Reply-To: <20170524130204.21845-1-james.morse@arm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <85EF2371C6487C4B91A82ECDC37C5B96@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Punit Agrawal <punit.agrawal@arm.com>

On Wed, May 24, 2017 at 02:02:04PM +0100, James Morse wrote:
> memory_failure() chooses a recovery action function based on the page
> flags. For huge pages it uses the tail page flags which don't have
> anything interesting set, resulting in:
> > Memory failure: 0x9be3b4: Unknown page state
> > Memory failure: 0x9be3b4: recovery action for unknown page: Failed
>=20
> Instead, save a copy of the head page's flags if this is a huge page,
> this means if there are no relevant flags for this tail page, we use
> the head pages flags instead. This results in the me_huge_page()
> recovery action being called:
> > Memory failure: 0x9b7969: recovery action for huge page: Delayed
>=20
> For hugepages that have not yet been allocated, this allows the hugepage
> to be dequeued.
>=20
> CC: Punit Agrawal <punit.agrawal@arm.com>
> Signed-off-by: James Morse <james.morse@arm.com>

Looks good to me.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
> This is intended as a fix, but I can't find the patch that introduced thi=
s
> behaviour. (not recent, and there is a lot of history down there!)

Please add a tag

Fixes: 524fca1e7356 ("HWPOISON: fix misjudgement of page_action() for error=
s on mlocked pages")

>=20
> This doesn't apply to stable trees before v3.10...
> Cc: stable@vger.kernel.org # 3.10.105

You can skip older stable kernels to which the fix isn't cleanly applicable=
.

Thanks,
Naoya Horiguchi

>=20
>  mm/memory-failure.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 2527dfeddb00..44a6a33af219 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1184,7 +1184,10 @@ int memory_failure(unsigned long pfn, int trapno, =
int flags)
>  	 * page_remove_rmap() in try_to_unmap_one(). So to determine page statu=
s
>  	 * correctly, we save a copy of the page flags at this time.
>  	 */
> -	page_flags =3D p->flags;
> +	if (PageHuge(p))
> +		page_flags =3D hpage->flags;
> +	else
> +		page_flags =3D p->flags;
> =20
>  	/*
>  	 * unpoison always clear PG_hwpoison inside page lock
> --=20
> 2.11.0
>=20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
