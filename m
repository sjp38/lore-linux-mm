Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 87F656B0024
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 09:51:14 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 91-v6so7225218lfu.20
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 06:51:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u77-v6sor327401lff.17.2018.03.27.06.51.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 06:51:12 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC PATCH v2 0/2] Randomization of address chosen by mmap.
From: Ilya Smith <blackzert@gmail.com>
In-Reply-To: <20180327072432.GY5652@dhcp22.suse.cz>
Date: Tue, 27 Mar 2018 16:51:08 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <0549F29C-12FC-4401-9E85-A430BC11DA78@gmail.com>
References: <1521736598-12812-1-git-send-email-blackzert@gmail.com>
 <20180323124806.GA5624@bombadil.infradead.org>
 <651E0DB6-4507-4DA1-AD46-9C26ED9792A8@gmail.com>
 <20180326084650.GC5652@dhcp22.suse.cz>
 <01A133F4-27DF-4AE2-80D6-B0368BF758CD@gmail.com>
 <20180327072432.GY5652@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@synopsys.com, linux@armlinux.org.uk, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, jejb@parisc-linux.org, Helge Deller <deller@gmx.de>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, nyc@holomorphy.com, viro@zeniv.linux.org.uk, arnd@arndb.de, gregkh@linuxfoundation.org, deepa.kernel@gmail.com, Hugh Dickins <hughd@google.com>, kstewart@linuxfoundation.org, pombredanne@nexb.com, Andrew Morton <akpm@linux-foundation.org>, steve.capper@arm.com, punit.agrawal@arm.com, aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com, Kees Cook <keescook@chromium.org>, bhsharma@redhat.com, riel@redhat.com, nitin.m.gupta@oracle.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, ross.zwisler@linux.intel.com, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-alpha@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-snps-arc@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Linux-MM <linux-mm@kvack.org>


> On 27 Mar 2018, at 10:24, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Mon 26-03-18 22:45:31, Ilya Smith wrote:
>>=20
>>> On 26 Mar 2018, at 11:46, Michal Hocko <mhocko@kernel.org> wrote:
>>>=20
>>> On Fri 23-03-18 20:55:49, Ilya Smith wrote:
>>>>=20
>>>>> On 23 Mar 2018, at 15:48, Matthew Wilcox <willy@infradead.org> =
wrote:
>>>>>=20
>>>>> On Thu, Mar 22, 2018 at 07:36:36PM +0300, Ilya Smith wrote:
>>>>>> Current implementation doesn't randomize address returned by =
mmap.
>>>>>> All the entropy ends with choosing mmap_base_addr at the process
>>>>>> creation. After that mmap build very predictable layout of =
address
>>>>>> space. It allows to bypass ASLR in many cases. This patch make
>>>>>> randomization of address on any mmap call.
>>>>>=20
>>>>> Why should this be done in the kernel rather than libc?  libc is =
perfectly
>>>>> capable of specifying random numbers in the first argument of =
mmap.
>>>> Well, there is following reasons:
>>>> 1. It should be done in any libc implementation, what is not =
possible IMO;
>>>=20
>>> Is this really so helpful?
>>=20
>> Yes, ASLR is one of very important mitigation techniques which are =
really used=20
>> to protect applications. If there is no ASLR, it is very easy to =
exploit=20
>> vulnerable application and compromise the system. We can=E2=80=99t =
just fix all the=20
>> vulnerabilities right now, thats why we have mitigations - techniques =
which are=20
>> makes exploitation more hard or impossible in some cases.
>>=20
>> Thats why it is helpful.
>=20
> I am not questioning ASLR in general. I am asking whether we really =
need
> per mmap ASLR in general. I can imagine that some environments want to
> pay the additional price and other side effects, but considering this
> can be achieved by libc, why to add more code to the kernel?

