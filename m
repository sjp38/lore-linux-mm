Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB836B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 15:51:07 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id o6so18877637qkh.19
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:51:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e39sor21271233qtk.100.2017.11.27.12.51.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 12:51:06 -0800 (PST)
Date: Mon, 27 Nov 2017 15:51:04 -0500 (EST)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: mm/percpu.c: use smarter memory allocation for struct pcpu_alloc_info
 (crisv32 hang)
In-Reply-To: <20171127203335.GQ983427@devbig577.frc2.facebook.com>
Message-ID: <nycvar.YSQ.7.76.1711271534590.5925@knanqh.ubzr>
References: <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr> <20171118182542.GA23928@roeck-us.net> <20171127194105.GM983427@devbig577.frc2.facebook.com> <nycvar.YSQ.7.76.1711271515540.5925@knanqh.ubzr> <20171127203335.GQ983427@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Guenter Roeck <linux@roeck-us.net>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, linux-cris-kernel@axis.com

On Mon, 27 Nov 2017, Tejun Heo wrote:

> Hello,
> 
> On Mon, Nov 27, 2017 at 03:31:52PM -0500, Nicolas Pitre wrote:
> > So IMHO I don't think reverting the commit is the right thing to do. 
> > That commit is clearly not at fault here.
> 
> It's not about the blame.  We just want to avoid breaking boot in a
> way which is difficult to debug.  Once cris is fixed, we can re-apply
> the patch.

In that case I suggest the following instead. No point penalizing 
everyone for a single architecture's fault. And this will serve as a 
visible reminder to the cris people that they need to clean up.

----- >8
Subject: percpu: hack to let the CRIS architecture to boot until they clean up

Commit 438a506180 ("percpu: don't forget to free the temporary struct 
pcpu_alloc_info") uncovered a problem on the CRIS architecture where
the bootmem allocator is initialized with virtual addresses. Given it 
has:

    #define __va(x) ((void *)((unsigned long)(x) | 0x80000000))

then things just work out because the end result is the same whether you
give this a physical or a virtual address.

Untill you call memblock_free_early(__pa(address)) that is, because
values from __pa() don't match with the virtual addresses stuffed in the
bootmem allocator anymore.

Avoid freeing the temporary pcpu_alloc_info memory on that architecture
until they fix things up to let the kernel boot like it did before.

Signed-off-by: Nicolas Pitre <nico@linaro.org>

diff --git a/mm/percpu.c b/mm/percpu.c
index 79e3549cab..50e7fdf840 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -2719,7 +2719,11 @@ void __init setup_per_cpu_areas(void)
 
 	if (pcpu_setup_first_chunk(ai, fc) < 0)
 		panic("Failed to initialize percpu areas.");
+#ifdef CONFIG_CRIS
+#warning "the CRIS architecture has physical and virtual addresses confused"
+#else
 	pcpu_free_alloc_info(ai);
+#endif
 }
 
 #endif	/* CONFIG_SMP */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
