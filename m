Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 58F686B0009
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 18:16:55 -0500 (EST)
Received: by mail-yk0-f171.google.com with SMTP id u9so35979829ykd.1
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 15:16:55 -0800 (PST)
Received: from mail-yk0-x231.google.com (mail-yk0-x231.google.com. [2607:f8b0:4002:c07::231])
        by mx.google.com with ESMTPS id i8si12525855ybi.113.2016.02.01.15.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 15:16:54 -0800 (PST)
Received: by mail-yk0-x231.google.com with SMTP id z7so91398334yka.3
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 15:16:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+8MBbKSZKWQF5c+=P_c=jVkf0Xpky7ZJ4Jmyjq_RmDuNZnObA@mail.gmail.com>
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
	<CA+8MBbKSZKWQF5c+=P_c=jVkf0Xpky7ZJ4Jmyjq_RmDuNZnObA@mail.gmail.com>
Date: Mon, 1 Feb 2016 15:16:54 -0800
Message-ID: <CAPcyv4g0U_ein6XoznfHE2YozVx9bSuL2-qSw_ZiGGThZ61x+A@mail.gmail.com>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@amacapital.net>, linux-nvdimm <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Mon, Feb 1, 2016 at 3:10 PM, Tony Luck <tony.luck@gmail.com> wrote:
>> The most optimal way of alternatively calling two functions would be
>> something like this, IMO:
>>
>> alternative_call(memcpy, __mcsafe_copy, X86_FEATURE_MCRECOVERY,
>>                  ASM_OUTPUT2("=a" (mcsafe_ret.trapnr), "=d" (mcsafe_ret.remain)),
>>                  "D" (dst), "S" (src), "d" (len));
>>
>> I hope I've not messed up the calling convention but you want the inputs
>> in %rdi, %rsi, %rdx and the outputs in %rax, %rdx, respectively. Just
>> check the asm gcc generates and do not trust me :)
>>
>> The other thing you probably would need to do is create our own
>> __memcpy() which returns struct mcsafe_ret so that the signatures of
>> both functions match.
>>
>> Yeah, it is a bit of jumping through hoops but this way we do a CALL
>> <func_ptr> directly in asm, without any JMPs or NOPs padding the other
>> alternatives methods add.
>>
>> But if you don't care about a small JMP and that is not a hot path, you
>> could do the simpler:
>>
>>         if (static_cpu_has(X86_FEATURE_MCRECOVERY))
>>                 return __mcsafe_copy(...);
>>
>>         return memcpy();
>>
>> which adds a JMP or a 5-byte NOP depending on the X86_FEATURE_MCRECOVERY
>> setting.
>
> Dan,
>
> What do you want the API to look like at the point you make a call
> in the libnvdimm code?  Something like:
>
>         r = nvcopy(dst, src, len);
>
> where the innards of nvcopy() does the check for X86_FEATURE_MCE_RECOVERY?
>
> What is useful to you in the return value? The low level __mcsafe_copy() returns
> both a remainder and a trap number. But in your case I don't think you
> need the trap
> number (if the remaining count is not zero, then there must have been a #MC. #PF
> isn't an option for you, right?

RIght, we don't need a trap number just an error.  This is the v1
attempt at integrating mcsafe_copy:

https://lists.01.org/pipermail/linux-nvdimm/2016-January/003869.html

I think the only change needed is to use
static_cpu_has(X86_FEATURE_MCRECOVERY) like so:

+static inline int arch_memcpy_from_pmem(void *dst, const void __pmem *src,
+ size_t n)
+{
+ if (static_cpu_has(X86_FEATURE_MCRECOVERY)) {
+ struct mcsafe_ret ret;
+
+ ret = __mcsafe_copy(dst, (void __force *) src, n);
+ if (ret.remain)
+ return -EIO;
+ return 0;
+ }
+ memcpy(dst, (void __force *) src, n);
+ return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
