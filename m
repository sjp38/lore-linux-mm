Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id E48E36B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 18:07:43 -0400 (EDT)
Received: by lagz14 with SMTP id z14so1558879lag.14
        for <linux-mm@kvack.org>; Wed, 21 Mar 2012 15:07:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1331591456-20769-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1331591456-20769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1331591456-20769-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Wed, 21 Mar 2012 18:07:41 -0400
Message-ID: <CAP=VYLoGSckJH+2GytZN0V0P3Uuv-PiVneKbFsVb5kQa3kcTCQ@mail.gmail.com>
Subject: Re: [PATCH v4 2/3] thp: add HPAGE_PMD_* definitions for !CONFIG_TRANSPARENT_HUGEPAGE
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org

On Mon, Mar 12, 2012 at 6:30 PM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> These macros will be used in later patch, where all usage are expected
> to be optimized away without #ifdef CONFIG_TRANSPARENT_HUGEPAGE.
> But to detect unexpected usages, we convert existing BUG() to BUILD_BUG()=
.

Just a heads up that this showed up in linux-next today as the
cause of a new build failure for an ARM board:

http://kisskb.ellerman.id.au/kisskb/buildresult/5930053/

Paul.
--

git bisect start
# good: [fde7d9049e55ab85a390be7f415d74c9f62dd0f9] Linux 3.3-rc7
git bisect good fde7d9049e55ab85a390be7f415d74c9f62dd0f9
# bad: [9166d6581d1ca6795bcd38506c7d29bf39402a7d] Add linux-next
specific files for 20120321
git bisect bad 9166d6581d1ca6795bcd38506c7d29bf39402a7d
# good: [e863be5cac0a857302ccc0129326ca3634c1136a] Merge
remote-tracking branch 'net-next/master'
git bisect good e863be5cac0a857302ccc0129326ca3634c1136a
# good: [2ac4846c531fc33783999e8819a66d0f3e36058f] Merge
remote-tracking branch 'spi/spi/next'
git bisect good 2ac4846c531fc33783999e8819a66d0f3e36058f
# good: [a3ebef77540d27811aab7514b9aeaab13c573b46] Merge
remote-tracking branch 'oprofile/for-next'
git bisect good a3ebef77540d27811aab7514b9aeaab13c573b46
# good: [3ee174051be0246173ba8a386bb7a2d20d9e27c3] [arm-soc internal]
add back contents file
git bisect good 3ee174051be0246173ba8a386bb7a2d20d9e27c3
# good: [cc61a2762110efb0868bc326be52f3ecd22c4e99] Merge
remote-tracking branch 'dma-buf/for-next'
git bisect good cc61a2762110efb0868bc326be52f3ecd22c4e99
# bad: [dd09ea75ddb4d712abe5ec8a9b37619a99d4554c] kernel/watchdog.c:
add comment to watchdog() exit path
git bisect bad dd09ea75ddb4d712abe5ec8a9b37619a99d4554c
# good: [a80d01212507a57d48912f08ca22de039f4470b8] rmap: remove
__anon_vma_link() declaration
git bisect good a80d01212507a57d48912f08ca22de039f4470b8
# good: [dfac39f6a2daa212de0eb80bf14c76a2bee23dc4] memcg: remove
PCG_CACHE page_cgroup flag
git bisect good dfac39f6a2daa212de0eb80bf14c76a2bee23dc4
# bad: [8887892fd3354617e63be2399e286a86d0f9279c] alpha: use
set_current_blocked() and block_sigmask()
git bisect bad 8887892fd3354617e63be2399e286a86d0f9279c
# good: [0d7a67d6525414f8541f4a61084d783b4b53b8ec] memcg: remove
PCG_FILE_MAPPED fix cosmetic fix
git bisect good 0d7a67d6525414f8541f4a61084d783b4b53b8ec
# good: [ea20bf604adaab3a4ffb887083e62e7d76eb5d53] memcg: clean up
existing move charge code
git bisect good ea20bf604adaab3a4ffb887083e62e7d76eb5d53
# bad: [0709378dc1d716112e10de7f687af4993e69df7b] frv: use
set_current_blocked() and block_sigmask()
git bisect bad 0709378dc1d716112e10de7f687af4993e69df7b
# bad: [3135be0275c89f28c352554a0ec1874ea7cd3c3a] memcg: avoid THP
split in task migration
git bisect bad 3135be0275c89f28c352554a0ec1874ea7cd3c3a
# bad: [92c36300cf69f6ea1267d0bba7af708560c116d7] thp: add HPAGE_PMD_*
definitions for !CONFIG_TRANSPARENT_HUGEPAGE
git bisect bad 92c36300cf69f6ea1267d0bba7af708560c116d7
paul@yow-lpgnfs-02:~/git/linux-head$



>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Hillf Danton <dhillf@gmail.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: David Rientjes <rientjes@google.com>
> ---
> =A0include/linux/huge_mm.h | =A0 11 ++++++-----
> =A01 files changed, 6 insertions(+), 5 deletions(-)
>
> diff --git linux-next-20120307.orig/include/linux/huge_mm.h linux-next-20=
120307/include/linux/huge_mm.h
> index f56cacb..c8af7a2 100644
> --- linux-next-20120307.orig/include/linux/huge_mm.h
> +++ linux-next-20120307/include/linux/huge_mm.h
> @@ -51,6 +51,9 @@ extern pmd_t *page_check_address_pmd(struct page *page,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u=
nsigned long address,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 e=
num page_check_address_pmd_flag flag);
>
> +#define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
> +#define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
> +
> =A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> =A0#define HPAGE_PMD_SHIFT HPAGE_SHIFT
> =A0#define HPAGE_PMD_MASK HPAGE_MASK
> @@ -102,8 +105,6 @@ extern void __split_huge_page_pmd(struct mm_struct *m=
m, pmd_t *pmd);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(pmd_trans_splitting(*____pmd) || =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pmd_trans_huge(*____pmd)); =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0} while (0)
> -#define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
> -#define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
> =A0#if HPAGE_PMD_ORDER > MAX_ORDER
> =A0#error "hugepages can't be allocated by the buddy allocator"
> =A0#endif
> @@ -158,9 +159,9 @@ static inline struct page *compound_trans_head(struct=
 page *page)
> =A0 =A0 =A0 =A0return page;
> =A0}
> =A0#else /* CONFIG_TRANSPARENT_HUGEPAGE */
> -#define HPAGE_PMD_SHIFT ({ BUG(); 0; })
> -#define HPAGE_PMD_MASK ({ BUG(); 0; })
> -#define HPAGE_PMD_SIZE ({ BUG(); 0; })
> +#define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
> +#define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
> +#define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
>
> =A0#define hpage_nr_pages(x) 1
>
> --
> 1.7.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
