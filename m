Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4DFA6B0038
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 07:55:42 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id t94so3326936wrc.18
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 04:55:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s9sor9714205wra.14.2018.01.12.04.55.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jan 2018 04:55:41 -0800 (PST)
Date: Fri, 12 Jan 2018 13:55:38 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [REGRESSION] testing/selftests/x86/ pkeys build failures (was: Re:
 [PATCH] mm, x86: pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change signal
 semantics)
Message-ID: <20180112125537.bdl376ziiaqp664o@gmail.com>
References: <360ef254-48bc-aee6-70f9-858f773b8693@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <360ef254-48bc-aee6-70f9-858f773b8693@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, x86@kernel.org, Dave Hansen <dave.hansen@intel.com>, Ram Pai <linuxram@us.ibm.com>


* Florian Weimer <fweimer@redhat.com> wrote:

> This patch is based on the previous discussion (pkeys: Support setting
> access rights for signal handlers):
> 
>   https://marc.info/?t=151285426000001
> 
> It aligns the signal semantics of the x86 implementation with the upcoming
> POWER implementation, and defines a new flag, so that applications can
> detect which semantics the kernel uses.
> 
> A change in this area is needed to make memory protection keys usable for
> protecting the GOT in the dynamic linker.
> 
> (Feel free to replace the trigraphs in the commit message before committing,
> or to remove the program altogether.)

Could you please send patches not as MIME attachments?

Also, the protection keys testcase first need to be fixed, before we complicate 
them - for example on a pretty regular Ubuntu x86-64 installation they fail to 
build with the build errors attached further below.

On an older Fedora 23 installation, the testcases themselves don't build at all:

 fomalhaut:~/tip2/tools/testing/selftests/x86> make protection_keys
 gcc -O2 -g -std=gnu99 -pthread -Wall -no-pie    protection_keys.c   -o protection_keys
 gcc: error: unrecognized command line option a??-no-piea??
 <builtin>: recipe for target 'protection_keys' failed
 make: *** [protection_keys] Error 1

so it's one big mess at the moment that needs some love ...

Thanks,

	Ingo

==================>

triton:~/tip/tools/testing/selftests/x86> make
gcc -m32 -o /home/mingo/tip/tools/testing/selftests/x86/protection_keys_32 -O2 -g -std=gnu99 -pthread -Wall -no-pie  protection_keys.c -lrt -ldl -lm
In file included from /usr/include/signal.h:57:0,
                 from protection_keys.c:33:
protection_keys.c: In function a??signal_handlera??:
protection_keys.c:253:6: error: expected a??=a??, a??,a??, a??;a??, a??asma?? or a??__attribute__a?? before a??.a?? token
  u64 si_pkey;
      ^
protection_keys.c:253:6: error: expected expression before a??.a?? token
protection_keys.c:295:2: error: a??_sifieldsa?? undeclared (first use in this function)
  si_pkey = *si_pkey_ptr;
  ^
protection_keys.c:295:2: note: each undeclared identifier is reported only once for each function it appears in
In file included from protection_keys.c:46:0:
pkey-helpers.h: In function a??sigsafe_printfa??:
pkey-helpers.h:42:3: warning: ignoring return value of a??writea??, declared with attribute warn_unused_result [-Wunused-result]
   write(1, dprint_in_signal_buffer, len);
   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
protection_keys.c: In function a??dumpita??:
protection_keys.c:419:3: warning: ignoring return value of a??writea??, declared with attribute warn_unused_result [-Wunused-result]
   write(1, buf, nr_read);
   ^~~~~~~~~~~~~~~~~~~~~~
Makefile:47: recipe for target '/home/mingo/tip/tools/testing/selftests/x86/protection_keys_32' failed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
