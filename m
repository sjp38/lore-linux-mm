Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA846B0038
	for <linux-mm@kvack.org>; Sun, 19 Nov 2017 15:36:40 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id j190so1030256qka.18
        for <linux-mm@kvack.org>; Sun, 19 Nov 2017 12:36:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t82sor6090191qkl.91.2017.11.19.12.36.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 Nov 2017 12:36:38 -0800 (PST)
Date: Sun, 19 Nov 2017 15:36:36 -0500 (EST)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: mm/percpu.c: use smarter memory allocation for struct pcpu_alloc_info
 (crisv32 hang)
In-Reply-To: <20171118182542.GA23928@roeck-us.net>
Message-ID: <nycvar.YSQ.7.76.1711191525450.16045@knanqh.ubzr>
References: <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr> <20171118182542.GA23928@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, linux-cris-kernel@axis.com

On Sat, 18 Nov 2017, Guenter Roeck wrote:

> Hi,
> 
> On Tue, Oct 03, 2017 at 06:29:49PM -0400, Nicolas Pitre wrote:
> > On Tue, 3 Oct 2017, Tejun Heo wrote:
> > 
> > > On Tue, Oct 03, 2017 at 04:57:44PM -0400, Nicolas Pitre wrote:
> > > > This can be much smaller than a page on very small memory systems. 
> > > > Always rounding up the size to a page is wasteful in that case, and 
> > > > required alignment is smaller than the memblock default. Let's round 
> > > > things up to a page size only when the actual size is >= page size, and 
> > > > then it makes sense to page-align for a nicer allocation pattern.
> > > 
> > > Isn't that a temporary area which gets freed later during boot?
> > 
> > Hmmm...
> > 
> > It may get freed through 3 different paths where 2 of them are error 
> > paths. What looks like a non-error path is in pcpu_embed_first_chunk() 
> > called from setup_per_cpu_areas(). But there are two versions of 
> > setup_per_cpu_areas(): one for SMP and one for !SMP. And the !SMP case 
> > never calls pcpu_free_alloc_info() currently.
> > 
> > I'm not sure i understand that code fully, but maybe the following patch 
> > could be a better fit:
> > 
> > ----- >8
> > Subject: [PATCH] percpu: don't forget to free the temporary struct pcpu_alloc_info
> > 
> > Unlike the SMP case, the !SMP case does not free the memory for struct 
> > pcpu_alloc_info allocated in setup_per_cpu_areas(). And to give it a 
> > chance of being reused by the page allocator later, align it to a page 
> > boundary just like its size.
> > 
> > Signed-off-by: Nicolas Pitre <nico@linaro.org>
> 
> This patch causes my crisv32 qemu emulation to hang with no console output.
> 
> > 
> > diff --git a/mm/percpu.c b/mm/percpu.c
> > index 434844415d..caab63375b 100644
> > --- a/mm/percpu.c
> > +++ b/mm/percpu.c
> > @@ -1416,7 +1416,7 @@ struct pcpu_alloc_info * __init pcpu_alloc_alloc_info(int nr_groups,
> >  			  __alignof__(ai->groups[0].cpu_map[0]));
> >  	ai_size = base_size + nr_units * sizeof(ai->groups[0].cpu_map[0]);
> >  
> > -	ptr = memblock_virt_alloc_nopanic(PFN_ALIGN(ai_size), 0);
> > +	ptr = memblock_virt_alloc_nopanic(PFN_ALIGN(ai_size), PAGE_SIZE);
> >  	if (!ptr)
> >  		return NULL;
> >  	ai = ptr;
> > @@ -2295,6 +2295,7 @@ void __init setup_per_cpu_areas(void)
> >  
> >  	if (pcpu_setup_first_chunk(ai, fc) < 0)
> >  		panic("Failed to initialize percpu areas.");
> > +	pcpu_free_alloc_info(ai);
> 
> This is the culprit. Everything works fine if I remove this line.

Without this line, the memory at the ai pointer is leaked. Maybe this is 
modifying the memory allocation pattern and that triggers a bug later on 
in your case.

At that point the console driver is not yet initialized and any error 
message won't be printed. You should enable the early console mechanism 
in your kernel (see arch/cris/arch-v32/kernel/debugport.c) and see what 
that might tell you.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
