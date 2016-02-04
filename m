Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id C5FD94403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 02:08:56 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 65so35235292pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 23:08:56 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id p70si14740230pfj.241.2016.02.03.23.08.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 23:08:56 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id 65so2610018pfd.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 23:08:56 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 2/3] /proc/kpageflags: return KPF_SLAB for slab tail pages
Date: Thu,  4 Feb 2016 16:08:02 +0900
Message-Id: <1454569683-17918-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1454569683-17918-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1454569683-17918-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Currently /proc/kpageflags returns just KPF_COMPOUND_TAIL for slab tail pages,
which is inconvenient when grasping how slab pages are distributed (userspace
always needs to check which kind of tail pages by itself). This patch sets
KPF_SLAB for such pages.

With this patch:

  $ grep Slab /proc/meminfo ; tools/vm/page-types -b slab
  Slab:              64880 kB
               flags      page-count       MB  symbolic-flags                     long-symbolic-flags
  0x0000000000000080           16220       63  _______S__________________________________ slab
               total           16220       63

16220 pages equals to 64880 kB, so returned result is consistent with the
global counter.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/page.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git v4.5-rc2-mmotm-2016-02-02-17-08/fs/proc/page.c v4.5-rc2-mmotm-2016-02-02-17-08_patched/fs/proc/page.c
index 42998bb..40a4685 100644
--- v4.5-rc2-mmotm-2016-02-02-17-08/fs/proc/page.c
+++ v4.5-rc2-mmotm-2016-02-02-17-08_patched/fs/proc/page.c
@@ -160,6 +160,8 @@ u64 stable_page_flags(struct page *page)
 	u |= kpf_copy_bit(k, KPF_LOCKED,	PG_locked);
 
 	u |= kpf_copy_bit(k, KPF_SLAB,		PG_slab);
+	if (PageTail(page) && PageSlab(compound_head(page)))
+		u |= 1 << KPF_SLAB;
 
 	u |= kpf_copy_bit(k, KPF_ERROR,		PG_error);
 	u |= kpf_copy_bit(k, KPF_DIRTY,		PG_dirty);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
