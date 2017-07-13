Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11544440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 12:08:45 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id n2so4489056oig.12
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 09:08:45 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v8si4274294oie.78.2017.07.13.09.08.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 09:08:44 -0700 (PDT)
Received: from mail-vk0-f46.google.com (mail-vk0-f46.google.com [209.85.213.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 599B322C97
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 16:08:43 +0000 (UTC)
Received: by mail-vk0-f46.google.com with SMTP id r126so32727157vkg.0
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 09:08:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170713060706.o2cuko5y6irxwnww@suse.de>
References: <20170711132023.wdfpjxwtbqpi3wp2@suse.de> <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de> <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de> <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de> <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de> <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 13 Jul 2017 09:08:21 -0700
Message-ID: <CALCETrWF7hxR7rFCUwi5FZWPt_NUy2U5dV+zy6HUm_x+0jdomA@mail.gmail.com>
Subject: Re: Potential race in TLB flush batching?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Wed, Jul 12, 2017 at 11:07 PM, Mel Gorman <mgorman@suse.de> wrote:
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -455,6 +455,39 @@ void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
>         put_cpu();
>  }
>
> +/*
> + * Ensure that any arch_tlbbatch_add_mm calls on this mm are up to date when

s/are up to date/have flushed the TLBs/ perhaps?


Can you update this comment in arch/x86/include/asm/tlbflush.h:

         * - Fully flush a single mm.  .mm will be set, .end will be
         *   TLB_FLUSH_ALL, and .new_tlb_gen will be the tlb_gen to
         *   which the IPI sender is trying to catch us up.

by adding something like: This can also happen due to
arch_tlbflush_flush_one_mm(), in which case it's quite likely that
most or all CPUs are already up to date.

Thanks,
Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
