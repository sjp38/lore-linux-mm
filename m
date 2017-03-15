From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC PATCH 00/13] Introduce first class virtual address spaces
Date: Wed, 15 Mar 2017 09:51:31 -0700
Message-ID: <CALCETrX5gv+zdhOYro4-u3wGWjVCab28DFHPSm5=BVG_hKxy3A__25035.3534975604$1489596725$gmane$org@mail.gmail.com>
References: <CALCETrXKvNWv1OtoSo_HWf5ZHSvyGS1NsuQod6Zt+tEg3MT5Sg@mail.gmail.com>
 <20170314161229.tl6hsmian2gdep47@arch-dev>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by blaine.gmane.org with esmtp (Exim 4.84_2)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1coC9N-00010G-C6
	for glkm-linux-mm-2@m.gmane.org; Wed, 15 Mar 2017 17:51:49 +0100
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36A846B0391
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 12:51:54 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id b202so4842486vka.7
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:51:54 -0700 (PDT)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id h13si761482uac.103.2017.03.15.09.51.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 09:51:53 -0700 (PDT)
Received: by mail-vk0-x230.google.com with SMTP id r136so11858174vke.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:51:53 -0700 (PDT)
In-Reply-To: <20170314161229.tl6hsmian2gdep47@arch-dev>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Andy Lutomirski <luto@kernel.org>, Till Smejkal <till.smejkal@googlemail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de>

On Tue, Mar 14, 2017 at 9:12 AM, Till Smejkal
<till.smejkal@googlemail.com> wrote:
> On Mon, 13 Mar 2017, Andy Lutomirski wrote:
>> On Mon, Mar 13, 2017 at 7:07 PM, Till Smejkal
>> <till.smejkal@googlemail.com> wrote:
>> > On Mon, 13 Mar 2017, Andy Lutomirski wrote:
>> >> This sounds rather complicated.  Getting TLB flushing right seems
>> >> tricky.  Why not just map the same thing into multiple mms?
>> >
>> > This is exactly what happens at the end. The memory region that is des=
cribed by the
>> > VAS segment will be mapped in the ASes that use the segment.
>>
>> So why is this kernel feature better than just doing MAP_SHARED
>> manually in userspace?
>
> One advantage of VAS segments is that they can be globally queried by use=
r programs
> which means that VAS segments can be shared by applications that not nece=
ssarily have
> to be related. If I am not mistaken, MAP_SHARED of pure in memory data wi=
ll only work
> if the tasks that share the memory region are related (aka. have a common=
 parent that
> initialized the shared mapping). Otherwise, the shared mapping have to be=
 backed by a
> file.

What's wrong with memfd_create()?

> VAS segments on the other side allow sharing of pure in memory data by
> arbitrary related tasks without the need of a file. This becomes especial=
ly
> interesting if one combines VAS segments with non-volatile memory since o=
ne can keep
> data structures in the NVM and still be able to share them between multip=
le tasks.

What's wrong with regular mmap?

>
>> >> Ick.  Please don't do this.  Can we please keep an mm as just an mm
>> >> and not make it look magically different depending on which process
>> >> maps it?  If you need a trampoline (which you do, of course), just
>> >> write a trampoline in regular user code and map it manually.
>> >
>> > Did I understand you correctly that you are proposing that the switchi=
ng thread
>> > should make sure by itself that its code, stack, =E2=80=A6 memory regi=
ons are properly setup
>> > in the new AS before/after switching into it? I think, this would make=
 using first
>> > class virtual address spaces much more difficult for user applications=
 to the extend
>> > that I am not even sure if they can be used at all. At the moment, swi=
tching into a
>> > VAS is a very simple operation for an application because the kernel w=
ill just simply
>> > do the right thing.
>>
>> Yes.  I think that having the same mm_struct look different from
>> different tasks is problematic.  Getting it right in the arch code is
>> going to be nasty.  The heuristics of what to share are also tough --
>> why would text + data + stack or whatever you're doing be adequate?
>> What if you're in a thread?  What if two tasks have their stacks in
>> the same place?
>
> The different ASes that a task now can have when it uses first class virt=
ual address
> spaces are not realized in the kernel by using only one mm_struct per tas=
k that just
> looks differently but by using multiple mm_structs - one for each AS that=
 the task
> can execute in. When a task attaches a first class virtual address space =
to itself to
> be able to use another AS, the kernel adds a temporary mm_struct to this =
task that
> contains the mappings of the first class virtual address space and the on=
e shared
> with the task's original AS. If a thread now wants to switch into this at=
tached first
> class virtual address space the kernel only changes the 'mm' and 'active_=
mm' pointers
> in the task_struct of the thread to the temporary mm_struct and performs =
the
> corresponding mm_switch operation. The original mm_struct of the thread w=
ill not be
> changed.
>
> Accordingly, I do not magically make mm_structs look differently dependin=
g on the
> task that uses it, but create temporary mm_structs that only contain mapp=
ings to the
> same memory regions.

This sounds complicated and fragile.  What happens if a heuristically
shared region coincides with a region in the "first class address
space" being selected?

I think the right solution is "you're a user program playing virtual
address games -- make sure you do it right".

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
