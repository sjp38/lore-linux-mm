Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB6466B0260
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:37:21 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so69647032lfw.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:37:21 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id mm1si57898wjb.162.2016.07.15.03.37.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 03:37:20 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id q128so1755778wma.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:37:20 -0700 (PDT)
From: Topi Miettinen <toiwoton@gmail.com>
Subject: [PATCH 05/14] resource limits: track highwater mark of stack size
Date: Fri, 15 Jul 2016 13:35:52 +0300
Message-Id: <1468578983-28229-6-git-send-email-toiwoton@gmail.com>
In-Reply-To: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Topi Miettinen <toiwoton@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Track maximum stack size, to be able to configure
RLIMIT_STACK resource limits. The information is available
with taskstats and cgroupstats netlink socket.

Signed-off-by: Topi Miettinen <toiwoton@gmail.com>
---
 mm/mmap.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 0b10f56..305c456 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2019,6 +2019,8 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 	if (security_vm_enough_memory_mm(mm, grow))
 		return -ENOMEM;
 
+	update_resource_highwatermark(RLIMIT_STACK, actual_size);
+
 	return 0;
 }
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
