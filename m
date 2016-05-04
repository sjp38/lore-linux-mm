Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2ECB16B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 10:01:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b203so105347672pfb.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 07:01:59 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id j2si5135626pat.172.2016.05.04.07.01.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 07:01:58 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: kmap_atomic and preemption
Date: Wed, 4 May 2016 14:01:52 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075F4EA0647@us01wembx1.internal.synopsys.com>
References: <5729D0F4.9090907@synopsys.com>
 <20160504134729.GP3430@twins.programming.kicks-ass.net>
 <20160504155345.5fdd366e@free-electrons.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <dahi@linux.vnet.ibm.com>, Russell King <linux@arm.linux.org.uk>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Wednesday 04 May 2016 07:23 PM, Thomas Petazzoni wrote:=0A=
> Hello,=0A=
>=0A=
> On Wed, 4 May 2016 15:47:29 +0200, Peter Zijlstra wrote:=0A=
>=0A=
>> static inline void *kmap_atomic(struct page *page)=0A=
>> {=0A=
>> 	preempt_disable();=0A=
>> 	pagefault_disable();=0A=
>> 	if (!PageHighMem(page))=0A=
>> 		return page_address(page);=0A=
>>=0A=
>> 	return __kmap_atomic(page);=0A=
>> }=0A=
> This is essentially what has been done on ARM in commit=0A=
> 9ff0bb5ba60638a688a46e93df8c5009896672eb, showing a pretty significant=0A=
> improvement in network workloads.=0A=
=0A=
ARC already has that semantically - only not inline ! I really want to avoi=
d 2=0A=
needless LD-ADD-ST for the disabling of preemption and page fault for the l=
ow mem=0A=
pages by returning early !=0A=
=0A=
static inline void *kmap_atomic(struct page *page)=0A=
{=0A=
        if (!PageHighMem(page))=0A=
		return page_address(page);=0A=
=0A=
	preempt_disable();=0A=
	pagefault_disable();=0A=
	=0A=
	return __kmap_atomic(page);=0A=
=0A=
}=0A=
=0A=
>=0A=
> Best regards,=0A=
>=0A=
> Thomas=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
