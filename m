Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 964C66B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 12:58:46 -0500 (EST)
Received: by iow186 with SMTP id 186so34640696iow.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 09:58:46 -0800 (PST)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id z134si19141987iod.50.2015.12.14.09.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 09:58:46 -0800 (PST)
Received: by igbxm8 with SMTP id xm8so89862756igb.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 09:58:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151212101142.GA3867@pd.tnic>
References: <cover.1449861203.git.tony.luck@intel.com>
	<456153d09e85f2f139020a051caed3ca8f8fca73.1449861203.git.tony.luck@intel.com>
	<20151212101142.GA3867@pd.tnic>
Date: Mon, 14 Dec 2015 10:58:45 -0700
Message-ID: <CAOxpaSX5SH7T2AqvGoFDtEWKc9k_-77gbQXQd7FYQZ-Ep2kRhA@mail.gmail.com>
Subject: Re: [PATCHV2 1/3] x86, ras: Add new infrastructure for machine check
 fixup tables
From: Ross Zwisler <zwisler@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tony Luck <tony.luck@intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Sat, Dec 12, 2015 at 3:11 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Thu, Dec 10, 2015 at 01:58:04PM -0800, Tony Luck wrote:
<>
>> +#ifdef CONFIG_MCE_KERNEL_RECOVERY
>> +/* Given an address, look for it in the machine check exception tables. */
>> +const struct exception_table_entry *search_mcexception_tables(
>> +                                 unsigned long addr)
>> +{
>> +     const struct exception_table_entry *e;
>> +
>> +     e = search_extable(__start___mcex_table, __stop___mcex_table-1, addr);
>> +     return e;
>> +}
>> +#endif
>
> You can make this one a bit more readable by doing:
>
> /* Given an address, look for it in the machine check exception tables. */
> const struct exception_table_entry *
> search_mcexception_tables(unsigned long addr)
> {
> #ifdef CONFIG_MCE_KERNEL_RECOVERY
>         return search_extable(__start___mcex_table,
>                                __stop___mcex_table - 1, addr);
> #endif
> }

With this code if CONFIG_MCE_KERNEL_RECOVERY isn't defined you'll get
a compiler error that the function doesn't have a return statement,
right?  I think we need an #else to return NULL, or to have the #ifdef
encompass the whole function definition as it was in Tony's version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
