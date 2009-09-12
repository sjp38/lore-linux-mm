Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A69976B004D
	for <linux-mm@kvack.org>; Sat, 12 Sep 2009 07:22:01 -0400 (EDT)
Date: Sat, 12 Sep 2009 12:21:27 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH] fix undefined reference to user_shm_unlock
In-Reply-To: <Pine.LNX.4.64.0909121212560.488@sister.anvils>
Message-ID: <Pine.LNX.4.64.0909121218020.488@sister.anvils>
References: <alpine.LRH.2.00.0908241110420.21562@tundra.namei.org>
 <Pine.LNX.4.64.0908241258070.27704@sister.anvils> <4A929BF5.2050105@gmail.com>
  <Pine.LNX.4.64.0908241532470.9322@sister.anvils>
 <8bd0f97a0909110703o4d496a45jddc0d7d6fd8674b4@mail.gmail.com>
 <Pine.LNX.4.64.0909121212560.488@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>, Stefan Huber <shuber2@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Meerwald <pmeerw@cosy.sbg.ac.at>, James Morris <jmorris@namei.org>, William Irwin <wli@movementarian.org>, Mel Gorman <mel@csn.ul.ie>, Ravikiran G Thirumalai <kiran@scalex86.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

My 353d5c30c666580347515da609dd74a2b8e9b828 "mm: fix hugetlb bug due to
user_shm_unlock call" broke the CONFIG_SYSVIPC !CONFIG_MMU build of both
2.6.31 and 2.6.30.6: "undefined reference to `user_shm_unlock'".

gcc didn't understand my comment! so couldn't figure out to optimize
away user_shm_unlock() from the error path in the hugetlb-less case,
as it does elsewhere.  Help it to do so, in a language it understands.

Reported-by: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: stable@kernel.org
---

 ipc/shm.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 2.6.31/ipc/shm.c	2009-09-09 23:13:59.000000000 +0100
+++ linux/ipc/shm.c	2009-09-12 11:27:00.000000000 +0100
@@ -410,7 +410,7 @@ static int newseg(struct ipc_namespace *
 	return error;
 
 no_id:
-	if (shp->mlock_user)	/* shmflg & SHM_HUGETLB case */
+	if (is_file_hugepages(file) && shp->mlock_user)
 		user_shm_unlock(size, shp->mlock_user);
 	fput(file);
 no_file:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
