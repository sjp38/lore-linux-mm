Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B1D016B426A
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 10:36:21 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s27so8037605pgm.4
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 07:36:21 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l5si656390plt.5.2018.11.26.07.36.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 07:36:19 -0800 (PST)
Date: Mon, 26 Nov 2018 16:36:12 +0100
From: Jessica Yu <jeyu@kernel.org>
Subject: Re: [PATCH v9 RESEND 0/4] KASLR feature to randomize each loadable
 module
Message-ID: <20181126153611.GA17169@linux-8ccs>
References: <20181120232312.30037-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181120232312.30037-1-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org, kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com

+++ Rick Edgecombe [20/11/18 15:23 -0800]:
>Resending this because I missed Jessica in the "to" list. Also removing the part
>of this coverletter that talked about KPTI helping with some local kernel text
>de-randomizing methods, because I'm not sure I fully understand this.
>
>------------------------------------------------------------
>
>This is V9 of the "KASLR feature to randomize each loadable module" patchset.
>The purpose is to increase the randomization for the module space from 10 to 17
>bits, and also to make the modules randomized in relation to each other instead
>of just the address where the allocations begin, so that if one module leaks the
>location of the others can't be inferred.
>
>Why its useful
>==============
>Randomizing the location of executable code is a defense against control flow
>attacks, where the kernel is tricked into jumping, or speculatively executing
>code other than what is intended. By randomizing the location of the code, the
>attacker doesn't know where to redirect the control flow.
>
>Today the RANDOMIZE_BASE feature randomizes the base address where the module
>allocations begin with 10 bits of entropy for this purpose. From here, a highly
>deterministic algorithm allocates space for the modules as they are loaded and
>unloaded. If an attacker can predict the order and identities for modules that
>will be loaded (either by the system, or controlled by the user with
>request_module or BPF), then a single text address leak can give the attacker
>access to the locations of other modules. So in this case this new algorithm can
>take the entropy of the other modules from ~0 to 17, making it much more robust.
>
>Another problem today is that the low 10 bits of entropy makes brute force
>attacks feasible, especially in the case of speculative execution where a wrong
>guess won't necessarily cause a crash. In this case, increasing the
>randomization will force attacks to take longer, and so increase the time an
>attacker may be detected on a system.
>
>There are multiple efforts to apply more randomization to the core kernel text
>as well, and so this module space piece can be a first step to increasing
>randomization for all kernel space executable code.
>
>Userspace ASLR can get 28 bits of entropy or more, so at least increasing this
>to 17 for now improves what is currently a pretty low amount of randomization
>for the higher privileged kernel space.
>
>How it works
>============
>The algorithm is pretty simple. It just breaks the module space in two, a random
>area (2/3 of module space) and a backup area (1/3 of module space). It first
>tries to allocate up to 10000 randomly located starting pages inside the random
>section. If this fails, it will allocate in the backup area. The backup area
>base will be offset in the same way as current algorithm does for the base area,
>which has 10 bits of entropy.
>
>The vmalloc allocator can be used to try an allocation at a specific address,
>however it is usually used to try an allocation over a large address range, and
>so some behaviors which are non-issues in normal usage can be be sub-optimal
>when trying the an allocation at 10000 small ranges. So this patch also includes
>a new vmalloc function __vmalloc_node_try_addr and some other vmalloc tweaks
>that allow for more efficient trying of addresses.
>
>This algorithm targets maintaining high entropy for many 1000's of module
>allocations. This is because there are other users of the module space besides
>kernel modules, like eBPF JIT, classic BPF socket filter JIT and kprobes.

Hi Rick!

Sorry for the delay. I'd like to take a step back and ask some broader questions -

- Is the end goal of this patchset to randomize loading kernel modules, or most/all
   executable kernel memory allocations, including bpf, kprobes, etc?

