Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0DF6B0005
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 12:09:22 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d25-v6so25904993qkj.9
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 09:09:22 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i8-v6si3074546qtc.160.2018.07.10.09.09.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 09:09:20 -0700 (PDT)
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
References: <1530905572-817-1-git-send-email-longman@redhat.com>
 <20180709081920.GD22049@dhcp22.suse.cz>
 <62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
 <20180710142740.GQ14284@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Message-ID: <a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
Date: Tue, 10 Jul 2018 12:09:17 -0400
MIME-Version: 1.0
In-Reply-To: <20180710142740.GQ14284@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On 07/10/2018 10:27 AM, Michal Hocko wrote:
> On Mon 09-07-18 12:01:04, Waiman Long wrote:
>> On 07/09/2018 04:19 AM, Michal Hocko wrote:
> [...]
>>> later needs a special treatment while the first one is ok? There are
>>> quite some resources which allow a non privileged user to consume a l=
ot
>>> of memory and the memory controller is the only reliable way to mitig=
ate
>>> the risk.
>> Yes, memory controller is the only reliable way to mitigate the risk,
>> but not all tasks are under the control of a memory controller with
>> kernel memory limit.
> But those which you do not trust should. So why do we need yet another
> mechanism for the reclaim?

Sometimes it could be a programming error in the code. I had seen a
customer report about the negative dentries because of a bug in their
code that generated a lot of negative dentries causing problem. In such
a controlled environment, they may not want to run their applications
under a memory cgroup as there is overhead involved in that. So a
mechanism to highlight and notify the problem is probably good to have.

>
> [...]
>>>> Patch 1 tracks the number of negative dentries present in the LRU
>>>> lists and reports it in /proc/sys/fs/dentry-state.
>>> If anything I _think_ vmstat would benefit from this because behavior=
 of
>>> the memory reclaim does depend on the amount of neg. dentries.
>>>
>>>> Patch 2 adds a "neg-dentry-pc" sysctl parameter that can be used to =
to
>>>> specify a soft limit on the number of negative allowed as a percenta=
ge
>>>> of total system memory. This parameter is 0 by default which means n=
o
>>>> negative dentry limiting will be performed.
>>> percentage has turned out to be a really wrong unit for many tunables=

>>> over time. Even 1% can be just too much on really large machines.
>> Yes, that is true. Do you have any suggestion of what kind of unit
>> should be used? I can scale down the unit to 0.1% of the system memory=
=2E
>> Alternatively, one unit can be 10k/cpu thread, so a 20-thread system
>> corresponds to 200k, etc.
> I simply think this is a strange user interface. How much is a
> reasonable number? How can any admin figure that out?

Without the optional enforcement, the limit is essentially just a
notification mechanism where the system signals that there is something
wrong going on and the system administrator need to take a look. So it
is perfectly OK if the limit is sufficiently high that normally we won't
need to use that many negative dentries. The goal is to prevent negative
dentries from consuming a significant portion of the system memory.

I am going to reduce the granularity of each unit to 1/1000 of the total
system memory so that for large system with TB of memory, a smaller
amount of memory can be specified.

>>>> Patch 3 enables automatic pruning of least recently used negative
>>>> dentries when the total number is close to the preset limit.
>>> Please explain why this cannot be done in a standard dcache shrinking=

>>> way. I strongly suspect that you are developing yet another reclaim w=
ith
>>> its own sets of tunable and bypassing the existing infrastructure. I
>>> haven't read patches yet but the cover letter doesn't really explain
>>> design much so I am only guessing.
>> The standard dcache shrinking happens when the system is almost runnin=
g
>> out of free memory.
> Well, the standard reclaim happens when somebody needs memory. We are
> usually quite far away from "almost running out of memory". We do
> reclaim fs metadata including dentries so I really do not see why
> negative ones should be any special here.

That is fine. I can certainly live without the new reclaim mechanism.

>
>> This new shrinker will be turned on when the number
>> of negative dentries is closed to the limit even when there are still
>> plenty of free memory left. It will stop when the number of negative
>> dentries is lowered to a safe level. The new shrinker is designed to
>> impose as little overhead to the currently running tasks. That is not
>> true for the standard shrinker which will have a rather significant
>> performance impact to the currently running tasks.
> Do you have any numbers to back your claim? The memory reclaim is
> usually quite lightweight. Especially when we have a lot of clean
> fs {meta}data

In the case of dentries, it is the lock hold time of the LRU list that
can impact the normal filesystem operation. The new shrinker that I add
purposely limit the lock hold time whereas the standard shrinker can
hold the LRU for quite a long time if there are a lot of dentries to get
rid of. I have some performance numbers in the cover letter of this
patch about this.

>> I can remove the new shrinker if people really don't want to add a new=

>> one as long as I can keep the option to kill off newly created negativ=
e
>> dentries when the limit is exceeded.
> Please let's not add yet another memory reclaim mechanism. It will just=

> backfire sooner or later.

As said above, I am going to remove the new shrinker in the next version
of the patch. We can always add it back later on if we feel there is a
need to do it.

Cheers,
Longman
