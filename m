Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E02046B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 10:17:30 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id b31-v6so7441293plb.5
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 07:17:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r6-v6si12489035pfl.260.2018.06.08.07.17.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jun 2018 07:17:28 -0700 (PDT)
Date: Fri, 8 Jun 2018 16:17:24 +0200
From: Michal =?UTF-8?B?U3VjaMOhbmVr?= <msuchanek@suse.de>
Subject: Re: pkeys on POWER: Access rights not reset on execve
Message-ID: <20180608161724.3164c691@kitsune.suse.cz>
In-Reply-To: <05e7d0f4-0955-11ce-06c5-1c2ab1153499@redhat.com>
References: <20180520060425.GL5479@ram.oc3035372033.ibm.com>
	<CALCETrVvQkphypn10A_rkX35DNqi29MJcXYRpRiCFNm02VYz2g@mail.gmail.com>
	<20180520191115.GM5479@ram.oc3035372033.ibm.com>
	<aae1952c-886b-cfc8-e98b-fa3be5fab0fa@redhat.com>
	<20180603201832.GA10109@ram.oc3035372033.ibm.com>
	<4e53b91f-80a7-816a-3e9b-56d7be7cd092@redhat.com>
	<20180604140135.GA10088@ram.oc3035372033.ibm.com>
	<f2f61c24-8e8f-0d36-4e22-196a2a3f7ca7@redhat.com>
	<20180604190229.GB10088@ram.oc3035372033.ibm.com>
	<30040030-1aa2-623b-beec-dd1ceb3eb9a7@redhat.com>
	<20180608023441.GA5573@ram.oc3035372033.ibm.com>
	<2858a8eb-c9b5-42ce-5cfc-74a4b3ad6aa9@redhat.com>
	<20180608121551.3c151e0c@naga.suse.cz>
	<aa136e1e-3bf2-fd92-2eab-16469c467729@redhat.com>
	<20180608145413.393fa245@kitsune.suse.cz>
	<f440aaa4-0a55-3ccd-2df1-2ad595e9e17a@redhat.com>
	<20180608154954.327c19be@kitsune.suse.cz>
	<05e7d0f4-0955-11ce-06c5-1c2ab1153499@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, Ram Pai <linuxram@us.ibm.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Fri, 8 Jun 2018 15:51:03 +0200
Florian Weimer <fweimer@redhat.com> wrote:

> On 06/08/2018 03:49 PM, Michal Such=C3=A1nek wrote:
> > On Fri, 8 Jun 2018 14:57:06 +0200
> > Florian Weimer <fweimer@redhat.com> wrote:
> >  =20
> >> On 06/08/2018 02:54 PM, Michal Such=C3=A1nek wrote: =20
> >>> On Fri, 8 Jun 2018 12:44:53 +0200
> >>> Florian Weimer <fweimer@redhat.com> wrote:
> >>>     =20
> >>>> On 06/08/2018 12:15 PM, Michal Such=C3=A1nek wrote: =20
> >>>>> On Fri, 8 Jun 2018 07:53:51 +0200
> >>>>> Florian Weimer <fweimer@redhat.com> wrote:
> >>>>>        =20
> >>>>>> On 06/08/2018 04:34 AM, Ram Pai wrote: =20
> >>>>>>>>
> >>>>>>>> So the remaining question at this point is whether the Intel
> >>>>>>>> behavior (default-deny instead of default-allow) is
> >>>>>>>> preferable. =20
> >>>>>>>
> >>>>>>> Florian, remind me what behavior needs to fixed? =20
> >>>>>>
> >>>>>> See the other thread.  The Intel register equivalent to the AMR
> >>>>>> by default disallows access to yet-unallocated keys, so that
> >>>>>> threads which are created before key allocation do not
> >>>>>> magically gain access to a key allocated by another thread.
> >>>>>>       =20
> >>>>>
> >>>>> That does not make any sense. The threads share the address
> >>>>> space so they should also share the keys.
> >>>>>
> >>>>> Or in other words the keys are supposed to be acceleration of
> >>>>> mprotect() so if mprotect() magically gives access to threads
> >>>>> that did not call it so should pkey functions. If they cannot
> >>>>> do that then they fail the primary purpose. =20
> >>>>
> >>>> That's not how protection keys work.  The access rights are
> >>>> thread-specific, so that you can change them locally, without
> >>>> synchronization and expensive inter-node communication.
> >>>>    =20
> >>>
> >>> And the association of a key with part of the address space is
> >>> thread-local as well? =20
> >>
> >> No, that part is still per-process. =20
> >=20
> > So as said above it does not make sense to make keys per-thread. =20
>=20
> The keys are still global, but the access rights are per-thread and
> have to be for reliability reasons.
>=20

Oh, right. The association of keys to memory is independent of key
allocation. However, to change the key permissions or the memory
association to a key you need to allocate it. And key allocation is
propagated lazily between threads so you do not have to stop the world
to allocate a key. So if default key permissions of an unallocated
key allow access then allocating a key and associating it with memory
makes that memory accessible to threads that are not yet aware of the
fact the key has been allocated which is not desirable.

Sounds sensible.

Thanks

Michal
