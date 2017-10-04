Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71A996B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 15:00:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b189so9827820wmd.5
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 12:00:10 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t43si5231021edh.161.2017.10.04.12.00.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Oct 2017 12:00:09 -0700 (PDT)
Date: Wed, 4 Oct 2017 14:59:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/2] tty: fall back to N_NULL if switching to N_TTY fails
 during hangup
Message-ID: <20171004185959.GC2136@cmpxchg.org>
References: <20171003225504.GA966@cmpxchg.org>
 <20171004185813.GA2136@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171004185813.GA2136@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alan Cox <alan@llwyncelyn.cymru>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

We have seen NULL-pointer dereference crashes in tty->disc_data when
the N_TTY fallback driver failed to open during hangup. The immediate
cause of this open to fail has been addressed in the preceding patch
to vmalloc(), but this code could be more robust.

As Alan pointed out in 8a8dabf2dd68 ("tty: handle the case where we
cannot restore a line discipline"), the N_TTY driver, historically the
safe fallback that could never fail, can indeed fail, but the
surrounding code is not prepared to handle this. To avoid crashes he
added a new N_NULL driver to take N_TTY's place as the last resort.

Hook that fallback up to the hangup path. Update tty_ldisc_reinit() to
reflect the reality that n_tty_open can indeed fail.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 drivers/tty/tty_ldisc.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/tty/tty_ldisc.c b/drivers/tty/tty_ldisc.c
index 2fe216b276e2..84a8ac2a779f 100644
--- a/drivers/tty/tty_ldisc.c
+++ b/drivers/tty/tty_ldisc.c
@@ -694,10 +694,8 @@ int tty_ldisc_reinit(struct tty_struct *tty, int disc)
 	tty_set_termios_ldisc(tty, disc);
 	retval = tty_ldisc_open(tty, tty->ldisc);
 	if (retval) {
-		if (!WARN_ON(disc == N_TTY)) {
-			tty_ldisc_put(tty->ldisc);
-			tty->ldisc = NULL;
-		}
+		tty_ldisc_put(tty->ldisc);
+		tty->ldisc = NULL;
 	}
 	return retval;
 }
@@ -752,8 +750,9 @@ void tty_ldisc_hangup(struct tty_struct *tty, bool reinit)
 
 	if (tty->ldisc) {
 		if (reinit) {
-			if (tty_ldisc_reinit(tty, tty->termios.c_line) < 0)
-				tty_ldisc_reinit(tty, N_TTY);
+			if (tty_ldisc_reinit(tty, tty->termios.c_line) < 0 &&
+			    tty_ldisc_reinit(tty, N_TTY) < 0)
+				WARN_ON(tty_ldisc_reinit(tty, N_NULL) < 0);
 		} else
 			tty_ldisc_kill(tty);
 	}
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
