Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 079ED6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 16:03:48 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so176325877wic.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:03:47 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id cl1si26884718wib.44.2015.09.22.13.03.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA256 bits=128/128);
        Tue, 22 Sep 2015 13:03:46 -0700 (PDT)
Date: Tue, 22 Sep 2015 22:03:08 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
In-Reply-To: <20150916174906.51062FBC@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1509222157050.5606@nanos>
References: <20150916174903.E112E464@viggo.jf.intel.com> <20150916174906.51062FBC@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 16 Sep 2015, Dave Hansen wrote:
>  
> +static inline u16 vma_pkey(struct vm_area_struct *vma)
> +{
> +	u16 pkey = 0;
> +#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
> +	unsigned long f = vma->vm_flags;
> +	pkey |= (!!(f & VM_HIGH_ARCH_0)) << 0;
> +	pkey |= (!!(f & VM_HIGH_ARCH_1)) << 1;
> +	pkey |= (!!(f & VM_HIGH_ARCH_2)) << 2;
> +	pkey |= (!!(f & VM_HIGH_ARCH_3)) << 3;

Eew. What's wrong with:

     pkey = (vma->vm_flags & VM_PKEY_MASK) >> VM_PKEY_SHIFT;

???

> +static u16 fetch_pkey(unsigned long address, struct task_struct *tsk)

So here we get a u16 and assign it to si_pkey

> +	if (boot_cpu_has(X86_FEATURE_OSPKE) && si_code == SEGV_PKUERR)
> +		info.si_pkey = fetch_pkey(address, tsk);

which is int.

> +			int _pkey; /* FIXME: protection key value??

Inconsistent at least.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
