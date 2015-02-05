Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 06958828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 16:44:53 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id x3so6492503wes.0
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 13:44:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id wb6si749283wjc.62.2015.02.05.13.44.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Feb 2015 13:44:51 -0800 (PST)
Message-ID: <54D3E44B.7060501@redhat.com>
Date: Thu, 05 Feb 2015 16:44:43 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: madvise: Ignore repeated MADV_DONTNEED hints
References: <20150202165525.GM2395@suse.de> <20150202140506.392ff6920743f19ea44cff59@linux-foundation.org> <20150202221824.GN2395@suse.de>
In-Reply-To: <20150202221824.GN2395@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

On 02/02/2015 05:18 PM, Mel Gorman wrote:
> On Mon, Feb 02, 2015 at 02:05:06PM -0800, Andrew Morton wrote:
>> On Mon, 2 Feb 2015 16:55:25 +0000 Mel Gorman <mgorman@suse.de> wrote:
>>
>>> glibc malloc changed behaviour in glibc 2.10 to have per-thread arenas
>>> instead of creating new areans if the existing ones were contended.
>>> The decision appears to have been made so the allocator scales better but the
>>> downside is that madvise(MADV_DONTNEED) is now called for these per-thread
>>> areans during free. This tears down pages that would have previously
>>> remained. There is nothing wrong with this decision from a functional point
>>> of view but any threaded application that frequently allocates/frees the
>>> same-sized region is going to incur the full teardown and refault costs.
>>
>> MADV_DONTNEED has been there for many years.  How could this problem
>> not have been noticed during glibc 2.10 development/testing? 
> 
> I do not know. I only spotted it due to switching distributions. Looping
> allocations and frees of the same sizes is considered inefficient and it
> might have been dismissed on those grounds. It's probably less noticeable
> when it only affects threaded applications.
> 
>> Is there
>> some more recent kernel change which is triggering this?
>>
> 
> Not that I'm aware of.
> 
>>> This patch identifies when a thread is frequently calling MADV_DONTNEED
>>> on the same region of memory and starts ignoring the hint.
>>
>> That's pretty nasty-looking :(
>>
> 
> Yep, it is but we're very limited in terms of what we can do within the
> kernel here.
> 
>> And presumably there are all sorts of behaviours which will still
>> trigger the problem but which will avoid the start/end equality test in
>> ignore_madvise_hint()?
>>
> 
> Yes. I would expect that a simple pattern of multiple allocs followed by
> multiple frees in a loop would also trigger it.
> 
>> Really, this is a glibc problem and only a glibc problem. 
>> MADV_DONTNEED is unavoidably expensive and glibc is calling
>> MADV_DONTNEED for a region which it *does* need. 
> 
> To be fair to glibc, it calls it on a region it *thinks* it doesn't need only
> to reuse it immediately afterwards because of how the benchmark is
> implemented.
> 
>> Is there something
>> preventing this from being addressed within glibc?
>  
> I doubt it other than I expect they'll punt it back and blame either the
> application for being stupid or the kernel for being slow.

This sounds like something that could benefit from Minchan's
MADV_FREE, instead of MADV_DONTNEED.

If non page aligned malloc/free does not depend on pages
being zeroed, I suspect an MADV_DONTNEED resulting from
a malloc/free loop also does not depend on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
