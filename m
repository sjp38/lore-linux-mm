Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA336B0071
	for <linux-mm@kvack.org>; Fri, 26 Dec 2014 11:02:23 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id x12so14657175wgg.10
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 08:02:23 -0800 (PST)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id hm5si57076465wjc.56.2014.12.26.08.02.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Dec 2014 08:02:22 -0800 (PST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so17287792wib.16
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 08:02:22 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 2/3] mm: cma: introduce /proc/cmainfo
In-Reply-To: <264ce8ad192124f2afec9a71a2fc28779d453ba7.1419602920.git.s.strogin@partner.samsung.com>
References: <cover.1419602920.git.s.strogin@partner.samsung.com> <264ce8ad192124f2afec9a71a2fc28779d453ba7.1419602920.git.s.strogin@partner.samsung.com>
Date: Fri, 26 Dec 2014 17:02:18 +0100
Message-ID: <xa1tzjaaz9f9.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Stefan I. Strogin" <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>

On Fri, Dec 26 2014, "Stefan I. Strogin" <s.strogin@partner.samsung.com> wr=
ote:
> /proc/cmainfo contains a list of currently allocated CMA buffers for every
> CMA area when CONFIG_CMA_DEBUG is enabled.
>
> Format is:
>
> <base_phys_addr> - <end_phys_addr> (<size> kB), allocated by <PID>\
> 		(<command name>), latency <allocation latency> us
>  <stack backtrace when the buffer had been allocated>
>
> Signed-off-by: Stefan I. Strogin <s.strogin@partner.samsung.com>
> ---
>  mm/cma.c | 202 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  1 file changed, 202 insertions(+)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index a85ae28..ffaea26 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -34,6 +34,10 @@
>  #include <linux/cma.h>
>  #include <linux/highmem.h>
>  #include <linux/io.h>
> +#include <linux/list.h>
> +#include <linux/proc_fs.h>
> +#include <linux/uaccess.h>
> +#include <linux/time.h>
>=20=20
>  struct cma {
>  	unsigned long	base_pfn;
> @@ -41,8 +45,25 @@ struct cma {
>  	unsigned long	*bitmap;
>  	unsigned int order_per_bit; /* Order of pages represented by one bit */
>  	struct mutex	lock;
> +#ifdef CONFIG_CMA_DEBUG
> +	struct list_head buffers_list;
> +	struct mutex	list_lock;
> +#endif
>  };
>=20=20
> +#ifdef CONFIG_CMA_DEBUG
> +struct cma_buffer {
> +	unsigned long pfn;
> +	unsigned long count;
> +	pid_t pid;
> +	char comm[TASK_COMM_LEN];
> +	unsigned int latency;
> +	unsigned long trace_entries[16];
> +	unsigned int nr_entries;
> +	struct list_head list;
> +};
> +#endif
> +
>  static struct cma cma_areas[MAX_CMA_AREAS];
>  static unsigned cma_area_count;
>  static DEFINE_MUTEX(cma_mutex);
> @@ -132,6 +153,10 @@ static int __init cma_activate_area(struct cma *cma)
>  	} while (--i);
>=20=20
>  	mutex_init(&cma->lock);
> +#ifdef CONFIG_CMA_DEBUG
> +	INIT_LIST_HEAD(&cma->buffers_list);
> +	mutex_init(&cma->list_lock);
> +#endif
>  	return 0;
>=20=20
>  err:
> @@ -347,6 +372,86 @@ err:
>  	return ret;
>  }
>=20=20
> +#ifdef CONFIG_CMA_DEBUG
> +/**
> + * cma_buffer_list_add() - add a new entry to a list of allocated buffers
> + * @cma:     Contiguous memory region for which the allocation is perfor=
med.
> + * @pfn:     Base PFN of the allocated buffer.
> + * @count:   Number of allocated pages.
> + * @latency: Nanoseconds spent to allocate the buffer.
> + *
> + * This function adds a new entry to the list of allocated contiguous me=
mory
> + * buffers in a CMA area. It uses the CMA area specificated by the device
> + * if available or the default global one otherwise.
> + */
> +static int cma_buffer_list_add(struct cma *cma, unsigned long pfn,
> +			       int count, s64 latency)
> +{
> +	struct cma_buffer *cmabuf;
> +	struct stack_trace trace;
> +
> +	cmabuf =3D kmalloc(sizeof(struct cma_buffer), GFP_KERNEL);

	cmabuf =3D kmalloc(sizeof *cmabuf, GFP_KERNEL);

> +	if (!cmabuf)
> +		return -ENOMEM;
> +
> +	trace.nr_entries =3D 0;
> +	trace.max_entries =3D ARRAY_SIZE(cmabuf->trace_entries);
> +	trace.entries =3D &cmabuf->trace_entries[0];
> +	trace.skip =3D 2;
> +	save_stack_trace(&trace);
> +
> +	cmabuf->pfn =3D pfn;
> +	cmabuf->count =3D count;
> +	cmabuf->pid =3D task_pid_nr(current);
> +	cmabuf->nr_entries =3D trace.nr_entries;
> +	get_task_comm(cmabuf->comm, current);
> +	cmabuf->latency =3D (unsigned int) div_s64(latency, NSEC_PER_USEC);
> +
> +	mutex_lock(&cma->list_lock);
> +	list_add_tail(&cmabuf->list, &cma->buffers_list);
> +	mutex_unlock(&cma->list_lock);
> +
> +	return 0;
> +}
> +
> +/**
> + * cma_buffer_list_del() - delete an entry from a list of allocated buff=
ers
> + * @cma:   Contiguous memory region for which the allocation was perform=
ed.
> + * @pfn:   Base PFN of the released buffer.
> + *
> + * This function deletes a list entry added by cma_buffer_list_add().
> + */
> +static void cma_buffer_list_del(struct cma *cma, unsigned long pfn)
> +{
> +	struct cma_buffer *cmabuf;
> +
> +	mutex_lock(&cma->list_lock);
> +
> +	list_for_each_entry(cmabuf, &cma->buffers_list, list)
> +		if (cmabuf->pfn =3D=3D pfn) {
> +			list_del(&cmabuf->list);
> +			kfree(cmabuf);
> +			goto out;
> +		}

You do not have guarantee that CMA deallocations will match allocations
exactly.  User may allocate CMA region and then free it chunks.  I'm not
saying that the debug code must handle than case but at least I would
like to see a comment describing this shortcoming.

> +
> +	pr_err("%s(pfn %lu): couldn't find buffers list entry\n",
> +	       __func__, pfn);
> +
> +out:
> +	mutex_unlock(&cma->list_lock);
> +}
> +#else
> +static int cma_buffer_list_add(struct cma *cma, unsigned long pfn,
> +			       int count, s64 latency)
> +{
> +	return 0;
> +}
> +
> +static void cma_buffer_list_del(struct cma *cma, unsigned long pfn)
> +{
> +}
> +#endif /* CONFIG_CMA_DEBUG */
> +
>  /**
>   * cma_alloc() - allocate pages from contiguous area
>   * @cma:   Contiguous memory region for which the allocation is performe=
d.
> @@ -361,11 +466,15 @@ struct page *cma_alloc(struct cma *cma, int count, =
unsigned int align)
>  	unsigned long mask, offset, pfn, start =3D 0;
>  	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
>  	struct page *page =3D NULL;
> +	struct timespec ts1, ts2;
> +	s64 latency;
>  	int ret;
>=20=20
>  	if (!cma || !cma->count)
>  		return NULL;
>=20=20
> +	getnstimeofday(&ts1);
> +

If CMA_DEBUG is disabled, you waste time on measuring latency.  Either
use #ifdef or IS_ENABLED, e.g.:

	if (IS_ENABLED(CMA_DEBUG))
		getnstimeofday(&ts1);

>  	pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
>  		 count, align);
>=20=20
> @@ -413,6 +522,19 @@ struct page *cma_alloc(struct cma *cma, int count, u=
nsigned int align)
>  		start =3D bitmap_no + mask + 1;
>  	}
>=20=20
> +	getnstimeofday(&ts2);
> +	latency =3D timespec_to_ns(&ts2) - timespec_to_ns(&ts1);
> +
> +	if (page) {

	if (IS_ENABLED(CMA_DEBUG) && page) {
		getnstimeofday(&ts2);
		latency =3D timespec_to_ns(&ts2) - timespec_to_ns(&ts1);

> +		ret =3D cma_buffer_list_add(cma, pfn, count, latency);

You could also change cma_buffer_list_add to take ts1 as an argument
instead of latency and then latency calculating would be hidden inside
of that function.  Initialising ts1 should still be guarded with
IS_ENABLED of course.

> +		if (ret) {
> +			pr_warn("%s(): cma_buffer_list_add() returned %d\n",
> +				__func__, ret);
> +			cma_release(cma, page, count);
> +			page =3D NULL;

Harsh, but ok, if you want.

> +		}
> +	}
> +
>  	pr_debug("%s(): returned %p\n", __func__, page);
>  	return page;
>  }
> @@ -445,6 +567,86 @@ bool cma_release(struct cma *cma, struct page *pages=
, int count)
>=20=20
>  	free_contig_range(pfn, count);
>  	cma_clear_bitmap(cma, pfn, count);
> +	cma_buffer_list_del(cma, pfn);
>=20=20
>  	return true;
>  }
> +
> +#ifdef CONFIG_CMA_DEBUG
> +static void *s_start(struct seq_file *m, loff_t *pos)
> +{
> +	struct cma *cma =3D 0;
> +
> +	if (*pos =3D=3D 0 && cma_area_count > 0)
> +		cma =3D &cma_areas[0];
> +	else
> +		*pos =3D 0;
> +
> +	return cma;
> +}
> +
> +static int s_show(struct seq_file *m, void *p)
> +{
> +	struct cma *cma =3D p;
> +	struct cma_buffer *cmabuf;
> +	struct stack_trace trace;
> +
> +	mutex_lock(&cma->list_lock);
> +
> +	list_for_each_entry(cmabuf, &cma->buffers_list, list) {
> +		seq_printf(m, "0x%llx - 0x%llx (%lu kB), allocated by pid %u (%s), lat=
ency %u us\n",
> +			   (unsigned long long)PFN_PHYS(cmabuf->pfn),
> +			   (unsigned long long)PFN_PHYS(cmabuf->pfn +
> +							cmabuf->count),
> +			   (cmabuf->count * PAGE_SIZE) >> 10, cmabuf->pid,
> +			   cmabuf->comm, cmabuf->latency);
> +
> +		trace.nr_entries =3D cmabuf->nr_entries;
> +		trace.entries =3D &cmabuf->trace_entries[0];
> +
> +		seq_print_stack_trace(m, &trace, 0);
> +		seq_putc(m, '\n');
> +	}
> +
> +	mutex_unlock(&cma->list_lock);
> +	return 0;
> +}
> +
> +static void *s_next(struct seq_file *m, void *p, loff_t *pos)
> +{
> +	struct cma *cma =3D (struct cma *)p + 1;
> +
> +	return (cma < &cma_areas[cma_area_count]) ? cma : 0;
> +}
> +
> +static void s_stop(struct seq_file *m, void *p)
> +{
> +}
> +
> +static const struct seq_operations cmainfo_op =3D {
> +	.start =3D s_start,
> +	.show =3D s_show,
> +	.next =3D s_next,
> +	.stop =3D s_stop,
> +};
> +
> +static int cmainfo_open(struct inode *inode, struct file *file)
> +{
> +	return seq_open(file, &cmainfo_op);
> +}
> +
> +static const struct file_operations proc_cmainfo_operations =3D {
> +	.open =3D cmainfo_open,
> +	.read =3D seq_read,
> +	.llseek =3D seq_lseek,
> +	.release =3D seq_release_private,
> +};
> +
> +static int __init proc_cmainfo_init(void)
> +{
> +	proc_create("cmainfo", S_IRUSR, NULL, &proc_cmainfo_operations);
> +	return 0;
> +}
> +
> +module_init(proc_cmainfo_init);
> +#endif /* CONFIG_CMA_DEBUG */
> --=20
> 2.1.0
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
