Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC5A86B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 11:09:44 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id q35so11214764otg.14
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 08:09:44 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i8sor4368808oia.240.2018.02.13.08.09.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Feb 2018 08:09:40 -0800 (PST)
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-5-igor.stoppa@huawei.com>
 <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
 <20180126053542.GA30189@bombadil.infradead.org>
 <alpine.DEB.2.20.1802021236510.31548@nuc-kabylake>
 <f2ddaed0-313e-8664-8a26-9d10b66ed0c5@huawei.com>
 <b75b5903-0177-8ad9-5c2b-fc63438fb5f2@huawei.com>
 <CAFUG7CfrCpcbwgf5ixMC5EZZgiVVVp1NXhDHK1UoJJcC08R2qQ@mail.gmail.com>
 <8818bfd4-dd9f-f279-0432-69b59531bd41@huawei.com>
 <CAFUG7CeUhFcvA82uZ2ZH1j_6PM=aBo4XmYDN85pf8G0gPU44dg@mail.gmail.com>
 <17e5b515-84c8-dca2-1695-cdf819834ea2@huawei.com>
 <CAGXu5j+LS1pgOOroi7Yxp2nh=DwtTnU3p-NZa6bQu_wkvvVkwg@mail.gmail.com>
 <414027d3-dd73-cf11-dc2a-e8c124591646@redhat.com>
 <CAGXu5j++igQD4tMh0J8nZ9jNji5mU16C7OygFJ5Td+Bq-KSMgw@mail.gmail.com>
 <CAG48ez1utN_vwHUwk=BU6zM4Wa_53TPu8rm9JuTtY-vGP0Shqw@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <f4226a44-92fd-8ead-b458-7551ba82f96d@redhat.com>
Date: Tue, 13 Feb 2018 08:09:35 -0800
MIME-Version: 1.0
In-Reply-To: <CAG48ez1utN_vwHUwk=BU6zM4Wa_53TPu8rm9JuTtY-vGP0Shqw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, Boris Lukashev <blukashev@sempervictus.com>, Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@infradead.org>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On 02/12/2018 07:39 PM, Jann Horn wrote:
> On Tue, Feb 13, 2018 at 2:25 AM, Kees Cook <keescook@chromium.org> wrote:
>> On Mon, Feb 12, 2018 at 4:40 PM, Laura Abbott <labbott@redhat.com> wrote:
>>> On 02/12/2018 03:27 PM, Kees Cook wrote:
>>>>
>>>> On Sun, Feb 4, 2018 at 7:05 AM, Igor Stoppa <igor.stoppa@huawei.com>
>>>> wrote:
>>>>>
>>>>> On 04/02/18 00:29, Boris Lukashev wrote:
>>>>>>
>>>>>> On Sat, Feb 3, 2018 at 3:32 PM, Igor Stoppa <igor.stoppa@huawei.com>
>>>>>> wrote:
>>>>>
>>>>>
>>>>> [...]
>>>>>
>>>>>>> What you are suggesting, if I have understood it correctly, is that,
>>>>>>> when the pool is protected, the addresses already given out, will
>>>>>>> become
>>>>>>> traps that get resolved through a lookup table that is built based on
>>>>>>> the content of each allocation.
>>>>>>>
>>>>>>> That seems to generate a lot of overhead, not to mention the fact that
>>>>>>> it might not play very well with the MMU.
>>>>>>
>>>>>>
>>>>>> That is effectively what i'm suggesting - as a form of protection for
>>>>>> consumers against direct reads of data which may have been corrupted
>>>>>> by some irrelevant means. In the context of pmalloc, it would probably
>>>>>> be a separate type of ro+verified pool
>>>>>
>>>>> ok, that seems more like an extension though.
>>>>>
>>>>> ATM I am having problems gaining traction to get even the basic merged
>>>>> :-)
>>>>>
>>>>> I would consider this as a possibility for future work, unless it is
>>>>> said that it's necessary for pmalloc to be accepted ...
>>>>
>>>>
>>>> I would agree: let's get basic functionality in first. Both
>>>> verification and the physmap part can be done separately, IMO.
>>>
>>>
>>> Skipping over physmap leaves a pretty big area of exposure that could
>>> be difficult to solve later. I appreciate this might block basic
>>> functionality but I don't think we should just gloss over it without
>>> at least some idea of what we would do.
>>
>> What's our exposure on physmap for other regions? e.g. things that are
>> executable, or made read-only later (like __ro_after_init)?
> 
> I just checked on a system with a 4.9 kernel, and there seems to be no
> physical memory that is mapped as writable in the init PGD and
> executable elsewhere.
> 
> Ah, I think I missed something. At least on X86, set_memory_ro,
> set_memory_rw, set_memory_nx and set_memory_x all use
> change_page_attr_clear/change_page_attr_set, which use
> change_page_attr_set_clr, which calls __change_page_attr_set_clr()
> with a second parameter "checkalias" that is set to 1 unless the bit
> being changed is the NX bit, and that parameter causes the invocation
> of cpa_process_alias(), which will, for mapped ranges, also change the
> attributes of physmap ranges. set_memory_ro() and so on are also used
> by the module loading code.
> 
> But in the ARM64 code, I don't see anything similar. Does anyone with
> a better understanding of ARM64 want to check whether I missed
> something? Or maybe, with a recent kernel, check whether executable
> module pages show up with a second writable mapping in the
> "kernel_page_tables" file in debugfs?
> 

No, arm64 doesn't fixup the aliases, mostly because arm64 uses larger
page sizes which can't be broken down at runtime. CONFIG_PAGE_POISONING
does use 4K pages which could be adjusted at runtime. So yes, you are
right we would have physmap exposure on arm64 as well.

To the original question, it does sound like we are actually okay
with the physmap.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
