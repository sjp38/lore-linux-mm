Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id E6A0E6B0009
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 18:10:35 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id p63so93953605wmp.1
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 15:10:35 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id wm7si42870013wjc.125.2016.02.01.15.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 15:10:34 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id 128so11265413wmz.3
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 15:10:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160130102803.GB15296@pd.tnic>
References: <CA+8MBbLUtVh3E4RqcHbZ165v+fURGYPm=ejOn2cOPq012BwLSg@mail.gmail.com>
	<CAPcyv4hAenpeqPsj7Rd0Un_SgDpm+CjqH3EK72ho-=zZFvG7wA@mail.gmail.com>
	<CALCETrVRgaWS86wq4B6oZbEY5_ODb3Nh5OeE9vvdGdds6j_pYg@mail.gmail.com>
	<CAPcyv4iCbp0oR_V+XCTduLd1t2UxyFwaoJVk0_vwk8aO2Uh=bQ@mail.gmail.com>
	<CA+8MBbLFb1gdhFWeG-3V4=gHd-fHK_n1oJEFCrYiNa8Af6XAng@mail.gmail.com>
	<20160110112635.GC22896@pd.tnic>
	<20160111104425.GA29448@gmail.com>
	<CA+8MBbJpFWdkwC-yvmDFdFuLrchv2-XhPd3fk8A_hqOOyzm5og@mail.gmail.com>
	<20160114043956.GA8496@pd.tnic>
	<CA+8MBbKdH8v=gkTqzxpPRX9-jBEobU9XaEfZh=4cOXDjPE9fBA@mail.gmail.com>
	<20160130102803.GB15296@pd.tnic>
Date: Mon, 1 Feb 2016 15:10:34 -0800
Message-ID: <CA+8MBbKSZKWQF5c+=P_c=jVkf0Xpky7ZJ4Jmyjq_RmDuNZnObA@mail.gmail.com>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@amacapital.net>, linux-nvdimm <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

> The most optimal way of alternatively calling two functions would be
> something like this, IMO:
>
> alternative_call(memcpy, __mcsafe_copy, X86_FEATURE_MCRECOVERY,
>                  ASM_OUTPUT2("=a" (mcsafe_ret.trapnr), "=d" (mcsafe_ret.remain)),
>                  "D" (dst), "S" (src), "d" (len));
>
> I hope I've not messed up the calling convention but you want the inputs
> in %rdi, %rsi, %rdx and the outputs in %rax, %rdx, respectively. Just
> check the asm gcc generates and do not trust me :)
>
> The other thing you probably would need to do is create our own
> __memcpy() which returns struct mcsafe_ret so that the signatures of
> both functions match.
>
> Yeah, it is a bit of jumping through hoops but this way we do a CALL
> <func_ptr> directly in asm, without any JMPs or NOPs padding the other
> alternatives methods add.
>
> But if you don't care about a small JMP and that is not a hot path, you
> could do the simpler:
>
>         if (static_cpu_has(X86_FEATURE_MCRECOVERY))
>                 return __mcsafe_copy(...);
>
>         return memcpy();
>
> which adds a JMP or a 5-byte NOP depending on the X86_FEATURE_MCRECOVERY
> setting.

Dan,

What do you want the API to look like at the point you make a call
in the libnvdimm code?  Something like:

        r = nvcopy(dst, src, len);

where the innards of nvcopy() does the check for X86_FEATURE_MCE_RECOVERY?

What is useful to you in the return value? The low level __mcsafe_copy() returns
both a remainder and a trap number. But in your case I don't think you
need the trap
number (if the remaining count is not zero, then there must have been a #MC. #PF
isn't an option for you, right?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
