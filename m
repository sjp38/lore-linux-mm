Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF8BF6B0012
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:16:06 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id z1so4199212qtz.12
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:16:06 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id o21si1792425qtm.67.2018.03.21.15.16.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 15:16:05 -0700 (PDT)
Subject: Re: [PATCH 03/15] mm/hmm: HMM should have a callback before MM is
 destroyed v2
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-4-jglisse@redhat.com>
 <d89e417d-c939-4d18-72f5-08b22dc6cff0@nvidia.com>
 <20180321180342.GE3214@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <788cf786-edbf-ab43-af0d-abbe9d538757@nvidia.com>
Date: Wed, 21 Mar 2018 15:16:04 -0700
MIME-Version: 1.0
In-Reply-To: <20180321180342.GE3214@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/21/2018 11:03 AM, Jerome Glisse wrote:
> On Tue, Mar 20, 2018 at 09:14:34PM -0700, John Hubbard wrote:
>> On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
>>> From: Ralph Campbell <rcampbell@nvidia.com>

<snip>

>> Hi Jerome,
>>
>> This presents a deadlock problem (details below). As for solution ideas,=
=20
>> Mark Hairgrove points out that the MMU notifiers had to solve the
>> same sort of problem, and part of the solution involves "avoid
>> holding locks when issuing these callbacks". That's not an entire=20
>> solution description, of course, but it seems like a good start.
>>
>> Anyway, for the deadlock problem:
>>
>> Each of these ->release callbacks potentially has to wait for the=20
>> hmm_invalidate_range() callbacks to finish. That is not shown in any
>> code directly, but it's because: when a device driver is processing=20
>> the above ->release callback, it has to allow any in-progress operations=
=20
>> to finish up (as specified clearly in your comment documentation above).=
=20
>>
>> Some of those operations will invariably need to do things that result=20
>> in page invalidations, thus triggering the hmm_invalidate_range() callba=
ck.
>> Then, the hmm_invalidate_range() callback tries to acquire the same=20
>> hmm->mirrors_sem lock, thus leading to deadlock:
>>
>> hmm_invalidate_range():
>> // ...
>> 	down_read(&hmm->mirrors_sem);
>> 	list_for_each_entry(mirror, &hmm->mirrors, list)
>> 		mirror->ops->sync_cpu_device_pagetables(mirror, action,
>> 							start, end);
>> 	up_read(&hmm->mirrors_sem);
>=20
> That is just illegal, the release callback is not allowed to trigger
> invalidation all it does is kill all device's threads and stop device
> page fault from happening. So there is no deadlock issues. I can re-
> inforce the comment some more (see [1] for example on what it should
> be).

That rule is fine, and it is true that the .release callback will not=20
directly trigger any invalidations. However, the problem is in letting=20
any *existing* outstanding operations finish up. We have to let=20
existing operations "drain", in order to meet the requirement that=20
everything is done when .release returns.

For example, if a device driver thread is in the middle of working through
its fault buffer, it will call migrate_vma(), which will in turn unmap
pages. That will cause an hmm_invalidate_range() callback, which tries
to take hmm->mirrors_sems, and we deadlock.

There's no way to "kill" such a thread while it's in the middle of
migrate_vma(), you have to let it finish up.

>=20
> Also it is illegal for the sync callback to trigger any mmu_notifier
> callback. I thought this was obvious. The sync callback should only
> update device page table and do _nothing else_. No way to make this
> re-entrant.

That is obvious, yes. I am not trying to say there is any problem with
that rule. It's the "drain outstanding operations during .release",=20
above, that is the real problem.

thanks,
--=20
John Hubbard
NVIDIA

>=20
> For anonymous private memory migrated to device memory it is freed
> shortly after the release callback (see exit_mmap()). For share memory
> you might want to migrate back to regular memory but that will be fine
> as you will not get mmu_notifier callback any more.
>=20
> So i don't see any deadlock here.
>=20
> Cheers,
> J=C3=A9r=C3=B4me
>=20
> [1] https://cgit.freedesktop.org/~glisse/linux/commit/?h=3Dnouveau-hmm&id=
=3D93adb3e6b4f39d5d146b6a8afb4175d37bdd4890
>=20
