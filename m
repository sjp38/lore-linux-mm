Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F70C6B026E
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 20:56:20 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id l128so1849592qkb.7
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 17:56:20 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id r3si7802709qkd.367.2018.03.22.17.56.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 17:56:19 -0700 (PDT)
Subject: Re: [PATCH 04/15] mm/hmm: unregister mmu_notifier when last HMM
 client quit v2
References: <20180320020038.3360-5-jglisse@redhat.com>
 <20180321181614.9968-1-jglisse@redhat.com>
 <a9ba54c5-a2d9-49f6-16ad-46b79525b93c@nvidia.com>
 <20180321234110.GK3214@redhat.com>
 <cbc9dcba-0707-e487-d360-f6f7c8d5cb23@nvidia.com>
 <20180322233715.GA5011@redhat.com>
 <b858d92a-3a38-bfff-fe66-697c64ea2053@nvidia.com>
 <20180323005017.GB5011@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <45076a33-1dab-d4c0-d0b3-ea8e9782975f@nvidia.com>
Date: Thu, 22 Mar 2018 17:56:17 -0700
MIME-Version: 1.0
In-Reply-To: <20180323005017.GB5011@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/22/2018 05:50 PM, Jerome Glisse wrote:
> On Thu, Mar 22, 2018 at 05:13:14PM -0700, John Hubbard wrote:
>> On 03/22/2018 04:37 PM, Jerome Glisse wrote:
>>> On Thu, Mar 22, 2018 at 03:47:16PM -0700, John Hubbard wrote:
>>>> On 03/21/2018 04:41 PM, Jerome Glisse wrote:
>>>>> On Wed, Mar 21, 2018 at 04:22:49PM -0700, John Hubbard wrote:
>>>>>> On 03/21/2018 11:16 AM, jglisse@redhat.com wrote:
>>>>>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>
>> <snip>
>>
>>>>>
>>>>> No this code is correct. hmm->mm is set after hmm struct is allocated
>>>>> and before it is public so no one can race with that. It is clear in
>>>>> hmm_mirror_unregister() under the write lock hence checking it here
>>>>> under that same lock is correct.
>>>>
>>>> Are you implying that code that calls hmm_mirror_register() should do=
=20
>>>> it's own locking, to prevent simultaneous calls to that function? Beca=
use
>>>> as things are right now, multiple threads can arrive at this point. Th=
e
>>>> fact that mirror->hmm is not "public" is irrelevant; what matters is t=
hat
>>>>> 1 thread can change it simultaneously.
>>>
>>> The content of struct hmm_mirror should not be modified by code outside
>>> HMM after hmm_mirror_register() and before hmm_mirror_unregister(). Thi=
s
>>> is a private structure to HMM and the driver should not touch it, ie it
>>> should be considered as read only/const from driver code point of view.
>>
>> Yes, that point is clear and obvious.
>>
>>>
>>> It is also expected (which was obvious to me) that driver only call onc=
e
>>> and only once hmm_mirror_register(), and only once hmm_mirror_unregiste=
r()
>>> for any given hmm_mirror struct. Note that driver can register multiple
>>> _different_ mirror struct to same mm or differents mm.
>>>
>>> There is no need of locking on the driver side whatsoever as long as th=
e
>>> above rules are respected. I am puzzle if they were not obvious :)
>>
>> Those rules were not obvious. It's unusual to claim that register and un=
register
>> can run concurrently, but regiser and register cannot. Let's please docu=
ment
>> the rules a bit in the comments.
>=20
> I am really surprise this was not obvious. All existing _register API
> in the kernel follow this. You register something once only and doing
> it twice for same structure (ie unique struct hmm_mirror *mirror pointer
> value) leads to serious bugs (doing so concurently or not).
>=20
> For instance if you call mmu_notifier_register() twice (concurrently
> or not) with same pointer value for struct mmu_notifier *mn then bad
> thing will happen. Same for driver_register() but this one actualy
> have sanity check and complain loudly if that happens. I doubt there
> is any single *_register/unregister() in the kernel that does not
> follow this.

OK, then I guess no need to document it. In any case we know what to
expect here, so no problem there.

thanks,
--=20
John Hubbard
NVIDIA

>=20
> Note that doing register/unregister concurrently for the same unique
> hmm_mirror struct is also illegal. However concurrent register and
> unregister of different hmm_mirror struct is legal and this is the
> reasons for races we were discussing.
>=20
> Cheers,
> J=C3=A9r=C3=B4me
>=20
