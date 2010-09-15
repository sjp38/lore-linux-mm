Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 398976B0047
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 20:30:25 -0400 (EDT)
Message-ID: <4C90139A.1080809@redhat.com>
Date: Tue, 14 Sep 2010 20:30:18 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Deadlock possibly caused by too_many_isolated.
References: <20100915091118.3dbdc961@notabene>
In-Reply-To: <20100915091118.3dbdc961@notabene>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 09/14/2010 07:11 PM, Neil Brown wrote:

> Index: linux-2.6.32-SLE11-SP1/mm/vmscan.c
> ===================================================================
> --- linux-2.6.32-SLE11-SP1.orig/mm/vmscan.c	2010-09-15 08:37:32.000000000 +1000
> +++ linux-2.6.32-SLE11-SP1/mm/vmscan.c	2010-09-15 08:38:57.000000000 +1000
> @@ -1106,6 +1106,11 @@ static unsigned long shrink_inactive_lis
>   		/* We are about to die and free our memory. Return now. */
>   		if (fatal_signal_pending(current))
>   			return SWAP_CLUSTER_MAX;
> +		if (!(sc->gfp_mask&  __GFP_IO))
> +			/* Not allowed to do IO, so mustn't wait
> +			 * on processes that might try to
> +			 */
> +			return SWAP_CLUSTER_MAX;
>   	}
>
>   	/*

Close.  We must also be sure that processes without __GFP_FS
set in their gfp_mask do not wait on processes that do have
__GFP_FS set.

Considering how many times we've run into a bug like this,
I'm kicking myself for not having thought of it :(

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
