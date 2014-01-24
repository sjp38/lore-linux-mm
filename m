Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id A5FAB6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 02:04:14 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id d7so940008bkh.6
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 23:04:14 -0800 (PST)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id or7si1742644bkb.162.2014.01.23.23.04.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 23:04:13 -0800 (PST)
Received: by mail-ig0-f180.google.com with SMTP id m12so1820241iga.1
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 23:04:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52E20E98.7010703@ti.com>
References: <52E19C7D.7050603@intel.com>
	<CAE9FiQX9kTxnaqpWNgg3dUzr7+60YCrEx3q3xxO-G1n6z64xVQ@mail.gmail.com>
	<52E20A56.1000507@ti.com>
	<52E20E98.7010703@ti.com>
Date: Thu, 23 Jan 2014 23:04:12 -0800
Message-ID: <CAE9FiQWRkP1Hir6UFuPRGu6bXNd_SHonuaC-MG1UD-tSeE0teQ@mail.gmail.com>
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jan 23, 2014 at 10:56 PM, Santosh Shilimkar
<santosh.shilimkar@ti.com> wrote:
> On Friday 24 January 2014 01:38 AM, Santosh Shilimkar wrote:

> The patch which is now commit 457ff1d {lib/swiotlb.c: use
> memblock apis for early memory allocations} was the breaking the
> boot on Andrew's machine. Now if I look back the patch, based on your
> above description, I believe below hunk waS/is the culprit.
>
> @@ -172,8 +172,9 @@ int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
>         /*
>          * Get the overflow emergency buffer
>          */
> -       v_overflow_buffer = alloc_bootmem_low_pages_nopanic(
> -                                               PAGE_ALIGN(io_tlb_overflow));
> +       v_overflow_buffer = memblock_virt_alloc_nopanic(
> +                                               PAGE_ALIGN(io_tlb_overflow),
> +                                               PAGE_SIZE);
>         if (!v_overflow_buffer)
>                 return -ENOMEM;
>
>
> Looks like 'v_overflow_buffer' must be allocated from low memory in this
> case. Is that correct ?

yes.

but should the change like following

commit 457ff1de2d247d9b8917c4664c2325321a35e313
Author: Santosh Shilimkar <santosh.shilimkar@ti.com>
Date:   Tue Jan 21 15:50:30 2014 -0800

    lib/swiotlb.c: use memblock apis for early memory allocations


@@ -215,13 +220,13 @@ swiotlb_init(int verbose)
        bytes = io_tlb_nslabs << IO_TLB_SHIFT;

        /* Get IO TLB memory from the low pages */
-       vstart = alloc_bootmem_low_pages_nopanic(PAGE_ALIGN(bytes));
+       vstart = memblock_virt_alloc_nopanic(PAGE_ALIGN(bytes), PAGE_SIZE);
        if (vstart && !swiotlb_init_with_tbl(vstart, io_tlb_nslabs, verbose))
                return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
