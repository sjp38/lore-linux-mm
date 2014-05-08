Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 56CFD6B0114
	for <linux-mm@kvack.org>; Thu,  8 May 2014 14:28:52 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e53so1941037eek.25
        for <linux-mm@kvack.org>; Thu, 08 May 2014 11:28:51 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id t3si2257410eeg.61.2014.05.08.11.28.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 May 2014 11:28:51 -0700 (PDT)
Date: Thu, 8 May 2014 14:28:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/9] mm: memcontrol: retry reclaim for oom-disabled and
 __GFP_NOFAIL charges
Message-ID: <20140508182848.GP19914@cmpxchg.org>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-4-git-send-email-hannes@cmpxchg.org>
 <20140507144339.GI9489@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140507144339.GI9489@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, May 07, 2014 at 04:43:39PM +0200, Michal Hocko wrote:
> On Wed 30-04-14 16:25:37, Johannes Weiner wrote:
> > There is no reason why oom-disabled and __GFP_NOFAIL charges should
> > try to reclaim only once when every other charge tries several times
> > before giving up.  Make them all retry the same number of times.
> 
> I guess the idea whas that oom disabled (THP) allocation can fallback to
> a smaller allocation. I would suspect this would increase latency for
> THP page faults.

If it does, we should probably teach THP to use __GFP_NORETRY.

On that note, __GFP_NORETRY is currently useless for memcg because it
has !__GFP_WAIT semantics...  I'll include a fix for that in v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
