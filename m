Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46FB26B0003
	for <linux-mm@kvack.org>; Mon, 28 May 2018 11:32:18 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w8-v6so10639715wrn.10
        for <linux-mm@kvack.org>; Mon, 28 May 2018 08:32:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b15-v6si710764ede.438.2018.05.28.08.32.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 08:32:16 -0700 (PDT)
Subject: Re: [PATCH] mm, page_alloc: do not break __GFP_THISNODE by zonelist
 reset
From: Vlastimil Babka <vbabka@suse.cz>
References: <20180525130853.13915-1-vbabka@suse.cz>
 <20180525124300.964a1a15d953e8972625bb0f@linux-foundation.org>
 <4cd73f77-e6ab-bdd1-69a2-bd0f8413d189@suse.cz>
Message-ID: <26adcbc0-7741-4f39-9fac-fc7f387bdbe6@suse.cz>
Date: Mon, 28 May 2018 11:55:52 +0200
MIME-Version: 1.0
In-Reply-To: <4cd73f77-e6ab-bdd1-69a2-bd0f8413d189@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

On 05/25/2018 10:48 PM, Vlastimil Babka wrote:
> On 05/25/2018 09:43 PM, Andrew Morton wrote:
>> On Fri, 25 May 2018 15:08:53 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>>> we might consider this for 4.17 although I don't know if there's anything
>>> currently broken. Stable backports should be more important, but will have to
>>> be reviewed carefully, as the code went through many changes.
>>> BTW I think that also the ac->preferred_zoneref reset is currently useless if
>>> we don't also reset ac->nodemask from a mempolicy to NULL first (which we
>>> probably should for the OOM victims etc?), but I would leave that for a
>>> separate patch.
>>
>> Confused.  If nothing is currently broken then why is a backport
>> needed?  Presumably because we expect breakage in the future?  Can you
>> expand on this?
> 
> I mean that SLAB is currently not affected, but in older kernels than
> 4.7 that don't yet have 511e3a058812 ("mm/slab: make cache_grow() handle
> the page allocated on arbitrary node") it is. That's at least 4.4 LTS.
> Older ones I'll have to check.

So I've checked the non-EOL LTS's at kernel.org and:

4.16, 4.14, 4.9 - same as mainline (__GFP_THISNODE broken, but SLAB is OK)
4.4, 4.1, 3.16 - SLAB potentially broken if it makes an
ALLOC_NO_WATERMARKS allocation (our 4.4 kernel has backports that extend
it to also !ALLOC_CPUSET so it's more likely).
