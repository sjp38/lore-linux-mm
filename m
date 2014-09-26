Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id F379D6B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 13:07:27 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id i50so1155185qgf.39
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:07:26 -0700 (PDT)
Received: from mail-qa0-x22e.google.com (mail-qa0-x22e.google.com [2607:f8b0:400d:c00::22e])
        by mx.google.com with ESMTPS id g7si6558592qcl.11.2014.09.26.10.07.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 10:07:24 -0700 (PDT)
Received: by mail-qa0-f46.google.com with SMTP id x12so6287798qac.5
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:07:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <54259BD4.8090508@oracle.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com> <54259BD4.8090508@oracle.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 26 Sep 2014 10:07:04 -0700
Message-ID: <CACT4Y+Y0fzbs4DPt3n30R33cYqXEZ8E86tzCfzL6RUE9f+-r=w@mail.gmail.com>
Subject: Re: [PATCH v3 00/13] Kernel address sanitizer - runtime memory debugger.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-kbuild@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>

On Fri, Sep 26, 2014 at 10:01 AM, Sasha Levin <sasha.levin@oracle.com> wrote:
> On 09/24/2014 08:43 AM, Andrey Ryabinin wrote:
>> Hi.
>>
>> This is a third iteration of kerenel address sanitizer (KASan).
>>
>> KASan is a runtime memory debugger designed to find use-after-free
>> and out-of-bounds bugs.
>>
>> Currently KASAN supported only for x86_64 architecture and requires kernel
>> to be build with SLUB allocator.
>> KASAN uses compile-time instrumentation for checking every memory access, therefore you
>> will need a fresh GCC >= v5.0.0.
>
> Hi Andrey,
>
> I tried this patchset, with the latest gcc, and I'm seeing the following:
>
> arch/x86/kernel/head.o: In function `_GLOBAL__sub_I_00099_0_reserve_ebda_region':
> /home/sasha/linux-next/arch/x86/kernel/head.c:71: undefined reference to `__asan_init_v4'
> init/built-in.o: In function `_GLOBAL__sub_I_00099_0___ksymtab_system_state':
> /home/sasha/linux-next/init/main.c:1034: undefined reference to `__asan_init_v4'
> init/built-in.o: In function `_GLOBAL__sub_I_00099_0_init_uts_ns':
> /home/sasha/linux-next/init/version.c:50: undefined reference to `__asan_init_v4'
> init/built-in.o: In function `_GLOBAL__sub_I_00099_0_root_mountflags':
> /home/sasha/linux-next/init/do_mounts.c:638: undefined reference to `__asan_init_v4'
> init/built-in.o: In function `_GLOBAL__sub_I_00099_0_rd_prompt':
> /home/sasha/linux-next/init/do_mounts_rd.c:361: undefined reference to `__asan_init_v4'
> init/built-in.o:/home/sasha/linux-next/init/do_mounts_md.c:312: more undefined references to `__asan_init_v4' follow
>
>
> What am I missing?


Emission of __asan_init_vx needs to be disabled when
-fsanitize=kernel-address. Our kernel does not boot with them at all.
It probably hits some limit for something that can be increased. But I
don't want to investigate what that limit is, as __asan_init is not
needed for kasan at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
