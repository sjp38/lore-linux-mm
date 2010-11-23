Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1DCA76B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 09:50:22 -0500 (EST)
Received: by qwj8 with SMTP id 8so52264qwj.14
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 06:50:20 -0800 (PST)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: [PATCH 2/3] Inform kernel of FADV_DONTNEED hint in sender
Date: Tue, 23 Nov 2010 09:49:51 -0500
Message-Id: <1290523792-6170-3-git-send-email-bgamari.foss@gmail.com>
In-Reply-To: <20101122103756.E236.A69D9226@jp.fujitsu.com>
References: <20101122103756.E236.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, rsync@lists.samba.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

Use the FADV_DONTNEED fadvise hint after finishing reading an origin fd
in the sender.
---
 sender.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/sender.c b/sender.c
index 59dae7d..a934bfe 100644
--- a/sender.c
+++ b/sender.c
@@ -338,6 +338,12 @@ void send_files(int f_in, int f_out)
 		if (do_progress)
 			end_progress(st.st_size);
 
+                if (do_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED) != 0) {
+                        rsyserr(FERROR_XFER, errno,
+                                "fadvise failed in sending %s",
+                                full_fname(fname));
+                }
+
 		log_item(log_code, file, &initial_stats, iflags, NULL);
 
 		if (mbuf) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
