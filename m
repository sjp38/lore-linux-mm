Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3136B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 02:56:21 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id k66so1318521lfg.14
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 23:56:21 -0800 (PST)
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id 10si1797816lji.365.2017.11.22.23.56.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 23:56:19 -0800 (PST)
Date: Thu, 23 Nov 2017 08:56:17 +0100
From: Jesper Nilsson <jesper.nilsson@axis.com>
Subject: Re: mm/percpu.c: use smarter memory allocation for struct
 pcpu_alloc_info (crisv32 hang)
Message-ID: <20171123075617.GE20542@axis.com>
References: <62a3b680-6dde-d308-3da8-9c9a2789b114@roeck-us.net>
 <nycvar.YSQ.7.76.1711201305160.16045@knanqh.ubzr>
 <20171120185138.GB23789@roeck-us.net>
 <nycvar.YSQ.7.76.1711201512300.16045@knanqh.ubzr>
 <20171120211114.GA25984@roeck-us.net>
 <nycvar.YSQ.7.76.1711201918180.16045@knanqh.ubzr>
 <20171121014818.GA360@roeck-us.net>
 <nycvar.YSQ.7.76.1711202224490.16045@knanqh.ubzr>
 <20171122153453.GB20542@axis.com>
 <nycvar.YSQ.7.76.1711221133230.10610@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1711221133230.10610@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Jesper Nilsson <jespern@axis.com>, Guenter Roeck <linux@roeck-us.net>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, linux-cris-kernel@axis.com

On Wed, Nov 22, 2017 at 03:17:00PM -0500, Nicolas Pitre wrote:
> On Wed, 22 Nov 2017, Jesper Nilsson wrote:
> 
> > On Mon, Nov 20, 2017 at 10:50:46PM -0500, Nicolas Pitre wrote:
> > > On Mon, 20 Nov 2017, Guenter Roeck wrote:
> > > > On Mon, Nov 20, 2017 at 07:28:21PM -0500, Nicolas Pitre wrote:
> > > > > On Mon, 20 Nov 2017, Guenter Roeck wrote:
> > > > > 
> > > > > > bdata->node_min_pfn=60000 PFN_PHYS(bdata->node_min_pfn)=c0000000 start_off=536000 region=c0536000
> > > > > 
> > > > > If PFN_PHYS(bdata->node_min_pfn)=c0000000 and
> > > > > region=c0536000 that means phys_to_virt() is a no-op.
> > > > > 
> > > > No, it is |= 0x80000000
> > > 
> > > Then the bootmem registration looks very fishy. If you have:
> > > 
> > > > I think the problem is the 0x60000 in bdata->node_min_pfn. It is shifted
> > > > left by PFN_PHYS, making it 0xc0000000, which in my understanding is
> > > > a virtual address.
> > > 
> > > Exact.
> > > 
> > > #define __pa(x)                 ((unsigned long)(x) & 0x7fffffff)
> > > #define __va(x)                 ((void *)((unsigned long)(x) | 0x80000000))
> > > 
> > > With that, the only possible physical address range you may have is 
> > > 0x40000000 - 0x7fffffff, and it better start at 0x40000000. If that's 
> > > not where your RAM is then something is wrong.
> > > 
> > > This is in fact a very bad idea to define __va() and __pa() using 
> > > bitwise operations as this hides mistakes like defining physical RAM 
> > > address at 0xc0000000. Instead, it should look like:
> > > 
> > > #define __pa(x)                 ((unsigned long)(x) - 0x80000000)
> > > #define __va(x)                 ((void *)((unsigned long)(x) + 0x80000000))
> > > 
> > > This way, bad physical RAM address definitions will be caught 
> > > immediately.
> > > 
> > > > That doesn't seem to be easy to fix. It seems there is a mixup of physical
> > > > and  virtual addresses in the architecture.
> > > 
> > > Well... I don't think there is much else to say other than this needs 
> > > fixing.
> > 
> > The memory map for the ETRAX FS has the SDRAM mapped at both 0x40000000-0x7fffffff
> > and 0xc0000000-0xffffffff, and the difference is cached and non-cached.
> > That is actively (ab)used in the port, unfortunately, allthough I'm
> > uncertain if this is the problem in this case.
> 
> It certainly is a problem. If your cached RAM is physically mapped at 
> 0xc0000000 and you want it to be virtually mapped at 0xc0000000 then you 
> should have:
> 
> #define __pa(x)                 ((unsigned long)(x))
> #define __va(x)                 ((void *)(x))
> 
> i.e. no translation.

Sorry, it's the other way around, cached memory is at 0x40000000 and
non-cached is at 0xc0000000, so the translation is right, even if
as you pointed out earlier, it should be performed differently.

> For non-cached RAM access, there are specific 
> interfaces for that. For example, you could have dma_alloc_coherent() 
> take advantage of the fact that memory with the top bit cleared becomes 
> uncached. But __pa() is the wrong interface for obtaining uncached 
> memory.
> 
> Nicolas

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
