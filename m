Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0AF636B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 18:30:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i18so29887845wrb.21
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 15:30:03 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k6si21615704wma.165.2017.04.04.15.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 15:30:02 -0700 (PDT)
Date: Tue, 4 Apr 2017 18:29:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: vmscan: fix IO/refault regression in cache
 workingset transition
Message-ID: <20170404222952.GA28930@cmpxchg.org>
References: <20170404220052.27593-1-hannes@cmpxchg.org>
 <20170404150703.742c49d73921df6369ed3dbd@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404150703.742c49d73921df6369ed3dbd@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Apr 04, 2017 at 03:07:03PM -0700, Andrew Morton wrote:
> On Tue,  4 Apr 2017 18:00:52 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Since 59dc76b0d4df ("mm: vmscan: reduce size of inactive file list")
> > we noticed bigger IO spikes during changes in cache access patterns.
> > 
> > The patch in question shrunk the inactive list size to leave more room
> > for the current workingset in the presence of streaming IO. However,
> > workingset transitions that previously happened on the inactive list
> > are now pushed out of memory and incur more refaults to complete.
> > 
> > This patch disables active list protection when refaults are being
> > observed. This accelerates workingset transitions, and allows more of
> > the new set to establish itself from memory, without eating into the
> > ability to protect the established workingset during stable periods.
> > 
> > Fixes: 59dc76b0d4df ("mm: vmscan: reduce size of inactive file list")
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: <stable@vger.kernel.org> # 4.7+
> 
> That's a pretty large patch and the problem has been there for a year. 
> I'm not sure that it's 4.11 material, let alone -stable.  Care to
> explain further?

The problem statement is a little terse, my apologies.

The workloads that were measurably affected for us were hit pretty bad
by it, with refault/majfault rates doubling and tripling during cache
transitions, and the machines sustaining half-hour periods of 100% IO
utilization, where they'd previously have sub-minute peaks at 60-90%.

Stateful services that handle user data tend to be more conservative
with kernel upgrades. As a result we hit most page cache issues with
some delay, as was the case here.

The severity seemed to warrant a stable tag, but I agree that holding
out until 4.11.1 is probably better, given the invasiveness of this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
