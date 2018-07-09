Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0C56B030B
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 13:19:30 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 39-v6so10523292ple.6
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 10:19:30 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id k23-v6si15065893pls.134.2018.07.09.10.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 10:19:29 -0700 (PDT)
Subject: Re: [PATCH -mm -v4 05/21] mm, THP, swap: Support PMD swap mapping in
 free_swap_and_cache()/swap_free()
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180622035151.6676-6-ying.huang@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <49178f48-6635-353c-678d-3db436d3f9c3@linux.intel.com>
Date: Mon, 9 Jul 2018 10:19:25 -0700
MIME-Version: 1.0
In-Reply-To: <20180622035151.6676-6-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

I'm seeing a pattern here.

old code:

foo()
{
	do_swap_something()
}

new code:

foo(bool cluster)
{
	if (cluster)
		do_swap_cluster_something();
	else
		do_swap_something();
}

That make me fear that we have:
1. Created a new, wholly untested code path
2. Created two places to patch bugs
3. Are not reusing code when possible

The code non-resuse was, and continues to be, IMNHO, one of the largest
sources of bugs with the original THP implementation.  It might be
infeasible to do here, but let's at least give it as much of a go as we can.

Can I ask that you take another round through this set and:

1. Consolidate code refactoring into separate patches
2. Add comments to code, and avoid doing it solely in changelogs
3. Make an effort to share more code between the old code and new
   code.  Where code can not be shared, call that out in the changelog.

This is a *really* hard-to-review set at the moment.  Doing those things
will make it much easier to review and hopefully give us more
maintainable code going forward.

My apologies for not having done this review sooner.
