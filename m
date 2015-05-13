Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id AC40A6B0071
	for <linux-mm@kvack.org>; Wed, 13 May 2015 09:08:37 -0400 (EDT)
Received: by wgic8 with SMTP id c8so42979984wgi.1
        for <linux-mm@kvack.org>; Wed, 13 May 2015 06:08:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ch5si8427295wib.31.2015.05.13.06.08.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 May 2015 06:08:29 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/9 v5] Helper to abstract vma handling in media layer
Date: Wed, 13 May 2015 15:08:06 +0200
Message-Id: <1431522495-4692-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, mgorman@suse.de, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org, Jan Kara <jack@suse.cz>

  Hello,

I'm sending the fifth version of my patch series to abstract vma handling
from the various media drivers. The patches got some review from mm people and
testing from device driver guys so unless someone objects, patches will be
queued in media tree for the next merge window.

After this patch set drivers have to know much less details about vmas, their
types, and locking. Also quite some code is removed from them. As a bonus
drivers get automatically VM_FAULT_RETRY handling. The primary motivation for
this series is to remove knowledge about mmap_sem locking from as many places a
possible so that we can change it with reasonable effort.

The core of the series is the new helper get_vaddr_frames() which is given a
virtual address and it fills in PFNs / struct page pointers (depending on VMA
type) into the provided array. If PFNs correspond to normal pages it also grabs
references to these pages. The difference from get_user_pages() is that this
function can also deal with pfnmap, and io mappings which is what the media
drivers need.

I have tested the patches with vivid driver so at least vb2 code got some
exposure. Conversion of other drivers was just compile-tested (for x86 so e.g.
exynos driver which is only for Samsung platform is completely untested).

								Honza
Changes since v4:
* Minor cleanups and fixes pointed out by Mel and Vlasta
* Added Acked-by tags

Changes since v3:
* Added include <linux/vmalloc.h> into mm/gup.c as it's needed for some archs
* Fixed error path for exynos driver

Changes since v2:
* Renamed functions and structures as Mel suggested
* Other minor changes suggested by Mel
* Rebased on top of 4.1-rc2
* Changed functions to get pointer to array of pages / pfns to perform
  conversion if necessary. This fixes possible issue in the omap I may have
  introduced in v2 and generally makes the API less errorprone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
