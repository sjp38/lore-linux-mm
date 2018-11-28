Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4DEE56B4C55
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 04:57:19 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id a19so8060680otq.1
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 01:57:19 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b19si3333384otp.180.2018.11.28.01.57.17
        for <linux-mm@kvack.org>;
        Wed, 28 Nov 2018 01:57:18 -0800 (PST)
Date: Wed, 28 Nov 2018 09:57:35 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 0/2] =?utf-8?B?RG9u4oCZ?= =?utf-8?Q?t?= leave executable
 TLB entries to freed pages
Message-ID: <20181128095734.GA23467@arm.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
 <CDB8B7C1-FD55-44AD-9B71-B3A750BF5489@gmail.com>
 <449E6648-5599-476D-8136-EE570101F930@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <449E6648-5599-476D-8136-EE570101F930@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, naveen.n.rao@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, David Miller <davem@davemloft.net>, Masami Hiramatsu <mhiramat@kernel.org>, rostedt@goodmis.org, mingo@redhat.com, ast@kernel.org, daniel@iogearbox.net, jeyu@kernel.org, netdev@vger.kernel.org, ard.biesheuvel@linaro.org, jannh@google.com, kristen@linux.intel.com, dave.hansen@intel.com, deneen.t.dock@intel.com

On Tue, Nov 27, 2018 at 05:21:08PM -0800, Nadav Amit wrote:
> > On Nov 27, 2018, at 5:06 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
> > 
> >> On Nov 27, 2018, at 4:07 PM, Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:
> >> 
> >> Sometimes when memory is freed via the module subsystem, an executable
> >> permissioned TLB entry can remain to a freed page. If the page is re-used to
> >> back an address that will receive data from userspace, it can result in user
> >> data being mapped as executable in the kernel. The root of this behavior is
> >> vfree lazily flushing the TLB, but not lazily freeing the underlying pages. 
> >> 
> >> There are sort of three categories of this which show up across modules, bpf,
> >> kprobes and ftrace:
> >> 
> >> 1. When executable memory is touched and then immediatly freed
> >> 
> >>  This shows up in a couple error conditions in the module loader and BPF JIT
> >>  compiler.
> > 
> > Interesting!
> > 
> > Note that this may cause conflict with "x86: avoid W^X being broken during
> > modules loading”, which I recently submitted.
> 
> I actually have not looked on the vmalloc() code too much recent, but it
> seems … strange:
> 
>   void vm_unmap_aliases(void)
>   {       
> 
>   ...
>   	mutex_lock(&vmap_purge_lock);
>   	purge_fragmented_blocks_allcpus();
>   	if (!__purge_vmap_area_lazy(start, end) && flush)
>   		flush_tlb_kernel_range(start, end);
>   	mutex_unlock(&vmap_purge_lock);
>   }
> 
> Since __purge_vmap_area_lazy() releases the memory, it seems there is a time
> window between the release of the region and the TLB flush, in which the
> area can be allocated for another purpose. This can result in a
> (theoretical) correctness issue. No?

If __purge_vmap_area_lazy() returns false, then it hasn't freed the memory,
so we only invalidate the TLB if 'flush' is true in that case. If
__purge_vmap_area_lazy() returns true instead, then it takes care of the TLB
invalidation before the freeing.

Will
