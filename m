Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7D336B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 20:32:07 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a8so36821977pfg.0
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 17:32:07 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id wb2si28249738pab.58.2016.11.07.17.23.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Nov 2016 17:23:41 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 07/12] mm: thp: check pmd migration entry in common
 path
Date: Tue, 8 Nov 2016 01:22:37 +0000
Message-ID: <20161108012235.GA23310@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-8-git-send-email-n-horiguchi@ah.jp.nec.com>
 <201611080842.F85k1bSH%fengguang.wu@intel.com>
In-Reply-To: <201611080842.F85k1bSH%fengguang.wu@intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <87C4F6ACC459674884F5E778D7B6C544@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Nov 08, 2016 at 08:23:50AM +0800, kbuild test robot wrote:
> Hi Naoya,
>=20
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on v4.9-rc4 next-20161028]
> [if your patch is applied to the wrong git tree, please drop us a note to=
 help improve the system]
>=20
> url:    https://github.com/0day-ci/linux/commits/Naoya-Horiguchi/mm-x86-m=
ove-_PAGE_SWP_SOFT_DIRTY-from-bit-7-to-bit-6/20161108-080615
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: i386-randconfig-x007-201645 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=3Di386=20
>=20
> All error/warnings (new ones prefixed by >>):
>=20
>    mm/memory.c: In function 'copy_pmd_range':
> >> mm/memory.c:1002:7: error: implicit declaration of function 'pmd_relat=
ed' [-Werror=3Dimplicit-function-declaration]
>       if (pmd_related(*src_pmd)) {
>           ^~~~~~~~~~~
>    cc1: some warnings being treated as errors
> --

I forgot to declare a noop routine for CONFIG_TRANSPARENT_HUGEPAGE=3Dn.

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -222,6 +229,10 @@ static inline void vma_adjust_trans_huge(struct vm_are=
a_struct *vma,
 					 long adjust_next)
 {
 }
+static inline int pmd_related(pmd_t pmd)
+{
+	return 0;
+}
 static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 		struct vm_area_struct *vma)
 {


>    mm/mremap.c: In function 'move_page_tables':
> >> mm/mremap.c:197:7: error: implicit declaration of function 'pmd_relate=
d' [-Werror=3Dimplicit-function-declaration]
>       if (pmd_related(*old_pmd)) {
>           ^~~~~~~~~~~
>    In file included from include/asm-generic/bug.h:4:0,
>                     from arch/x86/include/asm/bug.h:35,
>                     from include/linux/bug.h:4,
>                     from include/linux/mmdebug.h:4,
>                     from include/linux/mm.h:8,
>                     from mm/mremap.c:10:
> >> include/linux/compiler.h:518:38: error: call to '__compiletime_assert_=
198' declared with attribute error: BUILD_BUG failed
>      _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>                                          ^
>    include/linux/compiler.h:501:4: note: in definition of macro '__compil=
etime_assert'
>        prefix ## suffix();    \
>        ^~~~~~
>    include/linux/compiler.h:518:2: note: in expansion of macro '_compilet=
ime_assert'
>      _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>      ^~~~~~~~~~~~~~~~~~~
>    include/linux/bug.h:54:37: note: in expansion of macro 'compiletime_as=
sert'
>     #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>                                         ^~~~~~~~~~~~~~~~~~
>    include/linux/bug.h:88:21: note: in expansion of macro 'BUILD_BUG_ON_M=
SG'
>     #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
>                         ^~~~~~~~~~~~~~~~
> >> include/linux/huge_mm.h:183:27: note: in expansion of macro 'BUILD_BUG=
'
>     #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
>                               ^~~~~~~~~
> >> mm/mremap.c:198:18: note: in expansion of macro 'HPAGE_PMD_SIZE'
>        if (extent =3D=3D HPAGE_PMD_SIZE) {
>                      ^~~~~~~~~~~~~~
>    cc1: some warnings being treated as errors

HPAGE_PMD_SIZE is available only in CONFIG_TRANSPARENT_HUGEPAGE=3Dy, and
this code looks to violate the rule, but it is in if (pmd_related()) block
which is compiled out in CONFIG_TRANSPARENT_HUGEPAGE=3Dn, so this is OK
only with the above change.

Thanks,
Naoya Horiguchi

> --
>    mm/madvise.c: In function 'madvise_free_pte_range':
> >> mm/madvise.c:277:6: error: implicit declaration of function 'pmd_relat=
ed' [-Werror=3Dimplicit-function-declaration]
>      if (pmd_related(*pmd))
>          ^~~~~~~~~~~
>    cc1: some warnings being treated as errors
>=20
> vim +/pmd_related +1002 mm/memory.c
>=20
>    996		dst_pmd =3D pmd_alloc(dst_mm, dst_pud, addr);
>    997		if (!dst_pmd)
>    998			return -ENOMEM;
>    999		src_pmd =3D pmd_offset(src_pud, addr);
>   1000		do {
>   1001			next =3D pmd_addr_end(addr, end);
> > 1002			if (pmd_related(*src_pmd)) {
>   1003				int err;
>   1004				VM_BUG_ON(next-addr !=3D HPAGE_PMD_SIZE);
>   1005				err =3D copy_huge_pmd(dst_mm, src_mm,
>=20
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Ce=
nter
> https://lists.01.org/pipermail/kbuild-all                   Intel Corpora=
tion

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
