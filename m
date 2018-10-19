Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0AAA96B0269
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 22:11:50 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h9-v6so23537466pgs.11
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 19:11:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a13-v6si22957335pls.229.2018.10.18.19.11.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 19:11:49 -0700 (PDT)
Date: Thu, 18 Oct 2018 19:11:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm, thp: consolidate THP gfp handling into
 alloc_hugepage_direct_gfpmask
Message-Id: <20181018191147.33e8d5e1ebd785c06aab7b30@linux-foundation.org>
In-Reply-To: <20180926142227.GZ6278@dhcp22.suse.cz>
References: <20180925120326.24392-1-mhocko@kernel.org>
	<20180925120326.24392-3-mhocko@kernel.org>
	<20180926133039.y7o5x4nafovxzh2s@kshutemo-mobl1>
	<20180926141708.GX6278@dhcp22.suse.cz>
	<20180926142227.GZ6278@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 26 Sep 2018 16:22:27 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> > MPOL_PREFERRED is handled by policy_node() before we call __alloc_pages_nodemask.
> > __GFP_THISNODE is applied only when we are not using
> > __GFP_DIRECT_RECLAIM which is handled in alloc_hugepage_direct_gfpmask
> > now.
> > Lastly MPOL_BIND wasn't handled explicitly but in the end the removed
> > late check would remove __GFP_THISNODE for it as well. So in the end we
> > are doing the same thing unless I miss something
> 
> Forgot to add. One notable exception would be that the previous code
> would allow to hit
> 	WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
> in policy_node if the requested node (e.g. cpu local one) was outside of
> the mbind nodemask. This is not possible now. We haven't heard about any
> such warning yet so it is unlikely that it happens though.

Perhaps a changelog addition is needed to cover the above?

I assume that David's mbind() concern has gone away.

No acks or reviewed-by's yet?
