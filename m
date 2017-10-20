Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A66FC6B0069
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 12:47:40 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id h6so11536916oia.17
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 09:47:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q10sor653129otb.117.2017.10.20.09.47.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 09:47:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171020071250.ftqn2d356yekkp5k@dhcp22.suse.cz>
References: <20171019200323.42491-1-nehaagarwal@google.com> <20171020071250.ftqn2d356yekkp5k@dhcp22.suse.cz>
From: Neha Agarwal <nehaagarwal@google.com>
Date: Fri, 20 Oct 2017 09:47:38 -0700
Message-ID: <CAEvLuNbH0azyfSydbu3yNZ-_xY-G_5YrDDneCwcFbv+NgYd10w@mail.gmail.com>
Subject: Re: [RFC PATCH] mm, thp: make deferred_split_shrinker memcg-aware
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Dan Williams <dan.j.williams@intel.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Kemi Wang <kemi.wang@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Shaohua Li <shli@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

[Sorry for multiple emails, it wasn't in plain text before, thus resending.]

On Fri, Oct 20, 2017 at 12:12 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 19-10-17 13:03:23, Neha Agarwal wrote:
>> deferred_split_shrinker is NUMA aware. Making it memcg-aware if
>> CONFIG_MEMCG is enabled to prevent shrinking memory of memcg(s) that are
>> not under memory pressure. This change isolates memory pressure across
>> memcgs from deferred_split_shrinker perspective, by not prematurely
>> splitting huge pages for the memcg that is not under memory pressure.
>
> Why do we need this? THP pages are usually not shared between memcgs. Or
> do you have a real world example where this is not the case? Your patch
> is adding quite a lot of (and to be really honest very ugly) code so
> there better should be a _very_ good reason to justify it. I haven't
> looked very closely to the code, at least all those ifdefs in the code
> are too ugly to live.
> --
> Michal Hocko
> SUSE Labs

Hi Michal,

Let me try to pitch the motivation first:
In the case of NUMA-aware shrinker, memory pressure may lead to
splitting and freeing subpages within a THP, irrespective of whether
the page belongs to the memcg that is under memory pressure. THP
sharing between memcgs is not a pre-condition for above to happen.

Let's consider two memcgs: memcg-A and memcg-B. Say memcg-A is under
memory pressure that is hitting its limit. If this memory pressure
invokes the shrinker (non-memcg-aware) and splits pages from memcg-B
queued for deferred splits, then that won't reduce memcg-A's usage. It
will reduce memcg-B's usage. Also, why should memcg-A's memory
pressure reduce memcg-B's usage.

By making this shrinker memcg-aware, we can invoke respective memcg
shrinkers to handle the memory pressure. Furthermore, with this
approach we can isolate the THPs of other memcg(s) (not under memory
pressure) from premature splits. Isolation aids in reducing
performance impact when we have several memcgs on the same machine.

Regarding ifdef ugliness: I get your point and agree with you on that.
I think I can do a better job at restricting the ugliness, will post
another version.

-- 
Thanks,
Neha Agarwal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
