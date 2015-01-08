Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 43C826B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 05:28:59 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id x12so1772285wgg.11
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 02:28:58 -0800 (PST)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id eq5si12407855wib.22.2015.01.08.02.28.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 02:28:58 -0800 (PST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so2294453wid.0
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 02:28:58 -0800 (PST)
Message-ID: <54AE5BE8.1050701@gmail.com>
Date: Thu, 08 Jan 2015 11:28:56 +0100
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] x86, mpx: Ensure unused arguments of prctl() MPX requests
 are 0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: mtk.manpages@gmail.com, Dave Hansen <dave.hansen@intel.com>, Qiaowei Ren <qiaowei.ren@intel.com>"Michael Kerrisk (gmail)" <mtk.manpages@gmail.com>, lkml <linux-kernel@vger.kernel.org>

From: Michael Kerrisk <mtk.manpages@gmail.com>

commit fe8c7f5cbf91124987106faa3bdf0c8b955c4cf7 added two new prctl()
operations, PR_MPX_ENABLE_MANAGEMENT and PR_MPX_DISABLE_MANAGEMENT.
However, no checks were included to ensure that unused arguments
are zero, as is done in many existing prctl()s and as should be 
done for all new prctl()s. This patch adds the required checks.

Signed-off-by: Michael Kerrisk <mtk.manpages@gmail.com>
---
 kernel/sys.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/sys.c b/kernel/sys.c
index a8c9f5a..ea9c881 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2210,9 +2210,13 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		up_write(&me->mm->mmap_sem);
 		break;
 	case PR_MPX_ENABLE_MANAGEMENT:
+		if (arg2 || arg3 || arg4 || arg5)
+			return -EINVAL;
 		error = MPX_ENABLE_MANAGEMENT(me);
 		break;
 	case PR_MPX_DISABLE_MANAGEMENT:
+		if (arg2 || arg3 || arg4 || arg5)
+			return -EINVAL;
 		error = MPX_DISABLE_MANAGEMENT(me);
 		break;
 	default:
-- 
1.9.3
-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
