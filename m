Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 4D6156B0185
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 10:43:16 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id up7so2471799pbc.1
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 07:43:15 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v4, part3 09/41] mm: use totalram_pages instead of num_physpages at runtime
Date: Sat,  6 Apr 2013 22:32:08 +0800
Message-Id: <1365258760-30821-10-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
References: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Miklos Szeredi <miklos@szeredi.hu>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, James Morris <jmorris@namei.org>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Patrick McHardy <kaber@trash.net>, fuse-devel@lists.sourceforge.net, netdev@vger.kernel.org

The global variable num_physpages is scheduled to be removed, so use
totalram_pages instead of num_physpages at runtime.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: fuse-devel@lists.sourceforge.net
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 fs/fuse/inode.c          |    2 +-
 kernel/power/snapshot.c  |    4 ++--
 net/ipv4/inet_fragment.c |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 137185c..0bca95d 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -782,7 +782,7 @@ static const struct super_operations fuse_super_operations = {
 static void sanitize_global_limit(unsigned *limit)
 {
 	if (*limit == 0)
-		*limit = ((num_physpages << PAGE_SHIFT) >> 13) /
+		*limit = ((totalram_pages << PAGE_SHIFT) >> 13) /
 			 sizeof(struct fuse_req);
 
 	if (*limit >= 1 << 16)
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 0de2857..8b5d1cd 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1651,7 +1651,7 @@ unsigned long snapshot_get_image_size(void)
 static int init_header(struct swsusp_info *info)
 {
 	memset(info, 0, sizeof(struct swsusp_info));
-	info->num_physpages = num_physpages;
+	info->num_physpages = get_num_physpages();
 	info->image_pages = nr_copy_pages;
 	info->pages = snapshot_get_image_size();
 	info->size = info->pages;
@@ -1795,7 +1795,7 @@ static int check_header(struct swsusp_info *info)
 	char *reason;
 
 	reason = check_image_kernel(info);
-	if (!reason && info->num_physpages != num_physpages)
+	if (!reason && info->num_physpages != get_num_physpages())
 		reason = "memory size";
 	if (reason) {
 		printk(KERN_ERR "PM: Image mismatch: %s\n", reason);
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 2bff045..425eb23 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -83,7 +83,7 @@ void inet_frags_init(struct inet_frags *f)
 
 	rwlock_init(&f->lock);
 
-	f->rnd = (u32) ((num_physpages ^ (num_physpages>>7)) ^
+	f->rnd = (u32) ((totalram_pages ^ (totalram_pages >> 7)) ^
 				   (jiffies ^ (jiffies >> 6)));
 
 	setup_timer(&f->secret_timer, inet_frag_secret_rebuild,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
