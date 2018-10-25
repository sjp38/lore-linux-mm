Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2966B0003
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 00:59:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r16-v6so4518887pgv.17
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 21:59:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cd15-v6si6899812plb.219.2018.10.24.21.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 21:59:28 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, thp: consolidate THP gfp handling into
 alloc_hugepage_direct_gfpmask
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-3-mhocko@kernel.org>
 <20180926133039.y7o5x4nafovxzh2s@kshutemo-mobl1>
 <20180926141708.GX6278@dhcp22.suse.cz> <20180926142227.GZ6278@dhcp22.suse.cz>
 <20181018191147.33e8d5e1ebd785c06aab7b30@linux-foundation.org>
 <20181019080657.GJ18839@dhcp22.suse.cz>
 <583b20e5-4925-e175-1533-5c2d2bab9192@suse.cz>
 <20181024161754.0d174e7c22113f4f8aad1940@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <983e0c59-99ef-796c-bfc4-00e67782d1f1@suse.cz>
Date: Thu, 25 Oct 2018 06:56:37 +0200
MIME-Version: 1.0
In-Reply-To: <20181024161754.0d174e7c22113f4f8aad1940@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 10/25/18 1:17 AM, Andrew Morton wrote:
> On Mon, 22 Oct 2018 15:27:54 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>>> : Moreover the oriinal code allowed to trigger
>>> : 	WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
>>> : in policy_node if the requested node (e.g. cpu local one) was outside of
>>> : the mbind nodemask. This is not possible now. We haven't heard about any
>>> : such warning yet so it is unlikely that it happens but still a signal of
>>> : a wrong code layering.
>>
>> Ah, as I said in the other mail, I think it's inaccurate, the warning
>> was not possible to hit.
>>
>> There's also a slight difference wrt MPOL_BIND. The previous code would
>> avoid using __GFP_THISNODE if the local node was outside of
>> policy_nodemask(). After your patch __GFP_THISNODE is avoided for all
>> MPOL_BIND policies. So there's a difference that if local node is
>> actually allowed by the bind policy's nodemask, previously
>> __GFP_THISNODE would be added, but now it won't be. I don't think it
>> matters that much though, but maybe the changelog could say that
>> (instead of the inaccurate note about warning). Note the other policy
>> where nodemask is relevant is MPOL_INTERLEAVE, and that's unchanged by
>> this patch.
> 
> So the above could go into the changelog, yes?

Yeah.

>> When that's addressed, you can add
> 
> What is it that you'd like to see addressed?  Purely changelog updates?

Right.

>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Thanks.
> 
