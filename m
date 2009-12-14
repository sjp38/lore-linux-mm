Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E34DC6B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 09:33:53 -0500 (EST)
Message-ID: <4B264CCA.5010609@redhat.com>
Date: Mon, 14 Dec 2009 09:33:46 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/8] Use prepare_to_wait_exclusive() instead prepare_to_wait()
References: <20091211164651.036f5340@annuminas.surriel.com> <20091214210823.BBAE.A69D9226@jp.fujitsu.com> <20091214212936.BBBA.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091214212936.BBBA.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On 12/14/2009 07:30 AM, KOSAKI Motohiro wrote:
> if we don't use exclusive queue, wake_up() function wake _all_ waited
> task. This is simply cpu wasting.
>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

>   		if (zone_watermark_ok(zone, sc->order, low_wmark_pages(zone),
>   					0, 0)) {
> -			wake_up(wq);
> +			wake_up_all(wq);
>   			finish_wait(wq,&wait);
>   			sc->nr_reclaimed += sc->nr_to_reclaim;
>   			return -ERESTARTSYS;

I believe we want to wake the processes up one at a time
here.  If the queue of waiting processes is very large
and the amount of excess free memory is fairly low, the
first processes that wake up can take the amount of free
memory back down below the threshold.  The rest of the
waiters should stay asleep when this happens.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
