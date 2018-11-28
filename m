Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B7D166B4F6F
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 18:11:51 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id d6-v6so18056108pfn.19
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 15:11:51 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p126si8498663pgp.529.2018.11.28.15.11.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 15:11:50 -0800 (PST)
Date: Wed, 28 Nov 2018 15:11:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] x86/modules: Make x86 allocs to flush when free
Message-Id: <20181128151145.78a3d8b1f66f6b8fd66f0629@linux-foundation.org>
In-Reply-To: <20181128000754.18056-3-rick.p.edgecombe@intel.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
	<20181128000754.18056-3-rick.p.edgecombe@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: luto@kernel.org, will.deacon@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, naveen.n.rao@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, mhiramat@kernel.org, rostedt@goodmis.org, mingo@redhat.com, ast@kernel.org, daniel@iogearbox.net, jeyu@kernel.org, netdev@vger.kernel.org, ard.biesheuvel@linaro.org, jannh@google.com, kristen@linux.intel.com, dave.hansen@intel.com, deneen.t.dock@intel.com

On Tue, 27 Nov 2018 16:07:54 -0800 Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:

> Change the module allocations to flush before freeing the pages.
> 
> ...
>
> --- a/arch/x86/kernel/module.c
> +++ b/arch/x86/kernel/module.c
> @@ -87,8 +87,8 @@ void *module_alloc(unsigned long size)
>  	p = __vmalloc_node_range(size, MODULE_ALIGN,
>  				    MODULES_VADDR + get_module_load_offset(),
>  				    MODULES_END, GFP_KERNEL,
> -				    PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
> -				    __builtin_return_address(0));
> +				    PAGE_KERNEL_EXEC, VM_IMMEDIATE_UNMAP,
> +				    NUMA_NO_NODE, __builtin_return_address(0));
>  	if (p && (kasan_module_alloc(p, size) < 0)) {
>  		vfree(p);
>  		return NULL;

Should any other architectures do this?
