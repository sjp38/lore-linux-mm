Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 47DBE6B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 04:04:38 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id r67so26369720pfr.6
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 01:04:38 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id p1si3761396pld.270.2017.02.23.01.04.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 01:04:37 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 07/14] migrate: Add copy_page_lists_mthread()
 function.
Date: Thu, 23 Feb 2017 08:54:20 +0000
Message-ID: <20170223085419.GA28246@hori1.linux.bs1.fc.nec.co.jp>
References: <20170217150551.117028-1-zi.yan@sent.com>
 <20170217150551.117028-8-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-8-zi.yan@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <731ADF738A99824D842AE3D2FF0811A3@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "apopple@au1.ibm.com" <apopple@au1.ibm.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>

On Fri, Feb 17, 2017 at 10:05:44AM -0500, Zi Yan wrote:
> From: Zi Yan <ziy@nvidia.com>
>=20
> It supports copying a list of pages via multi-threaded process.
> It evenly distributes a list of pages to a group of threads and
> uses the same subroutine as copy_page_mthread()

The new function has many duplicate lines with copy_page_mthread(),
so please consider factoring out them into a common routine.
That makes your code more readable/maintainable.

Thanks,
Naoya Horiguchi

>=20
> Signed-off-by: Zi Yan <ziy@nvidia.com>
> ---
>  mm/copy_pages.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  mm/internal.h   |  3 +++
>  2 files changed, 65 insertions(+)
>=20
> diff --git a/mm/copy_pages.c b/mm/copy_pages.c
> index c357e7b01042..516c0a1a57f3 100644
> --- a/mm/copy_pages.c
> +++ b/mm/copy_pages.c
> @@ -84,3 +84,65 @@ int copy_pages_mthread(struct page *to, struct page *f=
rom, int nr_pages)
>  	kfree(work_items);
>  	return 0;
>  }
> +
> +int copy_page_lists_mthread(struct page **to, struct page **from, int nr=
_pages)=20
> +{
> +	int err =3D 0;
> +	unsigned int cthreads, node =3D page_to_nid(*to);
> +	int i;
> +	struct copy_info *work_items;
> +	int nr_pages_per_page =3D hpage_nr_pages(*from);
> +	const struct cpumask *cpumask =3D cpumask_of_node(node);
> +	int cpu_id_list[32] =3D {0};
> +	int cpu;
> +
> +	cthreads =3D nr_copythreads;
> +	cthreads =3D min_t(unsigned int, cthreads, cpumask_weight(cpumask));
> +	cthreads =3D (cthreads / 2) * 2;
> +	cthreads =3D min_t(unsigned int, nr_pages, cthreads);
> +
> +	work_items =3D kzalloc(sizeof(struct copy_info)*nr_pages,
> +						 GFP_KERNEL);
> +	if (!work_items)
> +		return -ENOMEM;
> +
> +	i =3D 0;
> +	for_each_cpu(cpu, cpumask) {
> +		if (i >=3D cthreads)
> +			break;
> +		cpu_id_list[i] =3D cpu;
> +		++i;
> +	}
> +
> +	for (i =3D 0; i < nr_pages; ++i) {
> +		int thread_idx =3D i % cthreads;
> +
> +		INIT_WORK((struct work_struct *)&work_items[i],=20
> +				  copythread);
> +
> +		work_items[i].to =3D kmap(to[i]);
> +		work_items[i].from =3D kmap(from[i]);
> +		work_items[i].chunk_size =3D PAGE_SIZE * hpage_nr_pages(from[i]);
> +
> +		BUG_ON(nr_pages_per_page !=3D hpage_nr_pages(from[i]));
> +		BUG_ON(nr_pages_per_page !=3D hpage_nr_pages(to[i]));
> +
> +
> +		queue_work_on(cpu_id_list[thread_idx],=20
> +					  system_highpri_wq,=20
> +					  (struct work_struct *)&work_items[i]);
> +	}
> +
> +	/* Wait until it finishes  */
> +	for (i =3D 0; i < cthreads; ++i)
> +		flush_work((struct work_struct *) &work_items[i]);
> +
> +	for (i =3D 0; i < nr_pages; ++i) {
> +			kunmap(to[i]);
> +			kunmap(from[i]);
> +	}
> +
> +	kfree(work_items);
> +
> +	return err;
> +}
> diff --git a/mm/internal.h b/mm/internal.h
> index ccfc2a2969f4..175e08ed524a 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -498,4 +498,7 @@ extern const struct trace_print_flags pageflag_names[=
];
>  extern const struct trace_print_flags vmaflag_names[];
>  extern const struct trace_print_flags gfpflag_names[];
> =20
> +extern int copy_page_lists_mthread(struct page **to,
> +			struct page **from, int nr_pages);
> +
>  #endif	/* __MM_INTERNAL_H */
> --=20
> 2.11.0
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
