Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id A0C666B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:43:37 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id na2so15911907lbb.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 10:43:37 -0700 (PDT)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id e125si8655249lfg.57.2016.06.15.10.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 10:43:35 -0700 (PDT)
Received: by mail-lf0-x22d.google.com with SMTP id q132so23050359lfe.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 10:43:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLH+UzOhPfj5VkydHg=ZxbrQHQe6C1C-dbCBzsAmW9M2Q@mail.gmail.com>
References: <201606140353.WeDaHl1M%fengguang.wu@intel.com> <20160613141123.fcb245b6a7fd3199ae8a32d7@linux-foundation.org>
 <CAGXu5jLH+UzOhPfj5VkydHg=ZxbrQHQe6C1C-dbCBzsAmW9M2Q@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 15 Jun 2016 10:43:34 -0700
Message-ID: <CAGXu5jJ-ga0pXVtkCFSS6tGnsuhhNxOOguexUU14_4fwa3Uaeg@mail.gmail.com>
Subject: Re: [mel:mm-vmscan-node-lru-v7r3 38/200] slub.c:undefined reference
 to `cache_random_seq_create'
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Mel Gorman <mgorman@suse.de>, Thomas Garnier <thgarnie@google.com>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Jun 13, 2016 at 4:51 PM, Kees Cook <keescook@chromium.org> wrote:
> On Mon, Jun 13, 2016 at 2:11 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Tue, 14 Jun 2016 03:37:57 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
>>
>>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mel/linux mm-vmscan-node-lru-v7r3
>>> head:   276a5614a25ce20248f42bd4fb025b80ae0c9be1
>>> commit: 44c61fe5d7f13025a2a1f6efbbc0da75ad93ee19 [38/200] mm: SLUB freelist randomization
>>> config: x86_64-randconfig-x018-06140033 (attached as .config)
>>> compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
>>> reproduce:
>>>         git checkout 44c61fe5d7f13025a2a1f6efbbc0da75ad93ee19
>>>         # save the attached .config to linux build tree
>>>         make ARCH=x86_64
>>>
>>> All errors (new ones prefixed by >>):
>>>
>>>    mm/built-in.o: In function `init_cache_random_seq':
>>> >> slub.c:(.text+0x507dc): undefined reference to `cache_random_seq_create'
>>>    mm/built-in.o: In function `__kmem_cache_release':
>>> >> (.text+0x53979): undefined reference to `cache_random_seq_destroy'
>
> With that config, I get these errors.

The above errors were already fixed in
mm-slub-freelist-randomization-fix (moving it out of CONFIG_SLABINFO).

>
>> I don't even get that far with that .config.  With gcc-4.4.4 I get
>>
>> init/built-in.o: In function `initcall_blacklisted':
>> main.c:(.text+0x41): undefined reference to `__stack_chk_guard'
>> main.c:(.text+0xbe): undefined reference to `__stack_chk_guard'
>> init/built-in.o: In function `do_one_initcall':
>> (.text+0xeb): undefined reference to `__stack_chk_guard'
>> init/built-in.o: In function `do_one_initcall':
>> (.text+0x22b): undefined reference to `__stack_chk_guard'
>> init/built-in.o: In function `name_to_dev_t':
>> (.text+0x320): undefined reference to `__stack_chk_guard'
>> init/built-in.o:(.text+0x52e): more undefined references to `__stack_chk_guard'
>
> This, I don't. I'm scratching my head about how that's possible. The
> __stack_chk_guard is a compiler alias on x86...
>
>> Kees touched it last :)
>
> I'll take a closer look tomorrow...

Stupid question: were you doing a build for x86? This error really
shouldn't be possible since gcc defaults to tls for the guard on x86.
I don't have gcc 4.4.4 easily available, but I don't think it even has
the -mstack-protector-guard option to force this to change. (And I see
no reference to this option in the kernel tree.) AFAICT this error
should only happen when building with either
-mstack-protector-guard=global or an architecture that forces that,
along with some new code that triggers the stack protector but lacks
the symbol at link time, which also seems impossible. :P

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
