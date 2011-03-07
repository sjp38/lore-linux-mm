Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2578D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 03:34:22 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 535413EE0C1
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:34:15 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 352DE45DE50
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:34:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C67445DE4F
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:34:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EAF91DB803E
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:34:15 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CFD2D1DB802F
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:34:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/8] Add __GFP_OTHER_NODE flag
In-Reply-To: <1299182391-6061-7-git-send-email-andi@firstfloor.org>
References: <1299182391-6061-1-git-send-email-andi@firstfloor.org> <1299182391-6061-7-git-send-email-andi@firstfloor.org>
Message-Id: <20110307173042.8A04.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  7 Mar 2011 17:34:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, aarcange@redhat.com

> From: Andi Kleen <ak@linux.intel.com>
> 
> Add a new __GFP_OTHER_NODE flag to tell the low level numa statistics
> in zone_statistics() that an allocation is on behalf of another thread.
> This way the local and remote counters can be still correct, even
> when background daemons like khugepaged are changing memory
> mappings.
> 
> This only affects the accounting, but I think it's worth doing that
> right to avoid confusing users.
> 
> I first tried to just pass down the right node, but this required
> a lot of changes to pass down this parameter and at least one
> addition of a 10th argument to a 9 argument function. Using
> the flag is a lot less intrusive.

Yes, less intrusive. But are you using current NUMA stastics on
practical system?
I didn't numa stat recent 5 years at all. So, I'm curious your usecase.
IOW, I haven't convinced this is worthful to consume new GFP_ flags bit.

_now_, I can say I don't found any bug in this patch.

> 
> Open: should be also used for migration?
> 
> Cc: aarcange@redhat.com
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/gfp.h    |    2 ++
>  include/linux/vmstat.h |    4 ++--
>  mm/page_alloc.c        |    2 +-
>  mm/vmstat.c            |    9 +++++++--
>  4 files changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 814d50e..a064724 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -35,6 +35,7 @@ struct vm_area_struct;
>  #define ___GFP_NOTRACK		0
>  #endif
>  #define ___GFP_NO_KSWAPD	0x400000u
> +#define ___GFP_OTHER_NODE	0x800000u



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
