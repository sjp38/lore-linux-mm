Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C89E6B000D
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 19:10:35 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d5so928115qtg.7
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 16:10:35 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id l17si2167865qkk.482.2018.03.21.16.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 16:10:34 -0700 (PDT)
Subject: Re: [PATCH 03/15] mm/hmm: HMM should have a callback before MM is
 destroyed v2
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-4-jglisse@redhat.com>
 <d89e417d-c939-4d18-72f5-08b22dc6cff0@nvidia.com>
 <20180321180342.GE3214@redhat.com>
 <788cf786-edbf-ab43-af0d-abbe9d538757@nvidia.com>
 <20180321224620.GH3214@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <3f4e78a1-5a88-399d-e134-497229c42707@nvidia.com>
Date: Wed, 21 Mar 2018 16:10:32 -0700
MIME-Version: 1.0
In-Reply-To: <20180321224620.GH3214@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/21/2018 03:46 PM, Jerome Glisse wrote:
> On Wed, Mar 21, 2018 at 03:16:04PM -0700, John Hubbard wrote:
>> On 03/21/2018 11:03 AM, Jerome Glisse wrote:
>>> On Tue, Mar 20, 2018 at 09:14:34PM -0700, John Hubbard wrote:
>>>> On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
>>>>> From: Ralph Campbell <rcampbell@nvidia.com>
>>
>> <snip>
>>
>>>> Hi Jerome,
>>>>
>>>> This presents a deadlock problem (details below). As for solution idea=
s,=20
>>>> Mark Hairgrove points out that the MMU notifiers had to solve the
>>>> same sort of problem, and part of the solution involves "avoid
>>>> holding locks when issuing these callbacks". That's not an entire=20
>>>> solution description, of course, but it seems like a good start.
>>>>
>>>> Anyway, for the deadlock problem:
>>>>
>>>> Each of these ->release callbacks potentially has to wait for the=20
>>>> hmm_invalidate_range() callbacks to finish. That is not shown in any
>>>> code directly, but it's because: when a device driver is processing=20
>>>> the above ->release callback, it has to allow any in-progress operatio=
ns=20
>>>> to finish up (as specified clearly in your comment documentation above=
).=20
>>>>
>>>> Some of those operations will invariably need to do things that result=
=20
>>>> in page invalidations, thus triggering the hmm_invalidate_range() call=
back.
>>>> Then, the hmm_invalidate_range() callback tries to acquire the same=20
>>>> hmm->mirrors_sem lock, thus leading to deadlock:
>>>>
>>>> hmm_invalidate_range():
>>>> // ...
>>>> 	down_read(&hmm->mirrors_sem);
>>>> 	list_for_each_entry(mirror, &hmm->mirrors, list)
>>>> 		mirror->ops->sync_cpu_device_pagetables(mirror, action,
>>>> 							start, end);
>>>> 	up_read(&hmm->mirrors_sem);
>>>
>>> That is just illegal, the release callback is not allowed to trigger
>>> invalidation all it does is kill all device's threads and stop device
>>> page fault from happening. So there is no deadlock issues. I can re-
>>> inforce the comment some more (see [1] for example on what it should
>>> be).
>>
>> That rule is fine, and it is true that the .release callback will not=20
>> directly trigger any invalidations. However, the problem is in letting=20
>> any *existing* outstanding operations finish up. We have to let=20
>> existing operations "drain", in order to meet the requirement that=20
>> everything is done when .release returns.
>>
>> For example, if a device driver thread is in the middle of working throu=
gh
>> its fault buffer, it will call migrate_vma(), which will in turn unmap
>> pages. That will cause an hmm_invalidate_range() callback, which tries
>> to take hmm->mirrors_sems, and we deadlock.
>>
>> There's no way to "kill" such a thread while it's in the middle of
>> migrate_vma(), you have to let it finish up.
>>
>>> Also it is illegal for the sync callback to trigger any mmu_notifier
>>> callback. I thought this was obvious. The sync callback should only
>>> update device page table and do _nothing else_. No way to make this
>>> re-entrant.
>>
>> That is obvious, yes. I am not trying to say there is any problem with
>> that rule. It's the "drain outstanding operations during .release",=20
>> above, that is the real problem.
>=20
> Maybe just relax the release callback wording, it should stop any
> more processing of fault buffer but not wait for it to finish. In
> nouveau code i kill thing but i do not wait hence i don't deadlock.

But you may crash, because that approach allows .release to finish
up, thus removing the mm entirely, out from under (for example)
a migrate_vma call--or any other call that refers to the mm.

It doesn't seem too hard to avoid the problem, though: maybe we
can just drop the lock while doing the mirror->ops->release callback.
There are a few ways to do this, but one example is:=20

    -- take the lock,
        -- copy the list to a local list, deleting entries as you go,
    -- drop the lock,=20
    -- iterate through the local list copy and=20
        -- issue the mirror->ops->release callbacks.

At this point, more items could have been added to the list, so repeat
the above until the original list is empty.=20

This is subject to a limited starvation case if mirror keep getting=20
registered, but I think we can ignore that, because it only lasts as long a=
s=20
mirrors keep getting added, and then it finishes up.

>=20
> What matter is to stop any further processing. Yes some fault might
> be in flight but they will serialize on various lock.=20

Those faults in flight could already be at a point where they have taken
whatever locks they need, so we don't dare let the mm get destroyed while
such fault handling is in progress.


So just do not
> wait in the release callback, kill thing. I might have a bug where i
> still fill in GPU page table in nouveau, i will check nouveau code
> for that.

Again, we can't "kill" a thread of execution (this would often be an
interrupt bottom half context, btw) while it is, for example,
in the middle of migrate_vma.

I really don't believe there is a safe way to do this without draining
the existing operations before .release returns, and for that, we'll need t=
o=20
issue the .release callbacks while not holding locks.

thanks,
--=20
John Hubbard
NVIDIA

>=20
> Kill thing should also kill the channel (i don't do that in nouveau
> because i am waiting on some channel patchset) but i am not sure if
> hardware like it if we kill channel before stoping fault notification.
>=20
> Cheers,
> J=C3=A9r=C3=B4me
>=20
