Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6E46B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 04:17:07 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id y36so9176676plh.10
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 01:17:07 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w8sor4889514pfj.101.2017.12.20.01.17.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 01:17:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1352454e-bdb1-fcb0-8410-a89799c2f1b9@infradead.org>
References: <CACT4Y+a0NvG-qpufVcvObd_hWKF9xmTjmjCvV3_13LSgcFXL+Q@mail.gmail.com>
 <20171219090319.GD2787@dhcp22.suse.cz> <7cec6594-94c7-a238-4046-0061a9adc20d@infradead.org>
 <1352454e-bdb1-fcb0-8410-a89799c2f1b9@infradead.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 20 Dec 2017 10:16:44 +0100
Message-ID: <CACT4Y+bmn0Nmx7e7ge9Noyp3pgqOsyuDWUV4BwJsL7Q9X8=O0A@mail.gmail.com>
Subject: Re: mmots build error: version control conflict marker in file
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Dec 19, 2017 at 9:01 PM, Randy Dunlap <rdunlap@infradead.org> wrote=
:
> On 12/19/2017 12:00 PM, Randy Dunlap wrote:
>> On 12/19/2017 01:03 AM, Michal Hocko wrote:
>>> [CC Johannes]
>>>
>>> On Tue 19-12-17 09:36:20, Dmitry Vyukov wrote:
>>>> Hello,
>>>>
>>>> syzbot hit the following crash on 80f3359313dfd0e574d0d245dd93a7c3bf39=
e1fa
>>>> git://git.cmpxchg.org/linux-mmots.git master
>>>>
>>>> failed to run /usr/bin/make [make bzImage -j 32
>>>> CC=3D/syzkaller/gcc/bin/gcc]: exit status 2
>>>> scripts/kconfig/conf  --silentoldconfig Kconfig
>>>>   CHK     include/config/kernel.release
>>>>   CHK     include/generated/uapi/linux/version.h
>>>>   UPD     include/config/kernel.release
>>>>   CHK     scripts/mod/devicetable-offsets.h
>>>>   CHK     include/generated/utsrelease.h
>>>>   UPD     include/generated/utsrelease.h
>>>>   CHK     include/generated/bounds.h
>>>>   CHK     include/generated/timeconst.h
>>>>   CC      arch/x86/kernel/asm-offsets.s
>>>> In file included from ./arch/x86/include/asm/cpufeature.h:5:0,
>>>>                  from ./arch/x86/include/asm/thread_info.h:53,
>>>>                  from ./include/linux/thread_info.h:38,
>>>>                  from ./arch/x86/include/asm/preempt.h:7,
>>>>                  from ./include/linux/preempt.h:81,
>>>>                  from ./include/linux/spinlock.h:51,
>>>>                  from ./include/linux/mmzone.h:8,
>>>>                  from ./include/linux/gfp.h:6,
>>>>                  from ./include/linux/slab.h:15,
>>>>                  from ./include/linux/crypto.h:24,
>>>>                  from arch/x86/kernel/asm-offsets.c:9:
>>>> ./arch/x86/include/asm/processor.h:340:1: error: version control
>>>> conflict marker in file
>>>>  <<<<<<< HEAD
>>>>  ^~~~~~~
>>>> ./arch/x86/include/asm/processor.h:346:24: error: field =E2=80=98stack=
=E2=80=99 has
>>>> incomplete type
>>>>   struct SYSENTER_stack stack;
>>>>                         ^~~~~
>>>> ./arch/x86/include/asm/processor.h:347:1: error: version control
>>>> conflict marker in file
>>>>  =3D=3D=3D=3D=3D=3D=3D
>>>>  ^~~~~~~
>>>> Kbuild:56: recipe for target 'arch/x86/kernel/asm-offsets.s' failed
>>>> make[1]: *** [arch/x86/kernel/asm-offsets.s] Error 1
>>>> Makefile:1090: recipe for target 'prepare0' failed
>>>> make: *** [prepare0] Error 2
>>>
>>
>> Wow. arch/x86/include/asm/processor.h around line 340++ looks like this:
>>
>> <<<<<<< HEAD
>> struct SYSENTER_stack {
>>       unsigned long           words[64];
>> };
>>
>> struct SYSENTER_stack_page {
>>       struct SYSENTER_stack stack;
>> =3D=3D=3D=3D=3D=3D=3D
>> struct entry_stack {
>>       unsigned long           words[64];
>> };
>>
>> struct entry_stack_page {
>>       struct entry_stack stack;
>>>>>>>>> linux-next/akpm-base
>> } __aligned(PAGE_SIZE);
>
> That's only in the git tree.  The mmots that I get from tarballs/patches
> does not have this problem.


FWIW syzbot relies on the git tree, pulling git trees is currently the
only way of getting kernel sources it supports.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
