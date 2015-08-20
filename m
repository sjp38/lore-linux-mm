Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 943E06B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 21:02:28 -0400 (EDT)
Received: by paccq16 with SMTP id cq16so14716194pac.1
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 18:02:28 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id iv4si4461293pbc.82.2015.08.19.18.02.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Aug 2015 18:02:27 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [linux-next:master 9078/9582]
 arch/arm64/include/asm/pgtable.h:238:0: warning: "HUGE_MAX_HSTATE" redefined
Date: Thu, 20 Aug 2015 01:01:48 +0000
Message-ID: <20150820010148.GA859@hori1.linux.bs1.fc.nec.co.jp>
References: <201508192138.toXxw84b%fengguang.wu@intel.com>
 <20150819143305.fc1fbb979fee6e9b60c59d3c@linux-foundation.org>
In-Reply-To: <20150819143305.fc1fbb979fee6e9b60c59d3c@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4E0049EB149EA34F8033F07C31C84D9B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Aug 19, 2015 at 02:33:05PM -0700, Andrew Morton wrote:
> On Wed, 19 Aug 2015 21:32:40 +0800 kbuild test robot <fengguang.wu@intel.=
com> wrote:
>=20
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.g=
it master
> > head:   dcaa9a3e88c4082096bfed62d9de2d9b6ad9e3d6
> > commit: 878b6f5bcef8de64a5c39b685e785166357bf0dc [9078/9582] mm-hugetlb=
-proc-add-hugetlbpages-field-to-proc-pid-status-fix-3
> > config: arm64-allmodconfig (attached as .config)
> > reproduce:
> >   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/p=
lain/sbin/make.cross -O ~/bin/make.cross
> >   chmod +x ~/bin/make.cross
> >   git checkout 878b6f5bcef8de64a5c39b685e785166357bf0dc
> >   # save the attached .config to linux build tree
> >   make.cross ARCH=3Darm64=20
> >=20
> > All warnings (new ones prefixed by >>):
> >=20
> >    In file included from include/linux/mm.h:54:0,
> >                     from arch/arm64/kernel/asm-offsets.c:22:
> > >> arch/arm64/include/asm/pgtable.h:238:0: warning: "HUGE_MAX_HSTATE" r=
edefined
> >     #define HUGE_MAX_HSTATE  2
> >     ^
> >    In file included from include/linux/sched.h:27:0,
> >                     from arch/arm64/kernel/asm-offsets.c:21:
> >    include/linux/mm_types.h:372:0: note: this is the location of the pr=
evious definition
> >     #define HUGE_MAX_HSTATE 1
>=20
> I've spent far too long trying to come up with a nice fix for this and
> everything I try leads down a path of horror.  Our include files are a
> big mess.

Thanks for digging this. I agree to the direction of splitting header files
to reduce the complexity of header dependency. But if we need a quick fix
until your work in another email is merged, the following should work.

# I'll take a look on your patch.

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] hugetlb: overwrite HUGE_MAX_HSTATE definition

This dirty workaround will be removed when the circular dependency of
header files around mm_types.h and sched.h is fixed.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/arm64/include/asm/pgtable.h  | 3 +++
 arch/powerpc/include/asm/page.h   | 3 +++
 arch/tile/include/asm/page.h      | 3 +++
 arch/x86/include/asm/page_types.h | 3 +++
 4 files changed, 12 insertions(+)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgta=
ble.h
index 56283f8a675c..01208204dbb3 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -235,6 +235,9 @@ static inline void set_pte_at(struct mm_struct *mm, uns=
igned long addr,
 /*
  * Hugetlb definitions.
  */
+#if defined(HUGE_MAX_HSTATE) && HUGE_MAX_HSTATE =3D=3D 1
+#undef HUGE_MAX_HSTATE
+#endif
 #define HUGE_MAX_HSTATE		2
 #define HPAGE_SHIFT		PMD_SHIFT
 #define HPAGE_SIZE		(_AC(1, UL) << HPAGE_SHIFT)
diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/pag=
e.h
index 71294a6e976e..19ee05520353 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -45,6 +45,9 @@ extern unsigned int HPAGE_SHIFT;
 #define HPAGE_SIZE		((1UL) << HPAGE_SHIFT)
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
+#if defined(HUGE_MAX_HSTATE) && HUGE_MAX_HSTATE =3D=3D 1
+#undef HUGE_MAX_HSTATE
+#endif
 #define HUGE_MAX_HSTATE		(MMU_PAGE_COUNT-1)
 #endif
=20
diff --git a/arch/tile/include/asm/page.h b/arch/tile/include/asm/page.h
index a213a8d84a95..dac32bd65b99 100644
--- a/arch/tile/include/asm/page.h
+++ b/arch/tile/include/asm/page.h
@@ -136,6 +136,9 @@ static inline __attribute_const__ int get_order(unsigne=
d long size)
=20
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
=20
+#if defined(HUGE_MAX_HSTATE) && HUGE_MAX_HSTATE =3D=3D 1
+#undef HUGE_MAX_HSTATE
+#endif
 #define HUGE_MAX_HSTATE		6
=20
 #ifdef CONFIG_HUGETLB_PAGE
diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_=
types.h
index c7c712f2648b..747fa3b5ea3f 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -25,6 +25,9 @@
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
=20
+#if defined(HUGE_MAX_HSTATE) && HUGE_MAX_HSTATE =3D=3D 1
+#undef HUGE_MAX_HSTATE
+#endif
 #define HUGE_MAX_HSTATE 2
=20
 #define PAGE_OFFSET		((unsigned long)__PAGE_OFFSET)
--=20
2.4.3=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
