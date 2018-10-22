Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A12E6B0010
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 09:35:26 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c1-v6so24686803eds.15
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 06:35:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d42-v6si89093ede.47.2018.10.22.06.35.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 06:35:25 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, thp: consolidate THP gfp handling into
 alloc_hugepage_direct_gfpmask
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-3-mhocko@kernel.org>
 <20180926133039.y7o5x4nafovxzh2s@kshutemo-mobl1>
 <20180926141708.GX6278@dhcp22.suse.cz> <20180926142227.GZ6278@dhcp22.suse.cz>
 <26cb01ff-a094-79f4-7ceb-291e5e053c58@suse.cz>
 <20181022133058.GE18839@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <18476b0b-7300-f340-5845-9de0a019c65c@suse.cz>
Date: Mon, 22 Oct 2018 15:35:24 +0200
MIME-Version: 1.0
In-Reply-To: <20181022133058.GE18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 10/22/18 3:30 PM, Michal Hocko wrote:
> On Mon 22-10-18 15:15:38, Vlastimil Babka wrote:
>>> Forgot to add. One notable exception would be that the previous code
>>> would allow to hit
>>> 	WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
>>> in policy_node if the requested node (e.g. cpu local one) was outside of
>>> the mbind nodemask. This is not possible now. We haven't heard about any
>>> such warning yet so it is unlikely that it happens though.
>>
>> I don't think the previous code could hit the warning, as the hugepage
>> path that would add __GFP_THISNODE didn't call policy_node() (containing
>> the warning) at all. IIRC early of your patch did hit the warning
>> though, which is why you added the MPOL_BIND policy check.
> 
> Are you sure? What prevents node_isset(node, policy_nodemask()) == F and
> fallback to the !huge allocation path?

That can indeed happen, but then the code also skipped the "gfp |=
__GFP_THISNODE" part, right? So the warning wouldn't trigger.

> alloc_pages_vma is usually called
> with the local node and processes shouldn't run off their bounded num
> mask but is that guaranteed? Moreover do_huge_pmd_wp_page_fallback uses
> the former numa binding and that might be outside of the policy mask.
> 
> In any case, as I've said this is highly unlikely to hit which is
> underlined by the lack of reports.
> 
