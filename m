Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id EB9F86B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 15:53:52 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id e16so3186197lan.17
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:53:52 -0700 (PDT)
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
        by mx.google.com with ESMTPS id om4si16389674lbb.69.2014.07.15.12.53.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 12:53:51 -0700 (PDT)
Received: by mail-la0-f52.google.com with SMTP id e16so3151848lan.39
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:53:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 15 Jul 2014 12:53:30 -0700
Message-ID: <CALCETrVfqBpJaTJCnDH8pZf4-6x6oojv+8Vvm3XudJfhbstdOQ@mail.gmail.com>
Subject: Re: [RFC PATCH 0/11] Support Write-Through mapping on x86
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Dave Airlie <airlied@gmail.com>, Borislav Petkov <bp@alien8.de>

On Tue, Jul 15, 2014 at 12:34 PM, Toshi Kani <toshi.kani@hp.com> wrote:
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

Note that MTRRs are already partially deprecated: all drivers *should*
be using arch_phys_wc_add, not mtrr_add, and arch_phys_wc_add is a
no-op on systems with working PAT.

Unfortunately, I never finished excising mtrr_add.  Finishing the job
wouldn't be very hard.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
