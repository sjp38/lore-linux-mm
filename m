Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id B6EB06B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 19:47:03 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id i4so4912652oah.38
        for <linux-mm@kvack.org>; Thu, 18 Jul 2013 16:47:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130718143928.4f9b45807956e2fdb1ee3a22@linux-foundation.org>
References: <1374166572-7988-1-git-send-email-uulinux@gmail.com>
	<20130718143928.4f9b45807956e2fdb1ee3a22@linux-foundation.org>
Date: Fri, 19 Jul 2013 07:47:02 +0800
Message-ID: <CAAV+Mu7A5H_T2EroUDWaCSOs1j5_Z6hRNyzrwU2N1WPAOZ=JDw@mail.gmail.com>
Subject: Re: [PATCH] mm: negative left shift count when PAGE_SHIFT > 20
From: Jerry <uulinux@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: zhuwei.lu@archermind.com, tianfu.huang@archermind.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2013/7/19 Andrew Morton <akpm@linux-foundation.org>:
> On Fri, 19 Jul 2013 00:56:12 +0800 Jerry <uulinux@gmail.com> wrote:
>
>> When PAGE_SHIFT > 20, the result of "20 - PAGE_SHIFT" is negative. The
>> calculating here will generate an unexpected result. In addition, if
>> PAGE_SHIFT > 20, The memory size represented by numentries was already
>> integral multiple of 1MB.
>>
>
> If you tell me that you have a machine which has PAGE_SIZE=2MB and this
> was the only problem which prevented Linux from running on that machine
> then I'll apply the patch ;)
>

Hi Morton:
I just "grep -rn "#define\s\+PAGE_SHIFT" arch/", and find the
PAGE_SHIFT in some architecture is very big.
such as the following in "arch/hexagon/include/asm/page.h"
....
#ifdef CONFIG_PAGE_SIZE_256KB
#define PAGE_SHIFT 18
#define HEXAGON_L1_PTE_SIZE __HVM_PDE_S_256KB
#endif

#ifdef CONFIG_PAGE_SIZE_1MB
#define PAGE_SHIFT 20
#define HEXAGON_L1_PTE_SIZE __HVM_PDE_S_1MB
#endif
.....

Maybe the day of "A 2MB page" is not far. :-) I know it is just a
latent issue. Even if it won't generate a error when PAGE_SIZE == 20,
the calculating here is not necessary. In my mind, compiler would
optimize the calculating at that situation. But it is a little tricky.

In my patch, I think compiler would optimize "if (20 > PAGE_SIZE)", it
won't generate any machine instruction. Just a guarantee.

--
I love linux!!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
