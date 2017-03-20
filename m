Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A80196B0038
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 21:14:12 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b2so270231358pgc.6
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 18:14:12 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id y84si11119092pfd.160.2017.03.19.18.14.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 18:14:11 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id o126so14969298pfb.1
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 18:14:11 -0700 (PDT)
Date: Mon, 20 Mar 2017 09:14:08 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH tip] x86/mm: Correct fixmap header usage on adaptable
 MODULES_END
Message-ID: <20170320011408.GA28871@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170317175034.4701-1-thgarnie@google.com>
 <20170319160333.GA1187@WeideMBP.lan>
 <CAJcbSZE5Kq4ew3hHSSpMkReNf54EVpetA0hU09YYtkE2j=8m9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="EeQfGwPcQSOJBaQU"
Content-Disposition: inline
In-Reply-To: <CAJcbSZE5Kq4ew3hHSSpMkReNf54EVpetA0hU09YYtkE2j=8m9w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Mar 19, 2017 at 09:25:00AM -0700, Thomas Garnier wrote:
>On Sun, Mar 19, 2017 at 9:03 AM, Wei Yang <richard.weiyang@gmail.com> wrot=
e:
>> On Fri, Mar 17, 2017 at 10:50:34AM -0700, Thomas Garnier wrote:
>>>This patch remove fixmap header usage on non-x86 code that was
>>>introduced by the adaptable MODULE_END change.
>>
>> Hi, Thomas
>>
>> In this patch, it looks you are trying to do two things for my understan=
ding:
>> 1. To include <asm/fixmap.h> in asm/pagetable_64.h and remove the includ=
e in
>> some of the x86 files
>> 2. Remove <asm/fixmap.h> in mm/vmalloc.c
>>
>> I think your change log covers the second task in the patch, but not not=
 talk
>> about the first task you did in the patch. If you could mention it in co=
mmit
>> log, it would be good for maintain.
>
>I agree, I am not the best at writing commits (by far). What's the
>best way for me to correct that? (the bot seem to have taken it).
>

Simply mention it in your commit log is enough to me.

>>
>> BTW, I have little knowledge about MODULE_END. By searching the code
>> MODULE_END is not used in arch/x86. If you would like to mention the com=
mit
>> which introduce the problem, it would be more helpful to review the code.
>
>It is used in many places in arch/x86, kasan, head64, fault etc..:
>http://lxr.free-electrons.com/ident?i=3DMODULES_END
>

Oh, thanks :-)

>>
>>>
>>>Signed-off-by: Thomas Garnier <thgarnie@google.com>
>>>---
>>>Based on tip:x86/mm
>>>---
>>> arch/x86/include/asm/pgtable_64.h | 1 +
>>> arch/x86/kernel/module.c          | 1 -
>>> arch/x86/mm/dump_pagetables.c     | 1 -
>>> arch/x86/mm/kasan_init_64.c       | 1 -
>>> mm/vmalloc.c                      | 4 ----
>>> 5 files changed, 1 insertion(+), 7 deletions(-)
>>>
>>>diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pg=
table_64.h
>>>index 73c7ccc38912..67608d4abc2c 100644
>>>--- a/arch/x86/include/asm/pgtable_64.h
>>>+++ b/arch/x86/include/asm/pgtable_64.h
>>>@@ -13,6 +13,7 @@
>>> #include <asm/processor.h>
>>> #include <linux/bitops.h>
>>> #include <linux/threads.h>
>>>+#include <asm/fixmap.h>
>>>
>>
>> Hmm... I see in both pgtable_32.h and pgtable_64.h will include <asm/fix=
map.h>
>> after this change. And pgtable_32.h and pgtable_64.h will be included on=
ly in
>> pgtable.h. So is it possible to include <asm/fixmap.h> in pgtable.h for =
once
>> instead of include it in both files? Any concerns you would have?
>
>I am not sure I understood. Only 64-bit need this header to correctly
>get MODULES_END, that's why I added it to pgtable_64.h only. I tried
>to add it lower before and ran into multiple header errors.
>

When you look in to pgtable_64.h, you would see it includes <asm/fixmap.h>
too. Hmm... If only 64-bit need this header, would it be possible to remote=
 it
=66rom pgtable_32.h?


