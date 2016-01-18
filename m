Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 209086B0253
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 05:09:01 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id mw1so45554719igb.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 02:09:01 -0800 (PST)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id om7si25413277igb.3.2016.01.18.02.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 02:09:00 -0800 (PST)
Received: by mail-io0-x22c.google.com with SMTP id g73so352343797ioe.3
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 02:09:00 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 18 Jan 2016 11:09:00 +0100
Message-ID: <CAMuHMdX--N2GBxLapCJLe1vXQaNL8JPEihw5ENeO+8b3y84p0Q@mail.gmail.com>
Subject: BUILD_BUG() in smaps_account() (was: Re: [PATCHv12 01/37] mm, proc:
 adjust PSS calculation)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

Hi Kirill,

On Tue, Oct 6, 2015 at 5:23 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> With new refcounting all subpages of the compound page are not necessary
> have the same mapcount. We need to take into account mapcount of every
> sub-page.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Jerome Marchand <jmarchan@redhat.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  fs/proc/task_mmu.c | 47 +++++++++++++++++++++++++++++++----------------
>  1 file changed, 31 insertions(+), 16 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index bd167675a06f..ace02a4a07db 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -454,9 +454,10 @@ struct mem_size_stats {
>  };
>
>  static void smaps_account(struct mem_size_stats *mss, struct page *page,
> -               unsigned long size, bool young, bool dirty)
> +               bool compound, bool young, bool dirty)
>  {
> -       int mapcount;
> +       int i, nr = compound ? HPAGE_PMD_NR : 1;

If CONFIG_TRANSPARENT_HUGEPAGE is not set, we have:

    #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
    #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
    #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })

Depending on compiler version and optimization level, the BUILD_BUG() may be
optimized away (smaps_account() is always called with compound = false if
CONFIG_TRANSPARENT_HUGEPAGE=n), or lead to a build failure:

    fs/built-in.o: In function `smaps_account':
    task_mmu.c:(.text+0x4f8fa): undefined reference to
`__compiletime_assert_471'

Seen with m68k/allmodconfig or allyesconfig and gcc version 4.1.2 20061115
(prerelease) (Ubuntu 4.1.1-21).
Not seen when compiling the affected file with gcc 4.6.3 or 4.9.0, or with the
m68k defconfigs.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
