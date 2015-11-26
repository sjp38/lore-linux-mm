Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF566B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 18:24:25 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so99484663pab.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 15:24:25 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id ul5si6156423pab.201.2015.11.26.15.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 15:24:24 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so96518992pac.3
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 15:24:24 -0800 (PST)
Subject: Re: [PATCH v4 0/4] Allow customizable random offset to mmap_base
 address.
References: <1448578785-17656-1-git-send-email-dcashman@android.com>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <565794A2.8050304@android.com>
Date: Thu, 26 Nov 2015 15:24:18 -0800
MIME-Version: 1.0
In-Reply-To: <1448578785-17656-1-git-send-email-dcashman@android.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com

On 11/26/15 2:59 PM, Daniel Cashman wrote:
> Address Space Layout Randomization (ASLR) provides a barrier to exploitation of user-space processes in the presence of security vulnerabilities by making it more difficult to find desired code/data which could help an attack. This is done by adding a random offset to the location of regions in the process address space, with a greater range of potential offset values corresponding to better protection/a larger search-space for brute force, but also to greater potential for fragmentation.
> 
> The offset added to the mmap_base address, which provides the basis for the majority of the mappings for a process, is set once on process exec in arch_pick_mmap_layout() and is done via hard-coded per-arch values, which reflect, hopefully, the best compromise for all systems. The trade-off between increased entropy in the offset value generation and the corresponding increased variability in address space fragmentation is not absolute, however, and some platforms may tolerate higher amounts of entropy. This patch introduces both new Kconfig values and a sysctl interface which may be used to change the amount of entropy used for offset generation on a system.
> 
> The direct motivation for this change was in response to the libstagefright vulnerabilities that affected Android, specifically to information provided by Google's project zero at:
> 
> http://googleprojectzero.blogspot.com/2015/09/stagefrightened.html
> 
> The attack presented therein, by Google's project zero, specifically targeted the limited randomness used to generate the offset added to the mmap_base address in order to craft a brute-force-based attack. Concretely, the attack was against the mediaserver process, which was limited to respawning every 5 seconds, on an arm device. The hard-coded 8 bits used resulted in an average expected success rate of defeating the mmap ASLR after just over 10 minutes (128 tries at 5 seconds a piece). With this patch, and an accompanying increase in the entropy value to 16 bits, the same attack would take an average expected time of over 45 hours (32768 tries), which makes it both less feasible and more likely to be noticed.
> 
> The introduced Kconfig and sysctl options are limited by per-arch minimum and maximum values, the minimum of which was chosen to match the current hard-coded value and the maximum of which was chosen so as to give the greatest flexibility without generating an invalid mmap_base address, generally a 3-4 bits less than the number of bits in the user-space accessible virtual address space.
> 
> When decided whether or not to change the default value, a system developer should consider that mmap_base address could be placed anywhere up to 2^(value) bits away from the non-randomized location, which would introduce variable-sized areas above and below the mmap_base address such that the maximum vm_area_struct size may be reduced, preventing very large allocations.
> 
> Changes in v4:
> [all]
> * changed signed-off to dcashman@android.com from dcashman@google.com
> 
> [1/4]
> * mark min/max variables as 'const'
> * mark rnd_bits variables as '__read_mostly'
> * add default option for compat other than min
> * change docs to /proc/sys/vm from /proc/sys/vm
> * change procfs perms to 600
> 
> [3/4]
> * added arm64 ifdef COMPAT to avoid compilation error
> * added values for arm64 16k pages
> * changed arm64 config ARCH_VA_BITS to ARM64_VA_BITS
> * added 36 and 47 ARM64_VA_BITS defaults
> 
> not (yet) addressed:
> * changing config/procfs value to be page-size agnostic
> * changing makefile to avoid complicated config defaults
> * removing unsupported arm64 page and VA_BITS combos
> * mips, powerpc, s390
> 
> dcashman (4):
>   mm: mmap: Add new /proc tunable for mmap_base ASLR.
>   arm: mm: support ARCH_MMAP_RND_BITS.
>   arm64: mm: support ARCH_MMAP_RND_BITS.
>   x86: mm: support ARCH_MMAP_RND_BITS.
> 
>  Documentation/sysctl/vm.txt | 29 +++++++++++++++++++
>  arch/Kconfig                | 68 +++++++++++++++++++++++++++++++++++++++++++++
>  arch/arm/Kconfig            | 10 +++++++
>  arch/arm/mm/mmap.c          |  3 +-
>  arch/arm64/Kconfig          | 31 +++++++++++++++++++++
>  arch/arm64/mm/mmap.c        |  8 ++++--
>  arch/x86/Kconfig            | 16 +++++++++++
>  arch/x86/mm/mmap.c          | 12 ++++----
>  include/linux/mm.h          | 11 ++++++++
>  kernel/sysctl.c             | 22 +++++++++++++++
>  mm/mmap.c                   | 12 ++++++++
>  11 files changed, 212 insertions(+), 10 deletions(-)

A disclaimer: I posted this quickly to address breakage in linux-next
for arm64 w/out COMPAT, but won't be able to test until Monday.

Thank You,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
