Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C7A588E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 22:36:17 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g12-v6so272366plo.1
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 19:36:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t7-v6si20744730plo.165.2018.09.11.19.36.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 11 Sep 2018 19:36:16 -0700 (PDT)
Date: Tue, 11 Sep 2018 19:36:10 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 4/4] fs/dcache: Eliminate branches in
 nr_dentry_negative accounting
Message-ID: <20180912023610.GB20056@bombadil.infradead.org>
References: <1536693506-11949-1-git-send-email-longman@redhat.com>
 <1536693506-11949-5-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536693506-11949-5-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On Tue, Sep 11, 2018 at 03:18:26PM -0400, Waiman Long wrote:
> Because the accounting of nr_dentry_negative depends on whether a dentry
> is a negative one or not, branch instructions are introduced to handle
> the accounting conditionally. That may potentially slow down the task
> by a noticeable amount if that introduces sizeable amount of additional
> branch mispredictions.
> 
> To avoid that, the accounting code is now modified to use conditional
> move instructions instead, if supported by the architecture.

You're substituting your judgement here for the compiler's.  I don't
see a reason why the compiler couldn't choose to use a cmov in order
to do this:

	if (dentry->d_flags & DCACHE_LRU_LIST)
		this_cpu_inc(nr_dentry_negative);

unless our macrology has got too clever for the compilre to see through
it.  In which case, the right answer is to simplify the percpu code,
not to force the compiler to optimise the code in the way that makes
sense for your current microarchitecture.
