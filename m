Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id C17D26B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 14:16:45 -0500 (EST)
Received: by mail-yk0-f170.google.com with SMTP id v6so139815966ykc.2
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 11:16:45 -0800 (PST)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id y2si22288821ywe.350.2015.12.21.11.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 11:16:44 -0800 (PST)
Received: by mail-yk0-x22d.google.com with SMTP id x184so141006787yka.3
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 11:16:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151221181854.GF21582@pd.tnic>
References: <cover.1450283985.git.tony.luck@intel.com>
	<2e91c18f23be90b33c2cbfff6cce6b6f50592a96.1450283985.git.tony.luck@intel.com>
	<20151221181854.GF21582@pd.tnic>
Date: Mon, 21 Dec 2015 11:16:44 -0800
Message-ID: <CAPcyv4gum9EHTa80vAcFck2RXrALDquMu2EgaTOOXBYMj2zeKQ@mail.gmail.com>
Subject: Re: [PATCHV3 1/3] x86, ras: Add new infrastructure for machine check
 fixup tables
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Elliott@pd.tnic, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Mon, Dec 21, 2015 at 10:18 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Tue, Dec 15, 2015 at 05:29:30PM -0800, Tony Luck wrote:
>> Copy the existing page fault fixup mechanisms to create a new table
>> to be used when fixing machine checks. Note:
>> 1) At this time we only provide a macro to annotate assembly code
>> 2) We assume all fixups will in code builtin to the kernel.
>> 3) Only for x86_64
>> 4) New code under CONFIG_MCE_KERNEL_RECOVERY (default 'n')
>>
>> Signed-off-by: Tony Luck <tony.luck@intel.com>
>> ---
>>  arch/x86/Kconfig                  | 10 ++++++++++
>>  arch/x86/include/asm/asm.h        | 10 ++++++++--
>>  arch/x86/include/asm/mce.h        | 14 ++++++++++++++
>>  arch/x86/kernel/cpu/mcheck/mce.c  | 16 ++++++++++++++++
>>  arch/x86/kernel/vmlinux.lds.S     |  6 +++++-
>>  arch/x86/mm/extable.c             | 19 +++++++++++++++++++
>>  include/asm-generic/vmlinux.lds.h | 12 +++++++-----
>>  7 files changed, 79 insertions(+), 8 deletions(-)
>>
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index 96d058a87100..42d26b4d1ec4 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -1001,6 +1001,16 @@ config X86_MCE_INJECT
>>         If you don't know what a machine check is and you don't do kernel
>>         QA it is safe to say n.
>>
>> +config MCE_KERNEL_RECOVERY
>> +     bool "Recovery from machine checks in special kernel memory copy functions"
>> +     default n
>> +     depends on X86_MCE && X86_64
>
> Still no dependency on CONFIG_LIBNVDIMM.

I suggested we reverse the dependency and have the driver optionally
"select MCE_KERNEL_RECOVERY".  There may be other drivers outside of
LIBNVDIMM that want this functionality enabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
