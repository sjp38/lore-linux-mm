From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199908062312.QAA00496@google.engr.sgi.com>
Subject: [PATCH] Fix sys_mount not to free_page(0)
Date: Fri, 6 Aug 1999 16:12:32 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com, alan@lxorguk.ukuu.org.uk
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Linus/Alan,

Could you please take this patch into the 2.2 and 2.3 streams? It
basically prevents sys_mount() from trying to invoke free_page(0).
Note that copy_mount_options() might return 0 both in the case
where it allocates a page, and in the case it does not.

Thanks.

Kanoj
kanoj@engr.sgi.com

--- /usr/tmp/p_rdiff_a005Eo/super.c	Fri Aug  6 16:01:57 1999
+++ fs/super.c	Fri Aug  6 15:00:35 1999
@@ -1037,7 +1037,8 @@
 		retval = do_remount(dir_name,
 				    new_flags & ~MS_MGC_MSK & ~MS_REMOUNT,
 				    (char *) page);
-		free_page(page);
+		if (page)
+			free_page(page);
 		goto out;
 	}
 
@@ -1045,7 +1046,8 @@
 	if (retval < 0)
 		goto out;
 	fstype = get_fs_type((char *) page);
-	free_page(page);
+	if (page)
+		free_page(page);
 	retval = -ENODEV;
 	if (!fstype)		
 		goto out;
@@ -1099,7 +1101,8 @@
 	}
 	retval = do_mount(dev, dev_name, dir_name, fstype->name, flags,
 				(void *) page);
-	free_page(page);
+	if (page)
+		free_page(page);
 	if (retval)
 		goto clean_up;
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
