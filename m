Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id DC68A6B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 08:41:12 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fb10so8668614pad.16
        for <linux-mm@kvack.org>; Thu, 03 Jan 2013 05:41:12 -0800 (PST)
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20130102204712.GA17806@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
	 <20130102200848.GA4500@dcvr.yhbt.net>
	 <20130102204712.GA17806@dcvr.yhbt.net>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Jan 2013 05:41:09 -0800
Message-ID: <1357220469.21409.24574.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 2013-01-02 at 20:47 +0000, Eric Wong wrote:
> Eric Wong <normalperson@yhbt.net> wrote:
> > [1] my full setup is very strange.
> > 
> >     Other than the FUSE component I forgot to mention, little depends on
> >     the kernel.  With all this, the standalone toosleepy can get stuck.
> >     I'll try to reproduce it with less...
> 
> I just confirmed my toosleepy processes will get stuck while just
> doing "rsync -a" between local disks.  So this does not depend on
> sendfile or FUSE to reproduce.
> --

How do you tell your 'toosleepy' is stuck ?

If reading its output, you should change its logic, there is no
guarantee the recv() will deliver exactly 16384 bytes each round.

With the following patch, I cant reproduce the 'apparent stuck'

diff --git a/toosleepy.c b/toosleepy.c
index e64b7cd..df3610f 100644
--- a/toosleepy.c
+++ b/toosleepy.c
@@ -15,6 +15,7 @@
 #include <fcntl.h>
 #include <assert.h>
 #include <limits.h>
+#include <time.h>
 
 struct receiver {
 	int rfd;
@@ -53,6 +54,7 @@ static void * recv_loop(void *p)
 	ssize_t r, s;
 	size_t received = 0;
 	size_t sent = 0;
+	time_t t0 = time(NULL), t1;
 
 	for (;;) {
 		r = recv(rcvr->rfd, buf, sizeof(buf), 0);
@@ -80,9 +82,12 @@ static void * recv_loop(void *p)
 				write(-1, buf, sizeof(buf));
 			}
 		}
-		if ((received % (sizeof(buf) * sizeof(buf) * 16) == 0))
+		t1 = time(NULL);
+		if (t1 != t0) {
 			dprintf(2, " %d progress: %zu\n",
 			        rcvr->rfd, received);
+			t0 = t1;
+		}
 	}
 	dprintf(2, "%d got: %zu\n", rcvr->rfd, received);
 	if (rcvr->sfd >= 0) {





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
