Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id BDF4A6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 07:45:02 -0500 (EST)
Received: by wmvv187 with SMTP id v187so255283753wmv.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 04:45:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o6si34393784wjz.221.2015.11.25.04.45.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 04:45:01 -0800 (PST)
Subject: Re: hugepage compaction causes performance drop
References: <564DCEA6.3000802@suse.cz> <564EDFE5.5010709@intel.com>
 <564EE8FD.7090702@intel.com> <564EF0B6.10508@suse.cz>
 <20151123081601.GA29397@js1304-P5Q-DELUXE> <5652CF40.6040400@intel.com>
 <CAAmzW4M6oJukBLwucByK89071RukF4UEyt02A7ZjenpPr5rsdQ@mail.gmail.com>
 <5653DC2C.3090706@intel.com> <20151124045536.GA3112@js1304-P5Q-DELUXE>
 <5654116F.1030301@intel.com> <20151124082941.GA4136@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5655AD4A.4080001@suse.cz>
Date: Wed, 25 Nov 2015 13:44:58 +0100
MIME-Version: 1.0
In-Reply-To: <20151124082941.GA4136@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aaron Lu <aaron.lu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, lkp@lists.01.org, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>

On 11/24/2015 09:29 AM, Joonsoo Kim wrote:
> On Tue, Nov 24, 2015 at 03:27:43PM +0800, Aaron Lu wrote:
> 
> Thanks.
> 
> Okay. Output proves the theory. pagetypeinfo shows that there are
> too many unmovable pageblocks. isolate_freepages() should skip these
> so it's not easy to meet proper pageblock until need_resched(). Hence,
> updating cached pfn doesn't happen. (You can see unchanged free_pfn
> with 'grep compaction_begin tracepoint-output')

Hm to me it seems that the scanners meet a lot, so they restart at zone
boundaries and that's fine. There's nothing to cache.

> But, I don't think that updating cached pfn is enough to solve your problem.
> More complex change would be needed, I guess.

One factor is probably that THP only use async compaction and those don't result
in deferred compaction, which should help here. It also means that
pageblock_skip bits are not being reset except by kswapd...

Oh and pageblock_pfn_to_page is done before checking the pageblock skip bits, so
that's why it's prominent in the profiles. Although it was less prominent (9% vs
46% before) in the last data... was perf collected while tracing, thus
generating extra noise?

> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
