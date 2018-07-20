Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id F35536B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 03:19:58 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j4-v6so5363975pgq.16
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 00:19:58 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a24-v6si1272473pgh.357.2018.07.20.00.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 00:19:56 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH v4 0/8] swap: THP optimizing refactoring
Date: Fri, 20 Jul 2018 15:18:37 +0800
Message-Id: <20180720071845.17920-1-ying.huang@intel.com>
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
