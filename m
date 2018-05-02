Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9DFCA6B0003
	for <linux-mm@kvack.org>; Wed,  2 May 2018 17:50:47 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f19-v6so10980945pgv.4
        for <linux-mm@kvack.org>; Wed, 02 May 2018 14:50:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 1-v6si12071170plp.532.2018.05.02.14.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 14:50:46 -0700 (PDT)
Date: Wed, 2 May 2018 14:50:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3 v2] linux-next: mm: Track genalloc allocations
Message-Id: <20180502145044.373c268eeaaa9022b99f9191@linux-foundation.org>
In-Reply-To: <20180502010522.28767-1-igor.stoppa@huawei.com>
References: <20180502010522.28767-1-igor.stoppa@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: mhocko@kernel.org, keescook@chromium.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-security-module@vger.kernel.org, willy@infradead.org, labbott@redhat.com, linux-kernel@vger.kernel.org, igor.stoppa@huawei.com

On Wed,  2 May 2018 05:05:19 +0400 Igor Stoppa <igor.stoppa@gmail.com> wrote:

> This patchset was created as part of an older version of pmalloc, however
> it has value per-se, as it hardens the memory management for the generic
> allocator genalloc.
> 
> Genalloc does not currently track the size of the allocations it hands
> out.
> 
> Either by mistake, or due to an attack, it is possible that more memory
> than what was initially allocated is freed, leaving behind dangling
> pointers, ready for an use-after-free attack.
> 
> With this patch, genalloc becomes capable of tracking the size of each
> allocation it has handed out, when it's time to free it.
> 
> It can either verify that the size received is correct, when free is
> invoked, or it can decide autonomously how much memory to free, if the
> value received for the size parameter is 0.
> 
> These patches are proposed for beign merged into linux-next, to verify
> that they do not introduce regressions, by comparing the value received
> from the callers of the free function with the internal tracking.
> 
> For this reason, the patchset does not contain the removal of the size
> parameter from users of the free() function.
> 
> Later on, the "size" parameter can be dropped, and each caller can be
> adjusted accordingly.
> 
> However, I do not have access to most of the HW required for confirming
> that all of its users are not negatively affected.
> This is where I believe having the patches in linux-next would help to
> coordinate with the maintaiers of the code that uses gen_alloc.
> 
> Since there were comments about the (lack-of) efficiency introduced by
> this patchset, I have added some more explanations and calculations to the
> description of the first patch, the one adding the bitmap.
> My conclusion is that this patch should not cause any major perfomance
> problem.
> 
> Regarding the possibility of completely changing genalloc into some other
> type of allocator, I think it should not be a showstopper for this
> patchset, which aims to plug a security hole in genalloc, without
> introducing any major regression.
> 
> The security flaw is clear and present, while the benefit of introducing a
> new allocator is not clear, at least for the current users of genalloc.
> 
> And anyway the users of genalloc should be fixed to not pass any size
> parameter, which can be done after this patch is merged.
> 
> A newer, more efficient allocator will still benefit from not receiving a
> spurious parameter (size), when freeing memory.
> 
> ...
> 
>  Documentation/core-api/genalloc.rst |   4 +
>  include/linux/genalloc.h            | 112 +++---
>  lib/Kconfig.debug                   |  23 ++
>  lib/Makefile                        |   1 +
>  lib/genalloc.c                      | 742 ++++++++++++++++++++++++++----------
>  lib/test_genalloc.c                 | 419 ++++++++++++++++++++

That's a big patch, and I'm having trouble believing that it's
justified?  We're trying to reduce the harm in bugs (none of which are
known to exist) in a small number of drivers to avoid exploits, none of
which are known to exist and which may not even be possible.

Or something like that.  Perhaps all this is taking defensiveness a bit
too far?

And a bitmap is a pretty crappy way of managing memory anyway, surely? 
If this code is indeed performance-sensitive then perhaps a
reimplementation with some standard textbook allocator(?) is warranted?
