Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4AF2C6B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 13:51:16 -0400 (EDT)
Received: by wibg7 with SMTP id g7so34194976wib.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 10:51:15 -0700 (PDT)
Received: from mail-we0-x230.google.com (mail-we0-x230.google.com. [2a00:1450:400c:c03::230])
        by mx.google.com with ESMTPS id hd7si19107444wib.85.2015.03.16.10.51.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 10:51:14 -0700 (PDT)
Received: by wegp1 with SMTP id p1so43925154weg.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 10:51:14 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v4 4/5] mm: cma: add list of currently allocated CMA buffers to debugfs
In-Reply-To: <857357c314922e0d6f1d963ab74e5e4de5635799.1426521377.git.s.strogin@partner.samsung.com>
References: <cover.1426521377.git.s.strogin@partner.samsung.com> <857357c314922e0d6f1d963ab74e5e4de5635799.1426521377.git.s.strogin@partner.samsung.com>
Date: Mon, 16 Mar 2015 18:51:10 +0100
Message-ID: <xa1tlhiwompd.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

On Mon, Mar 16 2015, Stefan Strogin wrote:
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
> Signed-off-by: Stefan Strogin <stefan.strogin@gmail.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> @@ -127,6 +240,93 @@ static int cma_alloc_write(void *data, u64 val)
>=20=20
>  DEFINE_SIMPLE_ATTRIBUTE(cma_alloc_fops, NULL, cma_alloc_write, "%llu\n");
>=20=20
> +#ifdef CONFIG_CMA_BUFFER_LIST
> +static void *s_start(struct seq_file *seq, loff_t *ppos)
> +{
> +	struct cma *cma =3D seq->private;
> +	struct cma_buffer *cmabuf;
> +	loff_t n =3D *ppos;
> +
> +	mutex_lock(&cma->list_lock);
> +	cmabuf =3D list_first_entry(&cma->buffer_list, typeof(*cmabuf), list);
> +	list_for_each_entry(cmabuf, &cma->buffer_list, list)
> +		if (n-- =3D=3D 0)
> +			return cmabuf;
> +
> +	return 0;

	return NULL;

> +}

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
