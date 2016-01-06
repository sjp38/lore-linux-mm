Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 92A386B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 02:06:44 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id yy13so136241211pab.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 23:06:44 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 4si12931995pfa.245.2016.01.05.23.06.43
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 23:06:43 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v7 3/3] x86, mce: Add __mcsafe_copy()
Date: Wed, 6 Jan 2016 07:06:41 +0000
Message-ID: <A527EC4B-4069-4FDE-BE4C-5279C45BCABE@intel.com>
References: <cover.1451952351.git.tony.luck@intel.com>
	<5b0243c5df825ad0841f4bb5584cd15d3f013f09.1451952351.git.tony.luck@intel.com>,<CAPcyv4jjWT3Od_XvGpVb+O7MT95mBRXviPXi1zUfM5o+kN4CUA@mail.gmail.com>
In-Reply-To: <CAPcyv4jjWT3Od_XvGpVb+O7MT95mBRXviPXi1zUfM5o+kN4CUA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew
 Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

You were heading towards:

ld: undefined __mcsafe_copy

since that is also inside the #ifdef.=20

Weren't you going to "select" this?

I'm seriously wondering whether the ifdef still makes sense. Now I don't ha=
ve an extra exception table and routines to sort/search/fixup, it doesn't s=
eem as useful as it was a few iterations ago.

Sent from my iPhone

> On Jan 5, 2016, at 20:43, Dan Williams <dan.j.williams@intel.com> wrote:
>=20
>> On Thu, Dec 31, 2015 at 11:43 AM, Tony Luck <tony.luck@intel.com> wrote:
>> Make use of the EXTABLE_FAULT exception table entries. This routine
>> returns a structure to indicate the result of the copy:
>>=20
>> struct mcsafe_ret {
>>        u64 trapnr;
>>        u64 remain;
>> };
>>=20
>> If the copy is successful, then both 'trapnr' and 'remain' are zero.
>>=20
>> If we faulted during the copy, then 'trapnr' will say which type
>> of trap (X86_TRAP_PF or X86_TRAP_MC) and 'remain' says how many
>> bytes were not copied.
>>=20
>> Signed-off-by: Tony Luck <tony.luck@intel.com>
>> ---
>> arch/x86/Kconfig                 |  10 +++
>> arch/x86/include/asm/string_64.h |  10 +++
>> arch/x86/kernel/x8664_ksyms_64.c |   4 ++
>> arch/x86/lib/memcpy_64.S         | 136 +++++++++++++++++++++++++++++++++=
++++++
>> 4 files changed, 160 insertions(+)
>>=20
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index 96d058a87100..42d26b4d1ec4 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -1001,6 +1001,16 @@ config X86_MCE_INJECT
>>          If you don't know what a machine check is and you don't do kern=
el
>>          QA it is safe to say n.
>>=20
>> +config MCE_KERNEL_RECOVERY
>> +       bool "Recovery from machine checks in special kernel memory copy=
 functions"
>> +       default n
>> +       depends on X86_MCE && X86_64
>> +       ---help---
>> +         This option provides a new memory copy function mcsafe_memcpy(=
)
>> +         that is annotated to allow the machine check handler to return
>> +         to an alternate code path to return an error to the caller ins=
tead
>> +         of crashing the system. Say yes if you have a driver that uses=
 this.
>> +
>> config X86_THERMAL_VECTOR
>>        def_bool y
>>        depends on X86_MCE_INTEL
>> diff --git a/arch/x86/include/asm/string_64.h b/arch/x86/include/asm/str=
ing_64.h
>> index ff8b9a17dc4b..16a8f0e56e4a 100644
>> --- a/arch/x86/include/asm/string_64.h
>> +++ b/arch/x86/include/asm/string_64.h
>> @@ -78,6 +78,16 @@ int strcmp(const char *cs, const char *ct);
>> #define memset(s, c, n) __memset(s, c, n)
>> #endif
>>=20
>> +#ifdef CONFIG_MCE_KERNEL_RECOVERY
>> +struct mcsafe_ret {
>> +       u64 trapnr;
>> +       u64 remain;
>> +};
>=20
> Can we move this definition outside of the CONFIG_MCE_KERNEL_RECOVERY
> ifdef guard?  On a test integration branch the kbuild robot caught the
> following:
>=20
>   In file included from include/linux/pmem.h:21:0,
>                    from drivers/acpi/nfit.c:22:
>   arch/x86/include/asm/pmem.h: In function 'arch_memcpy_from_pmem':
>>> arch/x86/include/asm/pmem.h:55:21: error: storage size of 'ret' isn't k=
nown
>      struct mcsafe_ret ret;
>                        ^
>>> arch/x86/include/asm/pmem.h:57:9: error: implicit declaration of functi=
on '__mcsafe_copy' [-Werror=3Dimplicit-function-declaration]
>      ret =3D __mcsafe_copy(dst, (void __force *) src, n);
>            ^
>>> arch/x86/include/asm/pmem.h:55:21: warning: unused variable 'ret' [-Wun=
used-variable]
>      struct mcsafe_ret ret;
>                        ^
>   cc1: some warnings being treated as errors
>=20
> vim +55 arch/x86/include/asm/pmem.h
>=20
>    49  }
>    50
>    51  static inline int arch_memcpy_from_pmem(void *dst, const void
> __pmem *src,
>    52                  size_t n)
>    53  {
>    54          if (IS_ENABLED(CONFIG_MCE_KERNEL_RECOVERY)) {
>> 55                  struct mcsafe_ret ret;
>    56
>> 57                  ret =3D __mcsafe_copy(dst, (void __force *) src, n);
>    58                  if (ret.remain)
>    59                          return -EIO;
>    60                  return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
