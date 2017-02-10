Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 806F66B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 00:00:20 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id j82so26271129oih.6
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 21:00:20 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id v88si244237ota.185.2017.02.09.21.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 21:00:19 -0800 (PST)
Received: by mail-oi0-x232.google.com with SMTP id w204so14972315oiw.0
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 21:00:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1486653999.2900.63.camel@decadent.org.uk>
References: <20170118104625.550018627@linuxfoundation.org> <20170118104625.789178853@linuxfoundation.org>
 <1486653999.2900.63.camel@decadent.org.uk>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 9 Feb 2017 21:00:19 -0800
Message-ID: <CAPcyv4iFwmQnLRdW0whHLC0W_1Y2-j89vxxHyP=yD1mwGPBaHQ@mail.gmail.com>
Subject: Re: [PATCH 4.4 05/48] mm: fix devm_memremap_pages crash, use
 mem_hotplug_{begin, done}
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Thu, Feb 9, 2017 at 7:26 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Wed, 2017-01-18 at 11:46 +0100, Greg Kroah-Hartman wrote:
>> 4.4-stable review patch.  If anyone has any objections, please let me know.
>>
>> ------------------
>>
>> From: Dan Williams <dan.j.williams@intel.com>
>>
>> commit f931ab479dd24cf7a2c6e2df19778406892591fb upstream.
>>
>> Both arch_add_memory() and arch_remove_memory() expect a single threaded
>> context.
> [...]
>> The result is that two threads calling devm_memremap_pages()
>> simultaneously can end up colliding on pgd initialization.  This leads
>> to crash signatures like the following where the loser of the race
>> initializes the wrong pgd entry:
> [...]
>> Hold the standard memory hotplug mutex over calls to
>> arch_{add,remove}_memory().
> [...]
>
> This is not a sufficient fix, because memory_hotplug.c still assumes
> there's only one 'writer':
>
> void put_online_mems(void)
> {
>         ...
>         if (!--mem_hotplug.refcount && unlikely(mem_hotplug.active_writer))
>                 wake_up_process(mem_hotplug.active_writer);
>         ...
> }
>
> void mem_hotplug_begin(void)
> {
>         mem_hotplug.active_writer = current;
>
>         memhp_lock_acquire();
>         for (;;) {
>                 mutex_lock(&mem_hotplug.lock);
>                 if (likely(!mem_hotplug.refcount))
>                         break;
>                 __set_current_state(TASK_UNINTERRUPTIBLE);
>                 mutex_unlock(&mem_hotplug.lock);
>                 schedule();
>         }
> }
>
> With multiple writers, one or more of them may hang or
> {get,put}_online_mems() may mess up the hotplug reference count.

You're right. We need to hold lock_device_hotplug_sysfs() before
calling mem_hotplug_begin().  I'll take a look at a follow-on fix and
also add an assert_held_device_hotplug() helper to catch this in the
future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
