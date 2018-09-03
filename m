Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7176B682C
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 09:49:46 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b8-v6so539521oib.4
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 06:49:46 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u206-v6si12549892oia.326.2018.09.03.06.49.45
        for <linux-mm@kvack.org>;
        Mon, 03 Sep 2018 06:49:45 -0700 (PDT)
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by
 sparse
References: <cover.1535629099.git.andreyknvl@google.com>
 <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
 <20180831081123.6mo62xnk54pvlxmc@ltop.local>
 <20180831134244.GB19965@ZenIV.linux.org.uk>
 <CAAeHK+w86m6YztnTGhuZPKRczb-+znZ1hiJskPXeQok4SgcaOw@mail.gmail.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <01cadefd-c929-cb45-500d-7043cf3943f6@arm.com>
Date: Mon, 3 Sep 2018 14:49:38 +0100
MIME-Version: 1.0
In-Reply-To: <CAAeHK+w86m6YztnTGhuZPKRczb-+znZ1hiJskPXeQok4SgcaOw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, linux-kselftest@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, Jacob Bramley <Jacob.Bramley@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 03/09/18 13:34, Andrey Konovalov wrote:
> On Fri, Aug 31, 2018 at 3:42 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>> On Fri, Aug 31, 2018 at 10:11:24AM +0200, Luc Van Oostenryck wrote:
>>> On Thu, Aug 30, 2018 at 01:41:16PM +0200, Andrey Konovalov wrote:
>>>> This patch adds __force annotations for __user pointers casts detected by
>>>> sparse with the -Wcast-from-as flag enabled (added in [1]).
>>>>
>>>> [1] https://github.com/lucvoo/sparse-dev/commit/5f960cb10f56ec2017c128ef9d16060e0145f292
>>>
>>> Hi,
>>>
>>> It would be nice to have some explanation for why these added __force
>>> are useful.
> 
> I'll add this in the next version, thanks!
> 
>>         It would be even more useful if that series would either deal with
>> the noise for real ("that's what we intend here, that's what we intend there,
>> here's a primitive for such-and-such kind of cases, here we actually
>> ought to pass __user pointer instead of unsigned long", etc.) or left it
>> unmasked.
>>
>>         As it is, __force says only one thing: "I know the code is doing
>> the right thing here".  That belongs in primitives, and I do *not* mean the
>> #define cast_to_ulong(x) ((__force unsigned long)(x))
>> kind.
>>
>>         Folks, if you don't want to deal with that - leave the warnings be.
>> They do carry more information than "someone has slapped __force in that place".
>>
>> Al, very annoyed by that kind of information-hiding crap...
> 
> This patch only adds __force to hide the reports I've looked at and
> decided that the code does the right thing. The cases where this is
> not the case are handled by the previous patches in the patchset. I'll
> this to the patch description as well. Is that OK?
> 
I think as well that we should make explicit the information that
__force is hiding.
A possible solution could be defining some new address spaces and use
them where it is relevant in the kernel. Something like:

# define __compat_ptr __attribute__((noderef, address_space(5)))
# define __tagged_ptr __attribute__((noderef, address_space(6)))

In this way sparse can still identify the casting and trigger a warning.

We could at that point modify sparse to ignore these conversions when a
specific flag is passed (i.e. -Wignore-compat-ptr, -Wignore-tagged-ptr)
to exclude from the generated warnings the ones we have already dealt
with.

What do you think about this approach?
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

-- 
Regards,
Vincenzo
