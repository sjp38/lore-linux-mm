Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2790D6B000A
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:29:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t185-v6so2400422wmt.8
        for <linux-mm@kvack.org>; Mon, 14 May 2018 01:29:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w77-v6sor3846307wrb.67.2018.05.14.01.29.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 May 2018 01:29:21 -0700 (PDT)
Date: Mon, 14 May 2018 10:29:18 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/13] [v4] x86, pkeys: two protection keys bug fixes
Message-ID: <20180514082918.GA21574@gmail.com>
References: <20180509171336.76636D88@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180509171336.76636D88@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, akpm@linux-foundation.org, shuah@kernel.org, shakeelb@google.com


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> Hi x86 maintainers,
> 
> This set has been seen quite a few changes and additions since the
> last post.  Details below.
> 
> Changes from v3:
>  * Reordered patches following Ingo's recommendations: Introduce
>    failing selftests first, then the kernel code to fix the test
>    failure.
>  * Increase verbosity and accuracy of do_not_expect_pk_fault()
>    messages.
>  * Removed abort() use from tests.  Crashing is not nice.
>  * Remove some dead debugging code, fixing dprint_in_signal.
>  * Fix deadlocks from using printf() and friends in signal
>    handlers.
> 
> Changes from v2:
>  * Clarified commit message in patch 1/9 taking some feedback from
>    Shuah.
> 
> Changes from v1:
>  * Added Fixes: and cc'd stable.  No code changes.
> 
> --
> 
> This fixes two bugs, and adds selftests to make sure they stay fixed:
> 
> 1. pkey 0 was not usable via mprotect_pkey() because it had never
>    been explicitly allocated.
> 2. mprotect(PROT_EXEC) memory could sometimes be left with the
>    implicit exec-only protection key assigned.
> 
> I already posted #1 previously.  I'm including them both here because
> I don't think it's been picked up in case folks want to pull these
> all in a single bundle.
> 
> Dave Hansen (13):
>       x86/pkeys/selftests: give better unexpected fault error messages
>       x86/pkeys/selftests: Stop using assert()
>       x86/pkeys/selftests: remove dead debugging code, fix dprint_in_signal
>       x86/pkeys/selftests: avoid printf-in-signal deadlocks
>       x86/pkeys/selftests: Allow faults on unknown keys
>       x86/pkeys/selftests: Factor out "instruction page"
>       x86/pkeys/selftests: Add PROT_EXEC test
>       x86/pkeys/selftests: Fix pkey exhaustion test off-by-one
>       x86/pkeys: Override pkey when moving away from PROT_EXEC
>       x86/pkeys/selftests: Fix pointer math
>       x86/pkeys/selftests: Save off 'prot' for allocations
>       x86/pkeys/selftests: Add a test for pkey 0
>       x86/pkeys: Do not special case protection key 0
> 
>  arch/x86/include/asm/mmu_context.h            |   2 +-
>  arch/x86/include/asm/pkeys.h                  |  18 +-
>  arch/x86/mm/pkeys.c                           |  21 +-
>  tools/testing/selftests/x86/pkey-helpers.h    |  20 +-
>  tools/testing/selftests/x86/protection_keys.c | 187 +++++++++++++-----
>  5 files changed, 173 insertions(+), 75 deletions(-)

So this series is looking good to me in principle, but trying to build it I got 
warnings and errors - see the build log below.

Note that this is on a box with "Ubuntu 18.04 LTS (Bionic Beaver)".

Thanks,

	Ingo

================>

gcc -m32 -o /home/mingo/tip/tools/testing/selftests/x86/protection_keys_32 -O2 -g -std=gnu99 -pthread -Wall -no-pie -DCAN_BUILD_32 -DCAN_BUILD_64 protection_keys.c -lrt -ldl -lm
protection_keys.c:232:0: warning: "SEGV_BNDERR" redefined
 #define SEGV_BNDERR     3  /* failed address bound checks */
 
In file included from /usr/include/signal.h:58:0,
                 from protection_keys.c:33:
/usr/include/bits/siginfo-consts.h:117:0: note: this is the location of the previous definition
 #  define SEGV_BNDERR SEGV_BNDERR
 
protection_keys.c:233:0: warning: "SEGV_PKUERR" redefined
 #define SEGV_PKUERR     4
 
In file included from /usr/include/signal.h:58:0,
                 from protection_keys.c:33:
/usr/include/bits/siginfo-consts.h:119:0: note: this is the location of the previous definition
 #  define SEGV_PKUERR SEGV_PKUERR
 
protection_keys.c:387:5: error: conflicting types for a??pkey_geta??
 u32 pkey_get(int pkey, unsigned long flags)
     ^~~~~~~~
In file included from /usr/include/bits/mman-linux.h:115:0,
                 from /usr/include/bits/mman.h:45,
                 from /usr/include/sys/mman.h:41,
                 from protection_keys.c:37:
/usr/include/bits/mman-shared.h:64:5: note: previous declaration of a??pkey_geta?? was here
 int pkey_get (int __key) __THROW;
     ^~~~~~~~
protection_keys.c:409:5: error: conflicting types for a??pkey_seta??
 int pkey_set(int pkey, unsigned long rights, unsigned long flags)
     ^~~~~~~~
In file included from /usr/include/bits/mman-linux.h:115:0,
                 from /usr/include/bits/mman.h:45,
                 from /usr/include/sys/mman.h:41,
                 from protection_keys.c:37:
/usr/include/bits/mman-shared.h:60:5: note: previous declaration of a??pkey_seta?? was here
 int pkey_set (int __key, unsigned int __access_rights) __THROW;
     ^~~~~~~~
Makefile:67: recipe for target '/home/mingo/tip/tools/testing/selftests/x86/protection_keys_32' failed
make: *** [/home/mingo/tip/tools/testing/selftests/x86/protection_keys_32] Error 1
