Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 635AD6B0007
	for <linux-mm@kvack.org>; Wed,  2 May 2018 19:32:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r63so12212341pfl.12
        for <linux-mm@kvack.org>; Wed, 02 May 2018 16:32:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c9-v6sor974970pgp.370.2018.05.02.16.32.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 May 2018 16:32:33 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change signal semantics
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <f9f7edc5-6426-91aa-f279-2f9f4671957a@intel.com>
Date: Wed, 2 May 2018 16:32:30 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <2BE03B9A-B1E0-4707-8705-203F88B62A1C@amacapital.net>
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com> <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com> <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com> <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net> <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com> <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com> <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com> <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com> <a37b7deb-7f5a-3dfa-f360-956cab8a813a@intel.com> <CALCETrUM7wWZh55gaLiAoPqtxLLUJ4QC8r8zj62E9avJ6ZVu0w@mail.gmail.com> <f9f7edc5-6426-91aa-f279-2f9f4671957a@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Florian Weimer <fweimer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxram@us.ibm.com



> On May 2, 2018, at 3:32 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
>> On 05/02/2018 03:22 PM, Andy Lutomirski wrote:
>> That library wants other threads, signal handlers, and, in general, the
>> whole rest of the process to be restricted, and that library doesn't want=

>> race conditions.  The problem here is that, to get this right, we either
>> need the PKRU modifications to be syscalls or to take locks, and the lock=

>> approach is going to be fairly gross.
>=20
> I totally get the idea that a RDPKRU/WRPKRU is non-atomic and that it
> can't be mixed with asynchronous WRPKRU's in that thread.
>=20
> But, where do those come from in this scenario?  I'm not getting the
> secondary mechanism is that *makes* them unsafe.

pkey_alloc() itself.  If someone tries to allocate a key with a given defaul=
t mode, unless there=E2=80=99s already a key that already had that value in a=
ll threads or pkey_alloc() needs to asynchronously create such a key.

There is a partial hack that glibc could do. DSOs could have a way to static=
ally request a key (e.g. a PT_PKEY segment) and glibc could do all the pkey_=
alloc() calls before any threads get created. Of course, a DSO like this can=
=E2=80=99t be dlopened().  We still need a way for pkey_alloc() to update th=
e value for signal delivery, but that=E2=80=99s straightforward.=
