Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 403AA6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 06:40:47 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id r129so47620963wmr.0
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 03:40:47 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id i7si24827663wmf.59.2016.01.18.03.40.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 03:40:45 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id n5so59428074wmn.0
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 03:40:45 -0800 (PST)
Date: Mon, 18 Jan 2016 13:40:43 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: BUILD_BUG() in smaps_account() (was: Re: [PATCHv12 01/37] mm,
 proc: adjust PSS calculation)
Message-ID: <20160118114043.GA14531@node.shutemov.name>
References: <CAMuHMdX--N2GBxLapCJLe1vXQaNL8JPEihw5ENeO+8b3y84p0Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdX--N2GBxLapCJLe1vXQaNL8JPEihw5ENeO+8b3y84p0Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Mon, Jan 18, 2016 at 11:09:00AM +0100, Geert Uytterhoeven wrote:
> Hi Kirill,
> 
> On Tue, Oct 6, 2015 at 5:23 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > With new refcounting all subpages of the compound page are not necessary
> > have the same mapcount. We need to take into account mapcount of every
> > sub-page.
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Tested-by: Sasha Levin <sasha.levin@oracle.com>
> > Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > Acked-by: Jerome Marchand <jmarchan@redhat.com>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > ---
> >  fs/proc/task_mmu.c | 47 +++++++++++++++++++++++++++++++----------------
> >  1 file changed, 31 insertions(+), 16 deletions(-)
> >
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index bd167675a06f..ace02a4a07db 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -454,9 +454,10 @@ struct mem_size_stats {
> >  };
> >
> >  static void smaps_account(struct mem_size_stats *mss, struct page *page,
> > -               unsigned long size, bool young, bool dirty)
> > +               bool compound, bool young, bool dirty)
> >  {
> > -       int mapcount;
> > +       int i, nr = compound ? HPAGE_PMD_NR : 1;
> 
> If CONFIG_TRANSPARENT_HUGEPAGE is not set, we have:
> 
>     #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
>     #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
>     #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
> 
> Depending on compiler version and optimization level, the BUILD_BUG() may be
> optimized away (smaps_account() is always called with compound = false if
> CONFIG_TRANSPARENT_HUGEPAGE=n), or lead to a build failure:
> 
>     fs/built-in.o: In function `smaps_account':
>     task_mmu.c:(.text+0x4f8fa): undefined reference to
> `__compiletime_assert_471'
> 
> Seen with m68k/allmodconfig or allyesconfig and gcc version 4.1.2 20061115
> (prerelease) (Ubuntu 4.1.1-21).
> Not seen when compiling the affected file with gcc 4.6.3 or 4.9.0, or with the
> m68k defconfigs.

Ughh.

Please, test this:
