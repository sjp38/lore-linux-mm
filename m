Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id D834F6B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 21:31:53 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so37178085igb.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:31:53 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id ka10si10043017igb.53.2015.04.28.18.31.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 18:31:53 -0700 (PDT)
Message-ID: <55403484.8060906@hp.com>
Date: Tue, 28 Apr 2015 21:31:48 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v3
References: <1429785196-7668-1-git-send-email-mgorman@suse.de> <1429804437.24139.3@cpanel21.proisp.no>
In-Reply-To: <1429804437.24139.3@cpanel21.proisp.no>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel J Blueman <daniel@numascale.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 'Steffen Persvold' <sp@numascale.com>

On 04/23/2015 11:53 AM, Daniel J Blueman wrote:
> On Thu, Apr 23, 2015 at 6:33 PM, Mel Gorman <mgorman@suse.de> wrote:
>> The big change here is an adjustment to the topology_init path that 
>> caused
>> soft lockups on Waiman and Daniel Blue had reported it was an expensive
>> function.
>>
>> Changelog since v2
>> o Reduce overhead of topology_init
>> o Remove boot-time kernel parameter to enable/disable
>> o Enable on UMA
>>
>> Changelog since v1
>> o Always initialise low zones
>> o Typo corrections
>> o Rename parallel mem init to parallel struct page init
>> o Rebase to 4.0
> []
>
> Splendid work! On this 256c setup, topology_init now takes 185ms.
>
> This brings the kernel boot time down to 324s [1]. It turns out that 
> one memset is responsible for most of the time setting up the the PUDs 
> and PMDs; adapting memset to using non-temporal writes [3] avoids 
> generating RMW cycles, bringing boot time down to 186s [2].
>
> If this is a possibility, I can split this patch and map other arch's 
> memset_nocache to memset, or change the callsite as preferred; 
> comments welcome.
>
> Thanks,
>  Daniel
>
> [1] https://resources.numascale.com/telemetry/defermem/h8qgl-defer2.txt
> [2] 
> https://resources.numascale.com/telemetry/defermem/h8qgl-defer2-nontemporal.txt
>
> -- [3]
>
> From f822139736cab8434302693c635fa146b465273c Mon Sep 17 00:00:00 2001
> From: Daniel J Blueman <daniel@numascale.com>
> Date: Thu, 23 Apr 2015 23:26:27 +0800
> Subject: [RFC] Speedup PMD setup
>
> Using non-temporal writes prevents read-modify-write cycles,
> which are much slower over large topologies.
>
> Adapt the existing memset() function into a _nocache variant and use
> when setting up PMDs during early boot to reduce boot time.
>
> Signed-off-by: Daniel J Blueman <daniel@numascale.com>
> ---
> arch/x86/include/asm/string_64.h |  3 ++
> arch/x86/lib/memset_64.S         | 90 
> ++++++++++++++++++++++++++++++++++++++++
> mm/memblock.c                    |  2 +-
> 3 files changed, 94 insertions(+), 1 deletion(-)
>

I tried your patch on my 12-TB IvyBridge-EX test machine and the bootup 
time increased from 265s to 289s (24s increase). I think my IvyBridge-EX 
box was using the optimized memset_c_e (rep stosb) code which turned out 
to perform better than the non-temporal move in your code. I think that 
may be due to the temporal moves that need to be done at the beginning 
and end of the memory range.

I had tried to replace clear_page() with non-temporal moves. I generally 
got about a few percentage points improvement compared with the 
optimized clear_page_c() and clear_page_c_e() code. That is not a lot.

Anyway, I think the AMD box that you used wasn't setting the 
X86_FEATURE_REP_GOOD or X86_FEATURE_ERMS bits resulting in poor memset 
performance. If such a feature is supported in the AMD CPU (albeit in a 
different way), you may consider sending in patch to set those features 
bit. Alternatively, you will need to duplicate the alternative 
instruction stuff in your memset_nocache() to make sure that it can use 
the optimized code, if appropriate.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
