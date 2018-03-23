Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9086B0023
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 20:13:19 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x35so6783214qtx.5
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 17:13:19 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id j14si3221369qkk.201.2018.03.22.17.13.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 17:13:17 -0700 (PDT)
Subject: Re: [PATCH 04/15] mm/hmm: unregister mmu_notifier when last HMM
 client quit v2
References: <20180320020038.3360-5-jglisse@redhat.com>
 <20180321181614.9968-1-jglisse@redhat.com>
 <a9ba54c5-a2d9-49f6-16ad-46b79525b93c@nvidia.com>
 <20180321234110.GK3214@redhat.com>
 <cbc9dcba-0707-e487-d360-f6f7c8d5cb23@nvidia.com>
 <20180322233715.GA5011@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <b858d92a-3a38-bfff-fe66-697c64ea2053@nvidia.com>
Date: Thu, 22 Mar 2018 17:13:14 -0700
MIME-Version: 1.0
In-Reply-To: <20180322233715.GA5011@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/22/2018 04:37 PM, Jerome Glisse wrote:
> On Thu, Mar 22, 2018 at 03:47:16PM -0700, John Hubbard wrote:
>> On 03/21/2018 04:41 PM, Jerome Glisse wrote:
>>> On Wed, Mar 21, 2018 at 04:22:49PM -0700, John Hubbard wrote:
>>>> On 03/21/2018 11:16 AM, jglisse@redhat.com wrote:
>>>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>

<snip>

>>>
>>> No this code is correct. hmm->mm is set after hmm struct is allocated
>>> and before it is public so no one can race with that. It is clear in
>>> hmm_mirror_unregister() under the write lock hence checking it here
>>> under that same lock is correct.
>>
>> Are you implying that code that calls hmm_mirror_register() should do=20
>> it's own locking, to prevent simultaneous calls to that function? Becaus=
e
>> as things are right now, multiple threads can arrive at this point. The
>> fact that mirror->hmm is not "public" is irrelevant; what matters is tha=
t
>>> 1 thread can change it simultaneously.
>=20
> The content of struct hmm_mirror should not be modified by code outside
> HMM after hmm_mirror_register() and before hmm_mirror_unregister(). This
> is a private structure to HMM and the driver should not touch it, ie it
> should be considered as read only/const from driver code point of view.

Yes, that point is clear and obvious.

>=20
> It is also expected (which was obvious to me) that driver only call once
> and only once hmm_mirror_register(), and only once hmm_mirror_unregister(=
)
> for any given hmm_mirror struct. Note that driver can register multiple
> _different_ mirror struct to same mm or differents mm.
>=20
> There is no need of locking on the driver side whatsoever as long as the
> above rules are respected. I am puzzle if they were not obvious :)

Those rules were not obvious. It's unusual to claim that register and unreg=
ister
can run concurrently, but regiser and register cannot. Let's please documen=
t
the rules a bit in the comments.

>=20
> Note that the above rule means that for any given struct hmm_mirror their
> can only be one and only one call to hmm_mirror_register() happening, no
> concurrent call. If you are doing the latter then something is seriously
> wrong in your design.
>=20
> So to be clear on what variable are you claiming race ?
>   mirror->hmm ?
>   mirror->hmm->mm which is really hmm->mm (mirror part does not matter) ?
>=20
> I will hold resending v4 until tomorrow morning (eastern time) so that
> you can convince yourself that this code is right or prove me wrong.

No need to wait. The documentation request above is a minor point, and
we're OK with you resending v4 whenever you're ready.

thanks,
--=20
John Hubbard
NVIDIA
