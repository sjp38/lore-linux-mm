Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 436F66B0254
	for <linux-mm@kvack.org>; Sun,  2 Aug 2015 15:30:05 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so111795811wib.1
        for <linux-mm@kvack.org>; Sun, 02 Aug 2015 12:30:04 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id qo2si21345143wjc.150.2015.08.02.12.30.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Sun, 02 Aug 2015 12:30:03 -0700 (PDT)
Date: Sun, 2 Aug 2015 21:30:00 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH v2 4/4] coccinelle: mm:
 scripts/coccinelle/api/alloc/pool_zalloc-simple.cocci
In-Reply-To: <1438371404-3219-5-git-send-email-sean.stalley@intel.com>
Message-ID: <alpine.DEB.2.02.1508022129500.2044@localhost6.localdomain6>
References: <1438371404-3219-1-git-send-email-sean.stalley@intel.com> <1438371404-3219-5-git-send-email-sean.stalley@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Sean O. Stalley" <sean.stalley@intel.com>
Cc: corbet@lwn.net, vinod.koul@intel.com, bhelgaas@google.com, Julia.Lawall@lip6.fr, Gilles.Muller@lip6.fr, nicolas.palix@imag.fr, mmarek@suse.cz, akpm@linux-foundation.org, bigeasy@linutronix.de, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, dmaengine@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, cocci@systeme.lip6.fr

Acked-by: Julia Lawall <julia.lawall@lip6.fr>

On Fri, 31 Jul 2015, Sean O. Stalley wrote:

> add [pci|dma]_pool_zalloc coccinelle check.
> replaces instances of [pci|dma]_pool_alloc() followed by memset(0)
> with [pci|dma]_pool_zalloc().
> 
> Signed-off-by: Sean O. Stalley <sean.stalley@intel.com>
> ---
>  .../coccinelle/api/alloc/pool_zalloc-simple.cocci  | 84 ++++++++++++++++++++++
>  1 file changed, 84 insertions(+)
>  create mode 100644 scripts/coccinelle/api/alloc/pool_zalloc-simple.cocci
> 
> diff --git a/scripts/coccinelle/api/alloc/pool_zalloc-simple.cocci b/scripts/coccinelle/api/alloc/pool_zalloc-simple.cocci
> new file mode 100644
> index 0000000..9b7eb32
> --- /dev/null
> +++ b/scripts/coccinelle/api/alloc/pool_zalloc-simple.cocci
> @@ -0,0 +1,84 @@
> +///
> +/// Use *_pool_zalloc rather than *_pool_alloc followed by memset with 0
> +///
> +// Copyright: (C) 2015 Intel Corp.  GPLv2.
> +// Options: --no-includes --include-headers
> +//
> +// Keywords: dma_pool_zalloc, pci_pool_zalloc
> +//
> +
> +virtual context
> +virtual patch
> +virtual org
> +virtual report
> +
> +//----------------------------------------------------------
> +//  For context mode
> +//----------------------------------------------------------
> +
> +@depends on context@
> +expression x;
> +statement S;
> +@@
> +
> +* x = \(dma_pool_alloc\|pci_pool_alloc\)(...);
> +  if ((x==NULL) || ...) S
> +* memset(x,0, ...);
> +
> +//----------------------------------------------------------
> +//  For patch mode
> +//----------------------------------------------------------
> +
> +@depends on patch@
> +expression x;
> +expression a,b,c;
> +statement S;
> +@@
> +
> +- x = dma_pool_alloc(a,b,c);
> ++ x = dma_pool_zalloc(a,b,c);
> +  if ((x==NULL) || ...) S
> +- memset(x,0,...);
> +
> +@depends on patch@
> +expression x;
> +expression a,b,c;
> +statement S;
> +@@
> +
> +- x = pci_pool_alloc(a,b,c);
> ++ x = pci_pool_zalloc(a,b,c);
> +  if ((x==NULL) || ...) S
> +- memset(x,0,...);
> +
> +//----------------------------------------------------------
> +//  For org and report mode
> +//----------------------------------------------------------
> +
> +@r depends on org || report@
> +expression x;
> +expression a,b,c;
> +statement S;
> +position p;
> +@@
> +
> + x = @p\(dma_pool_alloc\|pci_pool_alloc\)(a,b,c);
> + if ((x==NULL) || ...) S
> + memset(x,0, ...);
> +
> +@script:python depends on org@
> +p << r.p;
> +x << r.x;
> +@@
> +
> +msg="%s" % (x)
> +msg_safe=msg.replace("[","@(").replace("]",")")
> +coccilib.org.print_todo(p[0], msg_safe)
> +
> +@script:python depends on report@
> +p << r.p;
> +x << r.x;
> +@@
> +
> +msg="WARNING: *_pool_zalloc should be used for %s, instead of *_pool_alloc/memset" % (x)
> +coccilib.report.print_report(p[0], msg)
> -- 
> 1.9.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
