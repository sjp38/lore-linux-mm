Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 867AE6B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 17:17:17 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id x53so71487221qtx.14
        for <linux-mm@kvack.org>; Wed, 24 May 2017 14:17:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k28si741642qtf.298.2017.05.24.14.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 14:17:16 -0700 (PDT)
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-12-git-send-email-longman@redhat.com>
 <20170519202624.GA15279@wtj.duckdns.org>
 <b1d02881-f522-8baa-5ebe-9b1ad74a03e4@redhat.com>
 <20170524203616.GO24798@htj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <9b147a7e-fec3-3b78-7587-3890efcd42f2@redhat.com>
Date: Wed, 24 May 2017 17:17:13 -0400
MIME-Version: 1.0
In-Reply-To: <20170524203616.GO24798@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 05/24/2017 04:36 PM, Tejun Heo wrote:
> Hello, Waiman.
>
> On Mon, May 22, 2017 at 01:13:16PM -0400, Waiman Long wrote:
>>> Maybe I'm misunderstanding the design, but this seems to push the
>>> processes which belong to the threaded subtree to the parent which is=

>>> part of the usual resource domain hierarchy thus breaking the no
>>> internal competition constraint.  I'm not sure this is something we'd=

>>> want.  Given that the limitation of the original threaded mode was th=
e
>>> required nesting below root and that we treat root special anyway
>>> (exactly in the way necessary), I wonder whether it'd be better to
>>> simply allow root to be both domain and thread root.
>> Yes, root can be both domain and thread root. I haven't placed any
>> restriction on that.
> I've been playing with the proposed "make the parent resource domain".
> Unfortunately, the parent - child relationship becomes weird.
>
> The parent becomes the thread root, which means that its
> cgroup.threads file becomes writable and threads can be put in there.
> It's really weird to write to a child's interface and have the
> parent's behavior changed.  This becomes weirder with delegation.  If
> a cgroup is delegated, its cgroup.threads should be delegated too but
> if the child enables threaded mode, that makes the undelegated parent
> thread root, which means that either 1. the delegatee can't migrate
> threads to the thread root or 2. if the parent's cgroup.threads is
> writeable, the delegatee can mass with other descendants under it
> which shouldn't be allowed.
>
> I think the operation of making a cgroup a thread root should happen
> on the cgroup where that's requested; otherwise, nesting becomes too
> twisted.  This should be solvable.  Will think more about it.
>
> Thanks.
>
An alternative is to have separate enabling for thread root. For example,=


# echo root > cgroup.threads
# echo enable > child/cgroup.threads

The first statement make the current cgroup the thread root. However,
setting it to a thread root doesn't make its child to be threaded. This
have to be explicitly done on each of the children. Once a child cgroup
is made to be threaded, all its descendants will be threaded. That will
have the same effect as the current patch.

With delegation, do you mean the relationship between a container and
its host?

Cheers,
Longman


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
