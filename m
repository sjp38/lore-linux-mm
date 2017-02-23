Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 923906B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 01:09:13 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 68so22128860pfx.1
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 22:09:13 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id v1si3383424pfg.106.2017.02.22.22.09.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 22:09:12 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 03/14] mm/migrate: Add copy_pages_mthread function
Date: Thu, 23 Feb 2017 06:06:50 +0000
Message-ID: <20170223060649.GA7336@hori1.linux.bs1.fc.nec.co.jp>
References: <20170217150551.117028-1-zi.yan@sent.com>
 <20170217150551.117028-4-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-4-zi.yan@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <9BE662D79A00AD46824CB3079090EE6A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "apopple@au1.ibm.com" <apopple@au1.ibm.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>

On Fri, Feb 17, 2017 at 10:05:40AM -0500, Zi Yan wrote:
> From: Zi Yan <ziy@nvidia.com>
>=20
> This change adds a new function copy_pages_mthread to enable multi thread=
ed
> page copy which can be utilized during migration. This function splits th=
e
> page copy request into multiple threads which will handle individual chun=
k
> and send them as jobs to system_highpri_wq work queue.
>=20
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  include/linux/highmem.h |  2 ++
>  mm/Makefile             |  2 ++
>  mm/copy_pages.c         | 86 +++++++++++++++++++++++++++++++++++++++++++=
++++++
>  3 files changed, 90 insertions(+)
>  create mode 100644 mm/copy_pages.c
>=20
> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> index bb3f3297062a..e1f4f1b82812 100644
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -236,6 +236,8 @@ static inline void copy_user_highpage(struct page *to=
, struct page *from,
> =20
>  #endif
> =20
> +int copy_pages_mthread(struct page *to, struct page *from, int nr_pages)=
;
> +
>  static inline void copy_highpage(struct page *to, struct page *from)
>  {
>  	char *vfrom, *vto;
> diff --git a/mm/Makefile b/mm/Makefile
> index aa0aa17cb413..cdd4bab9cc66 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -43,6 +43,8 @@ obj-y			:=3D filemap.o mempool.o oom_kill.o \
> =20
>  obj-y +=3D init-mm.o
> =20
> +obj-y +=3D copy_pages.o
> +
>  ifdef CONFIG_NO_BOOTMEM
>  	obj-y		+=3D nobootmem.o
>  else
> diff --git a/mm/copy_pages.c b/mm/copy_pages.c
> new file mode 100644
> index 000000000000..c357e7b01042
> --- /dev/null
> +++ b/mm/copy_pages.c
> @@ -0,0 +1,86 @@
> +/*
> + * This implements parallel page copy function through multi threaded
> + * work queues.
> + *
> + * Zi Yan <ziy@nvidia.com>
> + *
> + * This work is licensed under the terms of the GNU GPL, version 2.
> + */
> +#include <linux/highmem.h>
> +#include <linux/workqueue.h>
> +#include <linux/slab.h>
> +#include <linux/freezer.h>
> +
> +/*
> + * nr_copythreads can be the highest number of threads for given node
> + * on any architecture. The actual number of copy threads will be
> + * limited by the cpumask weight of the target node.
> + */
> +unsigned int nr_copythreads =3D 8;

If you give this as a constant, how about defining as macro?

> +
> +struct copy_info {
> +	struct work_struct copy_work;
> +	char *to;
> +	char *from;
> +	unsigned long chunk_size;
> +};
> +
> +static void copy_pages(char *vto, char *vfrom, unsigned long size)
> +{
> +	memcpy(vto, vfrom, size);
> +}
> +
> +static void copythread(struct work_struct *work)
> +{
> +	struct copy_info *info =3D (struct copy_info *) work;
> +
> +	copy_pages(info->to, info->from, info->chunk_size);
> +}
> +
> +int copy_pages_mthread(struct page *to, struct page *from, int nr_pages)
> +{
> +	unsigned int node =3D page_to_nid(to);
> +	const struct cpumask *cpumask =3D cpumask_of_node(node);
> +	struct copy_info *work_items;
> +	char *vto, *vfrom;
> +	unsigned long i, cthreads, cpu, chunk_size;
> +	int cpu_id_list[32] =3D {0};

Why 32? Maybe you can set the array size with nr_copythreads (macro version=
.)

> +
> +	cthreads =3D nr_copythreads;
> +	cthreads =3D min_t(unsigned int, cthreads, cpumask_weight(cpumask));

nitpick, but looks a little wordy, can it be simply like below?

  cthreads =3D min_t(unsigned int, nr_copythreads, cpumask_weight(cpumask))=
;

> +	cthreads =3D (cthreads / 2) * 2;

I'm not sure the intention here. # of threads should be even number?
If cpumask_weight() is 1, cthreads is 0, that could cause zero division.
So you had better making sure to prevent it.

Thanks,
Naoya Horiguchi

> +	work_items =3D kcalloc(cthreads, sizeof(struct copy_info), GFP_KERNEL);
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
> +	vfrom =3D kmap(from);
> +	vto =3D kmap(to);
> +	chunk_size =3D PAGE_SIZE * nr_pages / cthreads;
> +
> +	for (i =3D 0; i < cthreads; ++i) {
> +		INIT_WORK((struct work_struct *) &work_items[i], copythread);
> +
> +		work_items[i].to =3D vto + i * chunk_size;
> +		work_items[i].from =3D vfrom + i * chunk_size;
> +		work_items[i].chunk_size =3D chunk_size;
> +
> +		queue_work_on(cpu_id_list[i], system_highpri_wq,
> +					  (struct work_struct *) &work_items[i]);
> +	}
> +
> +	for (i =3D 0; i < cthreads; ++i)
> +		flush_work((struct work_struct *) &work_items[i]);
> +
> +	kunmap(to);
> +	kunmap(from);
> +	kfree(work_items);
> +	return 0;
> +}
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
