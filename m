Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id D25456B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 16:36:19 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id b68so124670760ywe.0
        for <linux-mm@kvack.org>; Wed, 24 May 2017 13:36:19 -0700 (PDT)
Received: from mail-yb0-x234.google.com (mail-yb0-x234.google.com. [2607:f8b0:4002:c09::234])
        by mx.google.com with ESMTPS id n9si5961793ybf.199.2017.05.24.13.36.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 13:36:18 -0700 (PDT)
Received: by mail-yb0-x234.google.com with SMTP id p143so48337456yba.2
        for <linux-mm@kvack.org>; Wed, 24 May 2017 13:36:18 -0700 (PDT)
Date: Wed, 24 May 2017 16:36:16 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
Message-ID: <20170524203616.GO24798@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-12-git-send-email-longman@redhat.com>
 <20170519202624.GA15279@wtj.duckdns.org>
 <b1d02881-f522-8baa-5ebe-9b1ad74a03e4@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b1d02881-f522-8baa-5ebe-9b1ad74a03e4@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello, Waiman.

On Mon, May 22, 2017 at 01:13:16PM -0400, Waiman Long wrote:
> > Maybe I'm misunderstanding the design, but this seems to push the
> > processes which belong to the threaded subtree to the parent which is
> > part of the usual resource domain hierarchy thus breaking the no
> > internal competition constraint.  I'm not sure this is something we'd
> > want.  Given that the limitation of the original threaded mode was the
> > required nesting below root and that we treat root special anyway
> > (exactly in the way necessary), I wonder whether it'd be better to
> > simply allow root to be both domain and thread root.
> 
> Yes, root can be both domain and thread root. I haven't placed any
> restriction on that.

I've been playing with the proposed "make the parent resource domain".
Unfortunately, the parent - child relationship becomes weird.

The parent becomes the thread root, which means that its
cgroup.threads file becomes writable and threads can be put in there.
It's really weird to write to a child's interface and have the
parent's behavior changed.  This becomes weirder with delegation.  If
a cgroup is delegated, its cgroup.threads should be delegated too but
if the child enables threaded mode, that makes the undelegated parent
thread root, which means that either 1. the delegatee can't migrate
threads to the thread root or 2. if the parent's cgroup.threads is
writeable, the delegatee can mass with other descendants under it
which shouldn't be allowed.

I think the operation of making a cgroup a thread root should happen
on the cgroup where that's requested; otherwise, nesting becomes too
twisted.  This should be solvable.  Will think more about it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
