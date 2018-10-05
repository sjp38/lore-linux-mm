Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 751EC6B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 10:55:52 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s1-v6so12533947qte.19
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 07:55:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c24-v6si5746501qtc.275.2018.10.05.07.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 07:55:51 -0700 (PDT)
Subject: Re: [PATCH v4 0/3] fs/dcache: Track # of negative dentries
References: <1536773742-32687-1-git-send-email-longman@redhat.com>
From: Waiman Long <longman@redhat.com>
Message-ID: <7054d7fe-5385-c743-b2ea-595e5988799f@redhat.com>
Date: Fri, 5 Oct 2018 10:55:47 -0400
MIME-Version: 1.0
In-Reply-To: <1536773742-32687-1-git-send-email-longman@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 09/12/2018 01:35 PM, Waiman Long wrote:
>  v3->v4:
>   - Drop patch 4 as it is just a minor optimization.
>   - Add a cc:stable tag to patch 1.
>   - Clean up some comments in patch 3.
>
>  v2->v3:
>   - With confirmation that the dummy array in dentry_stat structure
>     was never a replacement of a previously used field, patch 3 is now
>     reverted back to use one of dummy field as the negative dentry count
>     instead of adding a new field.
>
>  v1->v2:
>   - Clarify what the new nr_dentry_negative per-cpu counter is tracking
>     and open-code the increment and decrement as suggested by Dave Chinner.
>   - Append the new nr_dentry_negative count as the 7th element of dentry-state
>     instead of replacing one of the dummy entries.
>   - Remove patch "fs/dcache: Make negative dentries easier to be
>     reclaimed" for now as I need more time to think about what
>     to do with it.
>   - Add 2 more patches to address issues found while reviewing the
>     dentry code.
>   - Add another patch to change the conditional branch of
>     nr_dentry_negative accounting to conditional move so as to reduce
>     the performance impact of the accounting code.
>
> This patchset addresses 2 issues found in the dentry code and adds a
> new nr_dentry_negative per-cpu counter to track the total number of
> negative dentries in all the LRU lists.
>
> Patch 1 fixes a bug in the accounting of nr_dentry_unused in
> shrink_dcache_sb().
>
> Patch 2 removes the ____cacheline_aligned_in_smp tag from super_block
> LRU lists.
>
> Patch 3 adds the new nr_dentry_negative per-cpu counter.
>
> Various filesystem related tests were run and no statistically
> significant changes in performance outside of the possible noise range
> was observed.
>
> Waiman Long (3):
>   fs/dcache: Fix incorrect nr_dentry_unused accounting in
>     shrink_dcache_sb()
>   fs: Don't need to put list_lru into its own cacheline
>   fs/dcache: Track & report number of negative dentries
>
>  Documentation/sysctl/fs.txt | 26 ++++++++++++++++----------
>  fs/dcache.c                 | 38 +++++++++++++++++++++++++++++++++-----
>  include/linux/dcache.h      |  7 ++++---
>  include/linux/fs.h          |  9 +++++----
>  4 files changed, 58 insertions(+), 22 deletions(-)
>
Any comments on these patches. The first one actually is a bug fix.

Cheers,
Longman
