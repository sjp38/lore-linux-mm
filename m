Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9929B6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 13:10:07 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w84so38135993wmg.1
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 10:10:07 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j199si21520459wmg.52.2016.09.19.10.10.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 10:10:06 -0700 (PDT)
Date: Mon, 19 Sep 2016 10:09:51 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -v3 01/10] mm, swap: Make swap cluster size same of THP
 size on x86_64
Message-ID: <20160919170951.GA1059@cmpxchg.org>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
 <1473266769-2155-2-git-send-email-ying.huang@intel.com>
 <57D0FB10.5010609@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57D0FB10.5010609@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Thu, Sep 08, 2016 at 11:15:52AM +0530, Anshuman Khandual wrote:
> On 09/07/2016 10:16 PM, Huang, Ying wrote:
> > From: Huang Ying <ying.huang@intel.com>
> > 
> > In this patch, the size of the swap cluster is changed to that of the
> > THP (Transparent Huge Page) on x86_64 architecture (512).  This is for
> > the THP swap support on x86_64.  Where one swap cluster will be used to
> > hold the contents of each THP swapped out.  And some information of the
> > swapped out THP (such as compound map count) will be recorded in the
> > swap_cluster_info data structure.
> > 
> > For other architectures which want THP swap support, THP_SWAP_CLUSTER
> > need to be selected in the Kconfig file for the architecture.
> > 
> > In effect, this will enlarge swap cluster size by 2 times on x86_64.
> > Which may make it harder to find a free cluster when the swap space
> > becomes fragmented.  So that, this may reduce the continuous swap space
> > allocation and sequential write in theory.  The performance test in 0day
> > shows no regressions caused by this.
> 
> This patch needs to be split into two separate ones
> 
> (1) Add THP_SWAP_CLUSTER config option
> (2) Enable CONFIG_THP_SWAP_CLUSTER for X86_64

No, don't do that. This is a bit of an anti-pattern in this series,
where it introduces a thing in one patch, and a user for it in a later
patch. However, in order to judge whether that thing is good or not, I
need to know how exactly it's being used.

So, please, split your series into logical steps, not geographical
ones. When you introduce a function, config option, symbol, add it
along with the code that actually *uses* it, in the same patch.

It goes for this patch, but also stuff like the memcg accounting
functions, get_huge_swap_page() etc.

Start with the logical change, then try to isolate independent changes
that could make sense even without the rest of the series. If that
results in a large patch, then so be it. If a big change is hard to
review, then making me switch back and forth between emails will make
it harder, not easier, to make make sense of it.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
