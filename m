Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 058CE6B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 09:20:14 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id t196so138617710lff.3
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 06:20:13 -0800 (PST)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id o203si31047525lfo.109.2016.12.29.06.20.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Dec 2016 06:20:12 -0800 (PST)
Received: by mail-lf0-x22e.google.com with SMTP id t196so222151310lff.3
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 06:20:12 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: cma: print allocation failure reason and bitmap status
In-Reply-To: <20161229091449.GG29208@dhcp22.suse.cz>
References: <CGME20161229022722epcas5p4be0e1924f3c8d906cbfb461cab8f0374@epcas5p4.samsung.com> <1482978482-14007-1-git-send-email-jaewon31.kim@samsung.com> <20161229091449.GG29208@dhcp22.suse.cz>
Date: Thu, 29 Dec 2016 15:20:07 +0100
Message-ID: <xa1th95m7r6w.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, m.szyprowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On Thu, Dec 29 2016, Michal Hocko wrote:
> On Thu 29-12-16 11:28:02, Jaewon Kim wrote:
>> There are many reasons of CMA allocation failure such as EBUSY, ENOMEM, =
EINTR.
>> This patch prints the error value and bitmap status to know available pa=
ges
>> regarding fragmentation.
>>=20
>> This is an ENOMEM example with this patch.
>> [   11.616321]  [2:   Binder:711_1:  740] cma: cma_alloc: alloc failed, =
req-size: 256 pages, ret: -12
>
>> [   11.616365]  [2:   Binder:711_1:  740] number of available pages: 4+7=
+7+8+38+166+127=3D>357 pages, total: 2048 pages
>
> Could you be more specific why this part is useful?
>=20=20
>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>> ---
>>  mm/cma.c | 29 ++++++++++++++++++++++++++++-
>>  1 file changed, 28 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/mm/cma.c b/mm/cma.c
>> index c960459..535aa39 100644
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -369,7 +369,7 @@ struct page *cma_alloc(struct cma *cma, size_t count=
, unsigned int align)
>>  	unsigned long start =3D 0;
>>  	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
>>  	struct page *page =3D NULL;
>> -	int ret;
>> +	int ret =3D -ENOMEM;
>>=20=20
>>  	if (!cma || !cma->count)
>>  		return NULL;
>> @@ -427,6 +427,33 @@ struct page *cma_alloc(struct cma *cma, size_t coun=
t, unsigned int align)
>>  	trace_cma_alloc(pfn, page, count, align);
>>=20=20
>>  	pr_debug("%s(): returned %p\n", __func__, page);
>> +
>> +	if (ret !=3D 0) {
>> +		unsigned int nr, nr_total =3D 0;
>> +		unsigned long next_set_bit;
>> +
>> +		pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
>> +			__func__, count, ret);
>> +		mutex_lock(&cma->lock);
>> +		printk("number of available pages: ");
>> +		start =3D 0;
>> +		for (;;) {
>> +			bitmap_no =3D find_next_zero_bit(cma->bitmap, cma->count, start);
>> +			next_set_bit =3D find_next_bit(cma->bitmap, cma->count, bitmap_no);
>> +			nr =3D next_set_bit - bitmap_no;
>> +			if (bitmap_no >=3D cma->count)
>> +				break;

Put this just next to =E2=80=98bitmap_no =3D =E2=80=A6=E2=80=99 line.  No n=
eed to call
find_next_bit if we=E2=80=99re gonna break anyway.

>> +			if (nr_total =3D=3D 0)
>> +				printk("%u", nr);
>> +			else
>> +				printk("+%u", nr);

Perhaps also include location of the hole?  Something like:

		pr_cont("%s%u@%u", nr_total ? "+" : "", nr, bitmap_no);

>> +			nr_total +=3D nr;
>> +			start =3D bitmap_no + nr;
>> +		}
>> +		printk("=3D>%u pages, total: %lu pages\n", nr_total, cma->count);
>> +		mutex_unlock(&cma->lock);
>> +	}
>> +

I wonder if this should be wrapped in

#ifdef CMA_DEBUG
=E2=80=A6
#endif

On one hand it=E2=80=99s relatively expensive (even involving mutex locking=
) on
the other it=E2=80=99s in allocation failure path.

>>  	return page;
>>  }
>>=20=20
>> --=20
>> 1.9.1
>>=20
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
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
