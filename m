Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 674106B0035
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 10:54:53 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so1562669pab.29
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 07:54:53 -0700 (PDT)
Received: from BAY004-OMC4S6.hotmail.com (bay004-omc4s6.hotmail.com. [65.54.190.208])
        by mx.google.com with ESMTPS id by7si1119154pdb.216.2014.08.05.07.54.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Aug 2014 07:54:52 -0700 (PDT)
Message-ID: <BAY169-W348ADD9113F32C2B459631EFE30@phx.gbl>
From: Pintu Kumar <pintu.k@outlook.com>
Subject: RE: [linux-3.10.17] Could not allocate memory from free CMA areas
Date: Tue, 5 Aug 2014 20:24:50 +0530
In-Reply-To: <003201cfafb3$3fe43180$bfac9480$@lge.com>
References: 
 <54sabdnxop04vxd7ewndc0qf.1407077745645@email.android.com>,<003201cfafb3$3fe43180$bfac9480$@lge.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, PINTU KUMAR <pintu_agarwal@yahoo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "ritesh.list@gmail.com" <ritesh.list@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>
Cc: "pintu.k@samsung.com" <pintu.k@samsung.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "mina86@mina86.com" <mina86@mina86.com>, "ngupta@vflare.org" <ngupta@vflare.org>, "iqbalblr@gmail.com" <iqbalblr@gmail.com>, "rohit.kr@samsung.com" <rohit.kr@samsung.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>

Hello=2C=0A=
=0A=
> From: iamjoonsoo.kim@lge.com=0A=
> To: pintu_agarwal@yahoo.com=3B linux-mm@kvack.org=3B linux-arm-kernel@lis=
ts.infradead.org=3B linaro-mm-sig@lists.linaro.org=3B ritesh.list@gmail.com=
=0A=
> CC: pintu.k@outlook.com=3B pintu.k@samsung.com=3B vishu_1385@yahoo.com=3B=
 m.szyprowski@samsung.com=3B mina86@mina86.com=3B ngupta@vflare.org=3B iqba=
lblr@gmail.com=0A=
> Subject: RE: [linux-3.10.17] Could not allocate memory from free CMA area=
s=0A=
> Date: Mon=2C 4 Aug 2014 16:11:00 +0900=0A=
> =0A=
>> Dear Joonsoo=2C=0A=
>> =0A=
>> I tried your changes which are present at the below link. =0A=
>> https://github.com/JoonsooKim/linux/tree/cma-fix-up-v3.0-next-20140625=
=0A=
>> But unfortunately for me it did not help much. =0A=
>> After running various apps that uses ION nonmovable memory=2C it fails t=
o allocate memory after some time. When I see the pagetypeinfo shows lots o=
f CMA pages available and non-movable were very less and thus nonmovable al=
location were failing.=0A=
> =0A=
> Okay. CMA pages cannot be used for nonmovable memory=2C so it can fail in=
 above case.=0A=
> =0A=
>> However I noticed the failure was little delayed.=0A=
> =0A=
> It is good sign. I guess that there is movable/CMA ratio problem.=0A=
> My patchset uses free CMA pages in certain ratio to free movable page con=
sumption.=0A=
> If your system doesn't use movable page sufficiently=2C free CMA pages ca=
nnot=0A=
> be used fully. Could you test with following workaround?=0A=
> =0A=
> +       if (normal> cma) {=0A=
> +               zone->max_try_normal =3D pageblock_nr_pages=3B=0A=
> +               zone->max_try_cma =3D pageblock_nr_pages=3B=0A=
> +       } else {=0A=
> +               zone->max_try_normal =3D pageblock_nr_pages=3B=0A=
> +               zone->max_try_cma =3D pageblock_nr_pages=3B=0A=
> +       }=0A=
=0A=
I applied these changes but still the allocations are failing because there=
 are no non-movable memory left in the system.=0A=
With the changes I noticed that nr_cma_free sometimes becomes almost zero.=
=0A=
But in our case Display/Xorg needs to have atleast 8MB of CMA (contiguous) =
memory of order-8 and order-4 type.=0A=
CMA:56MB is shared across display=2Ccamera=2Cvideo etc.=0A=
=0A=
I think the previous changes are slightly better.=0A=
=0A=
My concern is that whether I am applying all you changes or missing some th=
ing.=0A=
I saw that your kernel version is based on next-20140625 but my kernel vers=
ion is 3.10.17.=0A=
And till now I applied only the below changes:=0A=
https://github.com/JoonsooKim/linux/commit/33a0416b3ac1cd7c88e6b35ee61b4a81=
a7a14afc =0A=
=0A=
But I haven't applied this:=0A=
https://github.com/JoonsooKim/linux/commit/166b4186d101b190cf50195d841e2189=
f2743649=0A=
(CMA: always treat free cma pages as non-free on watermark checking)=0A=
These changes have other dependencies which is not present in my kernel ver=
sion.=0A=
Like inclusion of ALLOC_FAIR and area->nr_cma_free.=0A=
Please let me know if these changes are also important for "aggressive allo=
c changes..."=0A=
=0A=
If possible please send me all the patches related to "aggressive cma.." so=
 that I can conclude on my experiment.=0A=
=0A=
Further I will share the experimental result from my side.=0A=
=0A=
=0A=
> =0A=
> Thanks.=0A=
> =0A=
 		 	   		  =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
