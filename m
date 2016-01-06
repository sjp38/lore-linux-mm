Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 182856B0005
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 12:05:02 -0500 (EST)
Received: by mail-yk0-f175.google.com with SMTP id k129so299637712yke.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 09:05:02 -0800 (PST)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com. [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id c3si81140ywe.137.2016.01.06.09.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 09:05:01 -0800 (PST)
Received: by mail-yk0-x22e.google.com with SMTP id v14so228762664ykd.3
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 09:05:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39FA3D50@ORSMSX114.amr.corp.intel.com>
References: <cover.1451952351.git.tony.luck@intel.com>
	<5b0243c5df825ad0841f4bb5584cd15d3f013f09.1451952351.git.tony.luck@intel.com>
	<CAPcyv4jjWT3Od_XvGpVb+O7MT95mBRXviPXi1zUfM5o+kN4CUA@mail.gmail.com>
	<A527EC4B-4069-4FDE-BE4C-5279C45BCABE@intel.com>
	<CAPcyv4iijhdXnD-4PuHkzbhhPra8eCRZ=df3XTE=z-efbQmVww@mail.gmail.com>
	<CAPcyv4g1dGC2YMN+JZPKhzbCm8PQJ7nJqV4JGjJ3w1PAf12v+Q@mail.gmail.com>
	<3908561D78D1C84285E8C5FCA982C28F39FA3D50@ORSMSX114.amr.corp.intel.com>
Date: Wed, 6 Jan 2016 09:05:01 -0800
Message-ID: <CAPcyv4j3uvN4S=okc36N7PaMGf3HtUOwCf75-Vs9OtmA2nhKuw@mail.gmail.com>
Subject: Re: [PATCH v7 3/3] x86, mce: Add __mcsafe_copy()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Wed, Jan 6, 2016 at 8:57 AM, Luck, Tony <tony.luck@intel.com> wrote:
>>> I do select it, but by randconfig I still need to handle the
>>> CONFIG_X86_MCE=n case.
>>>
>>>> I'm seriously wondering whether the ifdef still makes sense. Now I don't have an extra exception table and routines to sort/search/fixup, it doesn't seem as useful as it was a few iterations ago.
>>>
>>> Either way is ok with me.  That said, the extra definitions to allow
>>> it compile out when not enabled don't seem too onerous.
>>
>> This works for me, because all we need is the definitions.  As long as
>> we don't attempt to link to mcsafe_copy() we get the benefit of
>> compiling this out when de-selected:
>
> It seems  that Kconfig's "select" statement doesn't auto-select other things
> that are dependencies of the symbol you choose.
>
> CONFIG_MCE_KERNEL_RECOVERY really is dependent on
> CONFIG_X86_MCE ... having the code for the __mcsafe_copy()
> linked into the kernel won't do you any good without a machine
> check handler that jumps to the fixup code.
>
> So I think you have to select X86_MCE as well (or Kconfig needs
> to be taught to do it automatically ... but I have a nagging feeling
> that this is known behavior).
>

I don't want to force it on, otherwise we might as well remove the
ability to configure it.  Instead I have this:

config BLK_DEV_PMEM
       select MCE_KERNEL_RECOVERY if X86_MCE && X86_64

...that way if you turn on X86_MCE and BLK_DEV_PMEM you get
MCE_KERNEL_RECOVERY by default.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
