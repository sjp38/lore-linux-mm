Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 185E56B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 19:58:51 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 61F033EE0BD
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:58:49 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 40D8E45DEB2
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:58:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2743645DEAD
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:58:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 187F11DB803B
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:58:49 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D55791DB8037
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:58:48 +0900 (JST)
Date: Tue, 9 Aug 2011 08:51:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] vmscan: promote shared file mapped pages
Message-Id: <20110809085130.f3b5b2c7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110808110658.31053.55013.stgit@localhost6>
References: <20110808110658.31053.55013.stgit@localhost6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 8 Aug 2011 15:06:58 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Commit v2.6.33-5448-g6457474 (vmscan: detect mapped file pages used only once)
> greatly decreases lifetime of single-used mapped file pages.
> Unfortunately it also decreases life time of all shared mapped file pages.
> Because after commit v2.6.28-6130-gbf3f3bc (mm: don't mark_page_accessed in fault path)
> page-fault handler does not mark page active or even referenced.
> 
> Thus page_check_references() activates file page only if it was used twice while
> it stays in inactive list, meanwhile it activates anon pages after first access.
> Inactive list can be small enough, this way reclaimer can accidentally
> throw away any widely used page if it wasn't used twice in short period.
> 
> After this patch page_check_references() also activate file mapped page at first
> inactive list scan if this page is already used multiple times via several ptes.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

As other guys pointed out, it's better to show performance score change by
this patch in changelog.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/vmscan.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 47403c9..3cd766d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -724,7 +724,7 @@ static enum page_references page_check_references(struct page *page,
>  		 */
>  		SetPageReferenced(page);
>  
> -		if (referenced_page)
> +		if (referenced_page || referenced_ptes > 1)
>  			return PAGEREF_ACTIVATE;
>  
>  		return PAGEREF_KEEP;
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
