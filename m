Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E4A466B029C
	for <linux-mm@kvack.org>; Wed,  5 May 2010 21:24:07 -0400 (EDT)
Received: by vws3 with SMTP id 3so1636997vws.14
        for <linux-mm@kvack.org>; Wed, 05 May 2010 18:24:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BE14335.10702@ru.mvista.com>
References: <k2ncecb6d8f1004191627w3cd36450xf797f746460abb09@mail.gmail.com>
	 <20100420155122.6f2c26eb.akpm@linux-foundation.org>
	 <20100420230719.GB1432@n2100.arm.linux.org.uk>
	 <4BE14335.10702@ru.mvista.com>
Date: Thu, 6 May 2010 10:24:06 +0900
Message-ID: <p2g9c9fda241005051824k54e70136v8324d135b44c71b5@mail.gmail.com>
Subject: Re: Suspicious compilation warning
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Sergei Shtylyov <sshtylyov@mvista.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Stephen Rothwell <sfr@canb.auug.org.au>, Marcelo Jimenez <mroberto@cpti.cetuc.puc-rio.br>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, May 5, 2010 at 7:06 PM, Sergei Shtylyov <sshtylyov@mvista.com> wrot=
e:
> Hello.
>
> Russell King - ARM Linux wrote:
>
>>>> I get this warning while compiling for ARM/SA1100:
>>>>
>>>> mm/sparse.c: In function '__section_nr':
>>>> mm/sparse.c:135: warning: 'root' is used uninitialized in this functio=
n
>>>>
>>>> With a small patch in fs/proc/meminfo.c, I find that NR_SECTION_ROOTS
>>>> is zero, which certainly explains the warning.
>>>>
>>>> # cat /proc/meminfo
>>>> NR_SECTION_ROOTS=3D0
>>>> NR_MEM_SECTIONS=3D32
>>>> SECTIONS_PER_ROOT=3D512
>>>> SECTIONS_SHIFT=3D5
>>>> MAX_PHYSMEM_BITS=3D32
>>>>
>>>
>>> hm, who owns sparsemem nowadays? Nobody identifiable.
>>>
>>> Does it make physical sense to have SECTIONS_PER_ROOT > NR_MEM_SECTIONS=
?
>>>
>>
>> Well, it'll be about this number on everything using sparsemem extreme:
>>
>> #define SECTIONS_PER_ROOT =A0 =A0 =A0 (PAGE_SIZE / sizeof (struct mem_se=
ction))
>>
>> and with only 32 sections, this is going to give a NR_SECTION_ROOTS valu=
e
>> of zero. =A0I think the calculation of NR_SECTIONS_ROOTS is wrong.
>>
>> #define NR_SECTION_ROOTS =A0 =A0 =A0 =A0(NR_MEM_SECTIONS / SECTIONS_PER_=
ROOT)
>>
>> Clearly if we have 1 mem section, we want to have one section root, so
>> I think this division should round up any fractional part, thusly:
>>
>> #define NR_SECTION_ROOTS =A0 =A0 =A0 =A0((NR_MEM_SECTIONS + SECTIONS_PER=
_ROOT - 1)
>> / SECTIONS_PER_ROOT)
>>
>
> =A0There's DIV_ROUND_UP() macro for this kind of calculation.

Hi,

It tested with my board and working.
Just curious. If NR_SECTION_ROOTS is zero and uninitialized then
what's problem? Since we boot and working without patch.

Thank you,
Kyungmin Park

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
