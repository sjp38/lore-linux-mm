Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B5AC76B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 18:14:13 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id n128so106344975pfn.3
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:14:13 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id fd9si4813543pad.134.2016.01.26.15.14.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 15:14:13 -0800 (PST)
Received: by mail-pa0-x22e.google.com with SMTP id ho8so104780097pac.2
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:14:12 -0800 (PST)
Date: Tue, 26 Jan 2016 15:14:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 RESEND 1/2] arm, arm64: change_memory_common with
 numpages == 0 should be no-op.
In-Reply-To: <20160126155919.GA28238@arm.com>
Message-ID: <alpine.DEB.2.10.1601261513230.25141@chino.kir.corp.google.com>
References: <1453820393-31179-1-git-send-email-mika.penttila@nextfour.com> <1453820393-31179-2-git-send-email-mika.penttila@nextfour.com> <20160126155919.GA28238@arm.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-193334197-1453850051=:25141"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: mika.penttila@nextfour.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@arm.linux.org.uk, catalin.marinas@arm.com

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-193334197-1453850051=:25141
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 26 Jan 2016, Will Deacon wrote:

> From 57adec866c0440976c96a4b8f5b59fb411b1cacb Mon Sep 17 00:00:00 2001
> From: =?UTF-8?q?Mika=20Penttil=C3=A4?= <mika.penttila@nextfour.com>
> Date: Tue, 26 Jan 2016 15:47:25 +0000
> Subject: [PATCH] arm64: mm: avoid calling apply_to_page_range on empty range
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
> 
> Calling apply_to_page_range with an empty range results in a BUG_ON
> from the core code. This can be triggered by trying to load the st_drv
> module with CONFIG_DEBUG_SET_MODULE_RONX enabled:
> 
>   kernel BUG at mm/memory.c:1874!
>   Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
>   Modules linked in:
>   CPU: 3 PID: 1764 Comm: insmod Not tainted 4.5.0-rc1+ #2
>   Hardware name: ARM Juno development board (r0) (DT)
>   task: ffffffc9763b8000 ti: ffffffc975af8000 task.ti: ffffffc975af8000
>   PC is at apply_to_page_range+0x2cc/0x2d0
>   LR is at change_memory_common+0x80/0x108
> 
> This patch fixes the issue by making change_memory_common (called by the
> set_memory_* functions) a NOP when numpages == 0, therefore avoiding the
> erroneous call to apply_to_page_range and bringing us into line with x86
> and s390.
> 
> Cc: <stable@vger.kernel.org>
> Reviewed-by: Laura Abbott <labbott@redhat.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Mika Penttila <mika.penttila@nextfour.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>
> ---
>  arch/arm64/mm/pageattr.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/arch/arm64/mm/pageattr.c b/arch/arm64/mm/pageattr.c
> index 3571c7309c5e..cf6240741134 100644
> --- a/arch/arm64/mm/pageattr.c
> +++ b/arch/arm64/mm/pageattr.c
> @@ -57,6 +57,9 @@ static int change_memory_common(unsigned long addr, int numpages,
>  	if (end < MODULES_VADDR || end >= MODULES_END)
>  		return -EINVAL;
>  
> +	if (!numpages)
> +		return 0;
> +
>  	data.set_mask = set_mask;
>  	data.clear_mask = clear_mask;
>  

LGTM, I think this issue goes back to 3.17 due to commit 11d91a770f1f 
("arm64: Add CONFIG_DEBUG_SET_MODULE_RONX support") so perhaps annotate 
the stable@vger.kernel.org for 3.17+.
--397176738-193334197-1453850051=:25141--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
