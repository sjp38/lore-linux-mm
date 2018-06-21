Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA9E6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 17:23:23 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q8-v6so26015wmc.2
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 14:23:23 -0700 (PDT)
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id f10-v6si13568wmh.212.2018.06.21.14.23.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 14:23:22 -0700 (PDT)
Subject: Re: [PATCH 0/3] KASLR feature to randomize each loadable module
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
 <CAGXu5jLt8Zv-p=9J590WFppc3O6LWrAVdi-xtU7r_8f4j0XeRg@mail.gmail.com>
 <CAG48ez2uuQkSS9DLz6j5HbpuxaHMyAVYGMM+xoZEo51N=sHmdg@mail.gmail.com>
 <1529607615.29548.202.camel@intel.com>
From: Daniel Borkmann <daniel@iogearbox.net>
Message-ID: <4efbcefe-78fb-b7db-affd-ad86f9e9b0ee@iogearbox.net>
Date: Thu, 21 Jun 2018 23:23:11 +0200
MIME-Version: 1.0
In-Reply-To: <1529607615.29548.202.camel@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>, "jannh@google.com" <jannh@google.com>, "keescook@chromium.org" <keescook@chromium.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Van De Ven, Arjan" <arjan.van.de.ven@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "Accardi, Kristen C" <kristen.c.accardi@intel.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>

On 06/21/2018 08:59 PM, Edgecombe, Rick P wrote:
> On Thu, 2018-06-21 at 15:37 +0200, Jann Horn wrote:
>> On Thu, Jun 21, 2018 at 12:34 AM Kees Cook <keescook@chromium.org>
>> wrote:
>>> And most systems have <200 modules, really. I have 113 on a desktop
>>> right now, 63 on a server. So this looks like a trivial win.
>> But note that the eBPF JIT also uses module_alloc(). Every time a BPF
>> program (this includes seccomp filters!) is JIT-compiled by the
>> kernel, another module_alloc() allocation is made. For example, on my
>> desktop machine, I have a bunch of seccomp-sandboxed processes thanks
>> to Chrome. If I enable the net.core.bpf_jit_enable sysctl and open a
>> few Chrome tabs, BPF JIT allocations start showing up between
>> modules:
>>
>> # grep -C1 bpf_jit_binary_alloc /proc/vmallocinfo | cut -d' ' -f 2-
>> A  20480 load_module+0x1326/0x2ab0 pages=4 vmalloc N0=4
>> A  12288 bpf_jit_binary_alloc+0x32/0x90 pages=2 vmalloc N0=2
>> A  20480 load_module+0x1326/0x2ab0 pages=4 vmalloc N0=4
>> --
>> A  20480 load_module+0x1326/0x2ab0 pages=4 vmalloc N0=4
>> A  12288 bpf_jit_binary_alloc+0x32/0x90 pages=2 vmalloc N0=2
>> A  36864 load_module+0x1326/0x2ab0 pages=8 vmalloc N0=8
>> --
>> A  20480 load_module+0x1326/0x2ab0 pages=4 vmalloc N0=4
>> A  12288 bpf_jit_binary_alloc+0x32/0x90 pages=2 vmalloc N0=2
>> A  40960 load_module+0x1326/0x2ab0 pages=9 vmalloc N0=9
>> --
>> A  20480 load_module+0x1326/0x2ab0 pages=4 vmalloc N0=4
>> A  12288 bpf_jit_binary_alloc+0x32/0x90 pages=2 vmalloc N0=2
>> A 253952 load_module+0x1326/0x2ab0 pages=61 vmalloc N0=61
>>
>> If you use Chrome with Site Isolation, you have a few dozen open
>> tabs,
>> and the BPF JIT is enabled, reaching a few hundred allocations might
>> not be that hard.
>>
>> Also: What's the impact on memory usage? Is this going to increase
>> the
>> number of pagetables that need to be allocated by the kernel per
>> module_alloc() by 4K or 8K or so?
> Thanks, it seems it might require some extra memory.A A I'll look into it
> to find out exactly how much.
> 
> I didn't include eBFP modules in the randomization estimates, but it
> looks like they are usually smaller than a page. A So with the slight
> leap that the larger normal modules based estimateA is the worst case,
> you should still get ~800 modules at 18 bits. After that it will start
> to go down to 10 bits and so in either case it at least won't regress
> the randomness of the existing algorithm.

Assume typically complex (real) programs at around 2.5k BPF insns today.
In our case it's max a handful per net device, thus approx per netns (veth)
which can be few hundreds. Worst case is 4k that BPF allows and then JITs.
There's a BPF kselftest suite you could also run to check on worst case
upper bounds.
