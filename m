Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 933046B0279
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 15:03:18 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id o65so263309130yba.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 12:03:18 -0800 (PST)
Received: from mail-yb0-x243.google.com (mail-yb0-x243.google.com. [2607:f8b0:4002:c09::243])
        by mx.google.com with ESMTPS id f25si5451985ybj.18.2017.01.24.12.03.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 12:03:17 -0800 (PST)
Received: by mail-yb0-x243.google.com with SMTP id l23so13690908ybj.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 12:03:17 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 0/3] Fix zswap init failure behavior
Date: Tue, 24 Jan 2017 15:02:56 -0500
Message-Id: <20170124200259.16191-1-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org

If zswap fails to initialize itself at boot, it returns error from its
init function; but for built-in drivers, that does not unload them; and
more importantly, it doesn't prevent their sysfs module param interface
from being created.  In this case, changing the compressor or zpool param
will result in a WARNING because zswap didn't expect them to be changed if
initialization failed.

These patches fix that assumption, as well as allowing pool creation after
a failed initialization, if only the zpool and/or compressor creation
failed.

Dan Streetman (3):
  zswap: disable changing params if init fails
  zswap: allow initialization at boot without pool
  zswap: clear compressor or zpool param if invalid at init

 mm/zswap.c | 125 ++++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 100 insertions(+), 25 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
