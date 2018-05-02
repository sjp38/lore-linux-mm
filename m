Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3DBC26B0007
	for <linux-mm@kvack.org>; Wed,  2 May 2018 13:09:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n78so13421799pfj.4
        for <linux-mm@kvack.org>; Wed, 02 May 2018 10:09:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n127-v6sor2564597pga.70.2018.05.02.10.09.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 May 2018 10:09:43 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change signal semantics
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
Date: Wed, 2 May 2018 10:09:40 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net>
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com> <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com> <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linuxram@us.ibm.com



> On May 2, 2018, at 8:12 AM, Florian Weimer <fweimer@redhat.com> wrote:
>=20
>> On 05/02/2018 04:30 PM, Dave Hansen wrote:
>>> On 05/02/2018 06:26 AM, Florian Weimer wrote:
>>> pkeys support for IBM POWER intends to inherited the access rights of
>>> the current thread in signal handlers.  The advantage is that this
>>> preserves access to memory regions associated with non-default keys,
>>> enabling additional usage scenarios for memory protection keys which
>>> currently do not work on x86 due to the unconditional reset to the
>>> (configurable) default key in signal handlers.
>> What's the usage scenario that does not work?
>=20
> Here's what I want to do:
>=20
> Nick Clifton wrote a binutils patch which puts the .got.plt section on sep=
arate pages.  We allocate a protection key for it, assign it to all such sec=
tions in the process image, and change the access rights of the main thread t=
o disallow writes via that key during process startup.  In _dl_fixup, we ena=
ble write access to the GOT, update the GOT entry, and then disable it again=
.
>=20
> This way, we have a pretty safe form of lazy binding, without having to re=
sort to BIND_NOW.
>=20
> With the current kernel behavior on x86, we cannot do that because signal h=
andlers revert to the default (deny) access rights, so the GOT turns inacces=
sible.

Dave is right: the current behavior was my request, and I still think it=E2=80=
=99s correct.  The whole point is that, even if something nasty happens like=
 a SIGALRM handler hitting in the middle of _dl_fixup, the SIGALRM handler i=
s preventing from accidentally writing to the protected memory.  When SIGALR=
M returns, PKRU should get restored

Another way of looking at this is that the kernel would like to approximate w=
hat the ISA behavior *should* have been: the whole sequence =E2=80=9Cmodify P=
KRU; access memory; restore PKRU=E2=80=9D should be as atomic as possible.

Florian, what is the actual problematic sequence of events?

=E2=80=94Andy
