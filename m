Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1094C6B025F
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 05:25:22 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n13so1252629wmc.3
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 02:25:22 -0800 (PST)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id s123si393535wmd.94.2018.01.11.02.25.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 02:25:20 -0800 (PST)
Date: Thu, 11 Jan 2018 10:24:00 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 34/38] arm: Implement thread_struct whitelist for
 hardened usercopy
Message-ID: <20180111102400.GT17719@n2100.armlinux.org.uk>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
 <1515636190-24061-35-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1515636190-24061-35-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, linux-arm-kernel@lists.infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Wed, Jan 10, 2018 at 06:03:06PM -0800, Kees Cook wrote:
> ARM does not carry FPU state in the thread structure, so it can declare
> no usercopy whitelist at all.

This comment seems to be misleading.  We have stored FP state in the
thread structure for a long time - for example, VFP state is stored
in thread->vfpstate.hard, so we _do_ have floating point state in
the thread structure.

What I think this commit message needs to describe is why we don't
need a whitelist _despite_ having FP state in the thread structure.

At the moment, the commit message is making me think that this patch
is wrong and will introduce a regression.

Thanks.

> 
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>
> Cc: linux-arm-kernel@lists.infradead.org
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  arch/arm/Kconfig                 | 1 +
>  arch/arm/include/asm/processor.h | 7 +++++++
>  2 files changed, 8 insertions(+)
> 
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index 51c8df561077..3ea00d65f35d 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -50,6 +50,7 @@ config ARM
>  	select HAVE_ARCH_KGDB if !CPU_ENDIAN_BE32 && MMU
>  	select HAVE_ARCH_MMAP_RND_BITS if MMU
>  	select HAVE_ARCH_SECCOMP_FILTER if (AEABI && !OABI_COMPAT)
> +	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
>  	select HAVE_ARCH_TRACEHOOK
>  	select HAVE_ARM_SMCCC if CPU_V7
>  	select HAVE_EBPF_JIT if !CPU_ENDIAN_BE32
> diff --git a/arch/arm/include/asm/processor.h b/arch/arm/include/asm/processor.h
> index 338cbe0a18ef..01a41be58d43 100644
> --- a/arch/arm/include/asm/processor.h
> +++ b/arch/arm/include/asm/processor.h
> @@ -45,6 +45,13 @@ struct thread_struct {
>  	struct debug_info	debug;
>  };
>  
> +/* Nothing needs to be usercopy-whitelisted from thread_struct. */
> +static inline void arch_thread_struct_whitelist(unsigned long *offset,
> +						unsigned long *size)
> +{
> +	*offset = *size = 0;
> +}
> +
>  #define INIT_THREAD  {	}
>  
>  #define start_thread(regs,pc,sp)					\
> -- 
> 2.7.4
> 

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
