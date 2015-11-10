Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 08F7E6B0253
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 17:19:57 -0500 (EST)
Received: by qkao63 with SMTP id o63so5285184qka.2
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 14:19:56 -0800 (PST)
Received: from BLU004-OMC1S30.hotmail.com (blu004-omc1s30.hotmail.com. [65.55.116.41])
        by mx.google.com with ESMTPS id b63si4915688qgb.68.2015.11.10.14.19.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 10 Nov 2015 14:19:56 -0800 (PST)
Message-ID: <BLU436-SMTP1713224CA79B39CADC86406B9140@phx.gbl>
Date: Wed, 11 Nov 2015 06:22:25 +0800
From: Chen Gang <xili_gchen_5257@hotmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mmap.c: Remove redundant local variables for may_expand_vm()
References: <COL130-W65418E50E899195C9B2134B9150@phx.gbl> <20151110013945.GA24497@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20151110013945.GA24497@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "oleg@redhat.com" <oleg@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "dave@stgolabs.net" <dave@stgolabs.net>, "aarcange@redhat.com" <aarcange@redhat.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>


On 11/10/15 09:39=2C Naoya Horiguchi wrote:
> On Tue=2C Nov 10=2C 2015 at 05:41:08AM +0800=2C Chen Gang wrote:
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 2ce04a6..a515260 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -2988=2C12 +2988=2C7 @@ out:
>>   */
>>  int may_expand_vm(struct mm_struct *mm=2C unsigned long npages)
>=20
> marking inline?=20
>=20

For me=2C inline is OK. But I guess=2C it depends on the members tastes: "I=
t
is used at 5 areas within mm=2C inline will expand the binary size".

>>  {
>> -	unsigned long cur =3D mm->total_vm=3B	/* pages */
>> -	unsigned long lim=3B
>> -
>> -	lim =3D rlimit(RLIMIT_AS) >> PAGE_SHIFT=3B
>> -
>> -	if (cur + npages > lim)
>> +	if (mm->total_vm + npages > (rlimit(RLIMIT_AS) >> PAGE_SHIFT))
>>  		return 0=3B
>>  	return 1=3B
>=20
> How about doing simply
>=20
> 	return mm->total_vm + npages <=3D (rlimit(RLIMIT_AS) >> PAGE_SHIFT)=3B
>=20

For me=2C only one line is OK. But I guess=2C it also depends on the member=
s
tastes: does it let code a little complex?

If we can use bool instead of int for may_epand_mm() return value=2C I
guess=2C one line implementation (your idea) will be OK to all members.

> ? These changes save some bytes :)
>=20
>    text    data     bss     dec     hex filename=20
>   20566    2250      40   22856    5948 mm/mmap.o (before)
>=20
>    text    data     bss     dec     hex filename=20
>   20542    2250      40   22832    5930 mm/mmap.o (after)
>=20
> Thanks=2C
> Naoya Horiguchi
>=20

Thanks.
--=20
Chen Gang (=E9=99=88=E5=88=9A)

Open=2C share=2C and attitude like air=2C water=2C and life which God bless=
ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
