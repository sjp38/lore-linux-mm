Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f52.google.com (mail-lf0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id CA2FD6B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 17:46:51 -0500 (EST)
Received: by lfs39 with SMTP id 39so211998328lfs.3
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:46:51 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 42si30628666lfx.24.2015.11.30.14.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 14:46:50 -0800 (PST)
Date: Mon, 30 Nov 2015 17:46:34 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 09/13] mm: memcontrol: generalize the socket accounting
 jump label
Message-ID: <20151130224634.GA19849@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
 <1448401925-22501-10-git-send-email-hannes@cmpxchg.org>
 <565CBAC2.3080804@akamai.com>
 <20151130215007.GA31903@cmpxchg.org>
 <565CCDA1.905@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <565CCDA1.905@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Baron <jbaron@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, "peterz@infradead.org" <peterz@infradead.org>

On Mon, Nov 30, 2015 at 05:28:49PM -0500, Jason Baron wrote:
> On 11/30/2015 04:50 PM, Johannes Weiner wrote:
> > On Mon, Nov 30, 2015 at 04:08:18PM -0500, Jason Baron wrote:
> >> We're trying to move to the updated API, so this should be:
> >> static_branch_unlikely(&memcg_sockets_enabled_key)
> >>
> >> see: include/linux/jump_label.h for details.
> > 
> > Good point. There is another struct static_key in there as well. How
> > about the following on top of this series?
> > 
> 
> Looks fine - you may be able to make use of
> 'static_branch_enable()/disable()' instead of the inc()/dec() to simply
> set the branch direction, if you think its more readable. Although I
> didn't look to see if it would be racy here.

Thanks!

We actually need the reference counting semantics for both these keys.
It counts the number of active cgroups in existence that require the
code behind those static branches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