- It seems that a lot of complexity and heuristics are introduced just to
   accommodate the potential fragmentation that can happen when the module vmalloc
   space starts to get fragmented with bpf filters. I'm partial to the idea of
   splitting or having bpf own its own vmalloc space, similar to what Ard is already
   implementing for arm64.

   So a question for the bpf and x86 folks, is having a dedicated vmalloc region
   (as well as a seperate bpf_alloc api) for bpf feasible or desirable on x86_64?

   If bpf filters need to be within 2 GB of the core kernel, would it make sense
   to carve out a portion of the current module region for bpf filters?  According
   to Documentation/x86/x86_64/mm.txt, the module region is ~1.5 GB. I am doubtful
   that any real system will actually have 1.5 GB worth of kernel modules loaded.
   Is there a specific reason why that much space is dedicated to kernel modules,
   and would it be feasible to split that region cleanly with bpf?

- If bpf gets its own dedicated vmalloc space, and we stick to the single task
   of randomizing *just* kernel modules, could the vmalloc optimizations and the
   "backup" area be dropped? The benefits of the vmalloc optimizations seem to
   only be noticeable when we get to thousands of module_alloc allocations -
   again, a concern caused by bpf filters sharing the same space with kernel
   modules.

   So tldr, it seems to me that the concern of fragmentation, the vmalloc
   optimizations, and the main purpose of the backup area - basically, the more
   complex parts of this patchset - stems squarely from the fact that bpf filters
   share the same space as modules on x86. If we were to focus on randomizing
   *just* kernel modules, and if bpf and modules had their own dedicated regions,
   then I *think* the concrete use cases for the backup area and the vmalloc
   optimizations (if we're strictly considering just kernel modules) would
   mostly disappear (please correct me if I'm in the wrong here). Then tackling the
   randomization of bpf allocations could potentially be a separate task on its own.

Thanks!

Jessica

>Performance
>===========
>Simulations were run using module sizes derived from the x86_64 modules to
>measure the allocation performance at various levels of fragmentation and
>whether the backup area was used.
>
>Capacity
>--------
>There is a slight reduction in the capacity of modules as simulated by the
>x86_64 module sizes of <1000. Note this is a worst case, since in practice
>module allocations in the 1000's will consist of smaller BPF JIT allocations or
>kprobes which would fit better in the random area.
>
>Allocation time
>---------------
>Below are three sets of measurements in ns of the allocation time as measured by
>the included kselftests. The first two columns are this new algorithm with and
>with out the vmalloc optimizations for trying random addresses quickly. They are
>included for consideration of whether the changes are worth it. The last column
>is the performance of the original algorithm.
>
>Modules Vmalloc optimization    No Vmalloc Optimization Existing Module KASLR
>1000    1433                    1993                    3821
>2000    2295                    3681                    7830
>3000    4424                    7450                    13012
>4000    7746                    13824                   18106
>5000    12721                   21852                   22572
>6000    19724                   33926                   26443
>7000    27638                   47427                   30473
>8000    37745                   64443                   34200
>
>These allocations are not taking very long, but it may show up on systems with
>very high usage of the module space (BPF JITs). If the trade-off of touching
>vmalloc doesn't seem worth it to people, I can remove the optimizations.
>
>Randomness
>----------
>Unlike the existing algorithm, the amount of randomness provided has a
>dependency on the number of modules allocated and the sizes of the modules text
>sections. The entropy provided for the Nth allocation will come from three
>sources of randomness, the range of addresses for the random area, the
>probability the section will be allocated in the backup area and randomness from
>the number of modules already allocated in the backup area. For computing a
>lower bound entropy in the following calculations, the randomness of the modules
>already in the backup area, or overlapping from the random area, is ignored
>since it is usually small and will only increase the entropy. Below is an
>attempt to compute a worst case value for entropy to compare to the existing
>algorithm.
>
>For probability of the Nth allocation being in the backup area, p, a lower bound
>entropy estimate is calculated here as:
>
>Random Area Slots = ((2/3)*1073741824)/4096 = 174762
>
>Entropy = -( (1-p)*log2((1-p)/174762) + p*log2(p/1024) )
>
>For >8000 modules the entropy remains above 17.3. For non-speculative control
>flow attacks, an attack might crash the system. So the probability of the
>first guess being right can be more important than the Nth guess. KASLR schemes
>usually have equal probability for each possible position, but in this scheme
>that is not the case. So a more conservative comparison to existing schemes is
>the amount of information that would have to be guessed correctly for the
>position that has the highest probability for having the Nth module allocated
>(as that would be the attackers best guess):
>
>Min Info = MIN(-log2(p/1024), -log2((1-p)/174762))
>
>Allocations     Entropy
>1000            17.4
>2000            17.4
>3000            17.4
>4000            16.8
>5000            15.8
>6000            14.9
>7000            14.8
>8000            14.2
>
>If anyone is keeping track, these numbers are different than as reported in V2,
>because they are generated using the more compact allocation size heuristic that
>is included in the kselftest rather than the real much larger dataset. The
>heuristic generates randomization benchmarks that are slightly slower than the
>real dataset. The real dataset also isn't representative of the case of mostly
>smaller BPF filters, so it represents a worst case lower bound for entropy and
>in practice 17+ bits should be maintained to much higher number of modules.
>
>PTE usage
>---------
>Since the allocations are spread out over a wider address space, there is
>increased PTE usage which should not exceed 1.3MB more than the old algorithm.
>
>
>Changes for V9:
> - Better explanations in commit messages, instructions in kselftests (Andrew
>   Morton)
>
>Changes for V8:
> - Simplify code by removing logic for optimum handling of lazy free areas
>
>Changes for V7:
> - More 0-day build fixes, readability improvements (Kees Cook)
>
>Changes for V6:
> - 0-day build fixes by removing un-needed functional testing, more error
>   handling
>
>Changes for V5:
> - Add module_alloc test module
>
>Changes for V4:
> - Fix issue caused by KASAN, kmemleak being provided different allocation
>   lengths (padding).
> - Avoid kmalloc until sure its needed in __vmalloc_node_try_addr.
> - Fixed issues reported by 0-day.
>
>Changes for V3:
> - Code cleanup based on internal feedback. (thanks to Dave Hansen and Andriy
>   Shevchenko)
> - Slight refactor of existing algorithm to more cleanly live along side new
>   one.
> - BPF synthetic benchmark
>
>Changes for V2:
> - New implementation of __vmalloc_node_try_addr based on the
>   __vmalloc_node_range implementation, that only flushes TLB when needed.
> - Modified module loading algorithm to try to reduce the TLB flushes further.
> - Increase "random area" tries in order to increase the number of modules that
>   can get high randomness.
> - Increase "random area" size to 2/3 of module area in order to increase the
>   number of modules that can get high randomness.
> - Fix for 0day failures on other architectures.
> - Fix for wrong debugfs permissions. (thanks to Jann Horn)
> - Spelling fix. (thanks to Jann Horn)
> - Data on module_alloc performance and TLB flushes. (brought up by Kees Cook
>   and Jann Horn)
> - Data on memory usage. (suggested by Jann)
>
>
>Rick Edgecombe (4):
>  vmalloc: Add __vmalloc_node_try_addr function
>  x86/modules: Increase randomization for modules
>  vmalloc: Add debugfs modfraginfo
>  Kselftest for module text allocation benchmarking
>
> arch/x86/Kconfig                              |   3 +
> arch/x86/include/asm/kaslr_modules.h          |  38 ++
> arch/x86/include/asm/pgtable_64_types.h       |   7 +
> arch/x86/kernel/module.c                      | 111 ++++--
> include/linux/vmalloc.h                       |   3 +
> lib/Kconfig.debug                             |   9 +
> lib/Makefile                                  |   1 +
> lib/test_mod_alloc.c                          | 375 ++++++++++++++++++
> mm/vmalloc.c                                  | 228 +++++++++--
> tools/testing/selftests/bpf/test_mod_alloc.sh |  29 ++
> 10 files changed, 743 insertions(+), 61 deletions(-)
> create mode 100644 arch/x86/include/asm/kaslr_modules.h
> create mode 100644 lib/test_mod_alloc.c
> create mode 100755 tools/testing/selftests/bpf/test_mod_alloc.sh
>
>-- 
>2.17.1
>
