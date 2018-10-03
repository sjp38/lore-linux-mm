Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA9E76B0269
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 17:22:57 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id 199-v6so4349554wmv.6
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 14:22:57 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id t83-v6si2241646wmb.158.2018.10.03.14.22.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 14:22:56 -0700 (PDT)
Date: Wed, 3 Oct 2018 23:22:55 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: x86/mm: Found insecure W+X mapping at address (ptrval)/0xc00a0000
Message-ID: <20181003212255.GB28361@zn.tnic>
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de>
 <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de>
 <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de>
 <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
 <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de>
 <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Paul Menzel <pmenzel@molgen.mpg.de>, linux-mm@kvack.org, x86@kernel.org, lkml <linux-kernel@vger.kernel.org>

On Fri, Sep 28, 2018 at 04:55:19PM +0200, Thomas Gleixner wrote:
> Sorry for the delay and thanks for the data. A quick diff did not reveal
> anything obvious. I'll have a closer look and we probably need more (other)
> information to nail that down.

Just a brain dump of what I've found out so far.

Commenting out the init_mem_mapping() call below:

void __init init_mem_mapping(void)
{
        unsigned long end;

	...

        /* the ISA range is always mapped regardless of memory holes */
//      init_memory_mapping(0, ISA_END_ADDRESS);

changes the address the warning reports to:

[    4.392870] x86/mm: Found insecure W+X mapping at address 0xc0000000/0xc0000000

but the machine boots fine otherwise.

Which begs the question: why do we direct-map the ISA range at
PAGE_OFFSET at all? Do we have to have virtual mappings of it at all? I
thought ISA devices don't need that but this is long before my time...

Then, the warning say too:

[    4.399804] x86/mm: Checked W+X mappings: FAILED, 252 W+X pages found.

and there really are 252 pages  (I counted) which are W+X:

---[ Kernel Mapping ]---
0xc0000000-0xc0001000           4K     RW                     x  pte
0xc0001000-0xc0099000         608K     RW                     x  pte
0xc0099000-0xc009a000           4K     ro                     NX pte
0xc009a000-0xc009b000           4K     ro                     x  pte
0xc009b000-0xc009d000           8K     RW                     NX pte
0xc009d000-0xc00a0000          12K     RW                     x  pte
0xc00a0000-0xc00a2000           8K     RW                     x  pte
0xc00a2000-0xc00b8000          88K     RW                     x  pte
0xc00b8000-0xc00c0000          32K     RW                     x  pte
0xc00c0000-0xc00f3000         204K     RW                     x  pte
0xc00f3000-0xc00fc000          36K     RW                     x  pte
0xc00fc000-0xc00fd000           4K     RW                     x  pte
0xc00fd000-0xc0100000          12K     RW                     x  pte
...

but I can't find where those guys appear from. Will be adding more debug
printks to track it down.

Anyway, just a dump of the current state...

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
