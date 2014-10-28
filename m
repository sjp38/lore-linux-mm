Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id A6DB4900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 08:38:26 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id f15so546272lbj.37
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 05:38:25 -0700 (PDT)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com. [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id xu5si2337278lab.64.2014.10.28.05.38.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 05:38:24 -0700 (PDT)
Received: by mail-la0-f45.google.com with SMTP id gm9so516303lab.4
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 05:38:24 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: CMA: test_pages_isolated failures in alloc_contig_range
In-Reply-To: <2457604.k03RC2Mv4q@avalon>
References: <2457604.k03RC2Mv4q@avalon>
Date: Tue, 28 Oct 2014 13:38:20 +0100
Message-ID: <xa1tsii8l683.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-sh@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Minchan Kim <minchan@kernel.org>

On Sun, Oct 26 2014, Laurent Pinchart <laurent.pinchart@ideasonboard.com> w=
rote:
> Hello,
>
> I've run into a CMA-related issue while testing a DMA engine driver with=
=20
> dmatest on a Renesas R-Car ARM platform.=20
>
> When allocating contiguous memory through CMA the kernel prints the follo=
wing=20
> messages to the kernel log.
>
> [   99.770000] alloc_contig_range test_pages_isolated(6b843, 6b844) failed
> [  124.220000] alloc_contig_range test_pages_isolated(6b843, 6b844) failed
> [  127.550000] alloc_contig_range test_pages_isolated(6b845, 6b846) failed
> [  132.850000] alloc_contig_range test_pages_isolated(6b845, 6b846) failed
> [  151.390000] alloc_contig_range test_pages_isolated(6b843, 6b844) failed
> [  166.490000] alloc_contig_range test_pages_isolated(6b843, 6b844) failed
> [  181.450000] alloc_contig_range test_pages_isolated(6b845, 6b846) failed
>
> I've stripped the dmatest module down as much as possible to remove any=20
> hardware dependencies and came up with the following implementation.

Like Laura wrote, the message is not (should not be) a problem in
itself:

mm/page_alloc.c:

int alloc_contig_range(unsigned long start, unsigned long end,
		       unsigned migratetype)
{
	[=E2=80=A6]
	/* Make sure the range is really isolated. */
	if (test_pages_isolated(outer_start, end, false)) {
		pr_warn("alloc_contig_range test_pages_isolated(%lx, %lx) failed\n",
		       outer_start, end);
		ret =3D -EBUSY;
		goto done;
	}
	[=E2=80=A6]
done:
	undo_isolate_page_range(pfn_max_align_down(start),
				pfn_max_align_up(end), migratetype);
	return ret;
}

mm/cma.c:

struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
{
	[=E2=80=A6]
	for (;;) {
		bitmap_no =3D bitmap_find_next_zero_area(cma->bitmap,
				bitmap_maxno, start, bitmap_count, mask);
		if (bitmap_no >=3D bitmap_maxno)
			break;
		bitmap_set(cma->bitmap, bitmap_no, bitmap_count);

		pfn =3D cma->base_pfn + (bitmap_no << cma->order_per_bit);
		ret =3D alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
		if (ret =3D=3D 0) {
			page =3D pfn_to_page(pfn);
			break;
		}

		cma_clear_bitmap(cma, pfn, count);
		if (ret !=3D -EBUSY)
			break;

		pr_debug("%s(): memory range at %p is busy, retrying\n",
			 __func__, pfn_to_page(pfn));
		/* try again with a bit different memory target */
		start =3D bitmap_no + mask + 1;
	}
	[=E2=80=A6]
}

So as you can see cma_alloc will try another part of the cma region if
test_pages_isolated fails.

Obviously, if CMA region is fragmented or there's enough space for only
one allocation of required size isolation failures will cause allocation
failures, so it's best to avoid them, but they are not always avoidable.

To debug you would probably want to add more debug information about the
page (i.e. data from struct page) that failed isolation after the
pr_warn in alloc_contig_range.

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
