Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8A16B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:13:10 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u81so14804988wmu.3
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 03:13:10 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id u1si5685897wju.85.2016.08.19.03.13.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 03:13:08 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q128so2821490wma.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 03:13:08 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] fs, proc: optimize smaps output formatting
Date: Fri, 19 Aug 2016 12:12:58 +0200
Message-Id: <1471601580-17999-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joe Perches <joe@perches.com>, Jann Horn <jann@thejh.net>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
this is rebased on top of next-20160818. Joe has pointed out that
meminfo is using a similar trick so I have extracted guts of what we
have already and made it more generic to be usable for smaps as well
(patch 1). The second patch then replaces seq_printf with seq_write
and show_val_kb which should have smaller overhead and my measuring (in
kvm) shows quite a nice improvements. I hope kvm is not playing tricks
on me but I didn't get to test on a real HW.

Michal Hocko (2):
      proc, meminfo: abstract show_val_kb
      proc, smaps: reduce printing overhead

 fs/proc/internal.h | 17 ++++++++++
 fs/proc/meminfo.c  | 93 ++++++++++++++++++++++++++----------------------------
 fs/proc/task_mmu.c | 58 +++++++++++-----------------------
 3 files changed, 81 insertions(+), 87 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
