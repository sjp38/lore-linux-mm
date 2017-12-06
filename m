Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D3CC26B0496
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 05:02:32 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v69so1808210wrb.3
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 02:02:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p34si922260edb.413.2017.12.06.02.02.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 02:02:31 -0800 (PST)
Date: Wed, 6 Dec 2017 11:02:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171206100229.GI16386@dhcp22.suse.cz>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144219.22867-2-mhocko@kernel.org>
 <87tvx4e8sz.fsf@concordia.ellerman.id.au>
 <20171206092724.GH16386@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206092724.GH16386@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>

On Wed 06-12-17 10:27:24, Michal Hocko wrote:
> On Wed 06-12-17 16:15:24, Michael Ellerman wrote:
[...]
> > So I think I proved above that all the arches that are using 0x80000 are
> > also using mman-common.h, and vice-versa.
> > 
> > So you can put this in mman-common.h can't your?
> 
> Yes it seems I can. I would have to double check. It is true that
> defining the new flag closer to MAP_FIXED makes some sense

OK, so some recap
those which include generic mman-common.h directly
arch/sparc/include/uapi/asm/mman.h:#include <asm-generic/mman-common.h>
arch/powerpc/include/uapi/asm/mman.h:#include <asm-generic/mman-common.h>
arch/tile/include/uapi/asm/mman.h:#include <asm-generic/mman-common.h>

then we have
arch/metag/include/asm/mman.h
which includes uapi/asm/mman.h and that is a generic one
arch/metag/include/uapi/asm/Kbuild:generic-y += mman.h

others include generic mman.h
arch/arm/include/uapi/asm/mman.h:#include <asm-generic/mman.h>
arch/frv/include/uapi/asm/mman.h:#include <asm-generic/mman.h>
arch/ia64/include/uapi/asm/mman.h:#include <asm-generic/mman.h>
arch/m32r/include/uapi/asm/mman.h:#include <asm-generic/mman.h>
arch/mn10300/include/uapi/asm/mman.h:#include <asm-generic/mman.h>
arch/score/include/uapi/asm/mman.h:#include <asm-generic/mman.h>
arch/x86/include/uapi/asm/mman.h:#include <asm-generic/mman.h>

which includes mman-common.h as well

and then we are left with
arch/alpha/include/uapi/asm/mman.h
arch/mips/include/uapi/asm/mman.h
arch/parisc/include/uapi/asm/mman.h
arch/xtensa/include/uapi/asm/mman.h

which do not include anything. So the patch can be indeed simplified.
I will fold the following into the patch. I hope nothing got left behind
but my defconfig compile test on all arches which i have a cross
compiler for succeeded.
---
commit 52a9272f419f428cb079d340f64113325516ef9b
Author: Michal Hocko <mhocko@suse.com>
Date:   Wed Dec 6 10:46:16 2017 +0100

    - define MAP_FIXED_SAFE in asm-generic/mman-common.h as per Michael
      Ellerman because all architecture which use this header can share
      the same value. This will leave us with only 4 arches which need
      special handling.

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index ef3770262925..7287dbf1e11b 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -31,7 +31,6 @@
 #define MAP_NONBLOCK	0x40000		/* do not block on IO */
 #define MAP_STACK	0x80000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x100000	/* create a huge page mapping */
-
 #define MAP_FIXED_SAFE	0x200000	/* MAP_FIXED which doesn't unmap underlying mapping */
 
 #define MS_ASYNC	1		/* sync memory asynchronously */
diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
index 3ffd284e7160..e63bc37e33af 100644
--- a/arch/powerpc/include/uapi/asm/mman.h
+++ b/arch/powerpc/include/uapi/asm/mman.h
@@ -29,6 +29,5 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-#define MAP_FIXED_SAFE	0x800000	/* MAP_FIXED which doesn't unmap underlying mapping */
 
 #endif /* _UAPI_ASM_POWERPC_MMAN_H */
diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
index 0c282c09fae8..d21bffd5d3dc 100644
--- a/arch/sparc/include/uapi/asm/mman.h
+++ b/arch/sparc/include/uapi/asm/mman.h
@@ -24,7 +24,5 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-#define MAP_FIXED_SAFE	0x80000		/* MAP_FIXED which doesn't unmap underlying mapping */
-
 
 #endif /* _UAPI__SPARC_MMAN_H__ */
diff --git a/arch/tile/include/uapi/asm/mman.h b/arch/tile/include/uapi/asm/mman.h
index b212f5fd5345..9b7add95926b 100644
--- a/arch/tile/include/uapi/asm/mman.h
+++ b/arch/tile/include/uapi/asm/mman.h
@@ -30,7 +30,6 @@
 #define MAP_DENYWRITE	0x0800		/* ETXTBSY */
 #define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
 #define MAP_HUGETLB	0x4000		/* create a huge page mapping */
-#define MAP_FIXED_SAFE	0x8000		/* MAP_FIXED which doesn't unmap underlying mapping */
 
 
 /*
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 6d319c46fd90..1eca2cb10d44 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -25,6 +25,7 @@
 #else
 # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
 #endif
+#define MAP_FIXED_SAFE	0x80000		/* MAP_FIXED which doesn't unmap underlying mapping */
 
 /*
  * Flags for mlock
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index 56cde132a80a..2dffcbf705b3 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -13,7 +13,6 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-#define MAP_FIXED_SAFE	0x80000		/* MAP_FIXED which doesn't unmap underlying mapping */
 
 /* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage */
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
