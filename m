Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 183CE8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 13:17:23 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id w68-v6so8600988ith.0
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 10:17:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9-v6sor807516iol.217.2018.09.27.10.17.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 10:17:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <010001661bba2bbc-a5074e00-2009-414a-be8c-05c58545c7ec-000000@email.amazonses.com>
References: <20180927130707.151239-1-dvyukov@gmail.com> <010001661bba2bbc-a5074e00-2009-414a-be8c-05c58545c7ec-000000@email.amazonses.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 27 Sep 2018 19:17:01 +0200
Message-ID: <CACT4Y+atu0Fz0Bhqn+7qpRowySEVWXV+vwVbBZ5y3Z+NnSpLsQ@mail.gmail.com>
Subject: Re: [PATCH] mm: don't warn about large allocations for slab
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Dmitry Vyukov <dvyukov@gmail.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Sep 27, 2018 at 5:51 PM, Christopher Lameter <cl@linux.com> wrote:
> On Thu, 27 Sep 2018, Dmitry Vyukov wrote:
>
>> From: Dmitry Vyukov <dvyukov@google.com>
>>
>> This warning does not seem to be useful. Most of the time it fires when
>> allocation size depends on syscall arguments. We could add __GFP_NOWARN
>> to these allocation sites, but having a warning only to suppress it
>> does not make lots of sense. Moreover, this warnings never fires for
>> constant-size allocations and never for slub, because there are
>> additional checks and fallback to kmalloc_large() for large allocations
>> and kmalloc_large() does not warn. So the warning only fires for
>> non-constant allocations and only with slab, which is odd to begin with.
>> The warning leads to episodic unuseful syzbot reports. Remote it.
>
> /Remove/
>
> If its only for slab then KMALLOC_MAX_CACHE_SIZE and KMALLOC_MAX_SIZE are
> the same value.
>
>> While we are here also fix the check. We should check against
>> KMALLOC_MAX_CACHE_SIZE rather than KMALLOC_MAX_SIZE. It all kinda
>> worked because for slab the constants are the same, and slub always
>> checks the size against KMALLOC_MAX_CACHE_SIZE before kmalloc_slab().
>> But if we get there with size > KMALLOC_MAX_CACHE_SIZE anyhow
>> bad things will happen.
>
> Then the WARN_ON is correct just change the constant used. Ensure that
> SLAB does the same checks as SLUB.

Mailed v2 which adds the checks to slab.

I think the warning is still slightly wrong. It means a bug in slab
code, it has nothing to do with user-passed flags.
