Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8EF6B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 15:56:57 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so126112092pfa.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 12:56:57 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id h24si1515152pfk.146.2016.06.22.12.56.56
        for <linux-mm@kvack.org>;
        Wed, 22 Jun 2016 12:56:56 -0700 (PDT)
Subject: Re: JITs and 52-bit VA
References: <4A8E6E6D-6CF7-4964-A62E-467AE287D415@linaro.org>
 <576AA67E.50009@codeaurora.org>
 <CALCETrWQi1n4nbk1BdEnvXy1u3-4fX7kgWn6OerqOxHM6OCgXA@mail.gmail.com>
 <20160622191843.GA2045@uranus.lan>
 <CALCETrUH0uxfASkHkVVJhuFkEXvuVXhLc-Ed=Utn9E5vzx=Vzg@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <576AED88.6040805@intel.com>
Date: Wed, 22 Jun 2016 12:56:56 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrUH0uxfASkHkVVJhuFkEXvuVXhLc-Ed=Utn9E5vzx=Vzg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Christopher Covington <cov@codeaurora.org>, Maxim Kuvyrkov <maxim.kuvyrkov@linaro.org>, Linaro Dev Mailman List <linaro-dev@lists.linaro.org>, Arnd Bergmann <arnd.bergmann@linaro.org>, Mark Brown <broonie@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <dsafonov@virtuozzo.com>

On 06/22/2016 12:20 PM, Andy Lutomirski wrote:
>>> >> As an example, a 32-bit x86 program really could have something mapped
>>> >> above the 32-bit boundary.  It just wouldn't be useful, but the kernel
>>> >> should still understand that it's *user* memory.
>>> >>
>>> >> So you'd have PR_SET_MMAP_LIMIT and PR_GET_MMAP_LIMIT or similar instead.
>> >
>> > +1. Also it might be (not sure though, just guessing) suitable to do such
>> > thing via memory cgroup controller, instead of carrying this limit per
>> > each process (or task structure/vma or mm).
> I think we'll want this per mm.  After all, a high-VA-limit-aware bash
> should be able run high-VA-unaware programs without fiddling with
> cgroups.

Yeah, cgroups don't make a lot of sense.

On x86, the 48-bit virtual address is even hard-coded in the ABI[1].  So
we can't change *any* program's layout without either breaking the ABI
or having it opt in.

But, we're also lucky to only have one VA layout since day one.

1. www.x86-64.org/documentation/abi.pdf - a??... Therefore, conforming
processes may only use addresses from 0x00000000 00000000 to 0x00007fff
ffffffff .a??


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
