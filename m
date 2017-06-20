Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD226B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 19:29:18 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id c139so1240196ioc.3
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 16:29:18 -0700 (PDT)
Received: from mail-it0-x22b.google.com (mail-it0-x22b.google.com. [2607:f8b0:4001:c0b::22b])
        by mx.google.com with ESMTPS id 6si16378297itn.5.2017.06.20.16.29.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 16:29:16 -0700 (PDT)
Received: by mail-it0-x22b.google.com with SMTP id b205so23104585itg.1
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 16:29:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1eb1cfff-14f0-8fa9-1b48-679865339646@infradead.org>
References: <20170620230911.GA25238@beast> <1eb1cfff-14f0-8fa9-1b48-679865339646@infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 20 Jun 2017 16:29:15 -0700
Message-ID: <CAGXu5jLUqqg-aAD6mGs613GCH6H443+3VU9OfCca+=Lf+Z9j9g@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Allow slab_nomerge to be set at build time
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Christoph Lameter <cl@linux.com>, Jonathan Corbet <corbet@lwn.net>, Daniel Micay <danielmicay@gmail.com>, David Windsor <dave@nullcore.net>, Eric Biggers <ebiggers3@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 20, 2017 at 4:16 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
> On 06/20/2017 04:09 PM, Kees Cook wrote:
>> Some hardened environments want to build kernels with slab_nomerge
>> already set (so that they do not depend on remembering to set the kernel
>> command line option). This is desired to reduce the risk of kernel heap
>> overflows being able to overwrite objects from merged caches and changes
>> the requirements for cache layout control, increasing the difficulty of
>> these attacks. By keeping caches unmerged, these kinds of exploits can
>> usually only damage objects in the same cache (though the risk to metadata
>> exploitation is unchanged).
>>
>> Cc: Daniel Micay <danielmicay@gmail.com>
>> Cc: David Windsor <dave@nullcore.net>
>> Cc: Eric Biggers <ebiggers3@gmail.com>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>> v2: split out of slab whitelisting series
>> ---
>>  Documentation/admin-guide/kernel-parameters.txt | 10 ++++++++--
>>  init/Kconfig                                    | 14 ++++++++++++++
>>  mm/slab_common.c                                |  5 ++---
>>  3 files changed, 24 insertions(+), 5 deletions(-)
>
>> diff --git a/init/Kconfig b/init/Kconfig
>> index 1d3475fc9496..ce813acf2f4f 100644
>> --- a/init/Kconfig
>> +++ b/init/Kconfig
>> @@ -1891,6 +1891,20 @@ config SLOB
>>
>>  endchoice
>>
>> +config SLAB_MERGE_DEFAULT
>> +     bool "Allow slab caches to be merged"
>> +     default y
>> +     help
>> +       For reduced kernel memory fragmentation, slab caches can be
>> +       merged when they share the same size and other characteristics.
>> +       This carries a risk of kernel heap overflows being able to
>> +       overwrite objects from merged caches (and more easily control
>> +       cache layout), which makes such heap attacks easier to exploit
>> +       by attackers. By keeping caches unmerged, these kinds of exploits
>> +       can usually only damage objects in the same cache. To disable
>> +       merging at runtime, "slab_nomerge" can be passed on the kernel
>> +       command line.
>
>           command line or this option can be disabled in the kernel config.

Isn't that implicit in that it is Kconfig help text? Happy to add it,
but seems redundant to me.

-Kees

>
>> +
>>  config SLAB_FREELIST_RANDOM
>>       default n
>>       depends on SLAB || SLUB
>
> --
> ~Randy



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
