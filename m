Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED8D6B0255
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 18:20:14 -0500 (EST)
Received: by pacej9 with SMTP id ej9so59271187pac.2
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:20:14 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id v13si7271830pas.84.2015.11.18.15.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 15:20:13 -0800 (PST)
Received: by pacej9 with SMTP id ej9so59270918pac.2
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:20:13 -0800 (PST)
From: Daniel Cashman <dcashman@android.com>
Subject: [PATCH v3 0/4] Allow customizable random offset to mmap_base address.
Date: Wed, 18 Nov 2015 15:20:04 -0800
Message-Id: <1447888808-31571-1-git-send-email-dcashman@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com

From: dcashman <dcashman@google.com>

Address Space Layout Randomization (ASLR) provides a barrier to exploitation of user-space processes in the presence of security vulnerabilities by making it more difficult to find desired code/data which could help an attack. This is done by adding a random offset to the location of regions in the process address space, with a greater range of potential offset values corresponding to better protection/a larger search-space for brute force, but also to greater potential for fragmentation.

The offset added to the mmap_base address, which provides the basis for the majority of the mappings for a process, is set once on process exec in arch_pick_mmap_layout() and is done via hard-coded per-arch values, which reflect, hopefully, the best compromise for all systems. The trade-off between increased entropy in the offset value generation and the corresponding increased variability in address space fragmentation is not absolute, however, and some platforms may tolerate higher amounts of entropy. This patch introduces both new Kconfig values and a sysctl interface which may be used to change the amount of entropy used for offset generation on a system.

The direct motivation for this change was in response to the libstagefright vulnerabilities that affected Android, specifically to information provided by Google's project zero at:

http://googleprojectzero.blogspot.com/2015/09/stagefrightened.html

The attack presented therein, by Google's project zero, specifically targeted the limited randomness used to generate the offset added to the mmap_base address in order to craft a brute-force-based attack. Concretely, the attack was against the mediaserver process, which was limited to respawning every 5 seconds, on an arm device. The hard-coded 8 bits used resulted in an average expected success rate of defeating the mmap ASLR after just over 10 minutes (128 tries at 5 seconds a piece). With this patch, and an accompanying increase in the entropy value to 16 bits, the same attack would take an average expected time of over 45 hours (32768 tries), which makes it both less feasible and more likely to be noticed.

The introduced Kconfig and sysctl options are limited by per-arch minimum and maximum values, the minimum of which was chosen to match the current hard-coded value and the maximum of which was chosen so as to give the greatest flexibility without generating an invalid mmap_base address, generally a 3-4 bits less than the number of bits in the user-space accessible virtual address space.

When decided whether or not to change the default value, a system developer should consider that mmap_base address could be placed anywhere up to 2^(value) bits away from the non-randomized location, which would introduce variable-sized areas above and below the mmap_base address such that the maximum vm_area_struct size may be reduced, preventing very large allocations.

Changes in v3:
* moved sysctl from /proc/sys/kernel to /proc/sys/vm
* added to arch/x86 (both 32 and 64 bit)
* added to arch/arm64
* added ability for arch to specify default value in between max - min

dcashman (4):
  mm: mmap: Add new /proc tunable for mmap_base ASLR.
  arm: mm: support ARCH_MMAP_RND_BITS.
  arm64: mm: support ARCH_MMAP_RND_BITS.
  x86: mm: support ARCH_MMAP_RND_BITS.

 Documentation/sysctl/vm.txt | 29 ++++++++++++++++++++
 arch/Kconfig                | 64 +++++++++++++++++++++++++++++++++++++++++++++
 arch/arm/Kconfig            | 10 +++++++
 arch/arm/mm/mmap.c          |  3 +--
 arch/arm64/Kconfig          | 23 ++++++++++++++++
 arch/arm64/mm/mmap.c        |  6 +++--
 arch/x86/Kconfig            | 16 ++++++++++++
 arch/x86/mm/mmap.c          | 12 ++++-----
 include/linux/mm.h          | 11 ++++++++
 kernel/sysctl.c             | 22 ++++++++++++++++
 mm/mmap.c                   | 12 +++++++++
 11 files changed, 198 insertions(+), 10 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
