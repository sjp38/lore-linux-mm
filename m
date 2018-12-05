Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 713246B71D5
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 20:57:30 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t2so15575538pfj.15
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 17:57:30 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b5sor24141967pgq.18.2018.12.04.17.57.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 17:57:29 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <58a3b01c78b6c299f76c156f96211ff22ec28751.camel@intel.com>
Date: Tue, 4 Dec 2018 17:57:26 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <1913CD9F-B912-490A-8DEC-8C24CFF0F6D6@amacapital.net>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com> <20181128000754.18056-2-rick.p.edgecombe@intel.com> <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com> <20181204160304.GB7195@arm.com> <51281e69a3722014f718a6840f43b2e6773eed90.camel@intel.com> <CALCETrUiEWkSjnruCbBSi8WsDm071YiU5WEqoPhZbjezS0CrFw@mail.gmail.com> <58a3b01c78b6c299f76c156f96211ff22ec28751.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "luto@kernel.org" <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "jeyu@kernel.org" <jeyu@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "ast@kernel.org" <ast@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nadav.amit@gmail.com" <nadav.amit@gmail.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "jannh@google.com" <jannh@google.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>



> On Dec 4, 2018, at 3:52 PM, Edgecombe, Rick P <rick.p.edgecombe@intel.com>=
 wrote:
>=20
>> On Tue, 2018-12-04 at 12:09 -0800, Andy Lutomirski wrote:
>> On Tue, Dec 4, 2018 at 12:02 PM Edgecombe, Rick P
>> <rick.p.edgecombe@intel.com> wrote:
>>>=20
>>>> On Tue, 2018-12-04 at 16:03 +0000, Will Deacon wrote:
>>>> On Mon, Dec 03, 2018 at 05:43:11PM -0800, Nadav Amit wrote:
>>>>>> On Nov 27, 2018, at 4:07 PM, Rick Edgecombe <
>>>>>> rick.p.edgecombe@intel.com>
>>>>>> wrote:
>>>>>>=20
>>>>>> Since vfree will lazily flush the TLB, but not lazily free the
>>>>>> underlying
>>>>>> pages,
>>>>>> it often leaves stale TLB entries to freed pages that could get re-
>>>>>> used.
>>>>>> This is
>>>>>> undesirable for cases where the memory being freed has special
>>>>>> permissions
>>>>>> such
>>>>>> as executable.
>>>>>=20
>>>>> So I am trying to finish my patch-set for preventing transient W+X
>>>>> mappings
>>>>> from taking space, by handling kprobes & ftrace that I missed (thanks
>>>>> again
>>>>> for
>>>>> pointing it out).
>>>>>=20
>>>>> But all of the sudden, I don=E2=80=99t understand why we have the prob=
lem that
>>>>> this
>>>>> (your) patch-set deals with at all. We already change the mappings to
>>>>> make
>>>>> the memory writable before freeing the memory, so why can=E2=80=99t we=
 make it
>>>>> non-executable at the same time? Actually, why do we make the module
>>>>> memory,
>>>>> including its data executable before freeing it???
>>>>=20
>>>> Yeah, this is really confusing, but I have a suspicion it's a combinati=
on
>>>> of the various different configurations and hysterical raisins. We can'=
t
>>>> rely on module_alloc() allocating from the vmalloc area (see nios2) nor=

>>>> can we rely on disable_ro_nx() being available at build time.
>>>>=20
>>>> If we *could* rely on module allocations always using vmalloc(), then
>>>> we could pass in Rick's new flag and drop disable_ro_nx() altogether
>>>> afaict -- who cares about the memory attributes of a mapping that's abo=
ut
>>>> to disappear anyway?
>>>>=20
>>>> Is it just nios2 that does something different?
>>>>=20
>>>> Will
>>>=20
>>> Yea it is really intertwined. I think for x86, set_memory_nx everywhere
>>> would
>>> solve it as well, in fact that was what I first thought the solution sho=
uld
>>> be
>>> until this was suggested. It's interesting that from the other thread Ma=
sami
>>> Hiramatsu referenced, set_memory_nx was suggested last year and would ha=
ve
>>> inadvertently blocked this on x86. But, on the other architectures I hav=
e
>>> since
>>> learned it is a bit different.
>>>=20
>>> It looks like actually most arch's don't re-define set_memory_*, and so a=
ll
>>> of
>>> the frob_* functions are actually just noops. In which case allocating R=
WX
>>> is
>>> needed to make it work at all, because that is what the allocation is go=
ing
>>> to
>>> stay at. So in these archs, set_memory_nx won't solve it because it will=
 do
>>> nothing.
>>>=20
>>> On x86 I think you cannot get rid of disable_ro_nx fully because there i=
s
>>> the
>>> changing of the permissions on the directmap as well. You don't want som=
e
>>> other
>>> caller getting a page that was left RO when freed and then trying to wri=
te
>>> to
>>> it, if I understand this.
>>>=20
>>=20
>> Exactly.
>>=20
>> After slightly more thought, I suggest renaming VM_IMMEDIATE_UNMAP to
>> VM_MAY_ADJUST_PERMS or similar.  It would have the semantics you want,
>> but it would also call some arch hooks to put back the direct map
>> permissions before the flush.  Does that seem reasonable?  It would
>> need to be hooked up that implement set_memory_ro(), but that should
>> be quite easy.  If nothing else, it could fall back to set_memory_ro()
>> in the absence of a better implementation.
>=20
> With arch hooks, I guess we could remove disable_ro_nx then. I think you w=
ould
> still have to flush twice on x86 to really have no W^X violating window fr=
om the
> direct map (I think x86 is the only one that sets permissions there?). But=
 this
> could be down from sometimes 3. You could also directly vfree non exec RO m=
emory
> without set_memory_, like in BPF.=20

Just one flush if you=E2=80=99re careful. Set the memory not-present in the d=
irect map and zap it from the vmap area, then flush, then set it RW in the=20=


>=20
> The vfree deferred list would need to be moved since it then couldn't reus=
e the
> allocations since now the vfreed memory might be RO. It could kmalloc, or l=
ookup
> the vm_struct. So would probably be a little slower in the interrupt case.=
 Is
> this ok?

I=E2=80=99m fine with that. For eBPF, we should really have a lookaside list=
 for small allocations.
