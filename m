Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id BA2456B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 21:07:28 -0500 (EST)
Received: by qcxr5 with SMTP id r5so16980577qcx.10
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 18:07:28 -0800 (PST)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id 197si5886850qhc.26.2015.02.27.18.07.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 18:07:27 -0800 (PST)
Received: by mail-qg0-f54.google.com with SMTP id h3so3284717qgf.13
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 18:07:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150227171811.c9f6d0ca.akpm@linux-foundation.org>
References: <1424821185-16956-1-git-send-email-dpetigara@broadcom.com>
 <20150227132443.e17d574d45451f10f413f065@linux-foundation.org>
 <54F10358.1050102@broadcom.com> <20150227155458.697b7701d0a67ff7b4f3d9cb@linux-foundation.org>
 <54F114D0.3060306@broadcom.com> <20150227171811.c9f6d0ca.akpm@linux-foundation.org>
From: Gregory Fong <gregory.0xf0@gmail.com>
Date: Fri, 27 Feb 2015 18:06:57 -0800
Message-ID: <CADtm3G5QdadzTcKOjDO1mgtjU_vfqtG6DucTJYdTtyQirLfXDg@mail.gmail.com>
Subject: Re: [PATCH v2] mm: cma: fix CMA aligned offset calculation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Danesh Petigara <dpetigara@broadcom.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Fri, Feb 27, 2015 at 5:18 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 27 Feb 2015 17:07:28 -0800 Danesh Petigara <dpetigara@broadcom.com> wrote:
>
>> On 2/27/2015 3:54 PM, Andrew Morton wrote:
>> > On Fri, 27 Feb 2015 15:52:56 -0800 Danesh Petigara <dpetigara@broadcom.com> wrote:
>> >
>> >> On 2/27/2015 1:24 PM, Andrew Morton wrote:
>> >>> On Tue, 24 Feb 2015 15:39:45 -0800 Danesh Petigara <dpetigara@broadcom.com> wrote:
>> >>>
>> >>>> The CMA aligned offset calculation is incorrect for
>> >>>> non-zero order_per_bit values.
>> >>>>
>> >>>> For example, if cma->order_per_bit=1, cma->base_pfn=
>> >>>> 0x2f800000 and align_order=12, the function returns
>> >>>> a value of 0x17c00 instead of 0x400.
>> >>>>
>> >>>> This patch fixes the CMA aligned offset calculation.
>> >>>
>> >>> When fixing a bug please always describe the end-user visible effects
>> >>> of that bug.
>> >>>
>> >>> Without that information others are unable to understand why you are
>> >>> recommending a -stable backport.
>> >>>
>> >>
>> >> Thank you for the feedback. I had no crash logs to show, nevertheless, I
>> >> agree that a sentence describing potential effects of the bug would've
>> >> helped.
>> >
>> > What was the reason for adding a cc:stable?
>> >
>>
>> It was added since the commit that introduced the incorrect logic
>> (b5be83e) was already picked up by v3.19.
>
> argh.
>
> afaict the bug will, under some conditions cause cma_alloc() to report
> that no suitable free area is available in the arena when in fact such
> regions *are* available.  So it's effectively a bogus ENOMEM.
>
> Correct?  If so, what are the conditions under which this will occur?

This is correct, and it can occur for any nonzero order_per_bit value.
The previous calculation was wrong and would return too-large values
for the offset, so that when cma_alloc looks for free pages in the
bitmap with the requested alignment > order_per_bit, it starts too far
into the bitmap and so CMA allocations will fail despite there
actually being plenty of free pages remaining.  It will also probably
have the wrong alignment.  With this change, we will get the correct
offset into the bitmap.

One affected user is powerpc KVM, which has kvm_cma->order_per_bit set
to KVM_CMA_CHUNK_ORDER - PAGE_SHIFT, or 18 - 12 = 6.

I actually had written the offset function this way originally, then
tried to make it more like cma_bitmap_aligned_mask(), but screwed up
the transformation and it really wasn't any easier to understand
anyway.  That was stupid, sorry about that. =(

Best regards,
Gregory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
