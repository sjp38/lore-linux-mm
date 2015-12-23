Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3B01482F64
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 14:31:02 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id l9so100136147oia.2
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 11:31:02 -0800 (PST)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com. [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id vw13si4270287oeb.82.2015.12.23.11.31.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Dec 2015 11:31:01 -0800 (PST)
Received: by mail-ob0-x22c.google.com with SMTP id iw8so171057807obc.1
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 11:31:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151223125853.GF30213@pd.tnic>
References: <cover.1450283985.git.tony.luck@intel.com>
	<d560d03663b6fd7a5bbeae9842934f329a7dcbdf.1450283985.git.tony.luck@intel.com>
	<20151222111349.GB3728@pd.tnic>
	<CA+8MBbJ+T0Bkea48rivWEZRn8_iPiSvrPm5p22RfbS7V0_KyEA@mail.gmail.com>
	<20151223125853.GF30213@pd.tnic>
Date: Wed, 23 Dec 2015 11:31:00 -0800
Message-ID: <CAPcyv4gXDHGgiqfve_fP1RLXBGfyWarjWgUU3QPMhnFn_BbshA@mail.gmail.com>
Subject: Re: [PATCHV3 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tony Luck <tony.luck@gmail.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Elliott@pd.tnic, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>

On Wed, Dec 23, 2015 at 4:58 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Tue, Dec 22, 2015 at 11:38:07AM -0800, Tony Luck wrote:
>> I interpreted that comment as "stop playing with %rax in the fault
>> handler ... just change the IP to point the the .fixup location" ...
>> the target of the fixup being the "landing pad".
>>
>> Right now this function has only one set of fault fixups (for machine
>> checks). When I tackle copy_from_user() it will sprout a second
>> set for page faults, and then will look a bit more like Andy's dual
>> landing pad example.
>>
>> I still need an indicator to the caller which type of fault happened
>> since their actions will be different. So BIT(63) lives on ... but is
>> now set in the .fixup section rather than in the machine check
>> code.
>
> You mean this previous example of yours:
>
> int copy_from_user(void *to, void *from, unsigned long n)
> {
>         u64 ret = mcsafe_memcpy(to, from, n);
>
>         if (COPY_HAD_MCHECK(r)) {
>                 if (memory_failure(COPY_MCHECK_PADDR(ret) >> PAGE_SIZE, ...))
>                         force_sig(SIGBUS, current);
>                 return something;
>         } else
>                 return ret;
> }
>
> ?
>
> So what's wrong with mcsafe_memcpy() returning a proper retval which
> says what type of fault happened?
>
> I know, memcpy returns the ptr to @dest like a parrot but your version
> mcsafe_memcpy() will be different. It can even be called __mcsafe_memcpy
> and have a wrapper around it which fiddles out the proper retvals and
> returns @dest after all. It would still be cleaner this way IMHO.

We might leave this to the consumer.  It's already the case that
mcsafe_memcpy() is arch specific so I'm having to wrap its return
value into a generic value.  My current thinking is make
memcpy_from_pmem() return a pmem_cookie_t, and then have an arch
specific pmem_copy_error(pmem_cookit_t cookie) helper that interprets
the value.  This is similar to the situation we have with
dma_mapping_error().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
