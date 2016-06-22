Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67BD66B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 15:18:48 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id js8so46330732lbc.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 12:18:48 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id 205si1105493lfi.195.2016.06.22.12.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 12:18:46 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id l184so15253635lfl.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 12:18:46 -0700 (PDT)
Date: Wed, 22 Jun 2016 22:18:43 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: JITs and 52-bit VA
Message-ID: <20160622191843.GA2045@uranus.lan>
References: <4A8E6E6D-6CF7-4964-A62E-467AE287D415@linaro.org>
 <576AA67E.50009@codeaurora.org>
 <CALCETrWQi1n4nbk1BdEnvXy1u3-4fX7kgWn6OerqOxHM6OCgXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWQi1n4nbk1BdEnvXy1u3-4fX7kgWn6OerqOxHM6OCgXA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Christopher Covington <cov@codeaurora.org>, Maxim Kuvyrkov <maxim.kuvyrkov@linaro.org>, Linaro Dev Mailman List <linaro-dev@lists.linaro.org>, Arnd Bergmann <arnd.bergmann@linaro.org>, Mark Brown <broonie@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <dsafonov@virtuozzo.com>

On Wed, Jun 22, 2016 at 08:13:29AM -0700, Andy Lutomirski wrote:
...
> >
> > However based on the above discussion, it appears that some sort of
> > prctl(PR_GET_TASK_SIZE, ...) and prctl(PR_SET_TASK_SIZE, ...) may be
> > preferable for AArch64. (And perhaps other justifications for the new
> > calls influences the x86 decisions.) What do folks think?
> 
> I would advocate a slightly different approach:
> 
>  - Keep TASK_SIZE either unconditionally matching the hardware or keep
> TASK_SIZE as the actual logical split between user and kernel
> addresses.  Don't let it change at runtime under any circumstances.
> The reason is that there have been plenty of bugs and
> overcomplications that result from letting it vary.  For example, if
> (addr < TASK_SIZE) really ought to be the correct check (assuming
> USER_DS, anyway) for whether dereferencing addr will access user
> memory, at least on architectures with a global address space (which
> is most of them, I think).
> 
>  - If needed, introduce a clean concept of the maximum address that
> mmap will return, but don't call it TASK_SIZE.  So, if a user program
> wants to limit itself to less than the full hardware VA space (or less
> than 63 bits, for that matter), it can.
> 
> As an example, a 32-bit x86 program really could have something mapped
> above the 32-bit boundary.  It just wouldn't be useful, but the kernel
> should still understand that it's *user* memory.
> 
> So you'd have PR_SET_MMAP_LIMIT and PR_GET_MMAP_LIMIT or similar instead.

+1. Also it might be (not sure though, just guessing) suitable to do such
thing via memory cgroup controller, instead of carrying this limit per
each process (or task structure/vma or mm).

> Also, before getting *too* excited about this kind of VA limit, keep
> in mind that SPARC has invented this thingly called "Application Data
> Integrity".  It reuses some of the high address bits in hardware for
> other purposes.  I wouldn't be totally shocked if other architectures
> followed suit. (Although no one should copy SPARC's tagging scheme,
> please: it's awful.  these things should be controlled at the MMU
> level, not the cache tag level.  Otherwise aliased mappings get very
> confused.)

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
