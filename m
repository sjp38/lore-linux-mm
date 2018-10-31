Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21CE36B0007
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 13:54:57 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x8-v6so17381816qtc.15
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 10:54:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j3-v6si13269140qkf.0.2018.10.31.10.54.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 10:54:56 -0700 (PDT)
From: Florian Weimer <fweimer@redhat.com>
Subject: Re: PIE binaries are no longer mapped below 4 GiB on ppc64le
References: <87k1lyf2x3.fsf@oldenburg.str.redhat.com>
	<20181031185032.679e170a@naga.suse.cz>
Date: Wed, 31 Oct 2018 18:54:52 +0100
In-Reply-To: <20181031185032.679e170a@naga.suse.cz> ("Michal \=\?utf-8\?Q\?Suc\?\=
 \=\?utf-8\?Q\?h\=C3\=A1nek\=22's\?\=
	message of "Wed, 31 Oct 2018 18:50:32 +0100")
Message-ID: <877ehyf1cj.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal =?utf-8?Q?Such=C3=A1nek?= <msuchanek@suse.de>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

* Michal Such=C3=A1nek:

> On Wed, 31 Oct 2018 18:20:56 +0100
> Florian Weimer <fweimer@redhat.com> wrote:
>
>> We tried to use Go to build PIE binaries, and while the Go toolchain
>> is definitely not ready (it produces text relocations and problematic
>> relocations in general), it exposed what could be an accidental
>> userspace ABI change.
>>=20
>> With our 4.10-derived kernel, PIE binaries are mapped below 4 GiB, so
>> relocations like R_PPC64_ADDR16_HA work:
>>=20
> ...
>
>> There are fewer mappings because the loader detects a relocation
>> overflow and aborts (=E2=80=9Cerror while loading shared libraries:
>> R_PPC64_ADDR16_HA reloc at 0x0000000120f0983c for symbol `' out of
>> range=E2=80=9D), so I had to recover the mappings externally.  Disabling=
 ASLR
>> does not help.
>>=20
> ...
>>=20
>> And it needs to be built with:
>>=20
>>   go build -ldflags=3D-extldflags=3D-pie extld.go
>>=20
>> I'm not entirely sure what to make of this, but I'm worried that this
>> could be a regression that matters to userspace.
>
> I encountered the same when trying to build go on ppc64le. I am not
> familiar with the internals so I just let it be.
>
> It does not seem to matter to any other userspace.

It would matter to C code which returns the address of a global variable
in the main program through and (implicit) int return value.

The old behavior hid some pointer truncation issues.

> Maybe it would be good idea to generate 64bit relocations on 64bit
> targets?

Yes, the Go toolchain definitely needs fixing for PIE.  I don't dispute
that.

Thanks,
Florian
