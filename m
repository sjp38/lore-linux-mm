Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1336B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 04:08:32 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id n5so256027070pfn.2
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 01:08:32 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id v25si6214519pfa.203.2016.03.21.01.08.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 01:08:31 -0700 (PDT)
From: Chen Feng <puck.chen@hisilicon.com>
Subject: Delete flush cache all in arm64 platform.
Message-ID: <56EFABD3.7060700@hisilicon.com>
Date: Mon, 21 Mar 2016 16:07:47 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, catalin.marinas@arm.com
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, labbott@redhat.com, xuyiping@hisilicon.com, suzhuangluan@hisilicon.com, saberlily.xia@hisilicon.com, dan.zhao@hisilicon.com

Hi Mark,

With 68234df4ea7939f98431aa81113fbdce10c4a84b
arm64: kill flush_cache_all()
The documented semantics of flush_cache_all are not possible to provide
for arm64 (short of flushing the entire physical address space by VA),
and there are currently no users; KVM uses VA maintenance exclusively,
cpu_reset is never called, and the only two users outside of arch code
cannot be built for arm64.

While cpu_soft_reset and related functions (which call flush_cache_all)
were thought to be useful for kexec, their current implementations only
serve to mask bugs. For correctness kexec will need to perform
maintenance by VA anyway to account for system caches, line migration,
and other subtleties of the cache architecture. As the extent of this
cache maintenance will be kexec-specific, it should probably live in the
kexec code.

This patch removes flush_cache_all, and related unused components,
preventing further abuse.


This patch delete the flush_cache_all interface.

But if we use VA to flush cache to do cache-coherency with other master(eg:gpu)

We must iterate over the sg-list to flush by va to pa.

In this way, the iterate of sg-list may cost too much time(sg-table to sg-list) if
the sglist is too long. Take a look at the ion_pages_sync_for_device in ion.

The driver(eg: ION) need to use this interface(flush cache all) to *improve the efficiency*.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