I believe this is the only one right place for it. Adding these 200+ =
lines of=20
code we give this feature for any user - on desktop, on server, on IoT =
device,=20
on SCADA, etc. But if only glibc will implement =E2=80=98user-mode-aslr=E2=
=80=99 IoT and SCADA=20
devices will never get it.

>>>=20
>>>> 2. User mode is not that layer which should be responsible for =
choosing
>>>> random address or handling entropy;
>>>=20
>>> Why?
>>=20
>> Because of the following reasons:
>> 1. To get random address you should have entropy. These entropy =
shouldn=E2=80=99t be=20
>> exposed to attacker anyhow, the best case is to get it from kernel. =
So this is
>> a syscall.
>=20
> /dev/[u]random is not sufficient?

Using /dev/[u]random makes 3 syscalls - open, read, close. This is a =
performance
issue.

>=20
>> 2. You should have memory map of your process to prevent remapping or =
big
>> fragmentation. Kernel already has this map.
>=20
> /proc/self/maps?

Not any system has /proc and parsing /proc/self/maps is robust so it is =
the=20
performance issue. libc will have to do it on any mmap. And there is a =
possible=20
race here - application may mmap/unmap memory with native syscall during =
other=20
thread reading maps.

>> You will got another one in libc.
>> And any non-libc user of mmap (via syscall, etc) will make hole in =
your map.
>> This one also decrease performance cause you any way call =
syscall_mmap=20
>> which will try to find some address for you in worst case, but after =
you already
>> did some computing on it.
>=20
> I do not understand. a) you should be prepared to pay an additional
> price for an additional security measures and b) how would anybody =
punch
> a hole into your mapping?=20
>=20

I was talking about any code that call mmap directly without libc =
wrapper.

>> 3. The more memory you use in userland for these proposal, the easier =
for
>> attacker to leak it or use in exploitation techniques.
>=20
> This is true in general, isn't it? I fail to see how kernel chosen and
> user chosen ranges would make any difference.

My point here was that libc will have to keep memory representation as a =
tree=20
and this tree increase attack surface. It could be hidden in kernel as =
it is right now.

>=20
>> 4. It is so easy to fix Kernel function and so hard to support memory
>> management from userspace.
>=20
> Well, on the other hand the new layout mode will add a maintenance
> burden on the kernel and will have to be maintained for ever because =
it
> is a user visible ABI.

Thats why I made this patch as RFC and would like to discuss this ABI =
here. I=20
made randomize_va_space parameter to allow disable randomisation per =
whole=20
system. PF_RANDOMIZE flag may disable randomization for concrete process =
(or=20
process groups?). For architecture I=E2=80=99ve made info.random_shift =3D=
 0 , so if your=20
arch has small address space you may disable shifting. I also would like =
to add=20
some sysctl to allow process/groups to change this value and allow some=20=

processes to have shifts bigger then another. Lets discuss it, please.

>=20
>>>> 3. Memory fragmentation is unpredictable in this case
>>>>=20
>>>> Off course user mode could use random =E2=80=98hint=E2=80=99 =
address, but kernel may
>>>> discard this address if it is occupied for example and allocate =
just before
>>>> closest vma. So this solution doesn=E2=80=99t give that much =
security like=20
>>>> randomization address inside kernel.
>>>=20
>>> The userspace can use the new MAP_FIXED_NOREPLACE to probe for the
>>> address range atomically and chose a different range on failure.
>>>=20
>>=20
>> This algorithm should track current memory. If he doesn=E2=80=99t he =
may cause
>> infinite loop while trying to choose memory. And each iteration =
increase time
>> needed on allocation new memory, what is not preferred by any libc =
library
>> developer.
>=20
> Well, I am pretty sure userspace can implement proper free ranges
> tracking=E2=80=A6

I think we need to know what libc developers will say on implementing =
ASLR in=20
user-mode. I am pretty sure they will say =E2=80=98nether=E2=80=99 or =
=E2=80=98some-day=E2=80=99. And problem=20
of ASLR will stay forever.

Thanks,
Ilya
