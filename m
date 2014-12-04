Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id DD2286B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 11:26:33 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id l2so23151365wgh.41
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 08:26:33 -0800 (PST)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com. [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id fe6si45585626wjc.5.2014.12.04.08.26.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 08:26:32 -0800 (PST)
Received: by mail-wg0-f43.google.com with SMTP id l18so22981592wgh.30
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 08:26:32 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] CMA: add the amount of cma memory in meminfo
In-Reply-To: <547FCCE9.2020600@huawei.com>
References: <547FCCE9.2020600@huawei.com>
Date: Thu, 04 Dec 2014 17:26:29 +0100
Message-ID: <xa1tfvcvcrey.fsf@mina86.com>
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

Why is this line suddenly out of =E2=80=9C#ifdef CONFIG_TRANSPARENT_HUGEPAG=
E=E2=80=9D?

> -			, nid,
> -			K(node_page_state(nid, NR_ANON_TRANSPARENT_HUGEPAGES) *
> -			HPAGE_PMD_NR));
> -#else
> -		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +		       , nid, K(node_page_state(nid,
> +				NR_ANON_TRANSPARENT_HUGEPAGES) * HPAGE_PMD_NR)

This is mere white-space change which is confusing.

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

Again, please don't include white space changes.  They are confusing.

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
