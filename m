Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 697966B0038
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 18:13:48 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id x12so7313084wgg.26
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 15:13:47 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id z17si3919707wjr.162.2014.09.11.15.13.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 15:13:47 -0700 (PDT)
Date: Fri, 12 Sep 2014 00:13:32 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 06/10] mips: sync struct siginfo with general
 version
In-Reply-To: <1410425210-24789-7-git-send-email-qiaowei.ren@intel.com>
Message-ID: <alpine.DEB.2.10.1409120007550.4178@nanos>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-7-git-send-email-qiaowei.ren@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 11 Sep 2014, Qiaowei Ren wrote:

> Due to new fields about bound violation added into struct siginfo,
> this patch syncs it with general version to avoid build issue.

You completely fail to explain which build issue is addressed by this
patch. The code you added to kernel/signal.c which accesses _addr_bnd
is guarded by

+#ifdef SEGV_BNDERR

which is not defined my MIPS. Also why is this only affecting MIPS and
not any other architecture which provides its own struct siginfo ?

That patch makes no sense at all, at least not without a proper
explanation.

Thanks,

	tglx

> Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
> ---
>  arch/mips/include/uapi/asm/siginfo.h |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/mips/include/uapi/asm/siginfo.h b/arch/mips/include/uapi/asm/siginfo.h
> index e811744..d08f83f 100644
> --- a/arch/mips/include/uapi/asm/siginfo.h
> +++ b/arch/mips/include/uapi/asm/siginfo.h
> @@ -92,6 +92,10 @@ typedef struct siginfo {
>  			int _trapno;	/* TRAP # which caused the signal */
>  #endif
>  			short _addr_lsb;
> +			struct {
> +				void __user *_lower;
> +				void __user *_upper;
> +			} _addr_bnd;
>  		} _sigfault;
>  
>  		/* SIGPOLL, SIGXFSZ (To do ...)	 */
> -- 
> 1.7.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
