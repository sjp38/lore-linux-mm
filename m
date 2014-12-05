Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 92F986B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 12:41:14 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so2164598wiv.1
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 09:41:14 -0800 (PST)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id eb2si3318557wib.105.2014.12.05.09.41.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 09:41:13 -0800 (PST)
Received: by mail-wi0-f175.google.com with SMTP id l15so2171174wiw.2
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 09:41:13 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] CMA: add the amount of cma memory in meminfo
In-Reply-To: <547FCCE9.2020600@huawei.com>
References: <547FCCE9.2020600@huawei.com>
Date: Fri, 05 Dec 2014 18:41:04 +0100
Message-ID: <xa1ty4qm9eq7.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, m.szyprowski@samsung.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, Dec 04 2014, Xishi Qiu <qiuxishi@huawei.com> wrote:
> Add the amount of cma memory in the following meminfo.
> /proc/meminfo
> /sys/devices/system/node/nodeXX/meminfo
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

No second look:

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  drivers/base/node.c | 16 ++++++++++------
>  fs/proc/meminfo.c   | 12 +++++++++---
>  2 files changed, 19 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 472168c..a27e4e0 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -120,6 +120,9 @@ static ssize_t node_read_meminfo(struct device *dev,
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  		       "Node %d AnonHugePages:  %8lu kB\n"
>  #endif
> +#ifdef CONFIG_CMA
> +		       "Node %d FreeCMAPages:   %8lu kB\n"
> +#endif
>  			,
>  		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
>  		       nid, K(node_page_state(nid, NR_WRITEBACK)),
> @@ -136,14 +139,15 @@ static ssize_t node_read_meminfo(struct device *dev,
>  		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE) +
>  				node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
>  		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE)),
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE))
> -			, nid,
> -			K(node_page_state(nid, NR_ANON_TRANSPARENT_HUGEPAGES) *
> -			HPAGE_PMD_NR));
> -#else
> -		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +		       , nid, K(node_page_state(nid,
> +				NR_ANON_TRANSPARENT_HUGEPAGES) * HPAGE_PMD_NR)
> +#endif
> +#ifdef CONFIG_CMA
> +		       , nid, K(node_page_state(nid, NR_FREE_CMA_PAGES))
>  #endif
> +			);
>  	n +=3D hugetlb_report_node_meminfo(nid, buf + n);
>  	return n;
>  }
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index aa1eee0..d42e082 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -138,6 +138,9 @@ static int meminfo_proc_show(struct seq_file *m, void=
 *v)
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  		"AnonHugePages:  %8lu kB\n"
>  #endif
> +#ifdef CONFIG_CMA
> +		"FreeCMAPages:   %8lu kB\n"
> +#endif
>  		,
>  		K(i.totalram),
>  		K(i.freeram),
> @@ -187,11 +190,14 @@ static int meminfo_proc_show(struct seq_file *m, vo=
id *v)
>  		vmi.used >> 10,
>  		vmi.largest_chunk >> 10
>  #ifdef CONFIG_MEMORY_FAILURE
> -		,atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
> +		, atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
>  #endif
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -		,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
> -		   HPAGE_PMD_NR)
> +		, K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
> +				HPAGE_PMD_NR)
> +#endif
> +#ifdef CONFIG_CMA
> +		, K(global_page_state(NR_FREE_CMA_PAGES))
>  #endif
>  		);
>=20=20
> --=20
> 2.0.0
>
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
