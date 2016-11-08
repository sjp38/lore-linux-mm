Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67FB06B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 01:48:05 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id l66so63204134pfl.7
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 22:48:05 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id d10si29525559pab.95.2016.11.07.22.48.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Nov 2016 22:48:04 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 05/12] mm: thp: add core routines for thp/pmd
 migration
Date: Tue, 8 Nov 2016 06:46:55 +0000
Message-ID: <20161108064654.GA474@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-6-git-send-email-n-horiguchi@ah.jp.nec.com>
 <201611081136.ZuJrd6uJ%fengguang.wu@intel.com>
In-Reply-To: <201611081136.ZuJrd6uJ%fengguang.wu@intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <EBCA6E5FF0720D48B2D3195CC94113E7@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Nov 08, 2016 at 11:05:52AM +0800, kbuild test robot wrote:
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
> config: arm-at91_dt_defconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.g=
it/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=3Darm=20
>=20
> All errors (new ones prefixed by >>):
>=20
>    In file included from fs/proc/task_mmu.c:14:0:
>    include/linux/swapops.h: In function 'swp_entry_to_pmd':
> >> include/linux/swapops.h:216:14: error: empty scalar initializer
>      pmd_t pmd =3D {};
>                  ^
>    include/linux/swapops.h:216:14: note: (near initialization for 'pmd')
>=20
> vim +216 include/linux/swapops.h
>=20
>    210	{
>    211		return swp_entry(0, 0);
>    212	}
>    213=09
>    214	static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
>    215	{
>  > 216		pmd_t pmd =3D {};
>    217=09
>    218		return pmd;
>    219	}

Here is an alternative:

diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index db8a858cc6ff..748c9233b3a5 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -215,9 +215,7 @@ static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
=20
 static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
 {
-	pmd_t pmd =3D {};
-
-	return pmd;
+	return (pmd_t) { 0 };
 }
=20
 static inline int is_pmd_migration_entry(pmd_t pmd)

Thanks,
Naoya Horiguchi

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
