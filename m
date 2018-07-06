Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEDBB6B000A
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 22:55:41 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 13-v6so10433411oiq.1
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 19:55:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o11-v6sor5278475oib.108.2018.07.05.19.55.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 19:55:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180705082435.GA29656@gmail.com>
References: <153065162801.12250.4860144566061573514.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180705082435.GA29656@gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 5 Jul 2018 19:55:40 -0700
Message-ID: <CAPcyv4hw1a8+wwTYaQ0G0jWQzBCDaZ8zxYXw6gXtuWBYGX1LeQ@mail.gmail.com>
Subject: Re: [PATCH] x86/numa_emulation: Fix uniform size build failure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Wei Yang <richard.weiyang@gmail.com>, kbuild test robot <lkp@intel.com>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 5, 2018 at 1:24 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Dan Williams <dan.j.williams@intel.com> wrote:
>
>> The calculation of a uniform numa-node size attempted to perform
>> division with a 64-bit diviser leading to the following failure on
>> 32-bit:
>>
>>     arch/x86/mm/numa_emulation.o: In function `split_nodes_size_interleave_uniform':
>>     arch/x86/mm/numa_emulation.c:239: undefined reference to `__udivdi3'
>>
>> Convert the implementation to do the division in terms of pages and then
>> shift the result back to an absolute physical address.
>>
>> Fixes: 93e738834fcc ("x86/numa_emulation: Introduce uniform split capability")
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Cc: Wei Yang <richard.weiyang@gmail.com>
>> Reported-by: kbuild test robot <lkp@intel.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> I'm still getting this link failure on 32-bit kernels:
>
>  arch/x86/mm/numa_emulation.o: In function `split_nodes_size_interleave_uniform.constprop.1':
>  numa_emulation.c:(.init.text+0x669): undefined reference to `__udivdi3'
>  Makefile:1005: recipe for target 'vmlinux' failed
>
> config attached.
>
> These numa_emulation changes are a bit of a trainwreck - I'm removing both
> num_emulation commits from -tip for now, could you please resubmit a fixed/tested
> combo version?
>

So I squashed the fix and let the 0day robot chew on it all day with
no reports as of yet. I just recompiled it here and am not seeing the
link failure, can you send me the details of the kernel config + gcc
version that is failing?
