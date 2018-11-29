Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFECB6B52F0
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 09:06:22 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v12so1466332plp.16
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 06:06:22 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v5si2212770pgg.1.2018.11.29.06.06.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 06:06:21 -0800 (PST)
Date: Thu, 29 Nov 2018 23:06:16 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH 0/2] =?ISO-2022-JP?B?RG9uGyRCIUcbKEJ0?= leave executable
 TLB entries to freed pages
Message-Id: <20181129230616.f017059a093841dbaa4b82e6@kernel.org>
In-Reply-To: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: akpm@linux-foundation.org, luto@kernel.org, will.deacon@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, naveen.n.rao@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, rostedt@goodmis.org, mingo@redhat.com, ast@kernel.org, daniel@iogearbox.net, jeyu@kernel.org, netdev@vger.kernel.org, ard.biesheuvel@linaro.org, jannh@google.com, kristen@linux.intel.com, dave.hansen@intel.com, deneen.t.dock@intel.com

On Tue, 27 Nov 2018 16:07:52 -0800
Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:

> Sometimes when memory is freed via the module subsystem, an executable
> permissioned TLB entry can remain to a freed page. If the page is re-used to
> back an address that will receive data from userspace, it can result in user
> data being mapped as executable in the kernel. The root of this behavior is
> vfree lazily flushing the TLB, but not lazily freeing the underlying pages. 

Good catch!

> 
> There are sort of three categories of this which show up across modules, bpf,
> kprobes and ftrace:

For x86-64 kprobe, it sets the page NX and after that RW, and then release
via module_memfree. So I'm not sure it really happens on kprobes. (Of course
the default memory allocator is simpler so it may happen on other archs) But
interesting fixes.

Thank you,


> 
> 1. When executable memory is touched and then immediatly freed
> 
>    This shows up in a couple error conditions in the module loader and BPF JIT
>    compiler.
> 
> 2. When executable memory is set to RW right before being freed
> 
>    In this case (on x86 and probably others) there will be a TLB flush when its
>    set to RW and so since the pages are not touched between setting the
>    flush and the free, it should not be in the TLB in most cases. So this
>    category is not as big of a concern. However, techinically there is still a
>    race where an attacker could try to keep it alive for a short window with a
>    well timed out-of-bound read or speculative read, so ideally this could be
>    blocked as well.
> 
> 3. When executable memory is freed in an interrupt
> 
>    At least one example of this is the freeing of init sections in the module
>    loader. Since vmalloc reuses the allocation for the work queue linked list
>    node for the deferred frees, the memory actually gets touched as part of the
>    vfree operation and so returns to the TLB even after the flush from resetting
>    the permissions.
> 
> I have only actually tested category 1, and identified 2 and 3 just from reading
> the code.
> 
> To catch all of these, module_alloc for x86 is changed to use a new flag that
> instructs the unmap operation to flush the TLB before freeing the pages.
> 
> If this solution seems good I can plug the flag in for other architectures that
> define PAGE_KERNEL_EXEC.
> 
> 
> Rick Edgecombe (2):
>   vmalloc: New flag for flush before releasing pages
>   x86/modules: Make x86 allocs to flush when free
> 
>  arch/x86/kernel/module.c |  4 ++--
>  include/linux/vmalloc.h  |  1 +
>  mm/vmalloc.c             | 13 +++++++++++--
>  3 files changed, 14 insertions(+), 4 deletions(-)
> 
> -- 
> 2.17.1
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
