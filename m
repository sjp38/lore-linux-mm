Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91C2D6B000D
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 02:35:40 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q18-v6so18993359pll.3
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 23:35:40 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id x23-v6si2258448pfk.25.2018.07.12.23.35.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 23:35:39 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v5 05/11] mm, madvise_inject_error: Let memory_failure()
 optionally take a page reference
Date: Fri, 13 Jul 2018 06:31:25 +0000
Message-ID: <20180713063125.GA10034@hori1.linux.bs1.fc.nec.co.jp>
References: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153074044986.27838.16910122305490506387.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153074044986.27838.16910122305490506387.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <A161B23BB3FC5245AE184ADCF1A397DB@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Michal Hocko <mhocko@suse.com>, "hch@lst.de" <hch@lst.de>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jack@suse.cz" <jack@suse.cz>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>

Hello Dan,

On Wed, Jul 04, 2018 at 02:40:49PM -0700, Dan Williams wrote:
> The madvise_inject_error() routine uses get_user_pages() to lookup the
> pfn and other information for injected error, but it does not release
> that pin. The assumption is that failed pages should be taken out of
> circulation.
>
> However, for dax mappings it is not possible to take pages out of
> circulation since they are 1:1 physically mapped as filesystem blocks,
> or device-dax capacity. They also typically represent persistent memory
> which has an error clearing capability.
>
> In preparation for adding a special handler for dax mappings, shift the
> responsibility of taking the page reference to memory_failure(). I.e.
> drop the page reference and do not specify MF_COUNT_INCREASED to
> memory_failure().
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  mm/madvise.c |   18 +++++++++++++++---
>  1 file changed, 15 insertions(+), 3 deletions(-)
>
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 4d3c922ea1a1..b731933dddae 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -631,11 +631,13 @@ static int madvise_inject_error(int behavior,
>
>
>  	for (; start < end; start +=3D PAGE_SIZE << order) {
> +		unsigned long pfn;
>  		int ret;
>
>  		ret =3D get_user_pages_fast(start, 1, 0, &page);
>  		if (ret !=3D 1)
>  			return ret;
> +		pfn =3D page_to_pfn(page);
>
>  		/*
>  		 * When soft offlining hugepages, after migrating the page
> @@ -651,17 +653,27 @@ static int madvise_inject_error(int behavior,
>
>  		if (behavior =3D=3D MADV_SOFT_OFFLINE) {
>  			pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n",
> -						page_to_pfn(page), start);
> +					pfn, start);
>
>  			ret =3D soft_offline_page(page, MF_COUNT_INCREASED);
>  			if (ret)
>  				return ret;
>  			continue;
>  		}
> +
>  		pr_info("Injecting memory failure for pfn %#lx at process virtual addr=
ess %#lx\n",
> -						page_to_pfn(page), start);
> +				pfn, start);
> +
> +		ret =3D memory_failure(pfn, 0);
> +
> +		/*
> +		 * Drop the page reference taken by get_user_pages_fast(). In
> +		 * the absence of MF_COUNT_INCREASED the memory_failure()
> +		 * routine is responsible for pinning the page to prevent it
> +		 * from being released back to the page allocator.
> +		 */
> +		put_page(page);
>
> -		ret =3D memory_failure(page_to_pfn(page), MF_COUNT_INCREASED);

MF_COUNT_INCREASED means that the page refcount for memory error handling
is taken by the caller so you don't have to take one inside memory_failure(=
).
So this code don't keep with the definition, then another refcount can be
taken in memory_failure() in normal LRU page's case for example.
As a result the error message "Memory failure: %#lx: %s still referenced by
%d users\n" will be dumped in page_action().

So if you want to put put_page() in madvise_inject_error(), I think that

 		put_page(page);
 		ret =3D memory_failure(pfn, 0);

can be acceptable because the purpose of get_user_pages_fast() here is
just getting pfn, and the refcount itself is not so important.
IOW, memory_failure() is called only with pfn which never changes depending
on the page's status.
In production system memory_failure() is called via machine check code
without taking any pagecount, so I don't think the this injection interface
is properly mocking the real thing. So I'm feeling that this flag will be
wiped out at some point.

Thanks,
Naoya Horiguchi=
