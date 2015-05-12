Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id CFE366B0072
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:48:05 -0400 (EDT)
Received: by pdea3 with SMTP id a3so2978876pde.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:48:05 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id uw10si16820022pac.163.2015.05.12.02.48.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 12 May 2015 02:48:02 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/4] hwpoison fixes for v4.2
Date: Tue, 12 May 2015 09:46:46 +0000
Message-ID: <1431423998-1939-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

There are some long-standing issues on hwpoison, so this patchset mentions
them. I explain details about each bug in individual patches. In summary:

Patch 1: fix the wrong behavior in failing thp split

Patch 2: fix inconsistent refcounting problem on thp tail pages

Patch 3: fix isolation in soft offlining with keeping refcount

Patch 4: potential fix for me_huge_page()

The user visible effects of patch 1 to 3 are kernel panic with BUG_ON,
so I believe that this patchset helps hwpoison to be more reliable.

This series is based on v4.1-rc3 + Xie XiuQi's patch "memory-failure:
export page_type and action result".

Thanks,
Naoya Horiguchi
---
Tree: https://github.com/Naoya-Horiguchi/linux/tree/v4.1-rc3/hwpoison_for_v=
4.2
---
Summary:

Naoya Horiguchi (4):
      mm/memory-failure: split thp earlier in memory error handling
      mm/memory-failure: introduce get_hwpoison_page() for consistent refco=
unt handling
      mm: soft-offline: don't free target page in successful page migration
      mm/memory-failure: me_huge_page() does nothing for thp

 include/linux/mm.h   |   1 +
 mm/hwpoison-inject.c |   4 +-
 mm/memory-failure.c  | 164 +++++++++++++++++++----------------------------=
----
 mm/migrate.c         |   9 ++-
 mm/swap.c            |   2 -
 5 files changed, 70 insertions(+), 110 deletions(-)=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
