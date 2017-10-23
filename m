Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CD7846B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 07:33:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id z77so1252359wmc.16
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 04:33:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3si5468123wrb.55.2017.10.23.04.33.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 04:33:18 -0700 (PDT)
Date: Mon, 23 Oct 2017 13:33:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, thp: make deferred_split_shrinker memcg-aware
Message-ID: <20171023113315.jfu75pl4hytakjog@dhcp22.suse.cz>
References: <20171019200323.42491-1-nehaagarwal@google.com>
 <20171020071250.ftqn2d356yekkp5k@dhcp22.suse.cz>
 <CAEvLuNbH0azyfSydbu3yNZ-_xY-G_5YrDDneCwcFbv+NgYd10w@mail.gmail.com>
 <CAEvLuNbo=zf1aC9k7sitZgYPD=P1Awwne4mmUSRtJc0EF1xcAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEvLuNbo=zf1aC9k7sitZgYPD=P1Awwne4mmUSRtJc0EF1xcAA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Neha Agarwal <nehaagarwal@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Dan Williams <dan.j.williams@intel.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Kemi Wang <kemi.wang@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Shaohua Li <shli@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri 20-10-17 10:47:57, Neha Agarwal wrote:
> On Fri, Oct 20, 2017 at 9:47 AM, Neha Agarwal <nehaagarwal@google.com> wrote:
> > [Sorry for multiple emails, it wasn't in plain text before, thus resending.]
> >
> > On Fri, Oct 20, 2017 at 12:12 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >> On Thu 19-10-17 13:03:23, Neha Agarwal wrote:
> >>> deferred_split_shrinker is NUMA aware. Making it memcg-aware if
> >>> CONFIG_MEMCG is enabled to prevent shrinking memory of memcg(s) that are
> >>> not under memory pressure. This change isolates memory pressure across
> >>> memcgs from deferred_split_shrinker perspective, by not prematurely
> >>> splitting huge pages for the memcg that is not under memory pressure.
> >>
> >> Why do we need this? THP pages are usually not shared between memcgs. Or
> >> do you have a real world example where this is not the case? Your patch
> >> is adding quite a lot of (and to be really honest very ugly) code so
> >> there better should be a _very_ good reason to justify it. I haven't
> >> looked very closely to the code, at least all those ifdefs in the code
> >> are too ugly to live.
> >> --
> >> Michal Hocko
> >> SUSE Labs
> >
> > Hi Michal,
> >
> > Let me try to pitch the motivation first:
> > In the case of NUMA-aware shrinker, memory pressure may lead to
> > splitting and freeing subpages within a THP, irrespective of whether
> > the page belongs to the memcg that is under memory pressure. THP
> > sharing between memcgs is not a pre-condition for above to happen.
> 
> I think I got confused here. The point I want to make is that when a
> memcg is under memory pressure, only memcg-aware shrinkers are called.
> However, a memcg with partially-mapped THPs (which can be split and
> thus free up subpages) should be be able to split such THPs, to avoid
> oom-kills under memory pressure. By making this shrinker memcg-aware,
> we will be able to free up subpages by splitting partially-mapped THPs
> under memory pressure.

I still do not understand, sorry. How can we result in OOM due to THP
splitting. Please make sure to describe user visible effects that you
are seeing and why you think they need fixing along with a description
on how the fix works.

So far I am kinda lost to see what you are trying to achieve and why.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
