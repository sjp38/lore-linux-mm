Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id A1E116B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 15:40:22 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id 77so167868330ioc.2
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 12:40:22 -0800 (PST)
Received: from mail-io0-x234.google.com (mail-io0-x234.google.com. [2607:f8b0:4001:c06::234])
        by mx.google.com with ESMTPS id e1si8105857igl.65.2016.01.05.12.40.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 12:40:21 -0800 (PST)
Received: by mail-io0-x234.google.com with SMTP id 1so151968347ion.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 12:40:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1450718817-7082-1-git-send-email-dcashman@android.com>
References: <1450718817-7082-1-git-send-email-dcashman@android.com>
Date: Tue, 5 Jan 2016 12:40:21 -0800
Message-ID: <CAGXu5jJcwZJCDE9adzdvYJct+w2Yk2ySDfzTyqwf=AvrbAqJ4Q@mail.gmail.com>
Subject: Re: [PATCH v7 0/4] Allow customizable random offset to mmap_base address.
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Cashman <dcashman@android.com>, LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Hector Marco <hecmargi@upv.es>, Borislav Petkov <bp@suse.de>, Daniel Cashman <dcashman@google.com>, Arnd Bergmann <arnd@arndb.de>, jonathanh@nvidia.com

On Mon, Dec 21, 2015 at 9:26 AM, Daniel Cashman <dcashman@android.com> wrot=
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
> Changes in v7:
> * changed random bit-grabbing to explicit '&' rather than '%'
> * removed unsupported ARM64 combinations for CONFIG_ARCH_MMAP_RND_BITS_MA=
X
> * aligned default CONFIG_ARCH_MMAP_RND_BITS_MAX to match ARCH_MMAP_RND_BI=
TS_MIN
> * whitespace change for x86 Kconfig
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
>  arch/arm64/Kconfig          | 29 +++++++++++++++++++
>  arch/arm64/mm/mmap.c        |  8 ++++--
>  arch/x86/Kconfig            | 16 +++++++++++
>  arch/x86/mm/mmap.c          | 12 ++++----
>  include/linux/mm.h          | 11 ++++++++
>  kernel/sysctl.c             | 22 +++++++++++++++
>  mm/mmap.c                   | 12 ++++++++
>  11 files changed, 209 insertions(+), 10 deletions(-)
>
> --
> 2.6.0.rc2.230.g3dd15c0
>

Please consider this series:

Acked-by: Kees Cook <keescook@chromium.org>

Thanks for chipping away at it! :)

-Kees

--=20
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
