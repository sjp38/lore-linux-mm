Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5BB6B7145
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 18:27:40 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 143so9985450pgc.3
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 15:27:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d71sor23825488pga.73.2018.12.04.15.27.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 15:27:38 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <20CC2F71-308D-42E2-8C54-F64D7CC3863F@gmail.com>
Date: Tue, 4 Dec 2018 15:27:35 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <C658F765-F38B-44DF-9FCE-B5ECB5DD9A86@amacapital.net>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com> <20181128000754.18056-2-rick.p.edgecombe@intel.com> <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com> <CALCETrXvddt148fncMJqpjK98uatiK-44knYFWU0-ytf8X+iog@mail.gmail.com> <08141F66-F3E6-4CC5-AF91-1ED5F101A54C@gmail.com> <CALCETrXLrsKDBzDkN7sc9HYPWe9aV3NQzf4vMvM+FD8j6aA6AQ@mail.gmail.com> <20CC2F71-308D-42E2-8C54-F64D7CC3863F@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, "Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>, Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, "David S. Miller" <davem@davemloft.net>, Masami Hiramatsu <mhiramat@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, jeyu@kernel.org, Network Development <netdev@vger.kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jann Horn <jannh@google.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, Peter Zijlstra <peterz@infradead.org>




On Dec 4, 2018, at 2:48 PM, Nadav Amit <nadav.amit@gmail.com> wrote:

>> On Dec 4, 2018, at 11:48 AM, Andy Lutomirski <luto@kernel.org> wrote:
>>=20
>> On Tue, Dec 4, 2018 at 11:45 AM Nadav Amit <nadav.amit@gmail.com> wrote:
>>>> On Dec 4, 2018, at 10:56 AM, Andy Lutomirski <luto@kernel.org> wrote:
>>>>=20
>>>> On Mon, Dec 3, 2018 at 5:43 PM Nadav Amit <nadav.amit@gmail.com> wrote:=

>>>>>> On Nov 27, 2018, at 4:07 PM, Rick Edgecombe <rick.p.edgecombe@intel.c=
om> wrote:
>>>>>>=20
>>>>>> Since vfree will lazily flush the TLB, but not lazily free the underl=
ying pages,
>>>>>> it often leaves stale TLB entries to freed pages that could get re-us=
ed. This is
>>>>>> undesirable for cases where the memory being freed has special permis=
sions such
>>>>>> as executable.
>>>>>=20
>>>>> So I am trying to finish my patch-set for preventing transient W+X map=
pings
>>>>> from taking space, by handling kprobes & ftrace that I missed (thanks a=
gain for
>>>>> pointing it out).
>>>>>=20
>>>>> But all of the sudden, I don=E2=80=99t understand why we have the prob=
lem that this
>>>>> (your) patch-set deals with at all. We already change the mappings to m=
ake
>>>>> the memory writable before freeing the memory, so why can=E2=80=99t we=
 make it
>>>>> non-executable at the same time? Actually, why do we make the module m=
emory,
>>>>> including its data executable before freeing it???
>>>>=20
>>>> All the code you're looking at is IMO a very awkward and possibly
>>>> incorrect of doing what's actually necessary: putting the direct map
>>>> the way it wants to be.
>>>>=20
>>>> Can't we shove this entirely mess into vunmap?  Have a flag (as part
>>>> of vmalloc like in Rick's patch or as a flag passed to a vfree variant
>>>> directly) that makes the vunmap code that frees the underlying pages
>>>> also reset their permissions?
>>>>=20
>>>> Right now, we muck with set_memory_rw() and set_memory_nx(), which
>>>> both have very awkward (and inconsistent with each other!) semantics
>>>> when called on vmalloc memory.  And they have their own flushes, which
>>>> is inefficient.  Maybe the right solution is for vunmap to remove the
>>>> vmap area PTEs, call into a function like set_memory_rw() that resets
>>>> the direct maps to their default permissions *without* flushing, and
>>>> then to do a single flush for everything.  Or, even better, to cause
>>>> the change_page_attr code to do the flush and also to flush the vmap
>>>> area all at once so that very small free operations can flush single
>>>> pages instead of flushing globally.
>>>=20
>>> Thanks for the explanation. I read it just after I realized that indeed t=
he
>>> whole purpose of this code is to get cpa_process_alias()
>>> update the corresponding direct mapping.
>>>=20
>>> This thing (pageattr.c) indeed seems over-engineered and very unintuitiv=
e.
>>> Right now I have a list of patch-sets that I owe, so I don=E2=80=99t hav=
e the time
>>> to deal with it.
>>>=20
>>> But, I still think that disable_ro_nx() should not call set_memory_x().
>>> IIUC, this breaks W+X of the direct-mapping which correspond with the mo=
dule
>>> memory. Does it ever stop being W+X?? I=E2=80=99ll have another look.
>>=20
>> Dunno.  I did once chase down a bug where some memory got freed while
>> it was still read-only, and the results were hilarious and hard to
>> debug, since the explosion happened long after the buggy code
>> finished.
>=20
> This piece of code causes me pain and misery.
>=20
> So, it turns out that the direct map is *not* changed if you just change
> the NX-bit. See change_page_attr_set_clr():
>=20
>        /* No alias checking for _NX bit modifications */
>        checkalias =3D (pgprot_val(mask_set) | pgprot_val(mask_clr)) !=3D _=
PAGE_NX;
>=20
> How many levels of abstraction are broken in the way? What would happen
> if somebody tries to change the NX-bit and some other bit in the PTE?
> Luckily, I don=E2=80=99t think someone does=E2=80=A6 at least for now.
>=20
> So, again, I think the change I proposed makes sense. nios2 does not have
> set_memory_x() and it will not be affected.
>=20
> [ I can add a comment, although I don=E2=80=99t have know if nios2 has an N=
X bit,
> and I don=E2=80=99t find any code that defines PTEs. Actually where is pte=
_present()
> of nios2 being defined? Whatever. ]
>=20

At least rename the function, then. The last thing we need is for disable_ro=
_nx to *enable* NX.=
