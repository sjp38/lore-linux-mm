Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id B0E9B6B0035
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 10:00:18 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id q59so2421126wes.41
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 07:00:18 -0800 (PST)
Received: from smtp2.it.da.ut.ee (smtp2.it.da.ut.ee. [2001:bb8:2002:500:20f:1fff:fe04:1bbb])
        by mx.google.com with ESMTP id bo14si1519884wib.27.2013.12.08.07.00.17
        for <linux-mm@kvack.org>;
        Sun, 08 Dec 2013 07:00:17 -0800 (PST)
Date: Sun, 8 Dec 2013 17:00:16 +0200 (EET)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: Slab BUG with DEBUG_* options
In-Reply-To: <00000142ba77e59d-3e002746-996d-4843-b8f1-51d1431b47a9-000000@email.amazonses.com>
Message-ID: <alpine.SOC.1.00.1312040005350.25191@math.ut.ee>
References: <alpine.SOC.1.00.1311300125490.6363@math.ut.ee> <alpine.DEB.2.02.1312030930450.4115@gentwo.org> <00000142ba22e43b-99d8d7cb-9ecd-4f18-9609-8805270843d4-000000@email.amazonses.com> <alpine.SOC.1.00.1312032314040.25191@math.ut.ee>
 <00000142ba77e59d-3e002746-996d-4843-b8f1-51d1431b47a9-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Peter Hurley <peter@hurleysoftware.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org

(Added 3 addresses to CC from my RED state exception thread since this 
is related)

> On Tue, 3 Dec 2013, Meelis Roos wrote:
> 
> > Tested it. seems to hang after switching to another console. Before
> > that, slabs are initialized successfully, I verified it with my previous
> > debug printk sprinkle patch. Many allocations are still off slab - is
> > that OK?
> 
> Yes that was the intend. Only exempt the small ones.
> 
> > console [tty0] enabled, bootconsole disabled
> 
> Looks like the bootstrap worked.

But the configuration should work fine with this console setup - with no 
slab debug options, it booted fine... I decided to do more tests.

In short, tests about 3.11-rc2-00058:

clean kernel: boots OK, RED state on shutdown (the actual problem I am 
chasing)

clean kernel, slab debug: mm crash

your second slab patch, slab debug: OK - this one shows that the RED 
state problem went away too which is good but strange

clean kernel, your second slab patch: OK - no RED state

Following another lead I had discovered that I can make the RED state 
problem go away if I switch tty ldata allocation from vmalloc to 
kmalloc. Tests with that:

ldata alloc change only, no slab debug: OK (works around RED state 
somehow)

ldata alloc change + slab debug: mm crash, can not test for RED state

ldata alloc change + your second slab patch + slab debug: hang on boot 
after
console [tty0] enabled, bootconsole disabled
(after that, I should see all the dmesg again on serial but I do not).

ldata alloc change + your second slab patch + no slab debug: OK

So, in short:

your slab patch 2 seems to cure both slab debug startup crash and the 
RED state problem in this specific version of the kernel. However, it is 
still mystery to me why tty ldata alloc change vmalloc->kmalloc would 
break but that may to be in the serial field - will do more tests with 
this patch applied and newer kernels.

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
