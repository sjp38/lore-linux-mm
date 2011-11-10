Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8C2EA6B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 18:43:03 -0500 (EST)
Date: Thu, 10 Nov 2011 15:42:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: add free_hot_cold_page_list helper
Message-Id: <20111110154259.261f1534.akpm@linux-foundation.org>
In-Reply-To: <20111101074502.32668.93131.stgit@zurg>
References: <20110729075837.12274.58405.stgit@localhost6>
	<20111101074502.32668.93131.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com

On Tue, 01 Nov 2011 11:45:02 +0300
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> This patch adds helper free_hot_cold_page_list() to free list of 0-order pages.
> It frees pages directly from the list without temporary page-vector.
> It also calls trace_mm_pagevec_free() to simulate pagevec_free() behaviour.
> 
> bloat-o-meter:
> 
> add/remove: 1/1 grow/shrink: 1/3 up/down: 267/-295 (-28)
> function                                     old     new   delta
> free_hot_cold_page_list                        -     264    +264
> get_page_from_freelist                      2129    2132      +3
> __pagevec_free                               243     239      -4
> split_free_page                              380     373      -7
> release_pages                                606     510     -96
> free_page_list                               188       -    -188

Here's what you changed:

--- a/mm/page_alloc.c~mm-add-free_hot_cold_page_list-helper-v2
+++ a/mm/page_alloc.c
@@ -1210,6 +1210,9 @@ out:
 	local_irq_restore(flags);
 }
 
+/*
+ * Free a list of 0-order pages
+ */
 void free_hot_cold_page_list(struct list_head *list, int cold)
 {
 	struct page *page, *next;
@@ -1218,8 +1221,6 @@ void free_hot_cold_page_list(struct list
 		trace_mm_pagevec_free(page, cold);
 		free_hot_cold_page(page, cold);
 	}
-
-	INIT_LIST_HEAD(list);
 }
 
 /*
_

However I can't find any sign that you addressed Minchin's original
review comment regarding free_hot_cold_page_list():

: I understand you want to minimize changes without breaking current ABI
: with trace tools.
: But apparently, It's not a pagvec_free. It just hurts readability.
: As I take a look at the code, mm_pagevec_free isn't related to pagevec
: but I guess it can represent 0-order pages free because 0-order pages
: are freed only by pagevec until now.
: So, how about renaming it with mm_page_free or mm_page_free_zero_order?
: If you do, you need to do s/MM_PAGEVEC_FREE/MM_FREE_FREE/g in
: trace-pagealloc-postprocess.pl.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
