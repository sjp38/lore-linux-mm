Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A0BA56B4229
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 15:42:05 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id y13-v6so53507ita.8
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 12:42:05 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id s16-v6si67033ioa.165.2018.08.27.12.42.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 12:42:04 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Subject: Re: using range locks instead of mm_sem
From: Alex Kogan <alex.kogan@oracle.com>
In-Reply-To: <09ab74a2-f996-de7c-b0b2-46d82c971976@oracle.com>
Date: Mon, 27 Aug 2018 22:41:56 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <1AFAF0C5-0C8C-4CAD-9027-10C621B49C01@oracle.com>
References: <9ea84ad8-0404-077e-200d-14ad749cb784@oracle.com>
 <20180822144640.GB3677@linux-r8p5>
 <744f3cf3-d4ec-e3a6-e56d-8009dd8c5f14@linux.vnet.ibm.com>
 <09ab74a2-f996-de7c-b0b2-46d82c971976@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Dave Dice <dave.dice@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, jack@suse.com, linux-mm@kvack.org, Shady Issa <shady.issa@oracle.com>


> On Aug 24, 2018, at 6:39 PM, Shady Issa <shady.issa@oracle.com> wrote:
>=20
>=20
>=20
> On 08/24/2018 03:40 AM, Laurent Dufour wrote:
>> On 22/08/2018 16:46, Davidlohr Bueso wrote:
>>> On Wed, 22 Aug 2018, Shady Issa wrote:
>>>=20
>>>> Hi Davidlohr,
>>>>=20
>>>> I am interested in the idea of using range locks to replace mm_sem. =
I wanted to
>>>> start trying out using more fine-grained ranges instead of the full =
range
>>>> acquisitions
>>>> that are used in this patch =
(https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__lkml.org_lkml_2018=
_2_4_235&d=3DDwICaQ&c=3DRoP1YumCXCgaWHvlZYR8PZh8Bv7qIrMUB65eapI_JnE&r=3DQ-=
zBmi7tP5HosTvB8kUZjTYqSFMRtxg-kOQa59-zx9I&m=3DZCN6CnHZsYyZ_V0nWMSZgLmp-Gob=
wtrhI3Wx8UAIQuY&s=3DLtbMxuR2njAX0dm3L2lNQKvztbnLTfKjBd-S20cDPbE&e=3D). =
However, it
>>>> does not
>>>> seem straight forward to me how this is possible.
>>>>=20
>>>> First, the ranges that can be defined before acquiring the range =
lock based
>>>> on the
>>>> caller's input(i.e. ranges supplied by mprotect, mmap, munmap, =
etc.) are
>>>> oblivious of
>>>> the underlying VMAs. Two non-overlapping ranges can fall within the =
same VMA and
>>>> thus should not be allowed to run concurrently in case they are =
writes.
>>> Yes. This is a _big_ issue with range locking the addr space. I have =
yet
>>> to find a solution other than delaying vma modifying ops to avoid =
the races,
>>> which is fragile. Obviously locking the full range in such scenarios =
cannot
>>> be done either.
>> I think the range locked should be aligned to the underlying VMA plus =
one page
>> on each side to prevent that VMA to be merged.
How would one find the underlying VMA for the range lock acquisition?
Looks like that would require searching the rb-tree (currently protected =
by mm_sem), and that search has to be synchronized with concurrent tree =
modifications.

Regards,
=E2=80=94 Alex

>> But this raises a concern with the VMA merging mechanism which tends =
to limit
>> the number of VMAs and could lead to a unique VMA, limiting the =
advantage of a
>> locking based on the VMA's boundaries.
> To do so, the current merge implementation should be changed so that
> it does not access VMAs beyond the locked range, right? Also, this =
will
> not stop a merge from happening in case of a range spanning two VMAs
> for example.
>>=20
>>>> Second, even if ranges from the caller function are aligned with =
VMAs, the
>>>> extent of the
>>>> effect of operation is unknown. It is probable that an operation =
touching one
>>>> VMA will
>>>> end up performing modifications to the VMAs rbtree structure due to =
splits,
>>>> merges, etc.,
>>>> which requires the full range acquisition and is unknown =
beforehand.
>>> Yes, this is similar to the above as well.
>>>=20
>>>> I was wondering if I am missing something with this thought =
process, because
>>>> with the
>>>> current givings, it seems to me that range locks will boil down to =
just r/w
>>>> semaphore.
>>>> I would also be very grateful if you can point me to any more =
recent
>>>> discussions regarding
>>>> the use of range locks after this patch from February.
>>> You're on the right page.
>>>=20
>>> Thanks,
>>> Davidlohr
>>>=20
>=20
