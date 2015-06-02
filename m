Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5E36B0038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 11:12:14 -0400 (EDT)
Received: by oihb142 with SMTP id b142so127839606oih.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 08:12:14 -0700 (PDT)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id xs4si1750463obc.67.2015.06.02.08.12.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 08:12:13 -0700 (PDT)
Received: by obbnx5 with SMTP id nx5so129747652obb.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 08:12:13 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 0/5] zswap: make params runtime changeable
Date: Tue,  2 Jun 2015 11:11:52 -0400
Message-Id: <1433257917-13090-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

This patch series allows setting all zswap params at runtime, instead
of only being settable at boot-time.

The changes to zswap are rather large, due to the creation of zswap pools,
which contain both a compressor function as well as a zpool.  When either
the compressor or zpool param is changed at runtime, a new zswap pool is
created with the new compressor and zpool, and used for all new compressed
pages.  Any old zswap pools that still contain pages are retained only to
load pages from, and destroyed once they become empty.

One notable change required for this to work is to split the currently
global kernel param mutex into a global mutex only for built-in params,
and a per-module mutex for loadable module params.  The reason this change
is required is because zswap's compressor and zpool param handler callback
functions attempt to load, via crypto_has_comp() and the new zpool_has_pool()
functions, any required compressor or zpool modules.  The problem there is
that the zswap param callback functions run while the global param mutex is
locked, but when they attempt to load another module, if the loading module
has any params set e.g. via /etc/modprobe.d/*.conf, modprobe will also try
to take the global param mutex, and a deadlock will result, with the mutex
held by the zswap param callback which is waiting for modprobe, but modprobe
waiting for the mutex to change the loading module's param.  Using a
per-module mutex for all loadable modules prevents this, since each module
will take its own mutex and never conflict with another module's param
changes.


Dan Streetman (5):
  zpool: add zpool_has_pool()
  module: add per-module params lock
  zswap: runtime enable/disable
  zswap: dynamic pool creation
  zswap: change zpool/compressor at runtime

 arch/um/drivers/hostaudio_kern.c                 |  20 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |   6 +-
 drivers/net/wireless/libertas_tf/if_usb.c        |   6 +-
 drivers/usb/atm/ueagle-atm.c                     |   4 +-
 drivers/video/fbdev/vt8623fb.c                   |   4 +-
 include/linux/module.h                           |   1 +
 include/linux/moduleparam.h                      |  67 +--
 include/linux/zpool.h                            |   2 +
 kernel/module.c                                  |   1 +
 kernel/params.c                                  |  45 +-
 mm/zpool.c                                       |  25 +
 mm/zswap.c                                       | 696 +++++++++++++++++------
 net/mac80211/rate.c                              |   4 +-
 13 files changed, 640 insertions(+), 241 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
