Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 804526B0008
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 04:19:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y17-v6so513754eds.22
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 01:19:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h50-v6si1695249ede.283.2018.07.09.01.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 01:19:23 -0700 (PDT)
Date: Mon, 9 Jul 2018 10:19:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180709081920.GD22049@dhcp22.suse.cz>
References: <1530905572-817-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530905572-817-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On Fri 06-07-18 15:32:45, Waiman Long wrote:
[...]
> A rogue application can potentially create a large number of negative
> dentries in the system consuming most of the memory available if it
> is not under the direct control of a memory controller that enforce
> kernel memory limit.

How does this differ from other untracked allocations for untrusted
tasks in general? E.g. nothing really prevents a task to create a long
chain of unreclaimable dentries and even go to OOM potentially. Negative
dentries should be easily reclaimable on the other hand. So why does the
later needs a special treatment while the first one is ok? There are
quite some resources which allow a non privileged user to consume a lot
of memory and the memory controller is the only reliable way to mitigate
the risk.

> This patchset introduces changes to the dcache subsystem to track and
> optionally limit the number of negative dentries allowed to be created by
> background pruning of excess negative dentries or even kill it after use.
> This capability will help to limit the amount of memory that can be
> consumed by negative dentries.

How are you going to balance that between workload? What prevents a
rogue application to simply consume the limit and force all others in
the system to go slow path?

> Patch 1 tracks the number of negative dentries present in the LRU
> lists and reports it in /proc/sys/fs/dentry-state.

If anything I _think_ vmstat would benefit from this because behavior of
the memory reclaim does depend on the amount of neg. dentries.

> Patch 2 adds a "neg-dentry-pc" sysctl parameter that can be used to to
> specify a soft limit on the number of negative allowed as a percentage
> of total system memory. This parameter is 0 by default which means no
> negative dentry limiting will be performed.

percentage has turned out to be a really wrong unit for many tunables
over time. Even 1% can be just too much on really large machines.

> Patch 3 enables automatic pruning of least recently used negative
> dentries when the total number is close to the preset limit.

Please explain why this cannot be done in a standard dcache shrinking
way. I strongly suspect that you are developing yet another reclaim with
its own sets of tunable and bypassing the existing infrastructure. I
haven't read patches yet but the cover letter doesn't really explain
design much so I am only guessing.
-- 
Michal Hocko
SUSE Labs
