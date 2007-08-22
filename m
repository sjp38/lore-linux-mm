Date: Wed, 22 Aug 2007 15:14:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Do not fail if we cannot register a slab with sysfs
Message-ID: <Pine.LNX.4.64.0708221512260.17282@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Do not BUG() if we cannot register a slab with sysfs. Just print an
error. The only consequence of not registering is that the slab cache
is not visible via /sys/slab. A BUG() may not be visible that
early during boot and we have had multiple issues here already.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 930e6dc..9a57d46 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3813,7 +3813,9 @@ static int __init slab_sysfs_init(void)
 
 	list_for_each_entry(s, &slab_caches, list) {
 		err = sysfs_slab_add(s);
-		BUG_ON(err);
+		if (err)
+			printk(KERN_ERR "SLUB: Unable to add boot slab %s"
+						" to sysfs\n", s->name);
 	}
 
 	while (alias_list) {
@@ -3821,7 +3823,9 @@ static int __init slab_sysfs_init(void)
 
 		alias_list = alias_list->next;
 		err = sysfs_slab_alias(al->s, al->name);
-		BUG_ON(err);
+		if (err)
+			printk(KERN_ERR "SLUB: Unable to add boot slab alias"
+					" %s to sysfs\n", s->name);
 		kfree(al);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
