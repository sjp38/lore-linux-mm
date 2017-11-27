Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 07A296B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 15:31:55 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id d15so15094898qte.3
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:31:55 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p89sor19236150qkl.15.2017.11.27.12.31.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 12:31:54 -0800 (PST)
Date: Mon, 27 Nov 2017 15:31:52 -0500 (EST)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: mm/percpu.c: use smarter memory allocation for struct pcpu_alloc_info
 (crisv32 hang)
In-Reply-To: <20171127194105.GM983427@devbig577.frc2.facebook.com>
Message-ID: <nycvar.YSQ.7.76.1711271515540.5925@knanqh.ubzr>
References: <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr> <20171118182542.GA23928@roeck-us.net> <20171127194105.GM983427@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Guenter Roeck <linux@roeck-us.net>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, linux-cris-kernel@axis.com

On Mon, 27 Nov 2017, Tejun Heo wrote:

> Hello,
> 
> I'm reverting the offending commit till we figure out what's going on.

It is figured out. The cris port is wrongly initializing the bootmem 
allocator with virtual memory addresses rather than physical addresses. 
And because its __va() definition reads like this:

#define __va(x) ((void *)((unsigned long)(x) | 0x80000000))

then things just work out because the end result is the same whether you 
give this a physical or a virtual address.

Untill you call memblock_free_early(__pa(address)) that is, because 
values from __pa() don't match with the virtual addresses stuffed in the 
bootmem allocator anymore.

So IMHO I don't think reverting the commit is the right thing to do. 
That commit is clearly not at fault here.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
