Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id A0DFE6B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 15:11:27 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p63so174368224wmp.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 12:11:27 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id ip7si51233916wjb.98.2016.02.09.12.11.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 12:11:26 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id g62so140661wme.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 12:11:26 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 0/5] pre-decrement in error paths considered harmful
Date: Tue,  9 Feb 2016 21:11:11 +0100
Message-Id: <1455048677-19882-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, netdev@vger.kernel.org, linux-rdma@vger.kernel.org, linux-mm@kvack.org
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>

There are a few instances of

  for (i = 0; i < FOO; ++i) {
    ret = do_stuff(i)
    if (ret)
      goto err;
  }
  ...
  err:
  while (--i)
    undo_stuff(i);

At best, this fails to undo_stuff for i==0, but if i==0 was the case
that failed, we'll end up with an "infinite" loop in the error path
doing nasty stuff.

These were found with a simple coccinelle script

@@
expression i;
identifier l;
statement S;
@@
* l:
* while (--i)
    S

(and there were no false positives).

There's no dependencies between the patches; I just wanted to include
a common cover letter with a little background info.

Rasmus Villemoes (5):
  drm/gma500: fix error path in gma_intel_setup_gmbus()
  drm/i915: fix error path in intel_setup_gmbus()
  net/mlx4: fix some error handling in mlx4_multi_func_init()
  net: sxgbe: fix error paths in sxgbe_platform_probe()
  mm/backing-dev.c: fix error path in wb_init()

 drivers/gpu/drm/gma500/intel_gmbus.c                | 2 +-
 drivers/gpu/drm/i915/intel_i2c.c                    | 2 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c            | 4 ++--
 drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c | 4 ++--
 mm/backing-dev.c                                    | 2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
