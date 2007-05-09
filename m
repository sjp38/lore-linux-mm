Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id l49NBoYT029750
	for <linux-mm@kvack.org>; Wed, 9 May 2007 16:11:51 -0700
Received: from an-out-0708.google.com (andd40.prod.google.com [10.100.30.40])
	by zps38.corp.google.com with ESMTP id l49NBjXq016444
	for <linux-mm@kvack.org>; Wed, 9 May 2007 16:11:45 -0700
Received: by an-out-0708.google.com with SMTP id d40so102774and
        for <linux-mm@kvack.org>; Wed, 09 May 2007 16:11:45 -0700 (PDT)
Message-ID: <b040c32a0705091611mb35258ap334426e42d33372c@mail.gmail.com>
Date: Wed, 9 May 2007 16:11:44 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] check cpuset mems_allowed for sys_mbind
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I wonder why we don't check cpuset's mems_allowed node mask in the
sys_mbind() path?  sys_set_mempolicy() however, does the enforcement
against cpuset so process can not accidentally set mempolicy with
memory node mask that are not allowed to allocated from.  I think we
should have the equivalent check in the mbind path.   Otherwise, there
are discrepancy in what sys_mbind agrees to versus what the page
allocation policy that enforced by cpuset.  This discrepancy
subsequently causes performance surprises to the application.

Or is it left out intentionally?  for what reason?


Signed-off-by: Ken Chen <kenchen@google.com>

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d76e8eb..ef81080 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -762,7 +762,7 @@ long do_mbind(unsigned long start, unsig
 	if (end == start)
 		return 0;

-	if (mpol_check_policy(mode, nmask))
+	if (contextualize_policy(mode, nmask))
 		return -EINVAL;

 	new = mpol_new(mode, nmask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
