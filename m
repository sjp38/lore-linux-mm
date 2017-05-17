Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0F386B02F3
	for <linux-mm@kvack.org>; Wed, 17 May 2017 17:47:22 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id 190so14220888ybe.2
        for <linux-mm@kvack.org>; Wed, 17 May 2017 14:47:22 -0700 (PDT)
Received: from mail-yb0-x236.google.com (mail-yb0-x236.google.com. [2607:f8b0:4002:c09::236])
        by mx.google.com with ESMTPS id d200si1049077ybh.286.2017.05.17.14.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 14:47:21 -0700 (PDT)
Received: by mail-yb0-x236.google.com with SMTP id 187so8815ybg.0
        for <linux-mm@kvack.org>; Wed, 17 May 2017 14:47:20 -0700 (PDT)
Date: Wed, 17 May 2017 17:47:18 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
Message-ID: <20170517214718.GH942@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-12-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494855256-12558-12-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello, Waiman.

On Mon, May 15, 2017 at 09:34:10AM -0400, Waiman Long wrote:
> The current thread mode semantics aren't sufficient to fully support
> threaded controllers like cpu. The main problem is that when thread
> mode is enabled at root (mainly for performance reason), all the
> non-threaded controllers cannot be supported at all.
> 
> To alleviate this problem, the roles of thread root and threaded
> cgroups are now further separated. Now thread mode can only be enabled
> on a non-root leaf cgroup whose parent will then become the thread
> root. All the descendants of a threaded cgroup will still need to be
> threaded. All the non-threaded resource will be accounted for in the
> thread root. Unlike the previous thread mode, however, a thread root
> can have non-threaded children where system resources like memory
> can be further split down the hierarchy.
> 
> Now we could have something like
> 
> 	R -- A -- B
> 	 \
> 	  T1 -- T2
> 
> where R is the thread root, A and B are non-threaded cgroups, T1 and
> T2 are threaded cgroups. The cgroups R, T1, T2 form a threaded subtree
> where all the non-threaded resources are accounted for in R.  The no
> internal process constraint does not apply in the threaded subtree.
> Non-threaded controllers need to properly handle the competition
> between internal processes and child cgroups at the thread root.
> 
> This model will be flexible enough to support the need of the threaded
> controllers.

I do like the approach and it does address the issue with requiring at
least one level of nesting for the thread mode to be used with other
controllers.  I need to think a bit more about it and mull over what
Peterz was suggesting in the old thread.  I'll get back to you soon
but I'd really prefer this and the earlier related patches to be in
its own patchset so that we aren't dealing with different things at
the same time.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
