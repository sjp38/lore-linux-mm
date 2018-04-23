Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E00A66B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 06:52:07 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e22-v6so8333004ita.0
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 03:52:07 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0129.outbound.protection.outlook.com. [104.47.1.129])
        by mx.google.com with ESMTPS id f9-v6si10035741ioh.129.2018.04.23.03.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Apr 2018 03:52:06 -0700 (PDT)
Date: Mon, 23 Apr 2018 13:50:50 +0300
From: Aaro Koskinen <aaro.koskinen@nokia.com>
Subject: Re: [PATCH 1/5] x86, pti: fix boot problems from Global-bit setting
Message-ID: <20180423105050.GA16237@ak-laptop.emea.nsn-net.net>
References: <20180420222018.E7646EE1@viggo.jf.intel.com>
 <20180420222019.20C4A410@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180420222019.20C4A410@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mceier@gmail.com, aarcange@redhat.com, luto@kernel.org, arjan@linux.intel.com, bp@alien8.de, dan.j.williams@intel.com, dwmw2@infradead.org, gregkh@linuxfoundation.org, hughd@google.com, jpoimboe@redhat.com, jgross@suse.com, keescook@google.com, torvalds@linux-foundation.org, namit@vmware.com, peterz@infradead.org, tglx@linutronix.de

Hi,

On Fri, Apr 20, 2018 at 03:20:19PM -0700, Dave Hansen wrote:
> Part of the global bit _setting_ patches also includes clearing the
> Global bit when we do not want it.  That is done with
> set_memory_nonglobal(), which uses change_page_attr_clear() in
> pageattr.c under the covers.
> 
> The TLB flushing code inside pageattr.c has has checks like
> BUG_ON(irqs_disabled()), looking for interrupt disabling that might
> cause deadlocks.  But, these also trip in early boot on certain
> preempt configurations.  Just copy the existing BUG_ON() sequence from
> cpa_flush_range() to the other two sites and check for early boot.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Fixes: 39114b7a7 (x86/pti: Never implicitly clear _PAGE_GLOBAL for kernel image)
> Reported-by: Mariusz Ceier <mceier@gmail.com>
> Reported-by: Aaro Koskinen <aaro.koskinen@nokia.com>

Tested-by: Aaro Koskinen <aaro.koskinen@nokia.com>

A.

> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Arjan van de Ven <arjan@linux.intel.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: David Woodhouse <dwmw2@infradead.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Josh Poimboeuf <jpoimboe@redhat.com>
> Cc: Juergen Gross <jgross@suse.com>
> Cc: Kees Cook <keescook@google.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Nadav Amit <namit@vmware.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: linux-mm@kvack.org
> ---
> 
>  b/arch/x86/mm/pageattr.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff -puN arch/x86/mm/pageattr.c~pti-glb-boot-problem-fix arch/x86/mm/pageattr.c
> --- a/arch/x86/mm/pageattr.c~pti-glb-boot-problem-fix	2018-04-20 14:10:01.086749169 -0700
> +++ b/arch/x86/mm/pageattr.c	2018-04-20 14:10:01.090749169 -0700
> @@ -172,7 +172,7 @@ static void __cpa_flush_all(void *arg)
>  
>  static void cpa_flush_all(unsigned long cache)
>  {
> -	BUG_ON(irqs_disabled());
> +	BUG_ON(irqs_disabled() && !early_boot_irqs_disabled);
>  
>  	on_each_cpu(__cpa_flush_all, (void *) cache, 1);
>  }
> @@ -236,7 +236,7 @@ static void cpa_flush_array(unsigned lon
>  	unsigned long do_wbinvd = cache && numpages >= 1024; /* 4M threshold */
>  #endif
>  
> -	BUG_ON(irqs_disabled());
> +	BUG_ON(irqs_disabled() && !early_boot_irqs_disabled);
>  
>  	on_each_cpu(__cpa_flush_all, (void *) do_wbinvd, 1);
>  
> _
