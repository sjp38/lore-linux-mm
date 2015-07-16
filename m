Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 772CC2802B9
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 21:42:45 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so35862335pdb.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 18:42:45 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id ci16si10314366pdb.76.2015.07.15.18.42.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jul 2015 18:42:44 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 0/4] hwpoison: fixes on v4.2-rc2
Date: Thu, 16 Jul 2015 01:41:55 +0000
Message-ID: <1437010894-10262-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Recently I addressed a few of hwpoison race problems and the patches are me=
rged
on v4.2-rc1. It made progress, but unfortunately some problems still remain=
 due
to less coverage of my testing. So I'm trying to fix or avoid them in this =
series.

One point I'm expecting to discuss is that patch 4/4 changes the page flag =
set
to be checked on free time. In current behavior, __PG_HWPOISON is not suppo=
sed
to be set when the page is freed. I think that there is no strong reason fo=
r this
behavior, and it causes a problem hard to fix only in error handler side (b=
ecause
__PG_HWPOISON could be set at arbitrary timing.) So I suggest to change it.

With this patchset, the stress testing in official mce-test testsuite passe=
s.

Thanks,
Naoya Horiguchi
---
Tree: https://github.com/Naoya-Horiguchi/linux/tree/v4.2-rc2/hwpoison.v1
---
Summary:

Naoya Horiguchi (4):
      mm/memory-failure: unlock_page before put_page
      mm/memory-failure: fix race in counting num_poisoned_pages
      mm/memory-failure: give up error handling for non-tail-refcounted thp
      mm/memory-failure: check __PG_HWPOISON separately from PAGE_FLAGS_CHE=
CK_AT_*

 include/linux/page-flags.h | 10 +++++++---
 mm/huge_memory.c           |  7 +------
 mm/memory-failure.c        | 32 ++++++++++++++++++--------------
 mm/migrate.c               |  9 +++------
 mm/page_alloc.c            |  4 ++++
 5 files changed, 33 insertions(+), 29 deletions(-)=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
