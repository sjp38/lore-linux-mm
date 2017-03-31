Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6AC6B0397
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 13:05:32 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id h186so26509356vkg.17
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 10:05:32 -0700 (PDT)
Received: from mail-vk0-x229.google.com (mail-vk0-x229.google.com. [2607:f8b0:400c:c05::229])
        by mx.google.com with ESMTPS id d10si2519763uaa.249.2017.03.31.10.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 10:05:31 -0700 (PDT)
Received: by mail-vk0-x229.google.com with SMTP id r69so98211375vke.2
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 10:05:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170331080046.GI27098@dhcp22.suse.cz>
References: <alpine.LSU.2.20.1703290958390.4250@pobox.suse.cz>
 <1490767322-9914-1-git-send-email-maninder1.s@samsung.com>
 <20170329074522.GB27994@dhcp22.suse.cz> <CGME20170329060315epcas5p1c6f7ce3aca1b2770c5e1d9aaeb1a27e1@epcms5p1>
 <20170329092332epcms5p10ae8263c6e3ef14eac40e08a09eff9e6@epcms5p1>
 <20170329104355.GG27994@dhcp22.suse.cz> <CAJWu+opsnoyJZ7ZL2OVVzhn04ds-Z5VPYau7iB-OZDpjyqciTA@mail.gmail.com>
 <20170331080046.GI27098@dhcp22.suse.cz>
From: Joel Fernandes <joelaf@google.com>
Date: Fri, 31 Mar 2017 10:05:29 -0700
Message-ID: <CAJWu+ooKE0yC5t-nk4SyPphn3vjRVeZxMzdEwCrQSjhP=mryKQ@mail.gmail.com>
Subject: Re: [PATCH v2] module: check if memory leak by module.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vaneet Narang <v.narang@samsung.com>, Miroslav Benes <mbenes@suse.cz>, Maninder Singh <maninder1.s@samsung.com>, "jeyu@redhat.com" <jeyu@redhat.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris@chris-wilson.co.uk" <chris@chris-wilson.co.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "joonas.lahtinen@linux.intel.com" <joonas.lahtinen@linux.intel.com>, "keescook@chromium.org" <keescook@chromium.org>, "pavel@ucw.cz" <pavel@ucw.cz>, "jinb.park7@gmail.com" <jinb.park7@gmail.com>, "anisse@astier.eu" <anisse@astier.eu>, "rafael.j.wysocki@intel.com" <rafael.j.wysocki@intel.com>, "zijun_hu@htc.com" <zijun_hu@htc.com>, "mingo@kernel.org" <mingo@kernel.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "thgarnie@google.com" <thgarnie@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, PANKAJ MISHRA <pankaj.m@samsung.com>, Ajeet Kumar Yadav <ajeet.y@samsung.com>, =?UTF-8?B?7J207ZWZ67SJ?= <hakbong5.lee@samsung.com>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, =?UTF-8?B?656E66a/?= <lalit.mohan@samsung.com>, CPGS <cpgs@samsung.com>

On Fri, Mar 31, 2017 at 1:00 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 30-03-17 23:49:52, Joel Fernandes wrote:
>> Hi Michal,
>>
>> On Wed, Mar 29, 2017 at 3:43 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Wed 29-03-17 09:23:32, Vaneet Narang wrote:
>> >> Hi,
>> >>
>> >> >> Hmm, how can you track _all_ vmalloc allocations done on behalf of the
>> >> >> module? It is quite some time since I've checked kernel/module.c but
>> >> >> from my vague understading your check is basically only about statically
>> >> >> vmalloced areas by module loader. Is that correct? If yes then is this
>> >> >> actually useful? Were there any bugs in the loader code recently? What
>> >> >> led you to prepare this patch? All this should be part of the changelog!
>> >>
>> >> First of all there is no issue in kernel/module.c. This patch add functionality
>> >> to detect scenario where some kernel module does some memory allocation but gets
>> >> unloaded without doing vfree. For example
>> >> static int kernel_init(void)
>> >> {
>> >>         char * ptr = vmalloc(400 * 1024);
>> >>         return 0;
>> >> }
>> >
>> > How can you track that allocation back to the module? Does this patch
>> > actually works at all? Also why would be vmalloc more important than
>> > kmalloc allocations?
>>
>> Doesn't the patch use caller's (in this case, the module is the
>> caller) text address for tracking this? vma->vm->caller should track
>> the caller doing the allocation?
>
> Not really. First of all it will be vmalloc() to be tracked in the above
> the example because vmalloc is not inlined. And secondly even if the

vmalloc is not inlined, but __built_in_address(0) will return the
*return address* of vmalloc:

>From https://gcc.gnu.org/onlinedocs/gcc-4.6.0/gcc/Return-Address.html :
"The level argument is number of frames to scan up the call stack. A
value of 0 yields the return address of the current function"

> caller of the vmalloc was tracked then it would be hopelessly
> insufficient because you would get coverage of the _direct_ module usage
> of vmalloc rather than anything that the module triggered and that is
> outside of the module. Which means any library function etc...

Yes true, but I think the check is for direct allocations, done by the
module, not indirect ones... it may not be a catch-all issues type of
deal but is still IMO a good check since we already have
va->vm->caller available.

Thanks,
Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
