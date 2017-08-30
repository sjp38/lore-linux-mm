Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1051D6B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 15:09:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 83so13836857pgb.1
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 12:09:06 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id v24si5052836pgo.516.2017.08.30.12.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 12:09:04 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id r187so1098374pfr.3
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 12:09:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170830182357.GD32493@leverpostej>
References: <cover.1504109849.git.dvyukov@google.com> <663c2a30de845dd13cf3cf64c3dfd437295d5ce2.1504109849.git.dvyukov@google.com>
 <20170830182357.GD32493@leverpostej>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 30 Aug 2017 21:08:43 +0200
Message-ID: <CACT4Y+bRVdvgFkkWxAZm0dv5vTQat=OhGN5cU+nAVAHA-AndfA@mail.gmail.com>
Subject: Re: [PATCH 1/3] kcov: support comparison operands collection
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Victor Chibotaru <tchibo@google.com>, Alexander Popov <alex.popov@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, syzkaller <syzkaller@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 30, 2017 at 8:23 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> Hi,
>
> On Wed, Aug 30, 2017 at 06:23:29PM +0200, Dmitry Vyukov wrote:
>> From: Victor Chibotaru <tchibo@google.com>
>>
>> Enables kcov to collect comparison operands from instrumented code.
>> This is done by using Clang's -fsanitize=trace-cmp instrumentation
>> (currently not available for GCC).
>
> What's needed to build the kernel with Clang these days?
>
> I was under the impression that it still wasn't possible to build arm64
> with clang due to a number of missing features (e.g. the %a assembler
> output template).
>
>> The comparison operands help a lot in fuzz testing. E.g. they are
>> used in Syzkaller to cover the interiors of conditional statements
>> with way less attempts and thus make previously unreachable code
>> reachable.
>>
>> To allow separate collection of coverage and comparison operands two
>> different work modes are implemented. Mode selection is now done via
>> a KCOV_ENABLE ioctl call with corresponding argument value.
>>
>> Signed-off-by: Victor Chibotaru <tchibo@google.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: Alexander Popov <alex.popov@linux.com>
>> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Vegard Nossum <vegard.nossum@oracle.com>
>> Cc: Quentin Casasnovas <quentin.casasnovas@oracle.com>
>> Cc: syzkaller@googlegroups.com
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>> Clang instrumentation:
>> https://clang.llvm.org/docs/SanitizerCoverage.html#tracing-data-flow
>
> How stable is this?
>
> The comment at the end says "This interface is a subject to change."


The intention is that this is not subject to change anymore (since we
are using it in kernel).
I've mailed change to docs: https://reviews.llvm.org/D37303

FWIW, there is patch in flight that adds this instrumentation to gcc:
https://groups.google.com/forum/#!topic/syzkaller/CSLynn6nI-A
It seems to be stalled on review phase, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
