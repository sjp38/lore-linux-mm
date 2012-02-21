Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id D5D596B004A
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 14:54:04 -0500 (EST)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 55/73] fallthru: tmpfs support for lookup of d_type/d_ino in
 fallthrus [ver #2]
Date: Tue, 21 Feb 2012 18:04:22 +0000
Message-ID: <20120221180422.25235.59500.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120221175721.25235.8901.stgit@warthog.procyon.org.uk>
References: <20120221175721.25235.8901.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, viro@ZenIV.linux.org.uk, valerie.aurora@gmail.com
Cc: linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

From: Valerie Aurora <vaurora@redhat.com>

Now that we have full union lookup support, lookup the true d_type and
d_ino of a fallthru.

Original-author: Valerie Aurora <vaurora@redhat.com>
Signed-off-by: David Howells <dhowells@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
---

 fs/libfs.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index 43f1ac2..bd9388f 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -143,6 +143,7 @@ int dcache_readdir(struct file * filp, void * dirent, filldir_t filldir)
 	ino_t ino;
 	char d_type;
 	int i = filp->f_pos;
+	int err = 0;
 
 	switch (i) {
 		case 0:
@@ -177,9 +178,13 @@ int dcache_readdir(struct file * filp, void * dirent, filldir_t filldir)
 				spin_unlock(&next->d_lock);
 				spin_unlock(&dentry->d_lock);
 				if (d_is_fallthru(next)) {
-					/* XXX placeholder until generic_readdir_fallthru() arrives */
-					ino = 1;
-					d_type = DT_UNKNOWN;
+					/* On tmpfs, should only fail with ENOMEM, EIO, etc. */
+					err = generic_readdir_fallthru(filp->f_path.dentry,
+								       next->d_name.name,
+								       next->d_name.len,
+								       &ino, &d_type);
+					if (err)
+						return err;
 				} else {
 					ino = next->d_inode->i_ino;
 					d_type = dt_type(next->d_inode);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
