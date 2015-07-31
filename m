Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5236B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 02:49:14 -0400 (EDT)
Received: by obnw1 with SMTP id w1so47445136obn.3
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 23:49:14 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id ly15si3071252oeb.24.2015.07.30.23.49.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 23:49:13 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 0/5] hwpoison: fixes on v4.2-rc4
Date: Fri, 31 Jul 2015 06:46:12 +0000
Message-ID: <1438325105-10059-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This is v2 of hwpoison fix series for v4.2.
I reflected the feedback for v1, and tried another solution for "reuse just
after soft-offline" problem (see patch 5/5.)

General description (mostly identical to v1)
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Recently I addressed a few of hwpoison race problems and the patches are me=
rged
on v4.2-rc1. It made progress, but unfortunately some problems still remain=
 due
to less coverage of my testing. So I'm trying to fix or avoid them in this =
series.

One point I'm expecting to discuss is that patch 4/5 changes the page flag =
set
to be checked on free time. In current behavior, __PG_HWPOISON is not suppo=
sed
to be set when the page is freed. I think that there is no strong reason fo=
r this
behavior, and it causes a problem hard to fix only in error handler side (b=
ecause
__PG_HWPOISON could be set at arbitrary timing.) So I suggest to change it.

Test
=3D=3D=3D=3D

With this patchset, hwpoison stress testing in official mce-test testsuite
(which previously failed) passes.

Thanks,
Naoya Horiguchi
---
Tree: https://github.com/Naoya-Horiguchi/linux/tree/v4.2-rc4/hwpoison.v2
---
Summary:

Naoya Horiguchi (5):
      mm/memory-failure: unlock_page before put_page
      mm/memory-failure: fix race in counting num_poisoned_pages
      mm/memory-failure: give up error handling for non-tail-refcounted thp
      mm: check __PG_HWPOISON separately from PAGE_FLAGS_CHECK_AT_*
      mm/memory-failure: set PageHWPoison before migrate_pages()

 include/linux/page-flags.h | 10 +++++++---
 mm/huge_memory.c           |  7 +------
 mm/memory-failure.c        | 32 ++++++++++++++++++--------------
 mm/migrate.c               |  8 ++++++--
 mm/page_alloc.c            |  4 ++++
 5 files changed, 36 insertions(+), 25 deletions(-)=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
