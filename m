Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 26AA86B0038
	for <linux-mm@kvack.org>; Sat, 15 Oct 2016 07:56:41 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ry6so139388840pac.1
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 04:56:41 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id bl9si18676872pab.152.2016.10.15.04.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Oct 2016 04:56:40 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id s8so9084520pfj.2
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 04:56:40 -0700 (PDT)
Date: Sat, 15 Oct 2016 13:56:32 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH v5] z3fold: add shrinker
Message-Id: <20161015135632.541010b55bec496e2cae056e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>


This patch set implements shrinker for z3fold, preceded by some
code optimizations and preparations that I thought would be
reasonable to have as separate patches.

This patch set has been verified on x86 and on Qemu emulating
Versatile Express. fio results for the resulting code are:
Run status group 0 (all jobs):
  WRITE: io=3200.0MB, aggrb=13095KB/s, minb=3273KB/s, maxb=3284KB/s, mint=249447msec, maxt=250214msec

Run status group 1 (all jobs):
   READ: io=3200.0MB, aggrb=28992KB/s, minb=7248KB/s, maxb=7273KB/s, mint=112623msec, maxt=113021msec

Run status group 2 (all jobs):
   READ: io=1595.2MB, aggrb=8825KB/s, minb=2194KB/s, maxb=2224KB/s, mint=184517msec, maxt=185077msec
  WRITE: io=1604.9MB, aggrb=8879KB/s, minb=2207KB/s, maxb=2245KB/s, mint=184519msec, maxt=185079msec

Run status group 3 (all jobs):
   READ: io=1600.6MB, aggrb=8413KB/s, minb=2084KB/s, maxb=2132KB/s, mint=193286msec, maxt=194803msec
  WRITE: io=1599.5MB, aggrb=8406KB/s, minb=2099KB/s, maxb=2120KB/s, mint=193290msec, maxt=194825msec

Disk stats (read/write):
  zram0: ios=1636792/1638952, merge=0/0, ticks=169250/462410, in_queue=633700, util=85.33%

Just for comparison, zsmalloc gives slightly worse results:
Run status group 0 (all jobs):
  WRITE: io=3200.0MB, aggrb=12827KB/s, minb=3206KB/s, maxb=3230KB/s, mint=253603msec, maxt=255450msec

Run status group 1 (all jobs):
   READ: io=3200.0MB, aggrb=26184KB/s, minb=6546KB/s, maxb=6556KB/s, mint=124940msec, maxt=125144msec

Run status group 2 (all jobs):
   READ: io=1595.2MB, aggrb=8549KB/s, minb=2123KB/s, maxb=2162KB/s, mint=190151msec, maxt=191049msec
  WRITE: io=1604.9MB, aggrb=8601KB/s, minb=2145KB/s, maxb=2172KB/s, mint=190153msec, maxt=191051msec

Run status group 3 (all jobs):
   READ: io=1600.6MB, aggrb=8147KB/s, minb=2026KB/s, maxb=2049KB/s, mint=200339msec, maxt=201154msec
  WRITE: io=1599.5MB, aggrb=8142KB/s, minb=2023KB/s, maxb=2062KB/s, mint=200343msec, maxt=201158msec

Disk stats (read/write):
  zram0: ios=1637032/1639304, merge=0/0, ticks=175840/458740, in_queue=637140, util=82.48%

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
