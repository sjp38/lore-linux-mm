Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4D76B0009
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 09:56:54 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id z14so56949774igp.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 06:56:54 -0800 (PST)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id z1si26722316igl.72.2016.01.18.06.56.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 06:56:53 -0800 (PST)
Received: by mail-io0-x22e.google.com with SMTP id 77so520027280ioc.2
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 06:56:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160118114043.GA14531@node.shutemov.name>
References: <CAMuHMdX--N2GBxLapCJLe1vXQaNL8JPEihw5ENeO+8b3y84p0Q@mail.gmail.com>
	<20160118114043.GA14531@node.shutemov.name>
Date: Mon, 18 Jan 2016 15:56:53 +0100
Message-ID: <CAMuHMdXnQwKwxKJy+bpPDSw12+jteHmHD6gnMfPgynmbBK70ug@mail.gmail.com>
Subject: Re: BUILD_BUG() in smaps_account() (was: Re: [PATCHv12 01/37] mm,
 proc: adjust PSS calculation)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

Hi Kirill,

On Mon, Jan 18, 2016 at 12:40 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Mon, Jan 18, 2016 at 11:09:00AM +0100, Geert Uytterhoeven wrote:
>>     fs/built-in.o: In function `smaps_account':
>>     task_mmu.c:(.text+0x4f8fa): undefined reference to
>> `__compiletime_assert_471'
>>
>> Seen with m68k/allmodconfig or allyesconfig and gcc version 4.1.2 20061115
>> (prerelease) (Ubuntu 4.1.1-21).
>> Not seen when compiling the affected file with gcc 4.6.3 or 4.9.0, or with the
>> m68k defconfigs.
>
> Ughh.
>
> Please, test this:
>
> From 5ac27019f886eef033e84c9579e09099469ccbf9 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Mon, 18 Jan 2016 14:32:49 +0300
> Subject: [PATCH] mm, proc: add workaround for old compilers
>
> For THP=n, HPAGE_PMD_NR in smaps_account() expands to BUILD_BUG().
> That's fine since this codepath is eliminated by modern compilers.
>
> But older compilers have not that efficient dead code elimination.
> It causes problem at least with gcc 4.1.2 on m68k.
>
> Let's replace HPAGE_PMD_NR with 1 << compound_order(page).
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>

Thanks, that fixes it!

Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

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
