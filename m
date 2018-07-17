Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id CEF226B0008
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 20:51:47 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id q18-v6so25736754pll.3
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 17:51:47 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q4-v6si16496784pll.156.2018.07.16.17.51.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 17:51:46 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH v2 0/7] swap: THP optimizing refactoring
Date: Tue, 17 Jul 2018 08:51:46 +0800
Message-Id: <20180717005153.29483-1-ying.huang@intel.com>
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
