Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 15EF96B05FE
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 12:41:59 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 191so8767134oii.4
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 09:41:59 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y23si7737055oia.336.2017.07.15.09.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 09:41:58 -0700 (PDT)
Received: from mail-ua0-f169.google.com (mail-ua0-f169.google.com [209.85.217.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 81DFC22D40
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 16:41:57 +0000 (UTC)
Received: by mail-ua0-f169.google.com with SMTP id z22so66317174uah.1
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 09:41:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170715155518.ok2q62efc2vurqk5@suse.de>
References: <20170711155312.637eyzpqeghcgqzp@suse.de> <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de> <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de> <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de> <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de> <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
 <20170715155518.ok2q62efc2vurqk5@suse.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Sat, 15 Jul 2017 09:41:35 -0700
Message-ID: <CALCETrWbvt2n2PLtsVM5RgCKz+RZ30STFS2xZ=dacPZRwokFHw@mail.gmail.com>
Subject: Re: Potential race in TLB flush batching?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Sat, Jul 15, 2017 at 8:55 AM, Mel Gorman <mgorman@suse.de> wrote:
> The patch looks fine to be but when writing the patch, I wondered why the
> original code disabled preemption before inc_mm_tlb_gen. I didn't spot
> the reason for it but given the importance of properly synchronising with
> switch_mm, I played it safe. However, this should be ok on top and
> maintain the existing sequences

LGTM.  You could also fold it into your patch or even put it before
your patch, too.

FWIW, I didn't have any real reason to inc_mm_tlb_gen() with
preemption disabled.  I think I did it because the code it replaced
was also called with preemption off.  That being said, it's
effectively a single instruction, so it barely matters latency-wise.
(Hmm.  Would there be a performance downside if a thread got preempted
between inc_mm_tlb_gen() and doing the flush?  It could arbitrarily
delay the IPIs, which would give a big window for something else to
flush and maybe make our IPIs unnecessary.  Whether that's a win or a
loss isn't so clear to me.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
