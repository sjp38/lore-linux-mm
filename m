Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9DF6B0270
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:48:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f9-v6so3704986pfn.22
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:48:52 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x18-v6si4948122pll.193.2018.07.19.01.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 01:48:51 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH v3 0/8] swap: THP optimizing refactoring
Date: Thu, 19 Jul 2018 16:48:34 +0800
Message-Id: <20180719084842.11385-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

This patchset is based on 2018-07-13 head of mmotm tree.

Now the THP (Transparent Huge Page) swap optimizing is implemented in
the way like below,

#ifdef CONFIG_THP_SWAP
huge_function(...)
{
}
#else
normal_function(...)
{
}
#endif

general_function(...)
{
	if (huge)
		return thp_function(...);
	else
		return normal_function(...);
}

As pointed out by Dave Hansen, this will,

1. Created a new, wholly untested code path for huge page
2. Created two places to patch bugs
3. Are not reusing code when possible

This patchset is to address these problems via merging huge/normal
code path/functions if possible.

One concern is that this may cause code size to dilate when
!CONFIG_TRANSPARENT_HUGEPAGE.  The data shows that most refactoring
will only cause quite slight code size increase.

Best Regards,
Huang, Ying
