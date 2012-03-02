Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 0FB446B002C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 07:13:38 -0500 (EST)
Received: by vbbey12 with SMTP id ey12so1830844vbb.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2012 04:13:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1330648313-32593-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1330648313-32593-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Fri, 2 Mar 2012 20:13:36 +0800
Message-ID: <CAJd=RBBN9Rdf8WQSSYP2LCNdZZCaAOJ0sb98CxPxnz8gmLgnDw@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] thp: add HPAGE_PMD_* definitions for !CONFIG_TRANSPARENT_HUGEPAGE
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Fri, Mar 2, 2012 at 8:31 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> These macros will be used in later patch, where all usage are expected
> to be optimized away without #ifdef CONFIG_TRANSPARENT_HUGEPAGE.
> But to detect unexpected usages, we convert existing BUG() to BUILD_BUG()=
.
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Hillf Danton <dhillf@gmail.com>

> ---
> =C2=A0include/linux/huge_mm.h | =C2=A0 11 ++++++-----
> =C2=A01 files changed, 6 insertions(+), 5 deletions(-)
>
> diff --git linux-next-20120228.orig/include/linux/huge_mm.h linux-next-20=
120228/include/linux/huge_mm.h
> index f56cacb..c8af7a2 100644
> --- linux-next-20120228.orig/include/linux/huge_mm.h
> +++ linux-next-20120228/include/linux/huge_mm.h
> @@ -51,6 +51,9 @@ extern pmd_t *page_check_address_pmd(struct page *page,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long address,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum page_check_addres=
s_pmd_flag flag);
>
> +#define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
> +#define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
> +
> =C2=A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> =C2=A0#define HPAGE_PMD_SHIFT HPAGE_SHIFT
> =C2=A0#define HPAGE_PMD_MASK HPAGE_MASK
> @@ -102,8 +105,6 @@ extern void __split_huge_page_pmd(struct mm_struct *m=
m, pmd_t *pmd);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(pmd_trans_s=
plitting(*____pmd) || =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 pmd_trans_huge(*____pmd)); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} while (0)
> -#define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
> -#define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
> =C2=A0#if HPAGE_PMD_ORDER > MAX_ORDER
> =C2=A0#error "hugepages can't be allocated by the buddy allocator"
> =C2=A0#endif
> @@ -158,9 +159,9 @@ static inline struct page *compound_trans_head(struct=
 page *page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return page;
> =C2=A0}
> =C2=A0#else /* CONFIG_TRANSPARENT_HUGEPAGE */
> -#define HPAGE_PMD_SHIFT ({ BUG(); 0; })
> -#define HPAGE_PMD_MASK ({ BUG(); 0; })
> -#define HPAGE_PMD_SIZE ({ BUG(); 0; })
> +#define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
> +#define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
> +#define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
>
> =C2=A0#define hpage_nr_pages(x) 1
>
> --
> 1.7.7.6
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
