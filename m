Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 20AD26B7197
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 19:53:09 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so10098531pgi.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 16:53:09 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w12sor25591023plq.62.2018.12.04.16.53.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 16:53:07 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <3dc0492f209c630e40e93e9c657722041da0ed29.camel@intel.com>
Date: Tue, 4 Dec 2018 16:53:03 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <D092D8BE-711E-4BB4-B179-E897A8354120@gmail.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
 <20181128000754.18056-2-rick.p.edgecombe@intel.com>
 <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com>
 <20181204160304.GB7195@arm.com>
 <51281e69a3722014f718a6840f43b2e6773eed90.camel@intel.com>
 <A5ABCA50-12F0-4A19-B499-3927D59BF589@gmail.com>
 <e70c618d10ddbb834b7a3bbdd6e2bebed0f8719d.camel@intel.com>
 <843E4326-3426-4AEC-B0F7-2DC398A6E59A@gmail.com>
 <3dc0492f209c630e40e93e9c657722041da0ed29.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "jeyu@kernel.org" <jeyu@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "ast@kernel.org" <ast@kernel.org>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>

> On Dec 4, 2018, at 4:29 PM, Edgecombe, Rick P =
<rick.p.edgecombe@intel.com> wrote:
>=20
> On Tue, 2018-12-04 at 16:01 -0800, Nadav Amit wrote:
>>> On Dec 4, 2018, at 3:51 PM, Edgecombe, Rick P =
<rick.p.edgecombe@intel.com>
>>> wrote:
>>>=20
>>> On Tue, 2018-12-04 at 12:36 -0800, Nadav Amit wrote:
>>>>> On Dec 4, 2018, at 12:02 PM, Edgecombe, Rick P <
>>>>> rick.p.edgecombe@intel.com>
>>>>> wrote:
>>>>>=20
>>>>> On Tue, 2018-12-04 at 16:03 +0000, Will Deacon wrote:
>>>>>> On Mon, Dec 03, 2018 at 05:43:11PM -0800, Nadav Amit wrote:
>>>>>>>> On Nov 27, 2018, at 4:07 PM, Rick Edgecombe <
>>>>>>>> rick.p.edgecombe@intel.com>
>>>>>>>> wrote:
>>>>>>>>=20
>>>>>>>> Since vfree will lazily flush the TLB, but not lazily free the
>>>>>>>> underlying
>>>>>>>> pages,
>>>>>>>> it often leaves stale TLB entries to freed pages that could get
>>>>>>>> re-
>>>>>>>> used.
>>>>>>>> This is
>>>>>>>> undesirable for cases where the memory being freed has special
>>>>>>>> permissions
>>>>>>>> such
>>>>>>>> as executable.
>>>>>>>=20
>>>>>>> So I am trying to finish my patch-set for preventing transient =
W+X
>>>>>>> mappings
>>>>>>> from taking space, by handling kprobes & ftrace that I missed
>>>>>>> (thanks
>>>>>>> again
>>>>>>> for
>>>>>>> pointing it out).
>>>>>>>=20
>>>>>>> But all of the sudden, I don=E2=80=99t understand why we have =
the problem
>>>>>>> that
>>>>>>> this
>>>>>>> (your) patch-set deals with at all. We already change the =
mappings
>>>>>>> to
>>>>>>> make
>>>>>>> the memory writable before freeing the memory, so why can=E2=80=99=
t we make
>>>>>>> it
>>>>>>> non-executable at the same time? Actually, why do we make the =
module
>>>>>>> memory,
>>>>>>> including its data executable before freeing it???
>>>>>>=20
>>>>>> Yeah, this is really confusing, but I have a suspicion it's a
>>>>>> combination
>>>>>> of the various different configurations and hysterical raisins. =
We
>>>>>> can't
>>>>>> rely on module_alloc() allocating from the vmalloc area (see =
nios2)
>>>>>> nor
>>>>>> can we rely on disable_ro_nx() being available at build time.
>>>>>>=20
>>>>>> If we *could* rely on module allocations always using vmalloc(), =
then
>>>>>> we could pass in Rick's new flag and drop disable_ro_nx() =
altogether
>>>>>> afaict -- who cares about the memory attributes of a mapping =
that's
>>>>>> about
>>>>>> to disappear anyway?
>>>>>>=20
>>>>>> Is it just nios2 that does something different?
>>>>>>=20
>>>>>> Will
>>>>>=20
>>>>> Yea it is really intertwined. I think for x86, set_memory_nx =
everywhere
>>>>> would
>>>>> solve it as well, in fact that was what I first thought the =
solution
>>>>> should
>>>>> be
>>>>> until this was suggested. It's interesting that from the other =
thread
>>>>> Masami
>>>>> Hiramatsu referenced, set_memory_nx was suggested last year and =
would
>>>>> have
>>>>> inadvertently blocked this on x86. But, on the other architectures =
I
>>>>> have
>>>>> since
>>>>> learned it is a bit different.
>>>>>=20
>>>>> It looks like actually most arch's don't re-define set_memory_*, =
and so
>>>>> all
>>>>> of
>>>>> the frob_* functions are actually just noops. In which case =
allocating
>>>>> RWX
>>>>> is
>>>>> needed to make it work at all, because that is what the allocation =
is
>>>>> going
>>>>> to
>>>>> stay at. So in these archs, set_memory_nx won't solve it because =
it will
>>>>> do
>>>>> nothing.
>>>>>=20
>>>>> On x86 I think you cannot get rid of disable_ro_nx fully because =
there
>>>>> is
>>>>> the
>>>>> changing of the permissions on the directmap as well. You don't =
want
>>>>> some
>>>>> other
>>>>> caller getting a page that was left RO when freed and then trying =
to
>>>>> write
>>>>> to
>>>>> it, if I understand this.
>>>>>=20
>>>>> The other reasoning was that calling set_memory_nx isn't doing =
what we
>>>>> are
>>>>> actually trying to do which is prevent the pages from getting =
released
>>>>> too
>>>>> early.
>>>>>=20
>>>>> A more clear solution for all of this might involve refactoring =
some of
>>>>> the
>>>>> set_memory_ de-allocation logic out into __weak functions in =
either
>>>>> modules
>>>>> or
>>>>> vmalloc. As Jessica points out in the other thread though, modules =
does
>>>>> a
>>>>> lot
>>>>> more stuff there than the other module_alloc callers. I think it =
may
>>>>> take
>>>>> some
>>>>> thought to centralize AND make it optimal for every
>>>>> module_alloc/vmalloc_exec
>>>>> user and arch.
>>>>>=20
>>>>> But for now with the change in vmalloc, we can block the =
executable
>>>>> mapping
>>>>> freed page re-use issue in a cross platform way.
>>>>=20
>>>> Please understand me correctly - I didn=E2=80=99t mean that your =
patches are not
>>>> needed.
>>>=20
>>> Ok, I think I understand. I have been pondering these same things =
after
>>> Masami
>>> Hiramatsu's comments on this thread the other day.
>>>=20
>>>> All I did is asking - how come the PTEs are executable when they =
are
>>>> cleared
>>>> they are executable, when in fact we manipulate them when the =
module is
>>>> removed.
>>>=20
>>> I think the directmap used to be RWX so maybe historically its =
trying to
>>> return
>>> it to its default state? Not sure.
>>>=20
>>>> I think I try to deal with a similar problem to the one you =
encounter -
>>>> broken W^X. The only thing that bothered me in regard to your =
patches (and
>>>> only after I played with the code) is that there is still a =
time-window in
>>>> which W^X is broken due to disable_ro_nx().
>>>=20
>>> Totally agree there is overlap in the fixes and we should sync.
>>>=20
>>> What do you think about Andy's suggestion for doing the vfree =
cleanup in
>>> vmalloc
>>> with arch hooks? So the allocation goes into vfree fully setup and =
vmalloc
>>> frees
>>> it and on x86 resets the direct map.
>>=20
>> As long as you do it, I have no problem ;-)
>>=20
>> You would need to consider all the callers of module_memfree(), and =
probably
>> to untangle at least part of the mess in pageattr.c . If you are up =
to it,
>> just say so, and I=E2=80=99ll drop this patch. All I can say is =
=E2=80=9Cgood luck with all
>> that=E2=80=9D.
> I thought you were trying to prevent having any memory that at any =
time was W+X,
> how does vfree help with the module load time issues, where it starts =
WRX on
> x86?

I didn=E2=80=99t say it does. The patch I submitted before [1] should =
deal with the
issue of module loading, and I still think it is required. I also =
addressed
the kprobe and ftrace issues that you raised.

Perhaps it makes more sense that I will include the patch I proposed for
module cleanup to make the patch-set =E2=80=9Ccomplete=E2=80=9D. If you =
finish the changes
you propose before the patch is applied, it could be dropped. I just =
want to
get rid of this series, as it keeps collecting more and more patches.

I suspect it will not be the last version anyhow.

[1] https://lkml.org/lkml/2018/11/21/305=
