Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 1E6AC6B0031
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 13:17:01 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b47so2939625eek.7
        for <linux-mm@kvack.org>; Sat, 20 Jul 2013 10:16:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130719145729.840eeae88fad89d2c6915163@linux-foundation.org>
References: <1374166572-7988-1-git-send-email-uulinux@gmail.com>
	<20130718143928.4f9b45807956e2fdb1ee3a22@linux-foundation.org>
	<CAAV+Mu7A5H_T2EroUDWaCSOs1j5_Z6hRNyzrwU2N1WPAOZ=JDw@mail.gmail.com>
	<20130719145729.840eeae88fad89d2c6915163@linux-foundation.org>
Date: Sun, 21 Jul 2013 01:16:59 +0800
Message-ID: <CAAV+Mu6ehgowpGun81Ooips2Gt=GwpygOiC5wbFk=P7axhom4Q@mail.gmail.com>
Subject: Re: [PATCH] mm: negative left shift count when PAGE_SHIFT > 20
From: Jerry <uulinux@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: zhuwei.lu@archermind.com, tianfu.huang@archermind.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2013/7/20 Andrew Morton <akpm@linux-foundation.org>:
> On Fri, 19 Jul 2013 07:47:02 +0800 Jerry <uulinux@gmail.com> wrote:
>
>> 2013/7/19 Andrew Morton <akpm@linux-foundation.org>:
>> > On Fri, 19 Jul 2013 00:56:12 +0800 Jerry <uulinux@gmail.com> wrote:
>> >
>> >> When PAGE_SHIFT > 20, the result of "20 - PAGE_SHIFT" is negative. The
>> >> calculating here will generate an unexpected result. In addition, if
>> >> PAGE_SHIFT > 20, The memory size represented by numentries was already
>> >> integral multiple of 1MB.
>> >>
>> >
>> > If you tell me that you have a machine which has PAGE_SIZE=2MB and this
>> > was the only problem which prevented Linux from running on that machine
>> > then I'll apply the patch ;)
>> >
>>
>> Hi Morton:
>> I just "grep -rn "#define\s\+PAGE_SHIFT" arch/", and find the
>> PAGE_SHIFT in some architecture is very big.
>> such as the following in "arch/hexagon/include/asm/page.h"
>> ....
>> #ifdef CONFIG_PAGE_SIZE_256KB
>> #define PAGE_SHIFT 18
>> #define HEXAGON_L1_PTE_SIZE __HVM_PDE_S_256KB
>> #endif
>>
>> #ifdef CONFIG_PAGE_SIZE_1MB
>> #define PAGE_SHIFT 20
>> #define HEXAGON_L1_PTE_SIZE __HVM_PDE_S_1MB
>> #endif
>> .....
>
> Good heavens.
>
>> In my patch, I think compiler would optimize "if (20 > PAGE_SIZE)", it
>> won't generate any machine instruction. Just a guarantee.
>
> Well the existing code is a bit silly looking.  Why can't we just do
>
>         /* round applicable memory size up to nearest megabyte */
>         if (PAGE_SHIFT < 20)
>                 numentries = round_up(nr_kernel_pages, (1 << 20)/PAGE_SIZE);
>
> or similar?

Great. I have adjusted these code lines, and sent the latest one.

--
I love linux!!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
