Date: Tue, 12 Oct 2004 23:19:45 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page cache write performance issue
Message-Id: <20041012231945.2aff9a00.akpm@osdl.org>
In-Reply-To: <20041013054452.GB1618@frodo>
References: <20041013054452.GB1618@frodo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nathan Scott <nathans@sgi.com>
Cc: piggin@cyberone.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

Nathan Scott <nathans@sgi.com> wrote:
>
>  So, any ideas what happened to 2.6.9?

Does reverting the below fix it up?

>   Whats the rationale for commencing writeout earlier in 2.6
> (even when there's
>  so much free memory available)?

There wasn't much rationale behind that patch - that's why I dropped it the
first three times ;)  I have no problem with making it four times.

It could be that small values of unmapped_ratio are making background_ratio
too small.


--- a/mm/page-writeback.c	10 Aug 2004 04:16:17 -0000	1.43
+++ a/mm/page-writeback.c	13 Oct 2004 06:12:03 -0000
@@ -153,9 +153,11 @@
 	if (dirty_ratio < 5)
 		dirty_ratio = 5;
 
-	background_ratio = dirty_background_ratio;
-	if (background_ratio >= dirty_ratio)
-		background_ratio = dirty_ratio / 2;
+	/*
+	 * Keep the ratio between dirty_ratio and background_ratio roughly
+	 * what the sysctls are after dirty_ratio has been scaled (above).
+	 */
+	background_ratio = dirty_background_ratio * dirty_ratio/vm_dirty_ratio;
 
 	background = (background_ratio * total_pages) / 100;
 	dirty = (dirty_ratio * total_pages) / 100;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
