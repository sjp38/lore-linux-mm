Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55C3B6B5007
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 20:41:08 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id v72so208289pgb.10
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 17:41:08 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 15si319577pgv.351.2018.11.28.17.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 17:41:07 -0800 (PST)
Received: from mail-wm1-f49.google.com (mail-wm1-f49.google.com [209.85.128.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8DE132133F
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 01:41:06 +0000 (UTC)
Received: by mail-wm1-f49.google.com with SMTP id g67so548425wmd.2
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 17:41:06 -0800 (PST)
MIME-Version: 1.0
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com> <20181128000754.18056-3-rick.p.edgecombe@intel.com>
In-Reply-To: <20181128000754.18056-3-rick.p.edgecombe@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 28 Nov 2018 17:40:53 -0800
Message-ID: <CALCETrU+skBS0r6WtkwwMZJvb3s2vWB-JmDeZtVWV8pOkxKojQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] x86/modules: Make x86 allocs to flush when free
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrew Lutomirski <luto@kernel.org>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, "Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>, Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, "David S. Miller" <davem@davemloft.net>, Masami Hiramatsu <mhiramat@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, jeyu@kernel.org, Network Development <netdev@vger.kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jann Horn <jannh@google.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>

> On Nov 27, 2018, at 4:07 PM, Rick Edgecombe <rick.p.edgecombe@intel.com> =
wrote:
>
> Change the module allocations to flush before freeing the pages.
>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
> arch/x86/kernel/module.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
> index b052e883dd8c..1694daf256b3 100644
> --- a/arch/x86/kernel/module.c
> +++ b/arch/x86/kernel/module.c
> @@ -87,8 +87,8 @@ void *module_alloc(unsigned long size)
>    p =3D __vmalloc_node_range(size, MODULE_ALIGN,
>                    MODULES_VADDR + get_module_load_offset(),
>                    MODULES_END, GFP_KERNEL,
> -                    PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
> -                    __builtin_return_address(0));
> +                    PAGE_KERNEL_EXEC, VM_IMMEDIATE_UNMAP,
> +                    NUMA_NO_NODE, __builtin_return_address(0));

Hmm. How awful is the resulting performance for heavy eBPF users?  I=E2=80=
=99m
wondering if the JIT will need some kind of cache to reuse
allocations.

>    if (p && (kasan_module_alloc(p, size) < 0)) {
>        vfree(p);
>        return NULL;
> --
> 2.17.1
>
