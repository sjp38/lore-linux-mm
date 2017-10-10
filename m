Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3D516B0284
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:28:03 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id l46so11288110uai.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:28:03 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h5sor2062966uah.257.2017.10.10.08.28.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Oct 2017 08:28:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0e1d9dbe-6c09-979d-e0ba-c39368028cbf@virtuozzo.com>
References: <20171009150521.82775-1-glider@google.com> <20171009150521.82775-2-glider@google.com>
 <0e1d9dbe-6c09-979d-e0ba-c39368028cbf@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 10 Oct 2017 17:28:01 +0200
Message-ID: <CAG_fn=WaC2hk6i=CLq2u37MhZ_5FtOgbjyXScmqAnRh46uNNiQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] Makefile: support flag -fsanitizer-coverage=trace-cmp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Popov <alex.popov@linux.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, syzkaller <syzkaller@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 9, 2017 at 8:53 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
>
>
> On 10/09/2017 06:05 PM, Alexander Potapenko wrote:
>
>> v2: - updated KCOV_ENABLE_COMPARISONS description
>> ---
>>  Makefile             |  5 +++--
>>  lib/Kconfig.debug    | 10 ++++++++++
>>  scripts/Makefile.lib |  6 ++++++
>>  3 files changed, 19 insertions(+), 2 deletions(-)
>>
>> diff --git a/Makefile b/Makefile
>> index 2835863bdd5a..c2a8e56df748 100644
>> --- a/Makefile
>> +++ b/Makefile
>> @@ -374,7 +374,7 @@ AFLAGS_KERNEL     =3D
>>  LDFLAGS_vmlinux =3D
>>  CFLAGS_GCOV  :=3D -fprofile-arcs -ftest-coverage -fno-tree-loop-im $(ca=
ll cc-disable-warning,maybe-uninitialized,)
>>  CFLAGS_KCOV  :=3D $(call cc-option,-fsanitize-coverage=3Dtrace-pc,)
>> -
>> +CFLAGS_KCOV_COMPS :=3D $(call cc-option,-fsanitize-coverage=3Dtrace-cmp=
,)
>>
>>  # Use USERINCLUDE when you must reference the UAPI directories only.
>>  USERINCLUDE    :=3D \
>> @@ -420,7 +420,7 @@ export MAKE AWK GENKSYMS INSTALLKERNEL PERL PYTHON U=
TS_MACHINE
>>  export HOSTCXX HOSTCXXFLAGS LDFLAGS_MODULE CHECK CHECKFLAGS
>>
>>  export KBUILD_CPPFLAGS NOSTDINC_FLAGS LINUXINCLUDE OBJCOPYFLAGS LDFLAGS
>> -export KBUILD_CFLAGS CFLAGS_KERNEL CFLAGS_MODULE CFLAGS_GCOV CFLAGS_KCO=
V CFLAGS_KASAN CFLAGS_UBSAN
>> +export KBUILD_CFLAGS CFLAGS_KERNEL CFLAGS_MODULE CFLAGS_GCOV CFLAGS_KCO=
V CFLAGS_KCOV_COMPS CFLAGS_KASAN CFLAGS_UBSAN
>>  export KBUILD_AFLAGS AFLAGS_KERNEL AFLAGS_MODULE
>>  export KBUILD_AFLAGS_MODULE KBUILD_CFLAGS_MODULE KBUILD_LDFLAGS_MODULE
>>  export KBUILD_AFLAGS_KERNEL KBUILD_CFLAGS_KERNEL
>> @@ -822,6 +822,7 @@ KBUILD_CFLAGS   +=3D $(call cc-option,-Werror=3Ddesi=
gnated-init)
>>  KBUILD_ARFLAGS :=3D $(call ar-option,D)
>>
>>  include scripts/Makefile.kasan
>> +include scripts/Makefile.kcov
>
> scripts/Makefile.kcov doesn't exist.
Good catch! Will fix.

>
>
>
>> diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
>> index 5e975fee0f5b..7ddd5932c832 100644
>> --- a/scripts/Makefile.lib
>> +++ b/scripts/Makefile.lib
>> @@ -142,6 +142,12 @@ _c_flags +=3D $(if $(patsubst n%,, \
>>       $(CFLAGS_KCOV))
>>  endif
>>
>> +ifeq ($(CONFIG_KCOV_ENABLE_COMPARISONS),y)
>> +_c_flags +=3D $(if $(patsubst n%,, \
>> +     $(KCOV_INSTRUMENT_$(basetarget).o)$(KCOV_INSTRUMENT)$(CONFIG_KCOV_=
INSTRUMENT_ALL)), \
>> +     $(CFLAGS_KCOV_COMPS))
>> +endif
>> +
>
> Instead of this you could simply add -fsanitize-coverage=3Dtrace-cmp to C=
FLAGS_KCOV.
Indeed. I've refactored these bits and moved them to Makefile.kcov.
>
>>  # If building the kernel in a separate objtree expand all occurrences
>>  # of -Idir to -I$(srctree)/dir except for absolute paths (starting with=
 '/').
>>
>>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
