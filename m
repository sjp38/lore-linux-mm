Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08F8D6B0007
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 15:08:04 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x204-v6so15541326qka.6
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 12:08:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d57-v6si5487275qtk.6.2018.07.11.12.08.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 12:08:02 -0700 (PDT)
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
References: <1530905572-817-1-git-send-email-longman@redhat.com>
 <20180709081920.GD22049@dhcp22.suse.cz>
 <62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
 <20180710142740.GQ14284@dhcp22.suse.cz>
 <a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
 <20180711102139.GG20050@dhcp22.suse.cz>
 <9f24c043-1fca-ee86-d609-873a7a8f7a64@redhat.com>
 <1531330947.3260.13.camel@HansenPartnership.com>
From: Waiman Long <longman@redhat.com>
Message-ID: <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
Date: Wed, 11 Jul 2018 15:07:59 -0400
MIME-Version: 1.0
In-Reply-To: <1531330947.3260.13.camel@HansenPartnership.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>, Michal Hocko <mhocko@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On 07/11/2018 01:42 PM, James Bottomley wrote:
> On Wed, 2018-07-11 at 11:13 -0400, Waiman Long wrote:
>> On 07/11/2018 06:21 AM, Michal Hocko wrote:
>>> On Tue 10-07-18 12:09:17, Waiman Long wrote:
> [...]
>>>> I am going to reduce the granularity of each unit to 1/1000 of
>>>> the total system memory so that for large system with TB of
>>>> memory, a smaller amount of memory can be specified.
>>> It is just a matter of time for this to be too coarse as well.
>> The goal is to not have too much memory being consumed by negative
>> dentries and also the limit won't be reached by regular daily
>> activities. So a limit of 1/1000 of the total system memory will be
>> good enough on large memory system even if the absolute number is
>> really big.
> OK, I think the reason we're going round and round here without
> converging is that one of the goals of the mm subsystem is to manage
> all of our cached objects and to it the negative (and positive)
> dentries simply look like a clean cache of objects.  Right at the
> moment mm manages them in the same way it manages all the other caches,=

> a lot of which suffer from the "you can cause lots of allocations to
> artificially grow them" problem.  So the main question is why doesn't
> the current mm control of the caches work well enough for dentries?=20
> What are the problems you're seeing that mm should be catching?  If you=

> can answer this, then we could get on to whether a separate shrinker,
> cache separation or some fix in mm itself is the right answer.
>
> What you say above is based on a conclusion: limiting dentries improves=

> the system performance.  What we're asking for is evidence for that
> conclusion so we can explore whether the same would go for any of our
> other system caches (so do we have a global cache management problem or=

> is it only the dentry cache?)
>
> James
>
I am not saying that limiting dentries will improve performance. I am
just saying that unlimited growth in the number of negative dentries
will reduce the amount of memory available to other applications and
hence will have an impact on performance. Normally the amount of memory
consumed by dentries is a very small portion of the system memory.
Depending on memory size, it could be less than 1% or so. In such case,
doubling or even tripling the number of dentries probably won't have
much performance impact.

Unlike positive dentries which are constrained by the # of files in the
filesystems, the growth of negative dentries can be unlimited. A program
bug or a rogue application can easily generate a lot of negative
dentries consuming 10% or more system memory available if it is not
under the control of a memory controller limiting kernel memory.

The purpose of this patchset is to add a mechanism to track and
optionally limit the number of negative dentries that can be created in
a system. A new shrinker is added to round out the package, but it is
not an essential part of the patchset. The default memory shrinker will
be activated when the amount of free memory is low. I am going to drop
that in the next version of the patchset.

This patchset does change slightly the way dentries are handled in the
vfs layer. I will certainly welcome feedback as to whether those changes
are reasonable or not.

Cheers,
Longman
