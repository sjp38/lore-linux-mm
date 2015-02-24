Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id B319F6B0071
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:32:36 -0500 (EST)
Received: by wggy19 with SMTP id y19so8082802wgg.10
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:32:36 -0800 (PST)
Received: from mail-we0-x22a.google.com (mail-we0-x22a.google.com. [2a00:1450:400c:c03::22a])
        by mx.google.com with ESMTPS id f4si69595699wjy.26.2015.02.24.13.32.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 13:32:35 -0800 (PST)
Received: by wesx3 with SMTP id x3so27922984wes.6
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:32:34 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v3 3/4] mm: cma: add list of currently allocated CMA buffers to debugfs
In-Reply-To: <1fe64ae6f12eeda1c2aa59daea7f89e57e0e35a9.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com> <1fe64ae6f12eeda1c2aa59daea7f89e57e0e35a9.1424802755.git.s.strogin@partner.samsung.com>
Date: Tue, 24 Feb 2015 22:32:30 +0100
Message-ID: <xa1toaojov0x.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

On Tue, Feb 24 2015, Stefan Strogin <s.strogin@partner.samsung.com> wrote:
> When CONFIG_CMA_BUFFER_LIST is configured a file is added to debugfs:
> /sys/kernel/debug/cma/cma-<N>/buffers contains a list of currently alloca=
ted
> CMA buffers for each CMA region (N stands for number of CMA region).
>
> Format is:
> <base_phys_addr> - <end_phys_addr> (<size> kB), allocated by <PID> (<comm=
>)
>
> When CONFIG_CMA_ALLOC_STACKTRACE is configured then stack traces are save=
d when
> the allocations are made. The stack traces are added to cma/cma-<N>/buffe=
rs
> for each buffer list entry.
>
> Example:
>
> root@debian:/sys/kernel/debug/cma# cat cma-0/buffers
> 0x2f400000 - 0x2f417000 (92 kB), allocated by pid 1 (swapper/0)
>  [<c1142c4b>] cma_alloc+0x1bb/0x200
>  [<c143d28a>] dma_alloc_from_contiguous+0x3a/0x40
>  [<c10079d9>] dma_generic_alloc_coherent+0x89/0x160
>  [<c14456ce>] dmam_alloc_coherent+0xbe/0x100
>  [<c1487312>] ahci_port_start+0xe2/0x210
>  [<c146e0e0>] ata_host_start.part.28+0xc0/0x1a0
>  [<c1473650>] ata_host_activate+0xd0/0x110
>  [<c14881bf>] ahci_host_activate+0x3f/0x170
>  [<c14854e4>] ahci_init_one+0x764/0xab0
>  [<c12e415f>] pci_device_probe+0x6f/0xd0
>  [<c14378a8>] driver_probe_device+0x68/0x210
>  [<c1437b09>] __driver_attach+0x79/0x80
>  [<c1435eef>] bus_for_each_dev+0x4f/0x80
>  [<c143749e>] driver_attach+0x1e/0x20
>  [<c1437197>] bus_add_driver+0x157/0x200
>  [<c14381bd>] driver_register+0x5d/0xf0
> <...>
>
> Signed-off-by: Stefan Strogin <s.strogin@partner.samsung.com>


> --- a/mm/cma.h
> +++ b/mm/cma.h
> @@ -11,8 +13,32 @@ struct cma {
>  	struct hlist_head mem_head;
>  	spinlock_t mem_head_lock;
>  #endif
> +#ifdef CONFIG_CMA_BUFFER_LIST
> +	struct list_head buffer_list;
> +	struct mutex	list_lock;
> +#endif
>  };
>=20=20
> +#ifdef CONFIG_CMA_BUFFER_LIST
> +struct cma_buffer {
> +	unsigned long pfn;
> +	unsigned long count;
> +	pid_t pid;
> +	char comm[TASK_COMM_LEN];
> +#ifdef CONFIG_CMA_ALLOC_STACKTRACE
> +	unsigned long trace_entries[16];
> +	unsigned int nr_entries;
> +#endif
> +	struct list_head list;
> +};

This structure is only ever used in cma_debug.c so is there a reason
to define it in the header file?

> +
> +extern int cma_buffer_list_add(struct cma *cma, unsigned long pfn, int c=
ount);
> +extern void cma_buffer_list_del(struct cma *cma, unsigned long pfn, int =
count);
> +#else
> +#define cma_buffer_list_add(cma, pfn, count) { }
> +#define cma_buffer_list_del(cma, pfn, count) { }
> +#endif /* CONFIG_CMA_BUFFER_LIST */
> +
>  extern struct cma cma_areas[MAX_CMA_AREAS];
>  extern unsigned cma_area_count;


> +#ifdef CONFIG_CMA_BUFFER_LIST
> +static ssize_t cma_buffer_list_read(struct file *file, char __user *user=
buf,
> +				    size_t count, loff_t *ppos)
> +{
> +	struct cma *cma =3D file->private_data;
> +	struct cma_buffer *cmabuf;
> +	char *buf;
> +	int ret, n =3D 0;
> +#ifdef CONFIG_CMA_ALLOC_STACKTRACE
> +	struct stack_trace trace;
> +#endif
> +
> +	if (*ppos < 0 || !count)
> +		return -EINVAL;
> +
> +	buf =3D vmalloc(count);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	mutex_lock(&cma->list_lock);
> +	list_for_each_entry(cmabuf, &cma->buffer_list, list) {
> +		n +=3D snprintf(buf + n, count - n,
> +			      "0x%llx - 0x%llx (%lu kB), allocated by pid %u (%s)\n",
> +			      (unsigned long long)PFN_PHYS(cmabuf->pfn),
> +			      (unsigned long long)PFN_PHYS(cmabuf->pfn +
> +				      cmabuf->count),
> +			      (cmabuf->count * PAGE_SIZE) >> 10, cmabuf->pid,
> +			      cmabuf->comm);
> +
> +#ifdef CONFIG_CMA_ALLOC_STACKTRACE
> +		trace.nr_entries =3D cmabuf->nr_entries;
> +		trace.entries =3D &cmabuf->trace_entries[0];
> +		n +=3D snprint_stack_trace(buf + n, count - n, &trace, 0);
> +		n +=3D snprintf(buf + n, count - n, "\n");
> +#endif
> +	}
> +	mutex_unlock(&cma->list_lock);
> +
> +	ret =3D simple_read_from_buffer(userbuf, count, ppos, buf, n);
> +	vfree(buf);
> +
> +	return ret;
> +}

So in practice user space must allocate buffer big enough to read the
whole file into memory.  Calling read(2) with some count will never read
anything past the first count bytes of the file.

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
