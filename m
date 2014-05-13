Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id E10246B0080
	for <linux-mm@kvack.org>; Tue, 13 May 2014 00:57:08 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id ma3so531032pbc.9
        for <linux-mm@kvack.org>; Mon, 12 May 2014 21:57:08 -0700 (PDT)
Received: from bay0-omc3-s28.bay0.hotmail.com (bay0-omc3-s28.bay0.hotmail.com. [65.54.190.166])
        by mx.google.com with ESMTP id sd8si12054735pac.119.2014.05.12.21.57.07
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 21:57:08 -0700 (PDT)
Message-ID: <BAY169-W1F113CF53FD2DD325B23BEF340@phx.gbl>
From: Pintu Kumar <pintu.k@outlook.com>
Subject: RE: Questions regarding DMA buffer sharing using IOMMU
Date: Tue, 13 May 2014 10:27:07 +0530
In-Reply-To: <5370F66F.7060204@codeaurora.org>
References: 
 <BAY169-W12541AD089785F8BFBD4E26EF350@phx.gbl>,<5218408.5YRJXjS4BX@wuerfel>
 <BAY169-W1156E6803829CAB545274BCEF350@phx.gbl>,<5370F66F.7060204@codeaurora.org>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>

Thanks Lauraa for your answers.=0A=
I have few more queries below.=A0=0A=
=0A=
----------------------------------------=0A=
> Date: Mon=2C 12 May 2014 09:27:27 -0700=0A=
> From: lauraa@codeaurora.org=0A=
> To: pintu.k@outlook.com=3B arnd@arndb.de=3B linux-arm-kernel@lists.infrad=
ead.org=0A=
> CC: linux-mm@kvack.org=3B linux-kernel@vger.kernel.org=3B linaro-mm-sig@l=
ists.linaro.org=0A=
> Subject: Re: Questions regarding DMA buffer sharing using IOMMU=0A=
>=0A=
> On 5/12/2014 7:37 AM=2C Pintu Kumar wrote:=0A=
>> Hi=2C=0A=
>> Thanks for the reply.=0A=
>>=0A=
>> ----------------------------------------=0A=
>>> From: arnd@arndb.de=0A=
>>> To: linux-arm-kernel@lists.infradead.org=0A=
>>> CC: pintu.k@outlook.com=3B linux-mm@kvack.org=3B linux-kernel@vger.kern=
el.org=3B linaro-mm-sig@lists.linaro.org=0A=
>>> Subject: Re: Questions regarding DMA buffer sharing using IOMMU=0A=
>>> Date: Mon=2C 12 May 2014 14:00:57 +0200=0A=
>>>=0A=
>>> On Monday 12 May 2014 15:12:41 Pintu Kumar wrote:=0A=
>>>> Hi=2C=0A=
>>>> I have some queries regarding IOMMU and CMA buffer sharing.=0A=
>>>> We have an embedded linux device (kernel 3.10=2C RAM: 256Mb) in=0A=
>>>> which camera and codec supports IOMMU but the display does not support=
 IOMMU.=0A=
>>>> Thus for camera capture we are using iommu buffers using=0A=
>>>> ION/DMABUF. But for all display rendering we are using CMA buffers.=0A=
>>>> So=2C the question is how to achieve buffer sharing (zero-copy)=0A=
>>>> between Camera and Display using only IOMMU?=0A=
>>>> Currently we are achieving zero-copy using CMA. And we are=0A=
>>>> exploring options to use IOMMU.=0A=
>>>> Now we wanted to know which option is better? To use IOMMU or CMA?=0A=
>>>> If anybody have come across these design please share your thoughts an=
d results.=0A=
>>>=0A=
>>> There is a slight performance overhead in using the IOMMU in general=2C=
=0A=
>>> because the IOMMU has to fetch the page table entries from memory=0A=
>>> at least some of the time.=0A=
>>=0A=
>> Ok=2C we need to check performance later=0A=
>>=0A=
>>>=0A=
>>> If that overhead is within the constraints you have for transfers betwe=
en=0A=
>>> camera and codec=2C you are always better off using IOMMU since that=0A=
>>> means you don't have to do memory migration.=0A=
>>=0A=
>> Transfer between camera is codec is fine. But our major concern is singl=
e buffer=0A=
>> sharing between camera & display. Here camera supports iommu but display=
 does not support iommu.=0A=
>> Is it possible to render camera preview (iommu buffers) on display (not =
iommu and required physical contiguous overlay memory)?=0A=
>>=0A=
>=0A=
> I'm pretty sure the answer is no for zero copy IOMMU buffers if one of yo=
ur=0A=
> devices does not support IOMMU. If the data is coming in as individual pa=
ges=0A=
> and the hardware does not support scattered pages there isn't much you ca=
n=0A=
> do except copy to a contiguous buffer. At least with Ion=2C the heap type=
s can=0A=
> be set up in a particular way such that the client need never know about =
the=0A=
> existence of an IOMMU or not.=0A=
=0A=
So=2C the zero copy cannot be achieved between iommu and non-iommu devices?=
=0A=
Do you have any references like in case of QC MSM8974/etc=2C how this is ac=
hieved?=0A=
=0A=
Yes=2C we are using ION=2C with SYSTEM_HEAP=2C for IOMMU=2C in case of came=
ra=2C but still we could not=A0=0A=
render the preview on display.=0A=
You mean to say=2C with ION it is possible to do buffer sharing(a.k.a zero =
copy) =A0using the IOMMU heap?=0A=
=0A=
=0A=
>=0A=
>> Also is it possible to buffer sharing between 2 iommu supported devices?=
=0A=
>>=0A=
>=0A=
> I don't see why not but there isn't a lot of information to go on here.=
=0A=
=0A=
Is this also possible with ION?=0A=
Can you point out some use cases?=0A=
Like in our cases camera=2C codec and GPU have IOMMU. Is it possible to do =
zero copy here?=0A=
=0A=
=0A=
>=0A=
> Thanks=2C=0A=
> Laura=0A=
>=0A=
> --=0A=
> Qualcomm Innovation Center=2C Inc. is a member of Code Aurora Forum=2C=0A=
> hosted by The Linux Foundation=0A=
 		 	   		  =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
