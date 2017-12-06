Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3BE6B0069
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 12:33:17 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c3so2537027wrd.0
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 09:33:17 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a2sor1109786wmg.6.2017.12.06.09.33.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Dec 2017 09:33:16 -0800 (PST)
Date: Wed, 6 Dec 2017 18:33:13 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: x86 TLB flushing: INVPCID vs. deferred CR3 write
Message-ID: <20171206173313.cnjuzn7p2wrmerui@gmail.com>
References: <3062e486-3539-8a1f-5724-16199420be71@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3062e486-3539-8a1f-5724-16199420be71@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "Kleen, Andi" <andi.kleen@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>


* Dave Hansen <dave.hansen@intel.com> wrote:

> tl;dr: Kernels with pagetable isolation using INVPCID compile kernels
> 0.58% faster than using the deferred CR3 write.  This tends to say that
> we should leave things as-is and keep using INVPCID, but it's far from
> definitive.

Agreed, thanks for the detailed testing!

> If folks have better ideas for a test methodology, or specific workloads or 
> hardware where you want to see this tested, please speak up.

I had a look at the numbers and it all looks valid and good to me too - it's also 
the intuitive result IMHO.

I suspect there might be synthetic cache-hot workloads where the +330 cycles cost 
of INVPCID is higher than that of the extra TLB miss costs of a CR3 flush - but we 
do know that this offset is constant, while the cost of flushing all TLBs ever 
increases with the future increases of the TLB cache.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
