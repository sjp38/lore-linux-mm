Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0AAEB6B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 04:19:59 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so30958247pac.11
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 01:19:58 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id ks7si22676376pab.82.2015.01.12.01.19.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 12 Jan 2015 01:19:57 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NI200HC64RWJY90@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 12 Jan 2015 09:23:56 +0000 (GMT)
From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 0/5] kstrdup optimization
Date: Mon, 12 Jan 2015 10:18:38 +0100
Message-id: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrzej Hajda <a.hajda@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org, andi@firstfloor.org, andi@lisas.de, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

Hi,

kstrdup if often used to duplicate strings where neither source neither
destination will be ever modified. In such case we can just reuse the source
instead of duplicating it. The problem is that we must be sure that
the source is non-modifiable and its life-time is long enough.

I suspect the good candidates for such strings are strings located in kernel
.rodata section, they cannot be modifed because the section is read-only and
their life-time is equal to kernel life-time.

This small patchset proposes alternative version of kstrdup - kstrdup_const,
which returns source string if it is located in .rodata otherwise it fallbacks
to kstrdup.
To verify if the source is in .rodata function checks if the address is between
sentinels __start_rodata, __end_rodata. I guess it should work with all
architectures.

The main patch is accompanied by four patches constifying kstrdup for cases
where situtation described above happens frequently.

As I have tested the patchset on mobile platform (exynos4210-trats) it saves
3272 string allocations. Since minimal allocation is 32 or 64 bytes depending
on Kconfig options the patchset saves respectively about 100KB or 200KB of memory.

The patchset is based on 3.19-rc4.

This patchset have been already sent to the list as RFC.
Current version have following changes:
- added missing export,
- added kerneldocs,
- constified kstrdup in VFS devname allocation.

Regards
Andrzej


Andrzej Hajda (5):
  mm/util: add kstrdup_const
  kernfs: convert node name allocation to kstrdup_const
  clk: convert clock name allocations to kstrdup_const
  mm/slab: convert cache name allocations to kstrdup_const
  fs/namespace: convert devname allocation to kstrdup_const

 drivers/clk/clk.c      | 12 ++++++------
 fs/kernfs/dir.c        | 12 ++++++------
 fs/namespace.c         |  6 +++---
 include/linux/string.h |  3 +++
 mm/slab_common.c       |  6 +++---
 mm/util.c              | 38 ++++++++++++++++++++++++++++++++++++++
 6 files changed, 59 insertions(+), 18 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
