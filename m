Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 95A536B004D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 00:50:42 -0400 (EDT)
Received: by yxe10 with SMTP id 10so1441530yxe.12
        for <linux-mm@kvack.org>; Thu, 15 Oct 2009 21:50:41 -0700 (PDT)
Message-ID: <4AD7FB57.2030403@vflare.org>
Date: Fri, 16 Oct 2009 10:19:27 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 7/9] swap_info: swap count continuations
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils> <Pine.LNX.4.64.0910150153560.3291@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0910150153560.3291@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, hongshin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10/15/2009 06:26 AM, Hugh Dickins wrote:
> Swap is duplicated (reference count incremented by one) whenever the same
> swap page is inserted into another mm (when forking finds a swap entry in
> place of a pte, or when reclaim unmaps a pte to insert the swap entry).
> 
> swap_info_struct's vmalloc'ed swap_map is the array of these reference
> counts: but what happens when the unsigned short (or unsigned char since
> the preceding patch) is full? (and its high bit is kept for a cache flag)
> 
> We then lose track of it, never freeing, leaving it in use until swapoff:
> at which point we _hope_ that a single pass will have found all instances,
> assume there are no more, and will lose user data if we're wrong.
> 
> Swapping of KSM pages has not yet been enabled; but it is implemented,
> and makes it very easy for a user to overflow the maximum swap count:
> possible with ordinary process pages, but unlikely, even when pid_max
> has been raised from PID_MAX_DEFAULT.
> 
> This patch implements swap count continuations: when the count overflows,
> a continuation page is allocated and linked to the original vmalloc'ed
> map page, and this used to hold the continuation counts for that entry
> and its neighbours.  These continuation pages are seldom referenced:
> the common paths all work on the original swap_map, only referring to
> a continuation page when the low "digit" of a count is incremented or
> decremented through SWAP_MAP_MAX.
> 


I think the patch can be simplified a lot if we have just 2 levels (hard-coded)
of swap_map, each level having 16-bit count -- combined 32-bit count should be
sufficient for about anything. Saving 1-byte for level-1 swap_map and then having
arbitrary levels of swap_map doesn't look like its worth the complexity.

Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
