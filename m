Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7FEFE6B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 04:59:26 -0400 (EDT)
Received: by qkcs67 with SMTP id s67so3099934qkc.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 01:59:26 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id w199si8797998qha.64.2015.08.12.01.59.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Aug 2015 01:59:25 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 3/5] mm/hwpoison: introduce put_hwpoison_page to put
 refcount for memory error handling
Date: Wed, 12 Aug 2015 08:58:18 +0000
Message-ID: <20150812085818.GE32192@hori1.linux.bs1.fc.nec.co.jp>
References: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
 <BLU436-SMTP127AFDD347F96AC6BDED54C80700@phx.gbl>
In-Reply-To: <BLU436-SMTP127AFDD347F96AC6BDED54C80700@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <DD8E3CC7B03BB048A03BD0C8586A19AC@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Aug 10, 2015 at 07:28:21PM +0800, Wanpeng Li wrote:
> Introduce put_hwpoison_page to put refcount for memory=20
> error handling.=20
>=20
> Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>

Thanks!

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  include/linux/mm.h  |    1 +
>  mm/memory-failure.c |   21 +++++++++++++++++++++
>  2 files changed, 22 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 554b0f0..c0a0b9f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2103,6 +2103,7 @@ extern int memory_failure(unsigned long pfn, int tr=
apno, int flags);
>  extern void memory_failure_queue(unsigned long pfn, int trapno, int flag=
s);
>  extern int unpoison_memory(unsigned long pfn);
>  extern int get_hwpoison_page(struct page *page);
> +extern void put_hwpoison_page(struct page *page);
>  extern int sysctl_memory_failure_early_kill;
>  extern int sysctl_memory_failure_recovery;
>  extern void shake_page(struct page *p, int access);
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index e0eb7ab..fa9aa21 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -922,6 +922,27 @@ int get_hwpoison_page(struct page *page)
>  }
>  EXPORT_SYMBOL_GPL(get_hwpoison_page);
> =20
> +/**
> + * put_hwpoison_page() - Put refcount for memory error handling:
> + * @page:	raw error page (hit by memory error)
> + */
> +void put_hwpoison_page(struct page *page)
> +{
> +	struct page *head =3D compound_head(page);
> +
> +	if (PageHuge(head)) {
> +		put_page(head);
> +		return;
> +	}
> +
> +	if (PageTransHuge(head))
> +		if (page !=3D head)
> +			put_page(head);
> +
> +	put_page(page);
> +}
> +EXPORT_SYMBOL_GPL(put_hwpoison_page);
> +
>  /*
>   * Do all that is necessary to remove user space mappings. Unmap
>   * the pages and send SIGBUS to the processes if the data was dirty.
> --=20
> 1.7.1
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
