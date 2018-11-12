Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7114B6B0282
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 07:29:10 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id k195so2350040wmd.0
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 04:29:10 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id l3si13607101wrx.95.2018.11.12.04.29.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 04:29:08 -0800 (PST)
MIME-Version: 1.0
Message-ID: <trinity-8a113065-6ab9-43cb-b48b-d55f8aee1751-1542025747660@msvc-mesg-gmx021>
From: "Qian Cai" <cai@gmx.us>
Subject: Re: crashkernel=512M is no longer working on this aarch64 server
Content-Type: text/plain; charset=UTF-8
Date: Mon, 12 Nov 2018 13:29:07 +0100
In-Reply-To: <20181112070151.51ea5caf@mschwideX1>
References: <1A7E2E89-34DB-41A0-BBA2-323073A7E298@gmx.us>
 <20181111123553.3a35a15c@mschwideX1>
 <77E3BE32-F509-43B3-8C5F-252416C04B7C@gmx.us>
 <20181112070151.51ea5caf@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, linux
 kernel <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 11/12/18 at 1:01 AM, Martin Schwidefsky wrote:

> On Sun, 11 Nov 2018 08:36:09 -0500
> Qian Cai <cai@gmx.us> wrote:
> 
> > > On Nov 11, 2018, at 6:35 AM, Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
> > > 
> > > On Sat, 10 Nov 2018 23:41:34 -0500
> > > Qian Cai <cai@gmx.us> wrote:
> > >   
> > >> It was broken somewhere between b00d209241ff and 3541833fd1f2.
> > >> 
> > >> [    0.000000] cannot allocate crashkernel (size:0x20000000)
> > >> 
> > >> Where a good one looks like this,
> > >> 
> > >> [    0.000000] crashkernel reserved: 0x0000000008600000 - 0x0000000028600000 (512 MB)
> > >> 
> > >> Some commits look more suspicious than others.
> > >> 
> > >>      mm: add mm_pxd_folded checks to pgtable_bytes accounting functions
> > >>      mm: introduce mm_[p4d|pud|pmd]_folded
> > >>      mm: make the __PAGETABLE_PxD_FOLDED defines non-empty  
> > > 
> > > The intent of these three patches is to add extra checks to the
> > > pgtable_bytes accounting function. If applied incorrectly the expected
> > > result would be warnings like this:
> > >  BUG: non-zero pgtables_bytes on freeing mm: 16384
> > > 
> > > The change Linus worried about affects the __PAGETABLE_PxD_FOLDED defines.
> > > These defines are used with #ifdef, #ifndef, and __is_defined() for the
> > > new mm_p?d_folded() macros. I can not see how this would make a difference
> > > for your iomem setup.
> > >   
> > >> # diff -u ../iomem.good.txt ../iomem.bad.txt 
> > >> --- ../iomem.good.txt	2018-11-10 22:28:20.092614398 -0500
> > >> +++ ../iomem.bad.txt	2018-11-10 20:39:54.930294479 -0500
> > >> @@ -1,9 +1,8 @@
> > >> 00000000-3965ffff : System RAM
> > >>   00080000-018cffff : Kernel code
> > >> -  018d0000-020affff : reserved
> > >> -  020b0000-045affff : Kernel data
> > >> -  08600000-285fffff : Crash kernel
> > >> -  28730000-2d5affff : reserved
> > >> +  018d0000-0762ffff : reserved
> > >> +  07630000-09b2ffff : Kernel data
> > >> +  231b0000-2802ffff : reserved
> > >>   30ec0000-30ecffff : reserved
> > >>   35660000-3965ffff : reserved
> > >> 39660000-396fffff : reserved
> > >> @@ -127,7 +126,7 @@
> > >>   7c5200000-7c520ffff : 0004:48:00.0
> > >> 1040000000-17fbffffff : System RAM
> > >>   13fbfd0000-13fdfdffff : reserved
> > >> -  16fba80000-17fbfdffff : reserved
> > >> +  16fafd0000-17fbfdffff : reserved
> > >>   17fbfe0000-17fbffffff : reserved
> > >> 1800000000-1ffbffffff : System RAM
> > >>   1bfbff0000-1bfdfeffff : reserved  
> > > 
> > > The easiest way to verify if the three commits have something to do with your
> > > problem is to revert them and run your test. Can you do that please ?  
> > Yes, you are right. Those commits have nothing to do with the problem. I should
> > realized it earlier as those are virtual memory vs physical memory. Sorry for the
> > nosie.
> > 
> > It turned out I made a wrong assumption that if kmemleak is disabled by default,
> > there should be no memory reserved for kmemleak at all which is not the case.
> > 
> > CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=600000
> > CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF=y
> > 
> > Even without kmemleak=on in the kernel cmdline, it still reserve early log memory
> > which causes not enough memory for crashkernel.
> > 
> > Since there seems no way to turn kmemleak on later after boot, is there any
> > reasons for the current behavior? 
> 
> Well seems like you do have CONFIG_DEBUG_KMEMLEAK=y in your config. The code
> contains data structures for the case that you want to use the kmemleak checker.
> The presence of these structures will change the sizes. The last commit in regard
> to the 'early_log' buffer has been from 2009 with this change:
> 
> @@ -232,8 +232,9 @@ struct early_log {
>  };
>  
>  /* early logging buffer and current position */
> -static struct early_log early_log[CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE];
> -static int crt_early_log;
> +static struct early_log
> +       early_log[CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE] __initdata;
> +static int crt_early_log __initdata;
>  
>  static void kmemleak_disable(void);
>  
> The current behavior is imho nothing new.
> 
> Would it be possible to disable CONFIG_DEBUG_KMEMLEAK for your kdump kernel?
> That seems like the simplest solution.
Ah, okay. Those are static memory allocations 
regardless of the kmemleak runtime setting.

The problem is that it has to disable kmemleak entirely 
and re-compile the kernel for the first-kernel as well, 
as crashkernel reservation happens in the first-kernel.

Hence, it loses flexibility to enable kmemleak during
boot time as well. I can live with it, although it does
not seem ideal.
