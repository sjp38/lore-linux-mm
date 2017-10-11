Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F64C6B025F
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 05:42:57 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id n82so890760oig.22
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 02:42:57 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 65si3244557oty.542.2017.10.11.02.42.56
        for <linux-mm@kvack.org>;
        Wed, 11 Oct 2017 02:42:56 -0700 (PDT)
Date: Wed, 11 Oct 2017 10:42:49 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: kmemleak: start address align for scan_large_block
Message-ID: <20171011094249.sot6wmafgrk374tg@localhost>
References: <20171011085334.7391-1-shuwang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171011085334.7391-1-shuwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuwang@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, chuhu@redhat.com, yizhan@redhat.com

On Wed, Oct 11, 2017 at 04:53:34PM +0800, shuwang@redhat.com wrote:
> From: Shu Wang <shuwang@redhat.com>
> 
> If the start address is not ptr bytes aligned, it may cause false
> positives when a pointer is split by MAX_SCAN_SIZE.
> 
> For example:
> tcp_metrics_nl_family is in __ro_after_init area. On my PC, the
> __start_ro_after_init is not ptr aligned, and
> tcp_metrics_nl_family->attrbuf was break by MAX_SCAN_SIZE.
> 
>  # cat /proc/kallsyms | grep __start_ro_after_init
>  ffffffff81afac8b R __start_ro_after_init
> 
>  (gdb) p &tcp_metrics_nl_family->attrbuf
>    (struct nlattr ***) 0xffffffff81b12c88 <tcp_metrics_nl_family+72>
> 
>  (gdb) p tcp_metrics_nl_family->attrbuf
>    (struct nlattr **) 0xffff88007b9d9400
> 
>  scan_block(_start=0xffffffff81b11c8b, _end=0xffffffff81b12c8b, 0)
>  scan_block(_start=0xffffffff81b12c8b, _end=0xffffffff81b13c8b, 0)
> 
> unreferenced object 0xffff88007b9d9400 (size 128):
>   backtrace:
>     kmemleak_alloc+0x4a/0xa0
>     __kmalloc+0xec/0x220
>     genl_register_family.part.8+0x11c/0x5c0
>     genl_register_family+0x6f/0x90
>     tcp_metrics_init+0x33/0x47
>     tcp_init+0x27a/0x293
>     inet_init+0x176/0x28a
>     do_one_initcall+0x51/0x1b0
> 
> Signed-off-by: Shu Wang <shuwang@redhat.com>

Nice catch. Thanks.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
