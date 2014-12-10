Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id D9E506B0072
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 20:46:45 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so1736445pab.21
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:45 -0800 (PST)
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com. [209.85.192.177])
        by mx.google.com with ESMTPS id vz6si4559701pab.0.2014.12.09.17.46.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 17:46:44 -0800 (PST)
Received: by mail-pd0-f177.google.com with SMTP id ft15so1697565pdb.8
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:43 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [RFC PATCH v3 4/7] vfs: update swap_{,de}activate documentation
Date: Tue,  9 Dec 2014 17:45:45 -0800
Message-Id: <5db0fd93b5de36b81625fc3f640caff2411ef996.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>

Parameters were added to swap_activate in the same patch series that
introduced it without updating the documentation. Additionally, the
documentation claims that non-existent address space operations
swap_{in,out} are used for swap I/O, but it's (now) direct_IO.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 Documentation/filesystems/Locking | 7 ++++---
 Documentation/filesystems/vfs.txt | 7 ++++---
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index b30753c..e72b4c3 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -205,7 +205,8 @@ prototypes:
 	int (*launder_page)(struct page *);
 	int (*is_partially_uptodate)(struct page *, unsigned long, unsigned long);
 	int (*error_remove_page)(struct address_space *, struct page *);
-	int (*swap_activate)(struct file *);
+	int (*swap_activate)(struct swap_info_struct *, struct file *,
+			     sector_t *);
 	int (*swap_deactivate)(struct file *);
 
 locking rules:
@@ -230,8 +231,8 @@ migratepage:		yes (both)
 launder_page:		yes
 is_partially_uptodate:	yes
 error_remove_page:	yes
-swap_activate:		no
-swap_deactivate:	no
+swap_activate:					yes
+swap_deactivate:				no
 
 	->write_begin(), ->write_end(), ->sync_page() and ->readpage()
 may be called from the request handler (/dev/loop).
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 20bf204..46ef103 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -600,8 +600,9 @@ struct address_space_operations {
 					unsigned long);
 	void (*is_dirty_writeback) (struct page *, bool *, bool *);
 	int (*error_remove_page) (struct mapping *mapping, struct page *page);
-	int (*swap_activate)(struct file *);
-	int (*swap_deactivate)(struct file *);
+	int (*swap_activate)(struct swap_info_struct *, struct file *,
+			     sector_t *);
+	void (*swap_deactivate)(struct file *);
 };
 
   writepage: called by the VM to write a dirty page to backing store.
@@ -788,7 +789,7 @@ struct address_space_operations {
 	memory. A return value of zero indicates success,
 	in which case this file can be used to back swapspace. The
 	swapspace operations will be proxied to this address space's
-	->swap_{out,in} methods.
+	->direct_IO method for both reads and writes.
 
   swap_deactivate: Called during swapoff on files where swap_activate
 	was successful.
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
