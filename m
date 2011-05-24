Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E38198D003B
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:16:16 -0400 (EDT)
Received: by vxk20 with SMTP id 20so7164126vxk.14
        for <linux-mm@kvack.org>; Tue, 24 May 2011 07:16:13 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 24 May 2011 16:16:13 +0200
Message-ID: <BANLkTinKonvpASu_G=Gr8C56WKvFSH5QAA@mail.gmail.com>
Subject: [RFC] [PATCH] drop_caches: add syslog entry
From: Martin Tegtmeier <martin.tegtmeier@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-mm@kvack.org

Dear Maintainers,

currently dropping the file system cache ("echo 1 >
/proc/sys/vm/drop_caches") doesn't leave any trace. However dropping
the fs cache can severely impact system behaviour and application
response times. Therefore I suggest to write a syslog entry if the
entire inode page cache is scrapped.
Since it is not an easy task to calculate the size of the droppable
filesystem cache I also suggest to add the number of dropped pages to
the syslog entry. This can be accomplished by saving the return value
of invalidate_mapping_pages().

The number of dropped pages is an important measure for capacity
planning. For the deployment of new SAP application instances we
would like to know the amount of memory that was freed from
fs caches.

Thanks,
   -Martin


 drop_caches.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)


commit b2219e84647bdf64fd6e7f9c5260c1e6bed24d58
Author: Martin Tegtmeier <martin.tegtmeier@gmail.com>
Date:   Tue May 24 15:24:20 2011 +0200

    drop_caches: add syslog entry

    Dropping the entire file system cache (inode cache) can severely
influence system behaviour
    yet currently dropping the file system cache is NOT traceable.
    This patch adds an entry to /var/log/messages with a time stamp
and the number of dropped pages.


    Signed-off-by: Martin Tegtmeier <martin.tegtmeier@gmail.com>

diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 98b77c8..f2e4dc4 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -12,6 +12,7 @@

 /* A global variable is a bit ugly, but it keeps the code simple */
 int sysctl_drop_caches;
+unsigned long pages_dropped;

 static void drop_pagecache_sb(struct super_block *sb, void *unused)
 {
@@ -28,7 +29,7 @@ static void drop_pagecache_sb(struct super_block
*sb, void *unused)
 		__iget(inode);
 		spin_unlock(&inode->i_lock);
 		spin_unlock(&inode_sb_list_lock);
-		invalidate_mapping_pages(inode->i_mapping, 0, -1);
+		pages_dropped += invalidate_mapping_pages(inode->i_mapping, 0, -1);
 		iput(toput_inode);
 		toput_inode = inode;
 		spin_lock(&inode_sb_list_lock);
@@ -55,8 +56,12 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
 	if (ret)
 		return ret;
 	if (write) {
-		if (sysctl_drop_caches & 1)
+		if (sysctl_drop_caches & 1) {
+			pages_dropped = 0;
 			iterate_supers(drop_pagecache_sb, NULL);
+			printk(KERN_INFO "drop_caches: %lu pages dropped from inode cache\n",
+				pages_dropped);
+		}
 		if (sysctl_drop_caches & 2)
 			drop_slab();
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
