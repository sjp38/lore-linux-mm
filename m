Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id D334B6B0032
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 17:57:31 -0400 (EDT)
Date: Fri, 19 Jul 2013 14:57:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: negative left shift count when PAGE_SHIFT > 20
Message-Id: <20130719145729.840eeae88fad89d2c6915163@linux-foundation.org>
In-Reply-To: <CAAV+Mu7A5H_T2EroUDWaCSOs1j5_Z6hRNyzrwU2N1WPAOZ=JDw@mail.gmail.com>
References: <1374166572-7988-1-git-send-email-uulinux@gmail.com>
	<20130718143928.4f9b45807956e2fdb1ee3a22@linux-foundation.org>
	<CAAV+Mu7A5H_T2EroUDWaCSOs1j5_Z6hRNyzrwU2N1WPAOZ=JDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerry <uulinux@gmail.com>
Cc: zhuwei.lu@archermind.com, tianfu.huang@archermind.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 19 Jul 2013 07:47:02 +0800 Jerry <uulinux@gmail.com> wrote:

> 2013/7/19 Andrew Morton <akpm@linux-foundation.org>:
> > On Fri, 19 Jul 2013 00:56:12 +0800 Jerry <uulinux@gmail.com> wrote:
> >
> >> When PAGE_SHIFT > 20, the result of "20 - PAGE_SHIFT" is negative. The
> >> calculating here will generate an unexpected result. In addition, if
> >> PAGE_SHIFT > 20, The memory size represented by numentries was already
> >> integral multiple of 1MB.
> >>
> >
> > If you tell me that you have a machine which has PAGE_SIZE=2MB and this
> > was the only problem which prevented Linux from running on that machine
> > then I'll apply the patch ;)
> >
> 
> Hi Morton:
> I just "grep -rn "#define\s\+PAGE_SHIFT" arch/", and find the
> PAGE_SHIFT in some architecture is very big.
> such as the following in "arch/hexagon/include/asm/page.h"
> ....
> #ifdef CONFIG_PAGE_SIZE_256KB
> #define PAGE_SHIFT 18
> #define HEXAGON_L1_PTE_SIZE __HVM_PDE_S_256KB
> #endif
> 
> #ifdef CONFIG_PAGE_SIZE_1MB
> #define PAGE_SHIFT 20
> #define HEXAGON_L1_PTE_SIZE __HVM_PDE_S_1MB
> #endif
> .....

Good heavens.

> In my patch, I think compiler would optimize "if (20 > PAGE_SIZE)", it
> won't generate any machine instruction. Just a guarantee.

Well the existing code is a bit silly looking.  Why can't we just do

	/* round applicable memory size up to nearest megabyte */
	if (PAGE_SHIFT < 20)
		numentries = round_up(nr_kernel_pages, (1 << 20)/PAGE_SIZE);

or similar?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
