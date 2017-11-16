Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DBDEF28025F
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 07:14:43 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 70so15983123pgf.5
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 04:14:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q13si755294pgt.668.2017.11.16.04.14.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 04:14:42 -0800 (PST)
Date: Thu, 16 Nov 2017 13:14:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171116121438.6vegs4wiahod3byl@dhcp22.suse.cz>
References: <20171116101900.13621-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171116101900.13621-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-api@vger.kernel.org
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>

[Ups, managed to screw the subject - fix it]

On Thu 16-11-17 11:18:58, Michal Hocko wrote:
> Hi,
> this has started as a follow up discussion [1][2] resulting in the
> runtime failure caused by hardening patch [3] which removes MAP_FIXED
> from the elf loader because MAP_FIXED is inherently dangerous as it
> might silently clobber and existing underlying mapping (e.g. stack). The
> reason for the failure is that some architectures enforce an alignment
> for the given address hint without MAP_FIXED used (e.g. for shared or
> file backed mappings).
> 
> One way around this would be excluding those archs which do alignment
> tricks from the hardening [4]. The patch is really trivial but it has
> been objected, rightfully so, that this screams for a more generic
> solution. We basically want a non-destructive MAP_FIXED.
> 
> The first patch introduced MAP_FIXED_SAFE which enforces the given
> address but unlike MAP_FIXED it fails with ENOMEM if the given range
> conflicts with an existing one. The flag is introduced as a completely
> new flag rather than a MAP_FIXED extension because of the backward
> compatibility. We really want a never-clobber semantic even on older
> kernels which do not recognize the flag. Unfortunately mmap sucks wrt.
> flags evaluation because we do not EINVAL on unknown flags. On those
> kernels we would simply use the traditional hint based semantic so the
> caller can still get a different address (which sucks) but at least not
> silently corrupt an existing mapping. I do not see a good way around
> that. Except we won't export expose the new semantic to the userspace at
> all. It seems there are users who would like to have something like that
> [5], though. Atomic address range probing in the multithreaded programs
> sounds like an interesting thing to me as well, although I do not have
> any specific usecase in mind.
> 
> The second patch simply replaces MAP_FIXED use in elf loader by
> MAP_FIXED_SAFE. I believe other places which rely on MAP_FIXED should
> follow. Actually real MAP_FIXED usages should be docummented properly
> and they should be more of an exception.
> 
> Does anybody see any fundamental reasons why this is a wrong approach?
> 
> Diffstat says
>  arch/alpha/include/uapi/asm/mman.h   |  2 ++
>  arch/metag/kernel/process.c          |  6 +++++-
>  arch/mips/include/uapi/asm/mman.h    |  2 ++
>  arch/parisc/include/uapi/asm/mman.h  |  2 ++
>  arch/powerpc/include/uapi/asm/mman.h |  1 +
>  arch/sparc/include/uapi/asm/mman.h   |  1 +
>  arch/tile/include/uapi/asm/mman.h    |  1 +
>  arch/xtensa/include/uapi/asm/mman.h  |  2 ++
>  fs/binfmt_elf.c                      | 12 ++++++++----
>  include/uapi/asm-generic/mman.h      |  1 +
>  mm/mmap.c                            | 11 +++++++++++
>  11 files changed, 36 insertions(+), 5 deletions(-)
> 
> [1] http://lkml.kernel.org/r/20171107162217.382cd754@canb.auug.org.au
> [2] http://lkml.kernel.org/r/1510048229.12079.7.camel@abdul.in.ibm.com
> [3] http://lkml.kernel.org/r/20171023082608.6167-1-mhocko@kernel.org
> [4] http://lkml.kernel.org/r/20171113094203.aofz2e7kueitk55y@dhcp22.suse.cz
> [5] http://lkml.kernel.org/r/87efp1w7vy.fsf@concordia.ellerman.id.au
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
