Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 046F26B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 05:30:09 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] Describe race of direct read and fork for unaligned buffers
Date: Mon, 30 Apr 2012 11:30:07 +0200
Message-Id: <1335778207-6511-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, mgorman@suse.de, Jeff Moyer <jmoyer@redhat.com>

This is a long standing problem (or a surprising feature) in our implementation
of get_user_pages() (used by direct IO). Since several attempts to fix it
failed (e.g.
http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg06542.html, or
http://lkml.indiana.edu/hypermail/linux/kernel/0903.1/01498.html refused in
http://comments.gmane.org/gmane.linux.kernel.mm/31569) and it's not completely
clear whether we really want to fix it given the costs, let's at least document
it.

CC: mgorman@suse.de
CC: Jeff Moyer <jmoyer@redhat.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---

--- a/man2/open.2	2012-04-27 00:07:51.736883092 +0200
+++ b/man2/open.2	2012-04-27 00:29:59.489892980 +0200
@@ -769,7 +769,12 @@
 and the file offset must all be multiples of the logical block size
 of the file system.
 Under Linux 2.6, alignment to 512-byte boundaries
-suffices.
+suffices. However, if the user buffer is not page aligned and direct read
+runs in parallel with a
+.BR fork (2)
+of the reader process, it may happen that the read data is split between
+pages owned by the original process and its child. Thus effectively read
+data is corrupted.
 .LP
 The
 .B O_DIRECT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
