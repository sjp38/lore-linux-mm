Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A09148D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 18:31:00 -0500 (EST)
From: Mandeep Singh Baines <msb@chromium.org>
Subject: [PATCH 4/6] TTY: use appropriate printk priority level
Date: Wed, 26 Jan 2011 15:29:28 -0800
Message-Id: <1296084570-31453-5-git-send-email-msb@chromium.org>
In-Reply-To: <20110125235700.GR8008@google.com>
References: <20110125235700.GR8008@google.com>
Sender: owner-linux-mm@kvack.org
To: gregkh@suse.de, rjw@sisk.pl, mingo@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mandeep Singh Baines <msb@chromium.org>
List-ID: <linux-mm.kvack.org>

printk()s without a priority level default to KERN_WARNING. To reduce
noise at KERN_WARNING, this patch set the priority level appriopriately
for unleveled printks()s. This should be useful to folks that look at
dmesg warnings closely.

Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
---
 drivers/tty/vt/vt.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/tty/vt/vt.c b/drivers/tty/vt/vt.c
index 76407ec..511d80e 100644
--- a/drivers/tty/vt/vt.c
+++ b/drivers/tty/vt/vt.c
@@ -2158,7 +2158,7 @@ static int do_con_write(struct tty_struct *tty, const unsigned char *buf, int co
 	currcons = vc->vc_num;
 	if (!vc_cons_allocated(currcons)) {
 	    /* could this happen? */
-		printk_once("con_write: tty %d not allocated\n", currcons+1);
+		printk_once(KERN_WARNING "con_write: tty %d not allocated\n", currcons+1);
 	    release_console_sem();
 	    return 0;
 	}
@@ -2940,7 +2940,7 @@ static int __init con_init(void)
 	gotoxy(vc, vc->vc_x, vc->vc_y);
 	csi_J(vc, 0);
 	update_screen(vc);
-	printk("Console: %s %s %dx%d",
+	pr_info("Console: %s %s %dx%d",
 		vc->vc_can_do_color ? "colour" : "mono",
 		display_desc, vc->vc_cols, vc->vc_rows);
 	printable = 1;
@@ -3103,7 +3103,7 @@ static int bind_con_driver(const struct consw *csw, int first, int last,
 			clear_buffer_attributes(vc);
 	}
 
-	printk("Console: switching ");
+	pr_info("Console: switching ");
 	if (!deflt)
 		printk("consoles %d-%d ", first+1, last+1);
 	if (j >= 0) {
@@ -3804,7 +3804,8 @@ void do_unblank_screen(int leaving_gfx)
 		return;
 	if (!vc_cons_allocated(fg_console)) {
 		/* impossible */
-		printk("unblank_screen: tty %d not allocated ??\n", fg_console+1);
+		pr_warning("unblank_screen: tty %d not allocated ??\n",
+			   fg_console+1);
 		return;
 	}
 	vc = vc_cons[fg_console].d;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
