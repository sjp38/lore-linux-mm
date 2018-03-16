Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 35ADD6B0025
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:37:36 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u200so7443792qka.21
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:37:36 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id q189si3082517qkb.310.2018.03.16.14.37.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:37:35 -0700 (PDT)
Subject: Re: [PATCH 03/14] mm/hmm: HMM should have a callback before MM is
 destroyed v2
References: <20180316191414.3223-1-jglisse@redhat.com>
 <20180316191414.3223-4-jglisse@redhat.com>
 <20180316141221.f2b622630de3f1da51a5c105@linux-foundation.org>
 <20180316212630.GC4861@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <0748100d-1414-93b8-baab-f08bb0b0b6ea@nvidia.com>
Date: Fri, 16 Mar 2018 14:37:33 -0700
MIME-Version: 1.0
In-Reply-To: <20180316212630.GC4861@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/16/2018 02:26 PM, Jerome Glisse wrote:
> On Fri, Mar 16, 2018 at 02:12:21PM -0700, Andrew Morton wrote:
>> On Fri, 16 Mar 2018 15:14:08 -0400 jglisse@redhat.com wrote:
>>
>>> The hmm_mirror_register() function registers a callback for when
>>> the CPU pagetable is modified. Normally, the device driver will
>>> call hmm_mirror_unregister() when the process using the device is
>>> finished. However, if the process exits uncleanly, the struct_mm
>>> can be destroyed with no warning to the device driver.
>>
>> Again, what are the user-visible effects of the bug?  Such info is
>> needed when others review our request for a -stable backport.  And the
>> many people who review -stable patches for integration into their own
>> kernel trees will want to understand the benefit of the patch to their
>> users.
>=20
> I have not had any issues in any of my own testing but nouveau driver
> is not as advance as the NVidia closed driver in respect to HMM inte-
> gration yet.
>=20
> If any issues they will happen between exit_mm() and exit_files() in
> do_exit() (kernel/exit.c) exit_mm() tear down the mm struct but without
> this callback the device driver might still be handling page fault and
> thus might potentialy tries to handle them against a dead mm_struct.
>=20
> So i am not sure what are the symptoms. To be fair there is no public
> driver using that part of HMM beside nouveau rfc patches. So at this
> point the impact on anybody is non existent. If anyone want to back-
> port nouveau HMM support once it make it upstream it will probably
> have to backport more things along the way. This is why i am not that
> aggressive on ccing stable so far.

The problem I'd like to avoid is: having a version of HMM in stable that
is missing this new callback. And without it, once the driver starts doing
actual concurrent operations, we can expect that the race condition will
happen.

It just seems unfortunate to have stable versions out there that would
be exposed to this, when it only require a small patch to avoid it.

On the other hand, it's also reasonable to claim that this is part of the
evolving HMM feature, and as such, this new feature does not belong in
stable.  I'm not sure which argument carries more weight here.

thanks,
--=20
John Hubbard
NVIDIA

>=20
> Cheers,
> J=C3=A9r=C3=B4me
>=20
