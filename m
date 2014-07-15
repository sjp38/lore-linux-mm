Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id B77DB6B0038
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 16:10:02 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so4291615pdj.36
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 13:10:02 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id cm4si12524283pbb.201.2014.07.15.13.10.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jul 2014 13:10:00 -0700 (PDT)
Message-ID: <53C58A69.3070207@zytor.com>
Date: Tue, 15 Jul 2014 13:09:13 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/11] Support Write-Through mapping on x86
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, konrad.wilk@oracle.com, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de

On 07/15/2014 12:34 PM, Toshi Kani wrote:
> This RFC patchset is aimed to seek comments/suggestions for the design
> and changes to support of Write-Through (WT) mapping.  The study below
> shows that using WT mapping may be useful for non-volatile memory.
> 
>   http://www.hpl.hp.com/techreports/2012/HPL-2012-236.pdf
> 
> There were idea & patches to support WT in the past, which stimulated
> very valuable discussions on this topic.
> 
>   https://lkml.org/lkml/2013/4/24/424
>   https://lkml.org/lkml/2013/10/27/70
>   https://lkml.org/lkml/2013/11/3/72
> 
> This RFC patchset tries to address the issues raised by taking the
> following design approach:
> 
>  - Keep the MTRR interface
>  - Keep the WB, WC, and UC- slots in the PAT MSR
>  - Keep the PAT bit unused
>  - Reassign the UC slot to WT in the PAT MSR
> 
> There are 4 usable slots in the PAT MSR, which are currently assigned to:
> 
>   PA0/4: WB, PA1/5: WC, PA2/6: UC-, PA3/7: UC
> 
> The PAT bit is unused since it shares the same bit as the PSE bit and
> there was a bug in older processors.  Among the 4 slots, the uncached
> memory type consumes 2 slots, UC- and UC.  They are functionally
> equivalent, but UC- allows MTRRs to overwrite it with WC.  All interfaces
> that set the uncached memory type use UC- in order to work with MTRRs.
> The PA3/7 slot is effectively unused today.  Therefore, this patchset
> reassigns the PA3/7 slot to WT.  If MTRRs get deprecated in future,
> UC- can be reassigned to UC, and there is still no need to consume
> 2 slots for the uncached memory type.

Not going to happen any time in the forseeable future.

Furthermore, I don't think it is a big deal if on some old, buggy
processors we take the performance hit of cache type demotion, as long
as we don't actively lose data.

> This patchset is consist of two parts.  The 1st part, patch [1/11] to
> [6/11], enables WT mapping and adds new interfaces for setting WT mapping.
> The 2nd part, patch [7/11] to [11/11], cleans up the code that has
> internal knowledge of the PAT slot assignment.  This keeps the kernel
> code independent from the PAT slot assignment.

I have given this piece of feedback at least three times now, possibly
to different people, and I'm getting a bit grumpy about it:

We already have an issue with Xen, because Xen assigned mappings
differently and it is incompatible with the use of PAT in Linux.  As a
result we get requests for hacks to work around this, which is something
I really don't want to see.  I would like to see a design involving a
"reverse PAT" table where the kernel can hold the mapping between memory
types and page table encodings (including the two different ones for
small and large pages.)

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
