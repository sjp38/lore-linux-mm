Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC2876B02BF
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 03:19:53 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id k66so4624538lfg.14
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 00:19:53 -0800 (PST)
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id g77si10069650lfh.245.2017.11.28.00.19.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 00:19:52 -0800 (PST)
Date: Tue, 28 Nov 2017 09:19:49 +0100
From: Jesper Nilsson <jesper.nilsson@axis.com>
Subject: Re: mm/percpu.c: use smarter memory allocation for struct
 pcpu_alloc_info (crisv32 hang)
Message-ID: <20171128081948.GE32368@axis.com>
References: <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr>
 <20171118182542.GA23928@roeck-us.net>
 <20171127194105.GM983427@devbig577.frc2.facebook.com>
 <nycvar.YSQ.7.76.1711271515540.5925@knanqh.ubzr>
 <20171127203335.GQ983427@devbig577.frc2.facebook.com>
 <nycvar.YSQ.7.76.1711271534590.5925@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1711271534590.5925@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Tejun Heo <tj@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jespern@axis.com>, linux-cris-kernel@axis.com

On Mon, Nov 27, 2017 at 03:51:04PM -0500, Nicolas Pitre wrote:
> On Mon, 27 Nov 2017, Tejun Heo wrote:
> 
> > Hello,
> > 
> > On Mon, Nov 27, 2017 at 03:31:52PM -0500, Nicolas Pitre wrote:
> > > So IMHO I don't think reverting the commit is the right thing to do. 
> > > That commit is clearly not at fault here.
> > 
> > It's not about the blame.  We just want to avoid breaking boot in a
> > way which is difficult to debug.  Once cris is fixed, we can re-apply
> > the patch.
> 
> In that case I suggest the following instead. No point penalizing 
> everyone for a single architecture's fault. And this will serve as a 
> visible reminder to the cris people that they need to clean up.
> 
> ----- >8
> Subject: percpu: hack to let the CRIS architecture to boot until they clean up
> 
> Commit 438a506180 ("percpu: don't forget to free the temporary struct 
> pcpu_alloc_info") uncovered a problem on the CRIS architecture where
> the bootmem allocator is initialized with virtual addresses. Given it 
> has:
> 
>     #define __va(x) ((void *)((unsigned long)(x) | 0x80000000))
> 
> then things just work out because the end result is the same whether you
> give this a physical or a virtual address.
> 
> Untill you call memblock_free_early(__pa(address)) that is, because
> values from __pa() don't match with the virtual addresses stuffed in the
> bootmem allocator anymore.
> 
> Avoid freeing the temporary pcpu_alloc_info memory on that architecture
> until they fix things up to let the kernel boot like it did before.
> 
> Signed-off-by: Nicolas Pitre <nico@linaro.org>
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 79e3549cab..50e7fdf840 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -2719,7 +2719,11 @@ void __init setup_per_cpu_areas(void)
>  
>  	if (pcpu_setup_first_chunk(ai, fc) < 0)
>  		panic("Failed to initialize percpu areas.");
> +#ifdef CONFIG_CRIS
> +#warning "the CRIS architecture has physical and virtual addresses confused"
> +#else
>  	pcpu_free_alloc_info(ai);
> +#endif
>  }
>  
>  #endif	/* CONFIG_SMP */

Works for me, and thanks.

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
