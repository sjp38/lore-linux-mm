Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADC726B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 09:53:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c13-v6so24659987ede.6
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 06:53:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l8-v6si10165346eje.206.2018.10.22.06.53.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 06:53:47 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, thp: consolidate THP gfp handling into
 alloc_hugepage_direct_gfpmask
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-3-mhocko@kernel.org>
 <20180926133039.y7o5x4nafovxzh2s@kshutemo-mobl1>
 <20180926141708.GX6278@dhcp22.suse.cz> <20180926142227.GZ6278@dhcp22.suse.cz>
 <26cb01ff-a094-79f4-7ceb-291e5e053c58@suse.cz>
 <20181022133058.GE18839@dhcp22.suse.cz>
 <18476b0b-7300-f340-5845-9de0a019c65c@suse.cz>
 <20181022134657.GG18839@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ccbf8264-8408-bfff-9da3-3408a4a7446e@suse.cz>
Date: Mon, 22 Oct 2018 15:53:45 +0200
MIME-Version: 1.0
In-Reply-To: <20181022134657.GG18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 10/22/18 3:46 PM, Michal Hocko wrote:
> On Mon 22-10-18 15:35:24, Vlastimil Babka wrote:
>> On 10/22/18 3:30 PM, Michal Hocko wrote:
>>> On Mon 22-10-18 15:15:38, Vlastimil Babka wrote:
>>>>> Forgot to add. One notable exception would be that the previous code
>>>>> would allow to hit
>>>>> 	WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
>>>>> in policy_node if the requested node (e.g. cpu local one) was outside of
>>>>> the mbind nodemask. This is not possible now. We haven't heard about any
>>>>> such warning yet so it is unlikely that it happens though.
>>>>
>>>> I don't think the previous code could hit the warning, as the hugepage
>>>> path that would add __GFP_THISNODE didn't call policy_node() (containing
>>>> the warning) at all. IIRC early of your patch did hit the warning
>>>> though, which is why you added the MPOL_BIND policy check.
>>>
>>> Are you sure? What prevents node_isset(node, policy_nodemask()) == F and
>>> fallback to the !huge allocation path?
>>
>> That can indeed happen, but then the code also skipped the "gfp |=
>> __GFP_THISNODE" part, right? So the warning wouldn't trigger.
> 
> I thought I have crawled all the code paths back then but maybe there
> were some phantom ones... If you are sure about then we can stick with
> the original changelog.

The __GFP_THISNODE would have to already be set in the 'gfp' parameter
of alloc_pages_vma(), and alloc_hugepage_direct_gfpmask() could not add
it. So in the context of alloc_hugepage_direct_gfpmask() users I believe
the patch is not removing nor adding the possibility of the warning to
trigger.
