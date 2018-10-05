Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CFE86B0271
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 12:28:09 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f89-v6so9357589pff.7
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 09:28:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d92-v6sor6850656pld.59.2018.10.05.09.28.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 09:28:08 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH v4 3/9] x86/cet/ibt: Add IBT legacy code bitmap allocation function
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <fc2f98ab46240c0498bdf4d7458b4373c1f02bf8.camel@intel.com>
Date: Fri, 5 Oct 2018 09:28:05 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <5BF3AE8F-CC2A-4160-9FF6-FEA171A76371@amacapital.net>
References: <20180921150553.21016-1-yu-cheng.yu@intel.com> <20180921150553.21016-4-yu-cheng.yu@intel.com> <20181003195702.GF32759@asgard.redhat.com> <fc2f98ab46240c0498bdf4d7458b4373c1f02bf8.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Eugene Syromiatnikov <esyr@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>



> On Oct 5, 2018, at 9:13 AM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>=20
>> On Wed, 2018-10-03 at 21:57 +0200, Eugene Syromiatnikov wrote:
>>> On Fri, Sep 21, 2018 at 08:05:47AM -0700, Yu-cheng Yu wrote:
>>> Indirect branch tracking provides an optional legacy code bitmap
>>> that indicates locations of non-IBT compatible code.  When set,
>>> each bit in the bitmap represents a page in the linear address is
>>> legacy code.
>>>=20
>>> We allocate the bitmap only when the application requests it.
>>> Most applications do not need the bitmap.
>>>=20
>>> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
>>> ---
>>> arch/x86/kernel/cet.c | 45 +++++++++++++++++++++++++++++++++++++++++++
>>> 1 file changed, 45 insertions(+)
>>>=20
>>> diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
>>> index 6adfe795d692..a65d9745af08 100644
>>> --- a/arch/x86/kernel/cet.c
>>> +++ b/arch/x86/kernel/cet.c
>>> @@ -314,3 +314,48 @@ void cet_disable_ibt(void)
>>>    wrmsrl(MSR_IA32_U_CET, r);
>>>    current->thread.cet.ibt_enabled =3D 0;
>>> }
>>> +
>>> +int cet_setup_ibt_bitmap(void)
>>> +{
>>> +    u64 r;
>>> +    unsigned long bitmap;
>>> +    unsigned long size;
>>> +
>>> +    if (!cpu_feature_enabled(X86_FEATURE_IBT))
>>> +        return -EOPNOTSUPP;
>>> +
>>> +    if (!current->thread.cet.ibt_bitmap_addr) {
>>> +        /*
>>> +         * Calculate size and put in thread header.
>>> +         * may_expand_vm() needs this information.
>>> +         */
>>> +        size =3D TASK_SIZE / PAGE_SIZE / BITS_PER_BYTE;
>>=20
>> TASK_SIZE_MAX is likely needed here, as an application can easily switch
>> between long an 32-bit protected mode.  And then the case of a CPU that
>> doesn't support 5LPT.
>=20
> If we had calculated bitmap size from TASK_SIZE_MAX, all 32-bit apps would=
 have
> failed the allocation for bitmap size > TASK_SIZE.  Please see values belo=
w,
> which is printed from the current code.
>=20
> Yu-cheng
>=20
>=20
> x64:
> TASK_SIZE_MAX    =3D 0000 7fff ffff f000
> TASK_SIZE    =3D 0000 7fff ffff f000
> bitmap size    =3D 0000 0000 ffff ffff
>=20
> x32:
> TASK_SIZE_MAX    =3D 0000 7fff ffff f000
> TASK_SIZE    =3D 0000 0000 ffff e000
> bitmap size    =3D 0000 0000 0001 ffff
>=20

I haven=E2=80=99t followed all the details here, but I have a general policy=
 of objecting to any new use of TASK_SIZE. If you really really need to depe=
nd on 32-bitness in new code, please figure out what exactly you mean by =E2=
=80=9C32-bit=E2=80=9D and use an explicit check.

Some day I would love to delete TASK_SIZE.=
