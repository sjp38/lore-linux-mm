Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA36F6B000D
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 12:44:02 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id u14-v6so1116662ybi.3
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 09:44:02 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 131-v6si1081410ybk.15.2018.10.23.09.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 09:44:01 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [RFC PATCH] mm: don't reclaim inodes with many attached pages
Date: Tue, 23 Oct 2018 16:43:29 +0000
Message-ID: <20181023164302.20436-1-guro@fb.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

Spock reported that the commit 172b06c32b94 ("mm: slowly shrink slabs
with a relatively small number of objects") leads to a regression on
his setup: periodically the majority of the pagecache is evicted
without an obvious reason, while before the change the amount of free
memory was balancing around the watermark.

The reason behind is that the mentioned above change created some
minimal background pressure on the inode cache. The problem is that
if an inode is considered to be reclaimed, all belonging pagecache
page are stripped, no matter how many of them are there. So, if a huge
multi-gigabyte file is cached in the memory, and the goal is to
reclaim only few slab objects (unused inodes), we still can eventually
evict all gigabytes of the pagecache at once.

The workload described by Spock has few large non-mapped files in the
pagecache, so it's especially noticeable.

To solve the problem let's postpone the reclaim of inodes, which have
more than 1 attached page. Let's wait until the pagecache pages will
be evicted naturally by scanning the corresponding LRU lists, and only
then reclaim the inode structure.

Reported-by: Spock <dairinin@gmail.com>
Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 fs/inode.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 73432e64f874..0cd47fe0dbe5 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -730,8 +730,11 @@ static enum lru_status inode_lru_isolate(struct list_h=
ead *item,
 		return LRU_REMOVED;
 	}
=20
-	/* recently referenced inodes get one more pass */
-	if (inode->i_state & I_REFERENCED) {
+	/*
+	 * Recently referenced inodes and inodes with many attached pages
+	 * get one more pass.
+	 */
+	if (inode->i_state & I_REFERENCED || inode->i_data.nrpages > 1) {
 		inode->i_state &=3D ~I_REFERENCED;
 		spin_unlock(&inode->i_lock);
 		return LRU_ROTATE;
--=20
2.17.2
