Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB076B0006
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:07:40 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id b193so621786wmd.7
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:07:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j7si15341925wrg.161.2018.01.31.15.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:07:39 -0800 (PST)
Date: Wed, 31 Jan 2018 15:07:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: don't expose page to fast gup before it's ready
Message-Id: <20180131150736.9703ab0826121f2e9e23cb8e@linux-foundation.org>
In-Reply-To: <20180109101050.GA83229@google.com>
References: <20180108225632.16332-1-yuzhao@google.com>
	<20180109084622.GF1732@dhcp22.suse.cz>
	<20180109101050.GA83229@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 9 Jan 2018 02:10:50 -0800 Yu Zhao <yuzhao@google.com> wrote:

> On Tue, Jan 09, 2018 at 09:46:22AM +0100, Michal Hocko wrote:
> > On Mon 08-01-18 14:56:32, Yu Zhao wrote:
> > > We don't want to expose page before it's properly setup. During
> > > page setup, we may call page_add_new_anon_rmap() which uses non-
> > > atomic bit op. If page is exposed before it's done, we could
> > > overwrite page flags that are set by get_user_pages_fast() or
> > > it's callers. Here is a non-fatal scenario (there might be other
> > > fatal problems that I didn't look into):
> > > 
> > > 	CPU 1				CPU1
> > > set_pte_at()			get_user_pages_fast()
> > > page_add_new_anon_rmap()		gup_pte_range()
> > > 	__SetPageSwapBacked()			SetPageReferenced()
> > > 
> > > Fix the problem by delaying set_pte_at() until page is ready.
> > 
> > Have you seen this race happening in real workloads or this is a code
> > review based fix or a theoretical issue? I am primarily asking because
> > the code is like that at least throughout git era and I do not remember
> > any issue like this. If you can really trigger this tiny race window
> > then we should mark the fix for stable.
> 
> I didn't observe the race directly. But I did get few crashes when
> trying to access mem_cgroup of pages returned by get_user_pages_fast().
> Those page were charged and they showed valid mem_cgroup in kdumps.
> So this led me to think the problem came from premature set_pte_at().
> 
> I think the fact that nobody complained about this problem is because
> the race only happens when using ksm+swap, and it might not cause
> any fatal problem even so. Nevertheless, it's nice to have set_pte_at()
> done consistently after rmap is added and page is charged.
> 
> > Also what prevents reordering here? There do not seem to be any barriers
> > to prevent __SetPageSwapBacked leak after set_pte_at with your patch.
> 
> I assumed mem_cgroup_commit_charge() acted as full barrier. Since you
> explicitly asked the question, I realized my assumption doesn't hold
> when memcg is disabled. So we do need something to prevent reordering
> in my patch. And it brings up the question whether we want to add more
> barrier to other places that call page_add_new_anon_rmap() and
> set_pte_at().

No progress here?  I have the patch marked "to be updated", hence it is
stuck.  Please let's get it finished off for 4.17-rc1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
