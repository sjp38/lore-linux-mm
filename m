Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3140A6B0035
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 13:48:27 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id l109so12870835yhq.19
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 10:48:26 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id s26si31464289yho.89.2013.12.05.10.48.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 10:48:26 -0800 (PST)
From: "Strashko, Grygorii" <grygorii.strashko@ti.com>
Subject: RE: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation
 apis
Date: Thu, 5 Dec 2013 18:48:21 +0000
Message-ID: <902E09E6452B0E43903E4F2D568737AB097B26B2@DNCE04.ent.ti.com>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
 <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com>
 <20131203232445.GX8277@htj.dyndns.org>
 <52A0AB34.2030703@ti.com>,<20131205165325.GA24062@mtj.dyndns.org>
In-Reply-To: <20131205165325.GA24062@mtj.dyndns.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Shilimkar, Santosh" <santosh.shilimkar@ti.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hi Tejun,=0A=
=0A=
>On Thu, Dec 05, 2013 at 06:35:00PM +0200, Grygorii Strashko wrote:=0A=
>> >> +#define memblock_virt_alloc_align(x, align) \=0A=
>> >> +  memblock_virt_alloc_try_nid(x, align, BOOTMEM_LOW_LIMIT, \=0A=
>> >> +                               BOOTMEM_ALLOC_ACCESSIBLE, MAX_NUMNODE=
S)=0A=
>> >=0A=
>> > Also, do we really need this align variant separate when the caller=0A=
>> > can simply specify 0 for the default?=0A=
>>=0A=
>> Unfortunately Yes.=0A=
>> We need it to keep compatibility with bootmem/nobootmem=0A=
>> which don't handle 0 as default align value.=0A=
>=0A=
>Hmm... why wouldn't just interpreting 0 to SMP_CACHE_BYTES in the=0A=
>memblock_virt*() function work?=0A=
>=0A=
=0A=
Problem is not with memblock_virt*(). The issue will happen in case if=0A=
memblock or nobootmem are disabled in below code (memblock_virt*() is disab=
led).=0A=
=0A=
+/* Fall back to all the existing bootmem APIs */=0A=
+#define memblock_virt_alloc(x) \=0A=
+       __alloc_bootmem(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)=0A=
=0A=
which will be transformed to =0A=
+/* Fall back to all the existing bootmem APIs */=0A=
+#define memblock_virt_alloc(x, align) \=0A=
+       __alloc_bootmem(x, align, BOOTMEM_LOW_LIMIT)=0A=
=0A=
and used as=0A=
=0A=
memblock_virt_alloc(size, 0);=0A=
=0A=
so, by default bootmem code will use 0 as default alignment and not SMP_CAC=
HE_BYTES=0A=
and that is wrong.=0A=
=0A=
Regards,=0A=
-grygorii=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
