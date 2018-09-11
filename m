Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8578E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 18:13:19 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r20-v6so12978989pgv.20
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 15:13:19 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id p91-v6si20520549plb.51.2018.09.11.15.13.17
        for <linux-mm@kvack.org>;
        Tue, 11 Sep 2018 15:13:18 -0700 (PDT)
Date: Wed, 12 Sep 2018 08:13:15 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 4/4] fs/dcache: Eliminate branches in
 nr_dentry_negative accounting
Message-ID: <20180911221315.GH5631@dastard>
References: <1536693506-11949-1-git-send-email-longman@redhat.com>
 <1536693506-11949-5-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536693506-11949-5-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On Tue, Sep 11, 2018 at 03:18:26PM -0400, Waiman Long wrote:
> Because the accounting of nr_dentry_negative depends on whether a dentry
> is a negative one or not, branch instructions are introduced to handle
> the accounting conditionally. That may potentially slow down the task
> by a noticeable amount if that introduces sizeable amount of additional
> branch mispredictions.
> 
> To avoid that, the accounting code is now modified to use conditional
> move instructions instead, if supported by the architecture.

I think this is a case of over-optimisation. It makes the code
harder to read for extremely marginal benefit, and if we ever need
to add any more code for negative dentries in these paths the first
thing we'll have to do is revert this change.

Unless you have numbers demonstrating that it's a clear performance
improvement, then NACK for this patch.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
