Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id CD0676B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 17:39:22 -0500 (EST)
Received: by ioc74 with SMTP id 74so26273431ioc.2
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 14:39:22 -0800 (PST)
Received: from mail-io0-x231.google.com (mail-io0-x231.google.com. [2607:f8b0:4001:c06::231])
        by mx.google.com with ESMTPS id q6si14666431igr.92.2015.12.01.14.39.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 14:39:22 -0800 (PST)
Received: by iofh3 with SMTP id h3so26415333iof.3
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 14:39:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1449000658-11475-1-git-send-email-dcashman@android.com>
References: <1449000658-11475-1-git-send-email-dcashman@android.com>
Date: Tue, 1 Dec 2015 14:39:21 -0800
Message-ID: <CAGXu5jLLm-ivTssMDJAEJHQYKTm_93KBmZ-KCNDrQM6s-9Znww@mail.gmail.com>
Subject: Re: [PATCH v5 0/4] Allow customizable random offset to mmap_base address.
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Hector Marco <hecmargi@upv.es>, Borislav Petkov <bp@suse.de>, Daniel Cashman <dcashman@google.com>, Arnd Bergmann <arnd@arndb.de>

On Tue, Dec 1, 2015 at 12:10 PM, Daniel Cashman <dcashman@android.com> wrot=
e:
> Address Space Layout Randomization (ASLR) provides a barrier to exploitat=
ion of user-space processes in the presence of security vulnerabilities by =
making it more difficult to find desired code/data which could help an atta=
ck. This is done by adding a random offset to the location of regions in th=
e process address space, with a greater range of potential offset values co=
rresponding to better protection/a larger search-space for brute force, but=
 also to greater potential for fragmentation.
>
> The offset added to the mmap_base address, which provides the basis for t=
he majority of the mappings for a process, is set once on process exec in a=
rch_pick_mmap_layout() and is done via hard-coded per-arch values, which re=
flect, hopefully, the best compromise for all systems. The trade-off betwee=
n increased entropy in the offset value generation and the corresponding in=
creased variability in address space fragmentation is not absolute, however=
, and some platforms may tolerate higher amounts of entropy. This patch int=
roduces both new Kconfig values and a sysctl interface which may be used to=
 change the amount of entropy used for offset generation on a system.
>
> The direct motivation for this change was in response to the libstagefrig=
ht vulnerabilities that affected Android, specifically to information provi=
ded by Google's project zero at:
>
> http://googleprojectzero.blogspot.com/2015/09/stagefrightened.html
>
> The attack presented therein, by Google's project zero, specifically targ=
eted the limited randomness used to generate the offset added to the mmap_b=
ase address in order to craft a brute-force-based attack. Concretely, the a=
ttack was against the mediaserver process, which was limited to respawning =
every 5 seconds, on an arm device. The hard-coded 8 bits used resulted in a=
n average expected success rate of defeating the mmap ASLR after just over =
10 minutes (128 tries at 5 seconds a piece). With this patch, and an accomp=
anying increase in the entropy value to 16 bits, the same attack would take=
 an average expected time of over 45 hours (32768 tries), which makes it bo=
th less feasible and more likely to be noticed.
>
> The introduced Kconfig and sysctl options are limited by per-arch minimum=
 and maximum values, the minimum of which was chosen to match the current h=
ard-coded value and the maximum of which was chosen so as to give the great=
est flexibility without generating an invalid mmap_base address, generally =
a 3-4 bits less than the number of bits in the user-space accessible virtua=
l address space.
>
> When decided whether or not to change the default value, a system develop=
er should consider that mmap_base address could be placed anywhere up to 2^=
(value) bits away from the non-randomized location, which would introduce v=
ariable-sized areas above and below the mmap_base address such that the max=
imum vm_area_struct size may be reduced, preventing very large allocations.
>
> Changes in v5:
> * Changed all Kconfig selection to depend on MMU config.
>   - inspired by Arnd Bermann patch: "ARM kernels with MMU disabled fail t=
o build because of CONFIG_ARCH_MMAP_RND_BITS:"
> * removed void casts for sysctl ctl_table entries
>   - depends on Andrew Morton patch: "include/linux/sysctl.h: make ctl_tab=
le.extra1/2 const"
>
> dcashman (4):
>   mm: mmap: Add new /proc tunable for mmap_base ASLR.
>   arm: mm: support ARCH_MMAP_RND_BITS.
>   arm64: mm: support ARCH_MMAP_RND_BITS.
>   x86: mm: support ARCH_MMAP_RND_BITS.
>
>  Documentation/sysctl/vm.txt | 29 +++++++++++++++++++
>  arch/Kconfig                | 68 +++++++++++++++++++++++++++++++++++++++=
++++++
>  arch/arm/Kconfig            |  9 ++++++
>  arch/arm/mm/mmap.c          |  3 +-
>  arch/arm64/Kconfig          | 31 +++++++++++++++++++++
>  arch/arm64/mm/mmap.c        |  8 ++++--
>  arch/x86/Kconfig            | 16 +++++++++++
>  arch/x86/mm/mmap.c          | 12 ++++----
>  include/linux/mm.h          | 11 ++++++++
>  kernel/sysctl.c             | 22 +++++++++++++++
>  mm/mmap.c                   | 12 ++++++++
>  11 files changed, 211 insertions(+), 10 deletions(-)
>
> --
> 2.6.0.rc2.230.g3dd15c0
>

Consider this whole series:

Acked-by: Kees Cook <keescook@chromium.org>

Thanks!

-Kees

--=20
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
