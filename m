Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A20186B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:42:44 -0500 (EST)
Received: by wmww144 with SMTP id w144so192487742wmw.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:42:44 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id qr6si5918243wjc.206.2015.12.08.10.42.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 10:42:43 -0800 (PST)
Date: Tue, 8 Dec 2015 19:41:53 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 27/34] x86, pkeys: make mprotect_key() mask off additional
 vm_flags
In-Reply-To: <20151204011502.251A0E5B@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081941040.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011502.251A0E5B@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Today, mprotect() takes 4 bits of data: PROT_READ/WRITE/EXEC/NONE.
> Three of those bits: READ/WRITE/EXEC get translated directly in to
> vma->vm_flags by calc_vm_prot_bits().  If a bit is unset in
> mprotect()'s 'prot' argument then it must be cleared in vma->vm_flags
> during the mprotect() call.
> 
> We do the by first calculating the VMA flags we want set, then
> clearing the ones we do not want to inherit from the original VMA:
> 
> 	vm_flags = calc_vm_prot_bits(prot, key);
> 	...
> 	newflags = vm_flags;
> 	newflags |= (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
> 
> However, we *also* want to mask off the original VMA's vm_flags in
> which we store the protection key.
> 
> To do that, this patch adds a new macro:
> 
> 	ARCH_VM_FLAGS_AFFECTED_BY_MPROTECT

-ENOSUCHMACRO
 
> which allows the architecture to specify additional bits that it would
> like cleared.  We use that to ensure that the VM_PKEY_BIT* bits get
> cleared.

Other than that: Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
