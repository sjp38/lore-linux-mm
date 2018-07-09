Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB4E86B02F4
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 12:01:07 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id e4-v6so4600016qtj.5
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 09:01:07 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b10-v6si9553331qtk.181.2018.07.09.09.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 09:01:06 -0700 (PDT)
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
References: <1530905572-817-1-git-send-email-longman@redhat.com>
 <20180709081920.GD22049@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Message-ID: <62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
Date: Mon, 9 Jul 2018 12:01:04 -0400
MIME-Version: 1.0
In-Reply-To: <20180709081920.GD22049@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On 07/09/2018 04:19 AM, Michal Hocko wrote:
> On Fri 06-07-18 15:32:45, Waiman Long wrote:
> [...]
>> A rogue application can potentially create a large number of negative
>> dentries in the system consuming most of the memory available if it
>> is not under the direct control of a memory controller that enforce
>> kernel memory limit.
> How does this differ from other untracked allocations for untrusted
> tasks in general? E.g. nothing really prevents a task to create a long
> chain of unreclaimable dentries and even go to OOM potentially. Negativ=
e
> dentries should be easily reclaimable on the other hand. So why does th=
e

I think all dentries are reclaimable. Yes, a rogue application or user
can create million of new files and hence dentries or consuming buffer
cache. The major difference here is the other attack can be very
noticeable and traceable. Filesystem limits may also be hit first before
the system is running out of memory. The negative dentry attack,
however, is more hidden and not easily traceable. So you won't know the
system is in trouble until it is almost running out of free memory.


> later needs a special treatment while the first one is ok? There are
> quite some resources which allow a non privileged user to consume a lot=

> of memory and the memory controller is the only reliable way to mitigat=
e
> the risk.

Yes, memory controller is the only reliable way to mitigate the risk,
but not all tasks are under the control of a memory controller with
kernel memory limit.

>> This patchset introduces changes to the dcache subsystem to track and
>> optionally limit the number of negative dentries allowed to be created=
 by
>> background pruning of excess negative dentries or even kill it after u=
se.
>> This capability will help to limit the amount of memory that can be
>> consumed by negative dentries.
> How are you going to balance that between workload? What prevents a
> rogue application to simply consume the limit and force all others in
> the system to go slow path?

With the current patchset, it is possible for a rogue application to
force every one else to go to slow path. One possible solution to this
is to go to the slowpath only for the newly created neg dentries, not
for those that have been created previously and reused again. Patch 5 of
the current series track which negative dentry is newly created and
handle it differently. I can move this up the series and use that
information to decide if we should go to the slowpath.

>> Patch 1 tracks the number of negative dentries present in the LRU
>> lists and reports it in /proc/sys/fs/dentry-state.
> If anything I _think_ vmstat would benefit from this because behavior o=
f
> the memory reclaim does depend on the amount of neg. dentries.
>
>> Patch 2 adds a "neg-dentry-pc" sysctl parameter that can be used to to=

>> specify a soft limit on the number of negative allowed as a percentage=

>> of total system memory. This parameter is 0 by default which means no
>> negative dentry limiting will be performed.
> percentage has turned out to be a really wrong unit for many tunables
> over time. Even 1% can be just too much on really large machines.

Yes, that is true. Do you have any suggestion of what kind of unit
should be used? I can scale down the unit to 0.1% of the system memory.
Alternatively, one unit can be 10k/cpu thread, so a 20-thread system
corresponds to 200k, etc.

>
>> Patch 3 enables automatic pruning of least recently used negative
>> dentries when the total number is close to the preset limit.
> Please explain why this cannot be done in a standard dcache shrinking
> way. I strongly suspect that you are developing yet another reclaim wit=
h
> its own sets of tunable and bypassing the existing infrastructure. I
> haven't read patches yet but the cover letter doesn't really explain
> design much so I am only guessing.

The standard dcache shrinking happens when the system is almost running
out of free memory. This new shrinker will be turned on when the number
of negative dentries is closed to the limit even when there are still
plenty of free memory left. It will stop when the number of negative
dentries is lowered to a safe level. The new shrinker is designed to
impose as little overhead to the currently running tasks. That is not
true for the standard shrinker which will have a rather significant
performance impact to the currently running tasks.

I can remove the new shrinker if people really don't want to add a new
one as long as I can keep the option to kill off newly created negative
dentries when the limit is exceeded.

Cheers,
Longman
