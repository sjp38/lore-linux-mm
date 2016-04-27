Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3D316B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:11:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so96231477pfy.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:11:05 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id kx15si6244259pab.97.2016.04.27.10.11.05
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 10:11:05 -0700 (PDT)
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5720F2A8.6070406@intel.com>
Date: Wed, 27 Apr 2016 10:11:04 -0700
MIME-Version: 1.0
In-Reply-To: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On 04/27/2016 10:01 AM, Odzioba, Lukasz wrote:
> Pieces of the puzzle:
> A) after process termination memory is not getting freed nor accounted as free

I don't think this part is necessarily a bug.  As long as we have stats
*somewhere*, and we really do "reclaim" them, I don't think we need to
call these pages "free".

> I am not sure whether it is expected behavior or a side effect of something else not
> going as it should. Temporarily I added lru_add_drain_all() to try_to_free_pages()
> which sort of hammers B case, but A is still present.

It's not expected behavior.  It's an unanticipated side effect of large
numbers of cpu threads, large pages on the LRU, and (relatively) small
zones.

> I am not familiar with this code, but I feel like draining lru_add work should be split
> into smaller pieces and done by kswapd to fix A and drain only as much pages as
> needed in try_to_free_pages to fix B.
> 
> Any comments/ideas/patches for a proper fix are welcome.

Here are my suggestions.  I've passed these along multiple times, but I
guess I'll repeat them again for good measure.

> 1. We need some statistics on the number and total *SIZES* of all pages
>    in the lru pagevecs.  It's too opaque now.
> 2. We need to make darn sure we drain the lru pagevecs before failing
>    any kind of allocation.
> 3. We need some way to drain the lru pagevecs directly.  Maybe the buddy
>    pcp lists too.
> 4. We need to make sure that a zone_reclaim_mode=0 system still drains
>    too.
> 5. The VM stats and their updates are now related to how often
>    drain_zone_pages() gets run.  That might be interacting here too.

6. Perhaps don't use the LRU pagevecs for large pages.  It limits the
   severity of the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
