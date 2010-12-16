Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0167B6B009F
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 19:03:14 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBH03B5E012454
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 17 Dec 2010 09:03:11 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5670045DE70
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:03:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3905045DE6B
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:03:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 28C1B1DB803E
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:03:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E71EB1DB803B
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:03:10 +0900 (JST)
Date: Fri, 17 Dec 2010 08:57:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memory hotplug: fix alignment check (Was Re: PROBLEM:
 __offline_isolated_pages may offline too many pages
Message-Id: <20101217085714.5525793b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101216102641.GK13914@csn.ul.ie>
References: <4D0786D3.7070007@akana.de>
	<20101215092134.e2c8849f.kamezawa.hiroyu@jp.fujitsu.com>
	<4D08899F.4050502@akana.de>
	<20101216090657.9d3aaa4c.kamezawa.hiroyu@jp.fujitsu.com>
	<20101216102641.GK13914@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Ingo Korb <ingo@akana.de>, linux-mm@kvack.org, akpm@linux-foundation.org, cl@linux-foundation.org, yinghai@kernel.org, andi.kleen@intel.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Dec 2010 10:26:41 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> Other than the spelling mistakes in the changelog and the lack of a
> subject;
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> 
Thank you. fixed one.
==

offline_pages()'s sanity check of given range is wrong. It should
be aligned to MAX_ORDER. Current existing caller uses SECTION_SIZE
alignment, so this change has no influence to existing callers.

Reported-by: Ingo Korb <ingo@akana.de>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memory_hotplug.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

Index: linux-2.6.37-rc5/mm/memory_hotplug.c
===================================================================
--- linux-2.6.37-rc5.orig/mm/memory_hotplug.c
+++ linux-2.6.37-rc5/mm/memory_hotplug.c
@@ -798,10 +798,14 @@ static int offline_pages(unsigned long s
 	struct memory_notify arg;
 
 	BUG_ON(start_pfn >= end_pfn);
-	/* at least, alignment against pageblock is necessary */
-	if (!IS_ALIGNED(start_pfn, pageblock_nr_pages))
+	/*
+	 * Considering Buddy system which joins nearby pages, the range
+	 * in offline should be aligned to MAX_ORDER. If not, isolated
+	 * page will be joined to other (not isolated) pages.
+	 */
+	if (!IS_ALIGNED(start_pfn, MAX_ORDER_NR_PAGES))
 		return -EINVAL;
-	if (!IS_ALIGNED(end_pfn, pageblock_nr_pages))
+	if (!IS_ALIGNED(end_pfn, MAX_ORDER_NR_PAGES))
 		return -EINVAL;
 	/* This makes hotplug much easier...and readable.
 	   we assume this for now. .*/
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
