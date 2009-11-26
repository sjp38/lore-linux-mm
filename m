Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2A3026B0083
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 21:50:24 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAQ2oJhb010062
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 26 Nov 2009 11:50:19 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 596D545DE55
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:50:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2753345DE51
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:50:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F247D1DB803F
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:50:18 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D3551DB8043
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:50:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: do not evict inactive pages when skipping an active list scan
In-Reply-To: <20091125133752.2683c3e4@bree.surriel.com>
References: <20091125133752.2683c3e4@bree.surriel.com>
Message-Id: <20091126110340.5A62.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 26 Nov 2009 11:50:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lwoodman@redhat.com, kosaki.motohiro@fujitsu.co.jp, Tomasz Chmielewski <mangoo@wpkg.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> In AIM7 runs, recent kernels start swapping out anonymous pages
> well before they should.  This is due to shrink_list falling
> through to shrink_inactive_list if !inactive_anon_is_low(zone, sc),
> when all we really wanted to do is pre-age some anonymous pages to
> give them extra time to be referenced while on the inactive list.
> 
> The obvious fix is to make sure that shrink_list does not fall
> through to scanning/reclaiming inactive pages when we called it
> to scan one of the active lists.
> 
> This change should be safe because the loop in shrink_zone ensures
> that we will still shrink the anon and file inactive lists whenever
> we should.

Good catch!


> 
> Reported-by: Larry Woodman <lwoodman@redhat.com>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 777af57..ec4dfda 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1469,13 +1469,15 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
>  {
>  	int file = is_file_lru(lru);
>  
> -	if (lru == LRU_ACTIVE_FILE && inactive_file_is_low(zone, sc)) {
> -		shrink_active_list(nr_to_scan, zone, sc, priority, file);
> +	if (lru == LRU_ACTIVE_FILE) {
> +		if (inactive_file_is_low(zone, sc))
> +		      shrink_active_list(nr_to_scan, zone, sc, priority, file);
>  		return 0;
>  	}
>  
> -	if (lru == LRU_ACTIVE_ANON && inactive_anon_is_low(zone, sc)) {
> -		shrink_active_list(nr_to_scan, zone, sc, priority, file);
> +	if (lru == LRU_ACTIVE_ANON) {
> +		if (inactive_file_is_low(zone, sc))

This inactive_file_is_low() should be inactive_anon_is_low().
cut-n-paste programming often makes similar mistake. probaby we need make
more cleanup to this function.

How about this? (this is incremental patch from you)


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a8f61c0..80e94a2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1467,22 +1467,25 @@ static int inactive_file_is_low(struct zone *zone, struct scan_control *sc)
 	return low;
 }
 
+static int inactive_list_is_low(struct zone *zone, struct scan_control *sc, int file)
+{
+	if (file)
+		return inactive_file_is_low(zone, sc);
+	else
+		return inactive_anon_is_low(zone, sc);
+}
+
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	struct zone *zone, struct scan_control *sc, int priority)
 {
 	int file = is_file_lru(lru);
 
-	if (lru == LRU_ACTIVE_FILE) {
-		if (inactive_file_is_low(zone, sc))
+	if (is_active_lru(lru)) {
+		if (inactive_list_is_low(zone, sc, file))
 		      shrink_active_list(nr_to_scan, zone, sc, priority, file);
 		return 0;
 	}
 
-	if (lru == LRU_ACTIVE_ANON) {
-		if (inactive_file_is_low(zone, sc))
-		      shrink_active_list(nr_to_scan, zone, sc, priority, file);
-		return 0;
-	}
 	return shrink_inactive_list(nr_to_scan, zone, sc, priority, file);
 }
 
-- 
1.6.5.2






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
