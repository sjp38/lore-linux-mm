Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFC506B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 11:02:36 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id q20so155579668ioi.0
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 08:02:36 -0800 (PST)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id r198si1263341ita.65.2017.01.23.08.02.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 08:02:35 -0800 (PST)
Received: by mail-it0-x243.google.com with SMTP id o185so10639131itb.1
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 08:02:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <ffce0866-0233-c7c4-027a-a0a1caa26cf3@suse.cz>
References: <20170123121649.3180300-1-arnd@arndb.de> <ffce0866-0233-c7c4-027a-a0a1caa26cf3@suse.cz>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 23 Jan 2017 17:02:34 +0100
Message-ID: <CAK8P3a29aAA-YCkk=2h3iW=KTW=kq=gSniWfCzZs4nmpa8Adfw@mail.gmail.com>
Subject: Re: [PATCH] mm: ensure alloc_flags in slow path are initialized
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Jan 23, 2017 at 1:55 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 01/23/2017 01:16 PM, Arnd Bergmann wrote:

>> To be honest, I can't figure that out either, maybe it is or
>> maybe not,
>
>
> Seems the report is correct and not false positive, in scenario when we goto
> nopage before the assignment, and then goto retry because of __GFP_NOFAIL.

Ok, thanks for checking!

>> but moving the existing initialization up a little
>> higher looks safe and makes it obvious to both me and gcc that
>> the initialization comes before the first use.
>>
>> Fixes: 74eaa4a97e8e ("mm: consolidate GFP_NOFAIL checks in the allocator
>> slowpath")
>
>
> That's a non-stable -next commit ID for mmotm patch:
> mm-consolidate-gfp_nofail-checks-in-the-allocator-slowpath.patch
>
> The patch itself was OK, the problem only comes from integration with
> another mmotm patch (also independently OK):
> mm-page_alloc-fix-premature-oom-when-racing-with-cpuset-mems-update.patch
>
> By their ordering in mmotm, it would work to treat this as a fix for the
> GFP_NOFAIL patch, possibly merged into it.

Ok. I only tracked down which commit introduced the warning, which was
the one above.

    Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
