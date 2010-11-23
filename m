Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B37226B0089
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 09:50:24 -0500 (EST)
Received: by mail-qw0-f41.google.com with SMTP id 8so52264qwj.14
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 06:50:23 -0800 (PST)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: [PATCH 3/3] Inform kernel of FADV_DONTNEED hint in receiver
Date: Tue, 23 Nov 2010 09:49:52 -0500
Message-Id: <1290523792-6170-4-git-send-email-bgamari.foss@gmail.com>
In-Reply-To: <20101122103756.E236.A69D9226@jp.fujitsu.com>
References: <20101122103756.E236.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, rsync@lists.samba.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

Use the FADV_DONTNEED fadvise hint after finishing writing to a
destinataion fd in the receiver.
---
 receiver.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/receiver.c b/receiver.c
index 39c5e49..33b21fb 100644
--- a/receiver.c
+++ b/receiver.c
@@ -721,6 +721,12 @@ int recv_files(int f_in, char *local_name)
 		recv_ok = receive_data(f_in, fnamecmp, fd1, st.st_size,
 				       fname, fd2, F_LENGTH(file));
 
+                if (do_fadvise(fd2, 0, 0, POSIX_FADV_DONTNEED) != 0) {
+                        rsyserr(FERROR_XFER, errno,
+                                "fadvise failed in writing %s",
+                                full_fname(fname));
+                }
+
 		log_item(log_code, file, &initial_stats, iflags, NULL);
 
 		if (fd1 != -1)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
