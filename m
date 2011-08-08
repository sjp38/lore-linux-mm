Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF9A6B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 20:06:15 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 745053EE081
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 09:06:11 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EB6545DF42
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 09:06:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 467F545DF47
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 09:06:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A6BE1DB802F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 09:06:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 06F7F1DB8037
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 09:06:11 +0900 (JST)
Date: Tue, 9 Aug 2011 08:58:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] vmscan: activate executable pages after first usage
Message-Id: <20110809085853.16cedb1b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110808110659.31053.92935.stgit@localhost6>
References: <20110808110658.31053.55013.stgit@localhost6>
	<20110808110659.31053.92935.stgit@localhost6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 8 Aug 2011 15:07:00 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Logic added in commit v2.6.30-5507-g8cab475
> (vmscan: make mapped executable pages the first class citizen)
> was noticeably weakened in commit v2.6.33-5448-g6457474
> (vmscan: detect mapped file pages used only once)
> 
> Currently these pages can become "first class citizens" only after second usage.
> 
> After this patch page_check_references() will activate they after first usage,
> and executable code gets yet better chance to stay in memory.
> 
> TODO:
> run some cool tests like in v2.6.30-5507-g8cab475 =)
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

How effective does this work on your test ?



> ---
>  mm/vmscan.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3cd766d..29b3612 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -727,6 +727,12 @@ static enum page_references page_check_references(struct page *page,
>  		if (referenced_page || referenced_ptes > 1)
>  			return PAGEREF_ACTIVATE;
>  
> +		/*
> +		 * Activate file-backed executable pages after first usage.
> +		 */
> +		if (vm_flags & VM_EXEC)
> +			return PAGEREF_ACTIVATE;
> +
>  		return PAGEREF_KEEP;
>  	}
>  
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