>>
>>> extern pud_t level3_kernel_pgt[512];
>>> extern pud_t level3_ident_pgt[512];
>>>diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
>>>index fad61caac75e..477ae806c2fa 100644
>>>--- a/arch/x86/kernel/module.c
>>>+++ b/arch/x86/kernel/module.c
>>>@@ -35,7 +35,6 @@
>>> #include <asm/page.h>
>>> #include <asm/pgtable.h>
>>> #include <asm/setup.h>
>>>-#include <asm/fixmap.h>
>>>
>>> #if 0
>>> #define DEBUGP(fmt, ...)                              \
>>>diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables=
=2Ec
>>>index 75efeecc85eb..58b5bee7ea27 100644
>>>--- a/arch/x86/mm/dump_pagetables.c
>>>+++ b/arch/x86/mm/dump_pagetables.c
>>>@@ -20,7 +20,6 @@
>>>
>>> #include <asm/kasan.h>
>>> #include <asm/pgtable.h>
>>>-#include <asm/fixmap.h>
>>>
>>> /*
>>>  * The dumper groups pagetable entries of the same type into one, and f=
or
>>>diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
>>>index 1bde19ef86bd..8d63d7a104c3 100644
>>>--- a/arch/x86/mm/kasan_init_64.c
>>>+++ b/arch/x86/mm/kasan_init_64.c
>>>@@ -9,7 +9,6 @@
>>>
>>> #include <asm/tlbflush.h>
>>> #include <asm/sections.h>
>>>-#include <asm/fixmap.h>
>>>
>>> extern pgd_t early_level4_pgt[PTRS_PER_PGD];
>>> extern struct range pfn_mapped[E820_X_MAX];
>>>diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>>>index b7d2a23349f4..0dd80222b20b 100644
>>>--- a/mm/vmalloc.c
>>>+++ b/mm/vmalloc.c
>>>@@ -36,10 +36,6 @@
>>> #include <asm/tlbflush.h>
>>> #include <asm/shmparam.h>
>>>
>>>-#ifdef CONFIG_X86
>>>-# include <asm/fixmap.h>
>>>-#endif
>>>-
>>> #include "internal.h"
>>>
>>> struct vfree_deferred {
>>>--
>>>2.12.0.367.g23dc2f6d3c-goog
>>
>> --
>> Wei Yang
>> Help you, Help me
>
>
>
>--=20
>Thomas

--=20
Wei Yang
Help you, Help me

--EeQfGwPcQSOJBaQU
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYzyzgAAoJEKcLNpZP5cTd2dAP/3HFkAqDuAkX3vl7FbyInQQj
wfBHTTU47kKULaXHiBZ4AB8ldFs1TT4Uztuz2vLcFOQQkESiywY8ATXSb/Sfywfn
Z0URXqaA2ogowyURS8Ni77KqwQnUNEhMjXs7FerpSB7qSWdkmZNC69nVGFbKedIX
z8FvulCKKqnPE1srtKsHrwZzy+IphO/Jl4Tg6x4QTPt/SGK9PubUmyKxmK360HGU
P+oKAs88JhKCZev65MsWnxCtVQmcDCCdH6W/Lcu+q+Fl5O3PQe70ywEENg0/hc+a
2IVeZLlkpPgQElzkNgU+gs72x0ngrIUWuyHoFijVkLcpH4VnrylNMiKH9jvkonLJ
uQyz5XLViiDgb+h+KB1o9J4EYwMic87fxogc5dwn8+GTR1yb4QbQJvc+3F07mIZB
66vCtMIm00wtm9EBGAb9VHEMzwOEkqfie1BW49qmdlENVM+0ohr17CAiamNb46vM
uEgiUgYBu/ItTncu1yFdV+IBPxKMlADcYzUihY2eEqmiIj5+1CjxUN+lwtG2IQS3
CiP9U+6g9YJOATXth08sZeihDm9DNdUuf4pFCV67Tyis0oESYP7H8UFWykrIxCfV
JcjV3fx/2h4evAWnLDI8k7kLXUqc2FKpxTP7tryAAHeAyjTLNwfP4DVmF8fu1mZK
JuKoPraYoKPmMSYYBj5a
=/Ca3
-----END PGP SIGNATURE-----

--EeQfGwPcQSOJBaQU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
