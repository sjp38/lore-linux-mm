Received: by an-out-0708.google.com with SMTP id c10so209372ana
        for <linux-mm@kvack.org>; Fri, 11 May 2007 00:05:51 -0700 (PDT)
Message-ID: <89af10f90705102358q58d4b07bmbaba1e511edd928b@mail.gmail.com>
Date: Fri, 11 May 2007 12:28:51 +0530
From: "ashwin chaugule" <ashwin.chaugule@gmail.com>
Subject: Re: [PATCH] Bug in mm/thrash.c function grab_swap_token()
In-Reply-To: <1178866168.4497.6.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070510122359.GA16433@srv1-m700-lanp.koti>
	 <20070510152957.edb26df3.akpm@linux-foundation.org>
	 <1178866168.4497.6.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mikukkon@iki.fi, Mika Kukkonen <mikukkon@miku.homelinux.net>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

This patch fixes a bug discovered by Mika Kukkonen in the swap token
code. An unsigned int was being decremented and then checked for < 0.

Signed-off-by: Ashwin Chaugule <ashwin.chaugule@gmail.com>

diff --git a/mm/thrash.c b/mm/thrash.c
index 9ef9071..60f3344 100644
--- a/mm/thrash.c
+++ b/mm/thrash.c
@@ -8,7 +8,7 @@
  * Simple token based thrashing protection, using the algorithm
  * described in:  http://www.cs.wm.edu/~sjiang/token.pdf
  *
- * Sep 2006, Ashwin Chaugule <ashwin.chaugule@celunite.com>
+ * Sep 2006, Ashwin Chaugule <ashwin.chaugule@gmail.com>
  * Improved algorithm to pass token:
  * Each task has a priority which is incremented if it contended
  * for the token in an interval less than its previous attempt.
@@ -48,9 +48,8 @@ void grab_swap_token(void)
                if (current_interval < current->mm->last_interval)
                        current->mm->token_priority++;
                else {
-                       current->mm->token_priority--;
-                       if (unlikely(current->mm->token_priority < 0))
-                               current->mm->token_priority = 0;
+                       if (current->mm->token_priority > 0)
+                               current->mm->token_priority--;
                }
                /* Check if we deserve the token */
                if (current->mm->token_priority >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
