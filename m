Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 456766B0253
	for <linux-mm@kvack.org>; Sun, 15 Nov 2015 20:35:58 -0500 (EST)
Received: by padhx2 with SMTP id hx2so157327627pad.1
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 17:35:58 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id go9si46463731pac.50.2015.11.15.17.35.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Nov 2015 17:35:57 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so159224803pab.0
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 17:35:56 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH V4] mm: fix kernel crash in khugepaged thread
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151113090115.1ad4235b@gandalf.local.home>
Date: Mon, 16 Nov 2015 09:35:53 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <2F74FF6B-66DC-4BF9-972A-C2F5FFFA979F@gmail.com>
References: <1447316462-19645-1-git-send-email-yalin.wang2010@gmail.com> <20151112092923.19ee53dd@gandalf.local.home> <5645BFAA.1070004@suse.cz> <D7E480F5-D879-4016-B530-5A4D7CB05675@gmail.com> <20151113090115.1ad4235b@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, jmarchan@redhat.com, mgorman@techsingularity.net, willy@linux.intel.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


> On Nov 13, 2015, at 22:01, Steven Rostedt <rostedt@goodmis.org> wrote:
>=20
> On Fri, 13 Nov 2015 19:54:11 +0800
> yalin wang <yalin.wang2010@gmail.com> wrote:
>=20
>>>>> 	TP_fast_assign(
>>>>> 		__entry->mm =3D mm;
>>>>> -		__entry->pfn =3D pfn;
>>>>> +		__entry->pfn =3D page_to_pfn(page); =20
>>>>=20
>>>> Instead of the condition, we could have:
>>>>=20
>>>> 	__entry->pfn =3D page ? page_to_pfn(page) : -1; =20
>>>=20
>>> I agree. Please do it like this. =20
>=20
> hmm, pfn is defined as an unsigned long, would -1 be the best.
> Or should it be (-1UL).
>=20
> Then we could also have:
>=20
>        TP_printk("mm=3D%p, scan_pfn=3D0x%lx%s, writable=3D%d, =
referenced=3D%d, none_or_zero=3D%d, status=3D%s, unmapped=3D%d",
>                __entry->mm,
>                __entry->pfn =3D=3D (-1UL) ? 0 : __entry->pfn,
> 		__entry->pfn =3D=3D (-1UL) ? "(null)" : "",
>=20
> Note the added %s after %lx I have in the print format.
>=20
> -- Steve
it is not easy to print for perf tools in userspace ,
if you use this format ,
for user space perf tool, it print the entry by look up the member in =
entry struct by offset ,
you print a dynamic string which user space perf tool don=E2=80=99t know =
how to print this string .

Thanks=20=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
