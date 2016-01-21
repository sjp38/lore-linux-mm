Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id AF1E76B0009
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 14:31:47 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id u188so239968857wmu.1
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 11:31:47 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id v130si6020717wme.80.2016.01.21.11.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 11:31:46 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id 123so12933538wmz.2
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 11:31:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAMuHMdXnQwKwxKJy+bpPDSw12+jteHmHD6gnMfPgynmbBK70ug@mail.gmail.com>
References: <CAMuHMdX--N2GBxLapCJLe1vXQaNL8JPEihw5ENeO+8b3y84p0Q@mail.gmail.com>
	<20160118114043.GA14531@node.shutemov.name>
	<CAMuHMdXnQwKwxKJy+bpPDSw12+jteHmHD6gnMfPgynmbBK70ug@mail.gmail.com>
Date: Thu, 21 Jan 2016 11:31:46 -0800
Message-ID: <CA+8MBbJyuzwVOcjtO5sS-qXFrB=3UC1CNMTeaMpbg9xf5Ded6w@mail.gmail.com>
Subject: Re: BUILD_BUG() in smaps_account() (was: Re: [PATCHv12 01/37] mm,
 proc: adjust PSS calculation)
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Mon, Jan 18, 2016 at 6:56 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> Hi Kirill,
>
> On Mon, Jan 18, 2016 at 12:40 PM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
>> On Mon, Jan 18, 2016 at 11:09:00AM +0100, Geert Uytterhoeven wrote:
>>>     fs/built-in.o: In function `smaps_account':
>>>     task_mmu.c:(.text+0x4f8fa): undefined reference to
>>> `__compiletime_assert_471'
>>>
>>> Seen with m68k/allmodconfig or allyesconfig and gcc version 4.1.2 20061115
>>> (prerelease) (Ubuntu 4.1.1-21).
>>> Not seen when compiling the affected file with gcc 4.6.3 or 4.9.0, or with the
>>> m68k defconfigs.
>>
>> Ughh.
>>
>> Please, test this:
>>
>> From 5ac27019f886eef033e84c9579e09099469ccbf9 Mon Sep 17 00:00:00 2001
>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Date: Mon, 18 Jan 2016 14:32:49 +0300
>> Subject: [PATCH] mm, proc: add workaround for old compilers
>>
>> For THP=n, HPAGE_PMD_NR in smaps_account() expands to BUILD_BUG().
>> That's fine since this codepath is eliminated by modern compilers.
>>
>> But older compilers have not that efficient dead code elimination.
>> It causes problem at least with gcc 4.1.2 on m68k.
>>
>> Let's replace HPAGE_PMD_NR with 1 << compound_order(page).
>>
>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
>
> Thanks, that fixes it!
>
> Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

Same breakage on ia64 (with gcc 4.3.4).  Same fix works for me.

Tested-by: Tony Luck <tony.luck@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
