Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B7BB46B0069
	for <linux-mm@kvack.org>; Sun,  1 Jan 2017 16:59:47 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id l68so164854975lfb.1
        for <linux-mm@kvack.org>; Sun, 01 Jan 2017 13:59:47 -0800 (PST)
Received: from mail-lf0-x22a.google.com (mail-lf0-x22a.google.com. [2a00:1450:4010:c07::22a])
        by mx.google.com with ESMTPS id t1si31850910lja.90.2017.01.01.13.59.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jan 2017 13:59:46 -0800 (PST)
Received: by mail-lf0-x22a.google.com with SMTP id y21so262529247lfa.1
        for <linux-mm@kvack.org>; Sun, 01 Jan 2017 13:59:45 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: cma: print allocation failure reason and bitmap status
In-Reply-To: <20161230094411.GD13301@dhcp22.suse.cz>
References: <CGME20161229022722epcas5p4be0e1924f3c8d906cbfb461cab8f0374@epcas5p4.samsung.com> <1482978482-14007-1-git-send-email-jaewon31.kim@samsung.com> <20161229091449.GG29208@dhcp22.suse.cz> <xa1th95m7r6w.fsf@mina86.com> <58660BBE.1040807@samsung.com> <20161230094411.GD13301@dhcp22.suse.cz>
Date: Sun, 01 Jan 2017 22:59:40 +0100
Message-ID: <xa1tpok6igqb.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, m.szyprowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On Fri, Dec 30 2016, Michal Hocko wrote:
> On Fri 30-12-16 16:24:46, Jaewon Kim wrote:
> [...]
>> >From 7577cc94da3af27907aa6eec590d2ef51e4b9d80 Mon Sep 17 00:00:00 2001
>> From: Jaewon Kim <jaewon31.kim@samsung.com>
>> Date: Thu, 29 Dec 2016 11:00:16 +0900
>> Subject: [PATCH] mm: cma: print allocation failure reason and bitmap sta=
tus
>>=20
>> There are many reasons of CMA allocation failure such as EBUSY, ENOMEM, =
EINTR.
>> But we did not know error reason so far. This patch prints the error val=
ue.
>>=20
>> Additionally if CONFIG_CMA_DEBUG is enabled, this patch shows bitmap sta=
tus to
>> know available pages. Actually CMA internally try all available regions =
because
>> some regions can be failed because of EBUSY. Bitmap status is useful to =
know in
>> detail on both ENONEM and EBUSY;
>>  ENOMEM: not tried at all because of no available region
>>          it could be too small total region or could be fragmentation is=
sue
>>  EBUSY:  tried some region but all failed
>>=20
>> This is an ENOMEM example with this patch.
>> [   13.250961]  [1:   Binder:715_1:  846] cma: cma_alloc: alloc failed, =
req-size: 256 pages, ret: -12
>> Avabile pages also will be shown if CONFIG_CMA_DEBUG is enabled
>> [   13.251052]  [1:   Binder:715_1:  846] cma: number of available pages=
: 4@572+7@585+7@601+8@632+38@730+166@1114+127@1921=3D>357 pages, total: 204=
8 pages
>
> please mention how to interpret this information.
>
> some more style suggestions below
>>=20
>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

>> ---
>>  mm/cma.c | 29 ++++++++++++++++++++++++++++-
>>  1 file changed, 28 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/mm/cma.c b/mm/cma.c
>> index c960459..1bcd9db 100644
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -369,7 +369,7 @@ struct page *cma_alloc(struct cma *cma, size_t count=
, unsigned int align)
>>      unsigned long start =3D 0;
>>      unsigned long bitmap_maxno, bitmap_no, bitmap_count;
>>      struct page *page =3D NULL;
>> -    int ret;
>> +    int ret =3D -ENOMEM;
>>=20=20
>>      if (!cma || !cma->count)
>>          return NULL;
>> @@ -427,6 +427,33 @@ struct page *cma_alloc(struct cma *cma, size_t coun=
t, unsigned int align)
>>      trace_cma_alloc(pfn, page, count, align);
>>=20=20
>>      pr_debug("%s(): returned %p\n", __func__, page);

This line should be moved after the =E2=80=98if (ret !=3D 0)=E2=80=99 block=
, i.e. just
before return.

>> +
>> +    if (ret !=3D 0)
>
> you can simply do
> 	if (!ret) {
>
> 		pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
> 			__func__, count, ret);
> 		debug_show_cma_areas();
> 	}
>
> 	return page;
>
> static void debug_show_cma_areas(void)
> {
> #ifdef CONFIG_CMA_DEBUG
> 	unsigned int nr, nr_total =3D 0;
> 	unsigned long next_set_bit;
>
> 	mutex_lock(&cma->lock);
> 	pr_info("number of available pages: ");
> 	start =3D 0;
> 	for (;;) {
> 		bitmap_no =3D find_next_zero_bit(cma->bitmap, cma->count, start);
> 		if (bitmap_no >=3D cma->count)
> 		break;
> 		next_set_bit =3D find_next_bit(cma->bitmap, cma->count, bitmap_no);
> 		nr =3D next_set_bit - bitmap_no;
> 		pr_cont("%s%u@%lu", nr_total ? "+" : "", nr, bitmap_no);
> 		nr_total +=3D nr;
> 		start =3D bitmap_no + nr;
> 	}
> 	pr_cont("=3D>%u pages, total: %lu pages\n", nr_total, cma->count);

Perhaps:
	pr_cont("=3D> %u free of %lu total pages\n", nr_total, cma->count);
or shorter (but more cryptic):
	pr_cont("=3D> %u/%lu pages\n", nr_total, cma->count);

> 	mutex_unlock(&cma->lock);
> #endif
> }

Actually, Linux style is more like:

#ifdef CONFIG_CMA_DEBUG
static void cma_debug_show_areas()
{
	=E2=80=A6
}
#else
static inline void cma_debug_show_areas() { }
#endif

>
> --=20
> Michal Hocko
> SUSE Labs

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
