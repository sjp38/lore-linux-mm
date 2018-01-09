Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E27CB6B0038
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 05:10:55 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id r8so8541570pgq.1
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 02:10:55 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f26sor3176699pge.133.2018.01.09.02.10.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 02:10:54 -0800 (PST)
Date: Tue, 9 Jan 2018 02:10:50 -0800
From: Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH] mm: don't expose page to fast gup before it's ready
Message-ID: <20180109101050.GA83229@google.com>
References: <20180108225632.16332-1-yuzhao@google.com>
 <20180109084622.GF1732@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180109084622.GF1732@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 09, 2018 at 09:46:22AM +0100, Michal Hocko wrote:
> On Mon 08-01-18 14:56:32, Yu Zhao wrote:
> > We don't want to expose page before it's properly setup. During
> > page setup, we may call page_add_new_anon_rmap() which uses non-
> > atomic bit op. If page is exposed before it's done, we could
> > overwrite page flags that are set by get_user_pages_fast() or
> > it's callers. Here is a non-fatal scenario (there might be other
> > fatal problems that I didn't look into):
> > 
> > 	CPU 1				CPU1
> > set_pte_at()			get_user_pages_fast()
> > page_add_new_anon_rmap()		gup_pte_range()
> > 	__SetPageSwapBacked()			SetPageReferenced()
> > 
> > Fix the problem by delaying set_pte_at() until page is ready.
> 
> Have you seen this race happening in real workloads or this is a code
> review based fix or a theoretical issue? I am primarily asking because
> the code is like that at least throughout git era and I do not remember
> any issue like this. If you can really trigger this tiny race window
> then we should mark the fix for stable.

I didn't observe the race directly. But I did get few crashes when
trying to access mem_cgroup of pages returned by get_user_pages_fast().
Those page were charged and they showed valid mem_cgroup in kdumps.
So this led me to think the problem came from premature set_pte_at().

I think the fact that nobody complained about this problem is because
the race only happens when using ksm+swap, and it might not cause
any fatal problem even so. Nevertheless, it's nice to have set_pte_at()
done consistently after rmap is added and page is charged.

> Also what prevents reordering here? There do not seem to be any barriers
> to prevent __SetPageSwapBacked leak after set_pte_at with your patch.

I assumed mem_cgroup_commit_charge() acted as full barrier. Since you
explicitly asked the question, I realized my assumption doesn't hold
when memcg is disabled. So we do need something to prevent reordering
in my patch. And it brings up the question whether we want to add more
barrier to other places that call page_add_new_anon_rmap() and
set_pte_at().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
