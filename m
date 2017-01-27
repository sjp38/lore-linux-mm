Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B10096B0033
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 03:16:58 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p192so50427764wme.1
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 00:16:58 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id v30si4962873wra.229.2017.01.27.00.16.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 00:16:57 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id r144so56459098wme.0
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 00:16:57 -0800 (PST)
Date: Fri, 27 Jan 2017 09:16:54 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC][PATCH 0/4] x86, mpx: Support larger address space (MAWA)
Message-ID: <20170127081654.GA25162@gmail.com>
References: <20170126224005.A6BBEF2C@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170126224005.A6BBEF2C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> Kirill is chugging right along getting his 5-level paging[1] patch set
> ready to be merged.  I figured I'd share an early draft of the MPX
> support that will to go along with it.
> 
> Background: there is a lot more detail about what bounds tables are in
> the changelog for fe3d197f843.  But, basically MPX bounds tables help
> us to store the ranges to which a pointer is allowed to point.  The
> tables are walked by hardware and they are indexed by the virtual
> address of the pointer being checked.
> 
> A larger virtual address space (from 5-level paging) means that we
> need larger tables.  5-level paging hardware includes a feature called
> MPX Address-Width Adjust (MAWA) that grows the bounds tables so they
> can address the new address space.  MAWA is controlled independently
> from the paging mode (via an MSR) so that old MPX binaries can run on
> new hardware and kernels supporting 5-level paging.
> 
> But, since userspace is responsible for allocating the table that is
> growing (the directory), we need to ensure that userspace and the
> kernel agree about the size of these tables and the kernel can set the
> MSR appropriately.
> 
> These are not quite ready to get applied anywhere, but I don't expect
> the basics to change unless folks have big problems with this.  The
> only big remaining piece of work is to update the MPX selftest code.
> 
> Dave Hansen (4):
>       x86, mpx: introduce per-mm MPX table size tracking
>       x86, mpx: update MPX to grok larger bounds tables
>       x86, mpx: extend MPX prctl() to pass in size of bounds directory
>       x86, mpx: context-switch new MPX address size MSR

On a related note, the MPX testcases seem to have gone from the 
tools/testing/selftests/x86/Makefile (possibly a merge mishap - the original 
commit adds it correctly), so they are not being built.

Plus I noticed that the pkeys testcases are producing a lot of noise:

triton:~/tip/tools/testing/selftests/x86> make
[...]
gcc -m64 -o protection_keys_64 -O2 -g -std=gnu99 -pthread -Wall  protection_keys.c -lrt -ldl
protection_keys.c: In function a??setup_hugetlbfsa??:
protection_keys.c:816:6: warning: unused variable a??ia?? [-Wunused-variable]
  int i;
      ^
protection_keys.c:815:6: warning: unused variable a??validated_nr_pagesa?? [-Wunused-variable]
  int validated_nr_pages;
      ^
protection_keys.c: In function a??test_pkey_syscalls_bad_argsa??:
protection_keys.c:1136:6: warning: unused variable a??bad_flaga?? [-Wunused-variable]
  int bad_flag = (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE) + 1;
      ^
protection_keys.c: In function a??test_pkey_alloc_exhausta??:
protection_keys.c:1153:16: warning: unused variable a??init_vala?? [-Wunused-variable]
  unsigned long init_val;
                ^
protection_keys.c:1152:16: warning: unused variable a??flagsa?? [-Wunused-variable]
  unsigned long flags;
                ^
In file included from protection_keys.c:45:0:
pkey-helpers.h: In function a??sigsafe_printfa??:
pkey-helpers.h:41:3: warning: ignoring return value of a??writea??, declared with attribute warn_unused_result [-Wunused-result]
   write(1, dprint_in_signal_buffer, len);
   ^
protection_keys.c: In function a??dumpita??:
protection_keys.c:407:3: warning: ignoring return value of a??writea??, declared with attribute warn_unused_result [-Wunused-result]
   write(1, buf, nr_read);
   ^
protection_keys.c: In function a??pkey_disable_seta??:
protection_keys.c:68:5: warning: a??orig_pkrua?? may be used uninitialized in this function [-Wmaybe-uninitialized]
  if (!(condition)) {   \
     ^
protection_keys.c:465:6: note: a??orig_pkrua?? was declared here
  u32 orig_pkru;
      ^
[...]

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
