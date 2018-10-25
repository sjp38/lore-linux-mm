Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B1CDD6B02AB
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 12:14:20 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x1-v6so343833eds.16
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 09:14:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8-v6si5251363edi.384.2018.10.25.09.14.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 09:14:19 -0700 (PDT)
Date: Thu, 25 Oct 2018 18:14:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, thp: consolidate THP gfp handling into
 alloc_hugepage_direct_gfpmask
Message-ID: <20181025161410.GT18839@dhcp22.suse.cz>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-3-mhocko@kernel.org>
 <20180926133039.y7o5x4nafovxzh2s@kshutemo-mobl1>
 <20180926141708.GX6278@dhcp22.suse.cz>
 <20180926142227.GZ6278@dhcp22.suse.cz>
 <20181018191147.33e8d5e1ebd785c06aab7b30@linux-foundation.org>
 <20181019080657.GJ18839@dhcp22.suse.cz>
 <583b20e5-4925-e175-1533-5c2d2bab9192@suse.cz>
 <20181024161754.0d174e7c22113f4f8aad1940@linux-foundation.org>
 <983e0c59-99ef-796c-bfc4-00e67782d1f1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <983e0c59-99ef-796c-bfc4-00e67782d1f1@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 25-10-18 06:56:37, Vlastimil Babka wrote:
> On 10/25/18 1:17 AM, Andrew Morton wrote:
> > On Mon, 22 Oct 2018 15:27:54 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> > 
> >>> : Moreover the oriinal code allowed to trigger
> >>> : 	WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
> >>> : in policy_node if the requested node (e.g. cpu local one) was outside of
> >>> : the mbind nodemask. This is not possible now. We haven't heard about any
> >>> : such warning yet so it is unlikely that it happens but still a signal of
> >>> : a wrong code layering.
> >>
> >> Ah, as I said in the other mail, I think it's inaccurate, the warning
> >> was not possible to hit.
> >>
> >> There's also a slight difference wrt MPOL_BIND. The previous code would
> >> avoid using __GFP_THISNODE if the local node was outside of
> >> policy_nodemask(). After your patch __GFP_THISNODE is avoided for all
> >> MPOL_BIND policies. So there's a difference that if local node is
> >> actually allowed by the bind policy's nodemask, previously
> >> __GFP_THISNODE would be added, but now it won't be. I don't think it
> >> matters that much though, but maybe the changelog could say that
> >> (instead of the inaccurate note about warning). Note the other policy
> >> where nodemask is relevant is MPOL_INTERLEAVE, and that's unchanged by
> >> this patch.
> > 
> > So the above could go into the changelog, yes?
> 
> Yeah.

Andrew. Do you want me to repost the patch or you plan to update the
changelog yourself?
-- 
Michal Hocko
SUSE Labs
